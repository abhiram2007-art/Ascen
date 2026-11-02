import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../services/level_service.dart';
import '../services/xp_service.dart';
import '../services/streak_service.dart';
import '../services/guild_service.dart';
import '../config/constants.dart';
import 'dart:async';

class PlayerProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  bool _showLevelUpAnimation = false;
  bool _showRankUpAnimation = false;
  int? _newLevel;
  RankInfo? _newRank;
  StreamSubscription? _userSubscription;
  
  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get showLevelUpAnimation => _showLevelUpAnimation;
  bool get showRankUpAnimation => _showRankUpAnimation;
  int? get newLevel => _newLevel;
  RankInfo? get newRank => _newRank;
  
  // Computed properties
  int get currentLevel => _user != null ? LevelService.getCurrentLevel(_user!.totalXP) : 1;
  double get levelProgress => _user != null ? LevelService.getLevelProgress(_user!.totalXP) : 0.0;
  int get xpToNextLevel => _user != null ? LevelService.getXPForNextLevel(_user!.totalXP) : 100;
  int get currentLevelXP => _user != null ? LevelService.getCurrentLevelXP(_user!.totalXP) : 0;
  RankInfo get currentRank => LevelService.getRank(currentLevel);
  String get currentTitle => LevelService.getTitle(currentLevel);
  
  /// Load user profile from Firestore
  Future<void> loadUser(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists && doc.data() != null) {
        _user = UserModel.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  /// Listen to user profile changes in real-time
  void listenToUser(String userId) {
    _userSubscription?.cancel();
    _userSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        _user = UserModel.fromMap(snapshot.data()!, snapshot.id);
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint('Error listening to user: $e');
    });
  }
  
  /// Add XP to user (handles level up, rank up, stats, guild XP, etc.)
  /// Returns total XP earned (including bonuses)
  Future<int> addXP({
    required String userId,
    required QuestDifficulty difficulty,
    required String statType,
  }) async {
    if (_user == null) return 0;
    
    final int oldLevel = currentLevel;
    final RankInfo oldRank = currentRank;

    // 1. Calculate base XP
    int baseXP = XPService.calculateQuestXP(difficulty);
    
    // 2. Calculate streak bonus
    int streakBonus = XPService.calculateStreakBonus(_user!.streak);
    int totalXPEarned = baseXP + streakBonus;
    
    // 3. Update totalXP
    int newTotalXP = _user!.totalXP + totalXPEarned;
    
    // 4. Check level up
    int updatedLevel = LevelService.getCurrentLevel(newTotalXP);
    if (updatedLevel > oldLevel) {
      _showLevelUpAnimation = true;
      _newLevel = updatedLevel;
    }
    
    // 5. Check rank promotion
    RankInfo updatedRank = LevelService.getRank(updatedLevel);
    if (updatedRank.name != oldRank.name) {
      _showRankUpAnimation = true;
      _newRank = updatedRank;
    }

    String updatedTitle = LevelService.getTitle(updatedLevel);
    
    // 6. Update stat
    Map<String, int> updatedStats = Map.from(_user!.stats);
    updatedStats[statType] = (updatedStats[statType] ?? 0) + totalXPEarned;
    
    // Update local user object optimistically
    _user = _user!.copyWith(
      totalXP: newTotalXP,
      level: updatedLevel,
      rank: updatedRank.name,
      title: updatedTitle,
      stats: updatedStats,
    );

    // 7. Update Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'totalXP': newTotalXP,
        'level': updatedLevel,
        'rank': updatedRank.name,
        'title': updatedTitle,
        'stats': updatedStats,
      });

      // 8. Add XP to Guild if user is in one
      if (_user!.guildId != null) {
        await GuildService().addGuildXP(_user!.guildId!, totalXPEarned);
      }
    } catch (e) {
      debugPrint('Error adding XP to Firestore/Guild: $e');
    }

    // 9. notifyListeners()
    notifyListeners();
    
    return totalXPEarned;
  }
  
  /// Update streak when a quest is completed
  Future<void> updateStreak(String userId) async {
    if (_user == null) return;
    
    try {
      int newStreak = StreakService.calculateNewStreak(_user!.streak, _user!.lastActiveDate);
      int newBestStreak = _user!.bestStreak;
      if (newStreak > newBestStreak) {
        newBestStreak = newStreak;
      }
      DateTime now = DateTime.now();
      
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'streak': newStreak,
        'bestStreak': newBestStreak,
        'lastActiveDate': Timestamp.fromDate(now),
      });
      
      _user = _user!.copyWith(
        streak: newStreak,
        bestStreak: newBestStreak,
        lastActiveDate: now,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating streak: $e');
    }
  }

  /// Check if streak expired due to missing a day (called on app open)
  Future<void> checkStreakExpiry(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (!doc.exists || doc.data() == null) return;

      final data = doc.data()!;
      final currentStreak = data['streak']?.toInt() ?? 0;
      final dynamic rawLastActive = data['lastActiveDate'];
      
      DateTime? lastActive;
      if (rawLastActive is Timestamp) {
        lastActive = rawLastActive.toDate();
      } else if (rawLastActive is String) {
        lastActive = DateTime.tryParse(rawLastActive);
      }

      if (lastActive != null && currentStreak > 0) {
        final now = DateTime.now();
        final yesterday = DateTime(now.year, now.month, now.day - 1);
        final lastDay = DateTime(lastActive.year, lastActive.month, lastActive.day);

        // If last completion was before yesterday, streak broke
        if (lastDay.isBefore(yesterday)) {
          await FirebaseFirestore.instance.collection('users').doc(userId).update({
            'streak': 0,
          });
          if (_user != null) {
            _user = _user!.copyWith(streak: 0);
            notifyListeners();
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking streak expiry: $e');
    }
  }
  
  /// Increment shadow army count
  Future<void> incrementShadowArmy(String userId) async {
    if (_user == null) return;
    
    try {
      int newCount = _user!.shadowArmy + 1;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'shadowArmy': newCount,
      });
      _user = _user!.copyWith(shadowArmy: newCount);
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing shadow army: $e');
    }
  }
  
  /// Clear level up animation flag
  void clearLevelUpAnimation() {
    _showLevelUpAnimation = false;
    _newLevel = null;
    notifyListeners();
  }
  
  /// Clear rank up animation flag  
  void clearRankUpAnimation() {
    _showRankUpAnimation = false;
    _newRank = null;
    notifyListeners();
  }
  
  /// Update user preferences (from onboarding)
  Future<void> updatePreferences(String userId, Map<String, dynamic> prefs) async {
    try {
      final Map<String, dynamic> updateData = {
        'preferences': prefs,
      };
      if (prefs.containsKey('name') && (prefs['name'] as String).isNotEmpty) {
        updateData['name'] = prefs['name'];
      }
      await FirebaseFirestore.instance.collection('users').doc(userId).update(updateData);
      if (prefs.containsKey('name') && _user != null) {
        _user = _user!.copyWith(
          name: prefs['name'],
          preferences: prefs,
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating preferences: $e');
    }
  }
  
  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}

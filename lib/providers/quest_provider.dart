import 'package:flutter/material.dart';
import '../models/quest_model.dart';
import '../services/quest_service.dart';
import '../config/constants.dart';
import 'dart:async';

class QuestProvider extends ChangeNotifier {
  final QuestService _questService = QuestService();
  
  List<QuestModel> _allQuests = [];
  List<QuestModel> _dailyQuests = [];
  bool _isLoading = false;
  StreamSubscription? _questSubscription;
  StreamSubscription? _dailyQuestSubscription;
  
  // Getters
  List<QuestModel> get allQuests => _allQuests;
  List<QuestModel> get dailyQuests => _dailyQuests;
  List<QuestModel> get mainQuests => _allQuests.where((q) => q.type == QuestType.main).toList();
  List<QuestModel> get sideQuests => _allQuests.where((q) => q.type == QuestType.side).toList();
  List<QuestModel> get habitQuests => _allQuests.where((q) => q.type == QuestType.habit).toList();
  List<QuestModel> get challengeQuests => _allQuests.where((q) => q.type == QuestType.challenge).toList();
  List<QuestModel> get completedQuests => _allQuests.where((q) => q.status == QuestStatus.completed).toList();
  List<QuestModel> get pendingQuests => _allQuests.where((q) => q.status == QuestStatus.pending).toList();
  bool get isLoading => _isLoading;
  int get completedToday => _dailyQuests.where((q) => q.status == QuestStatus.completed).length;
  int get totalToday => _dailyQuests.length;
  
  /// Reset daily quests and then start listening
  Future<void> initAndListen(String userId) async {
    // 1. Reset yesterday's recurring daily quests first
    await resetDailyQuests(userId);
    // 2. Then start real-time listeners
    listenToQuests(userId);
  }
  
  /// Reset recurring daily quests that were completed before today
  Future<void> resetDailyQuests(String userId) async {
    try {
      final count = await _questService.resetDailyQuests(userId);
      if (count > 0) {
        debugPrint('Reset $count daily quests for new day');
      }
    } catch (e) {
      debugPrint('Error resetting daily quests: $e');
    }
  }
  
  /// Start listening to user's quests
  void listenToQuests(String userId) {
    _isLoading = true;
    notifyListeners();
    
    _questSubscription?.cancel();
    _questSubscription = _questService.getQuests(userId).listen((quests) {
      _allQuests = quests;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to quests: $error');
      _isLoading = false;
      notifyListeners();
    });

    _dailyQuestSubscription?.cancel();
    _dailyQuestSubscription = _questService.getTodayDailyQuests(userId).listen((quests) {
      _dailyQuests = quests;
      notifyListeners();
    }, onError: (error) {
      debugPrint('Error listening to daily quests: $error');
    });
  }
  
  /// Create a new quest
  Future<void> createQuest(String userId, QuestModel quest) async {
    try {
      await _questService.createQuest(userId, quest).timeout(const Duration(seconds: 10));
    } catch (e) {
      debugPrint('Error creating quest: $e');
      rethrow;
    }
  }
  
  /// Complete a quest
  Future<void> completeQuest(String userId, String questId, {int? timeSpentMins, String? notes}) async {
    try {
      await _questService.completeQuest(userId, questId, timeSpentMins: timeSpentMins, notes: notes);
    } catch (e) {
      debugPrint('Error completing quest: $e');
      rethrow;
    }
  }
  
  /// Update a quest
  Future<void> updateQuest(String userId, QuestModel quest) async {
    try {
      await _questService.updateQuest(userId, quest);
    } catch (e) {
      debugPrint('Error updating quest: $e');
      rethrow;
    }
  }
  
  /// Delete a quest
  Future<void> deleteQuest(String userId, String questId) async {
    try {
      await _questService.deleteQuest(userId, questId);
    } catch (e) {
      debugPrint('Error deleting quest: $e');
      rethrow;
    }
  }
  
  /// Get quests filtered by type
  List<QuestModel> getQuestsByType(QuestType type) {
    return _allQuests.where((q) => q.type == type).toList();
  }
  
  @override
  void dispose() {
    _questSubscription?.cancel();
    _dailyQuestSubscription?.cancel();
    super.dispose();
  }
}

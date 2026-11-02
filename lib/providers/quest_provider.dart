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

  // Daily Progress Metrics
  int get totalToday => _dailyQuests.length;
  int get completedToday => _dailyQuests.where((q) => q.status == QuestStatus.completed).length;
  int get remainingToday => (totalToday - completedToday).clamp(0, 9999);
  double get todayCompletionRate => totalToday > 0 ? (completedToday / totalToday) : 0.0;
  int get todayCompletionPercent => (todayCompletionRate * 100).round();

  // Overall Metrics
  int get totalAllTime => _allQuests.length;
  int get completedAllTime => completedQuests.length;
  double get overallCompletionRate => totalAllTime > 0 ? (completedAllTime / totalAllTime) : 0.0;
  int get overallCompletionPercent => (overallCompletionRate * 100).round();

  // Missed Habits
  List<QuestModel> get missedQuests {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    return _allQuests.where((q) {
      if (q.status == QuestStatus.completed) return false;
      if (q.dueDate != null && q.dueDate!.isBefore(todayStart)) return true;
      return false;
    }).toList();
  }

  // Weekly Activity (Completions for Monday - Sunday this week)
  Map<int, int> getWeeklyCompletions() {
    final now = DateTime.now();
    final monday = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final Map<int, int> weekdayCounts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    
    for (final q in completedQuests) {
      if (q.completedAt != null) {
        final compDate = DateTime(q.completedAt!.year, q.completedAt!.month, q.completedAt!.day);
        if (!compDate.isBefore(monday) && compDate.difference(monday).inDays < 7) {
          int weekday = compDate.weekday;
          weekdayCounts[weekday] = (weekdayCounts[weekday] ?? 0) + 1;
        }
      }
    }
    return weekdayCounts;
  }

  // Monthly Activity (Completions in current month)
  int getMonthlyCompletions() {
    final now = DateTime.now();
    return completedQuests.where((q) {
      if (q.completedAt == null) return false;
      return q.completedAt!.year == now.year && q.completedAt!.month == now.month;
    }).length;
  }

  // Active Days this Month
  int getMonthlyActiveDays() {
    final now = DateTime.now();
    final Set<int> days = {};
    for (final q in completedQuests) {
      if (q.completedAt != null && q.completedAt!.year == now.year && q.completedAt!.month == now.month) {
        days.add(q.completedAt!.day);
      }
    }
    return days.length;
  }

  // Habit-wise completion breakdown
  Map<String, int> getHabitCompletionCounts() {
    final Map<String, int> counts = {};
    for (final q in completedQuests) {
      counts[q.title] = (counts[q.title] ?? 0) + 1;
    }
    return counts;
  }

  // Best Performing Habits (sorted highest to lowest)
  List<MapEntry<String, int>> get bestPerformingHabits {
    final counts = getHabitCompletionCounts().entries.toList();
    counts.sort((a, b) => b.value.compareTo(a.value));
    return counts;
  }

  // Habits Needing Improvement (active habits with fewest completions)
  List<QuestModel> get habitsNeedingImprovement {
    return _allQuests.where((q) => q.status != QuestStatus.completed).toList();
  }

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

  /// Uncomplete a quest
  Future<void> uncompleteQuest(String userId, String questId) async {
    try {
      await _questService.uncompleteQuest(userId, questId);
    } catch (e) {
      debugPrint('Error uncompleting quest: $e');
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

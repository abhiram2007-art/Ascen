import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quest_model.dart';
import '../config/constants.dart';

class QuestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Collection reference helper
  CollectionReference _questsRef(String userId) => 
    _firestore.collection('users').doc(userId).collection('quests');
  
  /// Create a new quest
  Future<String> createQuest(String userId, QuestModel quest) async {
    final docRef = await _questsRef(userId).add(quest.toMap());
    return docRef.id;
  }
  
  /// Get all quests for user
  Stream<List<QuestModel>> getQuests(String userId) {
    return _questsRef(userId).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return QuestModel.fromMap(data, doc.id);
      }).toList();
    });
  }
  
  /// Get quests by type (daily, main, etc.)
  Stream<List<QuestModel>> getQuestsByType(String userId, QuestType type) {
    return _questsRef(userId)
        .where('type', isEqualTo: type.name)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return QuestModel.fromMap(data, doc.id);
      }).toList();
    });
  }
  
  /// Get today's daily quests - only shows quests created today or recurring quests
  Stream<List<QuestModel>> getTodayDailyQuests(String userId) {
    return _questsRef(userId)
        .where('type', isEqualTo: QuestType.daily.name)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return QuestModel.fromMap(data, doc.id);
      }).where((quest) {
        // If it's recurring, always show it
        if (quest.isRecurring) return true;
        
        // If it's NOT recurring, only show it if it was created today
        final createdDate = DateTime(quest.createdAt.year, quest.createdAt.month, quest.createdAt.day);
        return createdDate.isAtSameMomentAs(todayStart);
      }).toList();
    });
  }
  
  /// DAILY RESET: Reset all recurring daily quests that were completed on a previous day
  Future<int> resetDailyQuests(String userId) async {
    int resetCount = 0;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    try {
      // Get all daily quests that are completed AND recurring
      final snapshot = await _questsRef(userId)
          .where('type', isEqualTo: QuestType.daily.name)
          .where('status', isEqualTo: QuestStatus.completed.name)
          .where('isRecurring', isEqualTo: true)
          .get();
      
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final completedAt = data['completedAt'];
        
        if (completedAt != null) {
          DateTime completedDate;
          if (completedAt is Timestamp) {
            completedDate = completedAt.toDate();
          } else {
            continue;
          }
          
          // If completed BEFORE today, we reset it BUT keep a history clone
          if (completedDate.isBefore(todayStart)) {
            // 1. Create a clone for history (not recurring)
            final historyDocRef = _questsRef(userId).doc();
            final historyData = Map<String, dynamic>.from(data);
            historyData['isRecurring'] = false; // So it doesn't show in today's list
            // Keep completedAt, timeSpent, notes intact for the history clone
            batch.set(historyDocRef, historyData);

            // 2. Reset the original recurring quest for today
            batch.update(doc.reference, {
              'status': QuestStatus.pending.name,
              'completedAt': null,
              'timeSpentMins': null,
              'completionNotes': null,
            });
            resetCount++;
          }
        }
      }
      
      if (resetCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      // Silently handle - quests just won't reset
    }
    
    return resetCount;
  }
  
  /// Update quest
  Future<void> updateQuest(String userId, QuestModel quest) async {
    if (quest.id.isEmpty) return;
    await _questsRef(userId).doc(quest.id).update(quest.toMap());
  }
  
  /// Complete a quest (set status to completed, set completedAt, timeSpent, notes)
  Future<void> completeQuest(String userId, String questId, {int? timeSpentMins, String? notes}) async {
    final Map<String, dynamic> updateData = {
      'status': QuestStatus.completed.name,
      'completedAt': FieldValue.serverTimestamp(),
    };
    if (timeSpentMins != null) {
      updateData['timeSpentMins'] = timeSpentMins;
    }
    if (notes != null) {
      updateData['completionNotes'] = notes;
    }
    await _questsRef(userId).doc(questId).update(updateData);
  }
  
  /// Delete quest
  Future<void> deleteQuest(String userId, String questId) async {
    await _questsRef(userId).doc(questId).delete();
  }
  
  /// Get completed quests count
  Future<int> getCompletedQuestsCount(String userId) async {
    try {
      final snapshot = await _questsRef(userId)
          .where('status', isEqualTo: QuestStatus.completed.name)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}

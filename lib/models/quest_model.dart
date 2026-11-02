import 'package:cloud_firestore/cloud_firestore.dart';
import '../config/constants.dart';

enum QuestStatus { pending, active, completed, failed }

class QuestModel {
  final String id;
  final String title;
  final String description;
  final QuestType type;
  final String category;
  final String statType;
  final int xpReward;
  final QuestDifficulty difficulty;
  final QuestStatus status;
  final DateTime? dueDate;
  final DateTime? completedAt;
  final String? goalId;
  final bool isRecurring;
  final DateTime createdAt;
  final int? timeSpentMins;
  final String? completionNotes;
  final String? reminderTime;

  const QuestModel({
    required this.id,
    required this.title,
    this.description = '',
    this.type = QuestType.daily,
    this.category = 'General',
    this.statType = 'intelligence',
    this.xpReward = 25,
    this.difficulty = QuestDifficulty.easy,
    this.status = QuestStatus.pending,
    this.dueDate,
    this.completedAt,
    this.goalId,
    this.isRecurring = false,
    required this.createdAt,
    this.timeSpentMins,
    this.completionNotes,
    this.reminderTime,
  });

  factory QuestModel.fromMap(Map<String, dynamic> map, String id) {
    return QuestModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: QuestType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => QuestType.daily,
      ),
      category: map['category'] ?? 'General',
      statType: map['statType'] ?? 'intelligence',
      xpReward: map['xpReward'] ?? 25,
      difficulty: QuestDifficulty.values.firstWhere(
        (e) => e.name == map['difficulty'],
        orElse: () => QuestDifficulty.easy,
      ),
      status: QuestStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => QuestStatus.pending,
      ),
      dueDate: _parseDateTime(map['dueDate']),
      completedAt: _parseDateTime(map['completedAt']),
      goalId: map['goalId'],
      isRecurring: map['isRecurring'] ?? false,
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      timeSpentMins: map['timeSpentMins']?.toInt(),
      completionNotes: map['completionNotes'],
      reminderTime: map['reminderTime'],
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.name,
      'category': category,
      'statType': statType,
      'xpReward': xpReward,
      'difficulty': difficulty.name,
      'status': status.name,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'goalId': goalId,
      'isRecurring': isRecurring,
      'createdAt': Timestamp.fromDate(createdAt),
      'timeSpentMins': timeSpentMins,
      'completionNotes': completionNotes,
      if (reminderTime != null) 'reminderTime': reminderTime,
    };
  }

  QuestModel copyWith({
    String? id,
    String? title,
    String? description,
    QuestType? type,
    String? category,
    String? statType,
    int? xpReward,
    QuestDifficulty? difficulty,
    QuestStatus? status,
    DateTime? dueDate,
    DateTime? completedAt,
    bool clearCompletedAt = false,
    String? goalId,
    bool? isRecurring,
    DateTime? createdAt,
    int? timeSpentMins,
    String? completionNotes,
    String? reminderTime,
  }) {
    return QuestModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      category: category ?? this.category,
      statType: statType ?? this.statType,
      xpReward: xpReward ?? this.xpReward,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      goalId: goalId ?? this.goalId,
      isRecurring: isRecurring ?? this.isRecurring,
      createdAt: createdAt ?? this.createdAt,
      timeSpentMins: timeSpentMins ?? this.timeSpentMins,
      completionNotes: completionNotes ?? this.completionNotes,
      reminderTime: reminderTime ?? this.reminderTime,
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

enum SessionStatus { active, paused, completed }

class SessionModel {
  final String id;
  final String questId;
  final String questTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int duration;
  final int xpEarned;
  final SessionStatus status;
  final String? notes;

  const SessionModel({
    required this.id,
    required this.questId,
    required this.questTitle,
    required this.startTime,
    this.endTime,
    this.duration = 0,
    this.xpEarned = 0,
    this.status = SessionStatus.active,
    this.notes,
  });

  factory SessionModel.fromMap(Map<String, dynamic> map, String id) {
    return SessionModel(
      id: id,
      questId: map['questId'] ?? '',
      questTitle: map['questTitle'] ?? '',
      startTime: (map['startTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endTime: map['endTime'] != null ? (map['endTime'] as Timestamp).toDate() : null,
      duration: map['duration']?.toInt() ?? 0,
      xpEarned: map['xpEarned']?.toInt() ?? 0,
      status: SessionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SessionStatus.active,
      ),
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questId': questId,
      'questTitle': questTitle,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'xpEarned': xpEarned,
      'status': status.name,
      'notes': notes,
    };
  }

  SessionModel copyWith({
    String? id,
    String? questId,
    String? questTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? duration,
    int? xpEarned,
    SessionStatus? status,
    String? notes,
  }) {
    return SessionModel(
      id: id ?? this.id,
      questId: questId ?? this.questId,
      questTitle: questTitle ?? this.questTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      xpEarned: xpEarned ?? this.xpEarned,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

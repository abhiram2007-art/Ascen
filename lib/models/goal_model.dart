import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalStatus { active, completed, abandoned }

class Milestone {
  final String name;
  final bool completed;

  const Milestone({
    required this.name,
    this.completed = false,
  });

  factory Milestone.fromMap(Map<String, dynamic> map) {
    return Milestone(
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed': completed,
    };
  }

  Milestone copyWith({
    String? name,
    bool? completed,
  }) {
    return Milestone(
      name: name ?? this.name,
      completed: completed ?? this.completed,
    );
  }
}

class GoalModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final DateTime? targetDate;
  final double progress;
  final List<Milestone> milestones;
  final GoalStatus status;
  final DateTime createdAt;

  const GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.targetDate,
    this.progress = 0.0,
    required this.milestones,
    this.status = GoalStatus.active,
    required this.createdAt,
  });

  factory GoalModel.fromMap(Map<String, dynamic> map, String id) {
    return GoalModel(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      targetDate: _parseDateTime(map['targetDate']),
      progress: (map['progress'] ?? 0.0).toDouble(),
      milestones: (map['milestones'] as List<dynamic>?)
              ?.map((e) => Milestone.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          [],
      status: GoalStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => GoalStatus.active,
      ),
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
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
      'category': category,
      'targetDate': targetDate != null ? Timestamp.fromDate(targetDate!) : null,
      'progress': progress,
      'milestones': milestones.map((e) => e.toMap()).toList(),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  GoalModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    DateTime? targetDate,
    double? progress,
    List<Milestone>? milestones,
    GoalStatus? status,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      targetDate: targetDate ?? this.targetDate,
      progress: progress ?? this.progress,
      milestones: milestones ?? this.milestones,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

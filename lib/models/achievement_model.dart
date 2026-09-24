import 'package:cloud_firestore/cloud_firestore.dart';

class AchievementModel {
  final String id;
  final String achievementKey;
  final String title;
  final String description;
  final String iconName;
  final int xpReward;
  final DateTime? earnedAt;
  final bool isEarned;
  final String requirement;

  const AchievementModel({
    required this.id,
    required this.achievementKey,
    required this.title,
    required this.description,
    required this.iconName,
    required this.xpReward,
    this.earnedAt,
    this.isEarned = false,
    required this.requirement,
  });

  factory AchievementModel.fromMap(Map<String, dynamic> map, String id) {
    return AchievementModel(
      id: id,
      achievementKey: map['achievementKey'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      iconName: map['iconName'] ?? '',
      xpReward: map['xpReward']?.toInt() ?? 0,
      earnedAt: map['earnedAt'] != null ? (map['earnedAt'] as Timestamp).toDate() : null,
      isEarned: map['isEarned'] ?? false,
      requirement: map['requirement'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'achievementKey': achievementKey,
      'title': title,
      'description': description,
      'iconName': iconName,
      'xpReward': xpReward,
      'earnedAt': earnedAt != null ? Timestamp.fromDate(earnedAt!) : null,
      'isEarned': isEarned,
      'requirement': requirement,
    };
  }

  AchievementModel copyWith({
    String? id,
    String? achievementKey,
    String? title,
    String? description,
    String? iconName,
    int? xpReward,
    DateTime? earnedAt,
    bool? isEarned,
    String? requirement,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      achievementKey: achievementKey ?? this.achievementKey,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      xpReward: xpReward ?? this.xpReward,
      earnedAt: earnedAt ?? this.earnedAt,
      isEarned: isEarned ?? this.isEarned,
      requirement: requirement ?? this.requirement,
    );
  }
}

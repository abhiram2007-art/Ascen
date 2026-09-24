import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final int level;
  final int xp;
  final int totalXP;
  final String rank;
  final int streak;
  final int bestStreak;
  final DateTime createdAt;
  final DateTime? lastActiveDate;
  final Map<String, dynamic> preferences;
  final Map<String, int> stats;
  final int shadowArmy;
  final String title;
  final String? guildId;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.level = 1,
    this.xp = 0,
    required this.totalXP,
    this.rank = 'E',
    this.streak = 0,
    this.bestStreak = 0,
    required this.createdAt,
    this.lastActiveDate,
    required this.preferences,
    required this.stats,
    this.shadowArmy = 0,
    this.title = 'Newborn Player',
    this.guildId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String id) {
    return UserModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      level: map['level']?.toInt() ?? 1,
      xp: map['xp']?.toInt() ?? 0,
      totalXP: map['totalXP']?.toInt() ?? 0,
      rank: map['rank'] ?? 'E',
      streak: map['streak']?.toInt() ?? 0,
      bestStreak: map['bestStreak']?.toInt() ?? 0,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActiveDate: _parseDateTime(map['lastActiveDate']),
      preferences: map['preferences'] != null ? Map<String, dynamic>.from(map['preferences']) : {},
      stats: map['stats'] != null ? Map<String, int>.from(map['stats']) : {
        'strength': 0,
        'intelligence': 0,
        'vitality': 0,
        'agility': 0,
        'perception': 0,
      },
      shadowArmy: map['shadowArmy']?.toInt() ?? 0,
      title: map['title'] ?? 'Newborn Player',
      guildId: map['guildId'],
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'level': level,
      'xp': xp,
      'totalXP': totalXP,
      'rank': rank,
      'streak': streak,
      'bestStreak': bestStreak,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActiveDate': lastActiveDate != null ? Timestamp.fromDate(lastActiveDate!) : null,
      'preferences': preferences,
      'stats': stats,
      'shadowArmy': shadowArmy,
      'title': title,
      if (guildId != null) 'guildId': guildId,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    int? level,
    int? xp,
    int? totalXP,
    String? rank,
    int? streak,
    int? bestStreak,
    DateTime? createdAt,
    DateTime? lastActiveDate,
    Map<String, dynamic>? preferences,
    Map<String, int>? stats,
    int? shadowArmy,
    String? title,
    String? guildId,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      totalXP: totalXP ?? this.totalXP,
      rank: rank ?? this.rank,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt ?? this.createdAt,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      preferences: preferences ?? this.preferences,
      stats: stats ?? this.stats,
      shadowArmy: shadowArmy ?? this.shadowArmy,
      title: title ?? this.title,
      guildId: guildId ?? this.guildId,
    );
  }
}

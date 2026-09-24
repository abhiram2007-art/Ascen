import 'package:cloud_firestore/cloud_firestore.dart';

class GuildModel {
  final String id;
  final String name;
  final String description;
  final int totalXP;
  final int level;
  final String leaderId;
  final List<String> memberIds;
  final DateTime createdAt;

  const GuildModel({
    required this.id,
    required this.name,
    required this.description,
    this.totalXP = 0,
    this.level = 1,
    required this.leaderId,
    required this.memberIds,
    required this.createdAt,
  });

  factory GuildModel.fromMap(Map<String, dynamic> map, String id) {
    return GuildModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      totalXP: map['totalXP']?.toInt() ?? 0,
      level: map['level']?.toInt() ?? 1,
      leaderId: map['leaderId'] ?? '',
      memberIds: List<String>.from(map['memberIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'totalXP': totalXP,
      'level': level,
      'leaderId': leaderId,
      'memberIds': memberIds,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

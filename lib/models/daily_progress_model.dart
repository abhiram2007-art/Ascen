class DailyProgressModel {
  final String id;
  final int totalXP;
  final int questsCompleted;
  final int questsTotal;
  final int focusTime;
  final int streakDay;
  final List<String> completedQuestIds;

  const DailyProgressModel({
    required this.id,
    this.totalXP = 0,
    this.questsCompleted = 0,
    this.questsTotal = 0,
    this.focusTime = 0,
    this.streakDay = 0,
    this.completedQuestIds = const [],
  });

  factory DailyProgressModel.fromMap(Map<String, dynamic> map, String id) {
    return DailyProgressModel(
      id: id,
      totalXP: map['totalXP']?.toInt() ?? 0,
      questsCompleted: map['questsCompleted']?.toInt() ?? 0,
      questsTotal: map['questsTotal']?.toInt() ?? 0,
      focusTime: map['focusTime']?.toInt() ?? 0,
      streakDay: map['streakDay']?.toInt() ?? 0,
      completedQuestIds: map['completedQuestIds'] != null
          ? List<String>.from(map['completedQuestIds'])
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'totalXP': totalXP,
      'questsCompleted': questsCompleted,
      'questsTotal': questsTotal,
      'focusTime': focusTime,
      'streakDay': streakDay,
      'completedQuestIds': completedQuestIds,
    };
  }

  DailyProgressModel copyWith({
    String? id,
    int? totalXP,
    int? questsCompleted,
    int? questsTotal,
    int? focusTime,
    int? streakDay,
    List<String>? completedQuestIds,
  }) {
    return DailyProgressModel(
      id: id ?? this.id,
      totalXP: totalXP ?? this.totalXP,
      questsCompleted: questsCompleted ?? this.questsCompleted,
      questsTotal: questsTotal ?? this.questsTotal,
      focusTime: focusTime ?? this.focusTime,
      streakDay: streakDay ?? this.streakDay,
      completedQuestIds: completedQuestIds ?? this.completedQuestIds,
    );
  }
}

class StreakService {
  /// Check if user completed at least one quest today
  static bool hasCompletedToday(DateTime? lastCompletionDate) {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    return lastCompletionDate.year == now.year && 
           lastCompletionDate.month == now.month && 
           lastCompletionDate.day == now.day;
  }
  
  /// Check if streak should continue (completed yesterday)
  static bool shouldContinueStreak(DateTime? lastCompletionDate) {
    if (lastCompletionDate == null) return false;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final lastCompletionDay = DateTime(
      lastCompletionDate.year, 
      lastCompletionDate.month, 
      lastCompletionDate.day
    );
    return lastCompletionDay.isAtSameMomentAs(yesterday) || hasCompletedToday(lastCompletionDate);
  }
  
  /// Calculate new streak value
  static int calculateNewStreak(int currentStreak, DateTime? lastCompletionDate) {
    if (hasCompletedToday(lastCompletionDate)) {
      return currentStreak;
    } else if (shouldContinueStreak(lastCompletionDate)) {
      return currentStreak + 1;
    } else {
      return 1;
    }
  }
  
  /// Check if this is the start of a new streak day
  static bool isNewStreakDay(DateTime? lastCompletionDate) {
    return !hasCompletedToday(lastCompletionDate);
  }
}

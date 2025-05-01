class Habit {
  final String? id;
  final String name;
  final String? category;
  bool isCompleted; // General completion (might not be needed if we track daily)
  bool isCompletedToday; // For the current day's tracking
  final int? goalCount;
  int progress;
  int progressToday; // For the current day's progress

  Habit({
    this.id,
    required this.name,
    this.category,
    this.isCompleted = false, // Consider if you need this
    this.isCompletedToday = false,
    this.goalCount,
    this.progress = 0, // Consider if you need this
    this.progressToday = 0,
  });

  factory Habit.fromJson(Map<String, dynamic> json, String documentId) {
    return Habit(
      id: documentId,
      name: json['name'] as String,
      category: json['category'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      goalCount: json['goalCount'] as int?,
      progress: json['progress'] as int? ?? 0,
      progressToday: json['progressToday'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'isCompletedToday': isCompletedToday,
      'goalCount': goalCount,
      'progress': progress,
      'progressToday': progressToday,
    };
  }







  
}
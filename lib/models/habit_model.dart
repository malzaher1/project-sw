class Habit {
  final String name;
  final String? category;
  bool isCompleted;
  final int? goalCount;
  int progress;

  Habit({required this.name, this.category, this.isCompleted = false, this.goalCount, this.progress = 0});

  // Add a fromJson method to create a Habit object from a Firestore document
  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      name: json['name'] as String,
      category: json['category'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      goalCount: json['goalCount'] as int?,
      progress: json['progress'] as int? ?? 0,
    );
  }

  // Optionally, add a toJson method to convert a Habit object to a Firestore document
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'goalCount': goalCount,
      'progress': progress,
    };
  }
}
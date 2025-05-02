class Habit {
  final String? id; // Add this line
  final String name;
  final String? category;
  bool isCompleted;
  final int? goalCount;
  int progress;
  bool isCompletedToday = false; 
  int? progressToday; 

  Habit({this.id, required this.name, this.category, this.isCompleted = false, this.goalCount, this.progress = 0, this.isCompletedToday=false, this.progressToday=0});

  factory Habit.fromJson(Map<String, dynamic> json, String documentId) { 
    return Habit(
      id: documentId, 
      name: json['name'] as String,
      category: json['category'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      goalCount: json['goalCount'] as int?,
      progress: json['progress'] as int? ?? 0,
      isCompletedToday: json['isCompletedToday'] as bool? ?? false,
      progressToday: json['progressToday'] as int? ?? 0,



    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'isCompleted': isCompleted,
      'goalCount': goalCount,
      'progress': progress,
      'isCompletedToday': isCompletedToday,
      'progressToday': progressToday,
    };
  }







  
}
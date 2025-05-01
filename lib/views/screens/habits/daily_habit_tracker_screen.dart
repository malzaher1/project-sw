import 'package:flutter/material.dart';

class DailyHabitTrackerScreen extends StatefulWidget {
  @override
  _DailyHabitTrackerScreenState createState() => _DailyHabitTrackerScreenState();
}

class _DailyHabitTrackerScreenState extends State<DailyHabitTrackerScreen> {
  // Sample data for today's habits (replace with actual data fetched from Firebase)
  final List<Habit> _todaysHabits = [
    Habit(name: 'Turn off lights', category: 'Energy', isCompleted: false),
    Habit(name: 'Walk or bike', category: 'Transportation', isCompleted: true),
    Habit(name: 'Reduce meat', category: 'Food', isCompleted: false),
    Habit(name: 'Read a book', category: 'Educational', isCompleted: true),
    Habit(name: 'Water plants', category: 'Other', isCompleted: false, goalCount: 2, progress: 1), // Example with count goal
  ];

  int _completedHabitsCount = 0;
  int _totalHabitsCount = 0;
  int _pointsEarnedToday = 0;

  @override
  void initState() {
    super.initState();
    _calculateProgress();
  }

  void _toggleHabitCompletion(int index, bool? newValue) {
    if (newValue != null) {
      setState(() {
        _todaysHabits[index].isCompleted = newValue;
        _calculateProgress();
        // TODO: Update points based on habit completion (we'll define point values later)
        _pointsEarnedToday = _todaysHabits.where((habit) => habit.isCompleted).length * 10; // Example: 10 points per completed habit
      });
      print('Habit "${_todaysHabits[index].name}" completed: $newValue, Points: $_pointsEarnedToday');
      // TODO: Save the updated habit completion status to Firebase
    }
  }

  void _updateCountProgress(int index, int newProgress) {
    setState(() {
      _todaysHabits[index].progress = newProgress;
      _calculateProgress();
      // TODO: Update points based on count goal completion
      if (_todaysHabits[index].progress == _todaysHabits[index].goalCount) {
        _pointsEarnedToday += 15; // Example: Award points on reaching count goal
      }
    });
    print('Habit "${_todaysHabits[index].name}" progress: $newProgress, Points: $_pointsEarnedToday');
    // TODO: Save the updated count progress to Firebase
  }

  void _calculateProgress() {
    _completedHabitsCount = _todaysHabits.where((habit) => habit.isCompleted || (habit.goalCount != null && habit.progress == habit.goalCount)).length;
    _totalHabitsCount = _todaysHabits.length;
  }

  double get _completionPercentage => _totalHabitsCount > 0 ? _completedHabitsCount / _totalHabitsCount : 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Habits'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                LinearProgressIndicator(
                  value: _completionPercentage,
                  backgroundColor: Colors.blue.shade100,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
                  minHeight: 10.0,
                ),
                SizedBox(height: 8.0),
                Text(
                  '${(_completionPercentage * 100).toStringAsFixed(0)}% Completed',
                  style: TextStyle(fontSize: 16.0, color: Colors.blue.shade700),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Points Earned Today: $_pointsEarnedToday',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.green.shade600),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _todaysHabits.length,
              itemBuilder: (context, index) {
                final habit = _todaysHabits[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                habit.name,
                                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                              ),
                              if (habit.category != null)
                                Text(
                                  habit.category!,
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              if (habit.goalCount != null)
                                Text('Goal: ${habit.progress}/${habit.goalCount}'),
                            ],
                          ),
                        ),
                        if (habit.goalCount == null)
                          Checkbox(
                            value: habit.isCompleted,
                            onChanged: (bool? newValue) => _toggleHabitCompletion(index, newValue),
                            activeColor: Colors.blue.shade600,
                          )
                        else
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              IconButton(
                                icon: Icon(Icons.remove),
                                onPressed: habit.progress > 0 ? () => _updateCountProgress(index, habit.progress - 1) : null,
                              ),
                              Text('${habit.progress}/${habit.goalCount}'),
                              IconButton(
                                icon: Icon(Icons.add),
                                onPressed: (habit.goalCount != null && habit.progress < habit.goalCount!) ? () => _updateCountProgress(index, habit.progress + 1): null,
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}

// Simple data model for a Habit
class Habit {
  final String name;
  final String? category;
  bool isCompleted;
  final int? goalCount;
  int progress;

  Habit({required this.name, this.category, this.isCompleted = false, this.goalCount, this.progress = 0});
}
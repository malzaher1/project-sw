import 'package:flutter/material.dart';
import 'package:project/models/habit_model.dart';
import 'package:project/services/habit_service.dart';

class DailyHabitTrackerScreen extends StatefulWidget {
  @override
  _DailyHabitTrackerScreenState createState() => _DailyHabitTrackerScreenState();
}

class _DailyHabitTrackerScreenState extends State<DailyHabitTrackerScreen> {
  List<Habit> _todaysHabits = [];
  int _completedHabitsCount = 0;
  int _totalHabitsCount = 0;
  int _pointsEarnedToday = 0;
  final HabitService _habitService = HabitService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

   Future<void> _loadHabits() async {
    setState(() {
      _isLoading = true;
    });
    _todaysHabits = await _habitService.getTodayUserHabits();
    _calculateProgress();
    setState(() {
      _isLoading = false;
    });
  }

  void _toggleHabitCompletion(int index, bool? newValue) {
    if (newValue != null) {
      setState(() {
        _todaysHabits[index].isCompleted = newValue;
        _calculateProgress();
        _pointsEarnedToday = _todaysHabits.where((habit) => habit.isCompleted).length * 10;
      });
      print('Habit "${_todaysHabits[index].name}" completed: $newValue, Points: $_pointsEarnedToday');
      _habitService.updateHabitCompletion(_todaysHabits[index].id!, newValue); 
    }
  }

  void _deleteHabit(int index) async {
    final habitToDelete = _todaysHabits[index];

    setState(() {
      _todaysHabits.removeAt(index);
      _calculateProgress();
    });

    // Delete from Firebase
    try {
      await _habitService.deleteHabit(habitToDelete.id!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${habitToDelete.name} deleted')),
      );
    } catch (e) {
      setState(() {
        _todaysHabits.insert(index, habitToDelete); // Re-insert on error
        _calculateProgress();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting ${habitToDelete.name}')),
      );
      print('Error deleting habit: $e');
    }
  }

   void _updateCountProgress(int index, int newProgress) {
    setState(() {
      _todaysHabits[index].progress = newProgress;
      _calculateProgress();
      if (_todaysHabits[index].progress == _todaysHabits[index].goalCount) {
        _pointsEarnedToday += 15;
      }
    });
    print('Habit "${_todaysHabits[index].name}" progress: $newProgress, Points: $_pointsEarnedToday');
    _habitService.updateHabitProgress(_todaysHabits[index].id!, newProgress); 
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                      return Dismissible(
                        key: Key(habit.id!), // Unique key for each item
                        direction: DismissDirection.endToStart, // Swipe from right to left to dismiss
                        background: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.0),
                          child: Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          _deleteHabit(index);
                        },
                        child: Card(
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
                                      onPressed: (habit.goalCount != null && habit.progress < habit.goalCount!)
                                          ? () => _updateCountProgress(index, habit.progress + 1)
                                          : null,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        )
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
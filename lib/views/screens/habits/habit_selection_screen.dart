import 'package:flutter/material.dart';
import 'package:project/services/habit_service.dart';

class HabitSelectionScreen extends StatefulWidget {
  @override
  _HabitSelectionScreenState createState() => _HabitSelectionScreenState();
}

class _HabitSelectionScreenState extends State<HabitSelectionScreen> {
  // Sample data for predefined habits (replace with your actual data)
  final Map<String, List<String>> _predefinedHabits = {
    'Energy': ['Turn off lights when leaving a room', 'Unplug chargers when not in use'],
    'Transportation': ['Walk or bike for short distances', 'Use public transport'],
    'Food': ['Reduce meat consumption', 'Avoid single-use plastics'],
    'Educational': ['Read a book for 30 minutes', 'Learn a new word daily'],
  };

  // To keep track of selected habits
  final Set<String> _selectedHabits = {};

  void _toggleHabit(String habit, bool isSelected) {
    setState(() {
      if (isSelected) {
        _selectedHabits.add(habit);
      } else {
        _selectedHabits.remove(habit);
      }
      print('Selected Habits: $_selectedHabits'); // For debugging
    });
  }
  
  final HabitService _habitService = HabitService();

  void _proceedToDailyTracker() async {
      if (_selectedHabits.isNotEmpty) {
        Map<String, String?> habitsWithCategory = {};
        _selectedHabits.forEach((habitName) {
          String? category;
          _predefinedHabits.forEach((cat, habits) {
            if (habits.contains(habitName)) {
              category = cat;
            }
          });
          habitsWithCategory[habitName] = category;
        });

        await _habitService.saveSelectedHabitsWithCategory(habitsWithCategory); 
        print('Proceeding with selected habits: $habitsWithCategory');
        Navigator.pushReplacementNamed(context, '/daily_tracker');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select at least one habit to continue.')),
        );
      }
    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Habits'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Choose habits you want to track:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            SizedBox(height: 16.0),
            ..._predefinedHabits.entries.map((entry) {
              final category = entry.key;
              final habits = entry.value;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                child: ExpansionTile(
                  title: Text(category, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue.shade600)),
                  children: habits.map((habit) {
                    final isSelected = _selectedHabits.contains(habit);
                    return CheckboxListTile(
                      title: Text(habit),
                      value: isSelected,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          _toggleHabit(habit, newValue);
                        }
                      },
                      controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
                    );
                  }).toList(),
                ),
              );
            }).toList(),
         
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _proceedToDailyTracker,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                padding: EdgeInsets.symmetric(vertical: 15.0),
                textStyle: TextStyle(fontSize: 18.0),
              ),
              child: Text('Proceed to Daily Tracker'),
            ),
            SizedBox(height: 16.0), // Add some space
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/add_custom_habit');
              },
              child: Text(
                '+ Add Custom Habit',
                style: TextStyle(fontSize: 16.0, color: Colors.blue.shade500),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
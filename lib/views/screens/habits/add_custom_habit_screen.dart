import 'package:flutter/material.dart';
import 'package:project/services/habit_service.dart';

class AddCustomHabitScreen extends StatefulWidget {
  const AddCustomHabitScreen({super.key});

  @override
  _AddCustomHabitScreenState createState() => _AddCustomHabitScreenState();
}

class _AddCustomHabitScreenState extends State<AddCustomHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitNameController = TextEditingController();
  String? _selectedCategory;
  bool _isCountGoal = false;
  final _goalCountController = TextEditingController(text: '1'); // Default to 1
  final List<String> _categories = ['Energy', 'Transportation', 'Food', 'Educational', 'Other'];

  void _toggleGoalType(bool value) {
    setState(() {
      _isCountGoal = value;
    });
  }

 

  final HabitService _habitService = HabitService();

  void _saveCustomHabit() async { // Make it async
    if (_formKey.currentState!.validate()) {
      final habitName = _habitNameController.text.trim();
      if (_selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a category.')),
        );
        return;
      }
      int? dailyGoalCount = _isCountGoal ? int.tryParse(_goalCountController.text) : null;

      await _habitService.saveCustomHabit(
        name: habitName,
        category: _selectedCategory,
        isCountGoal: _isCountGoal,
        goalCount: dailyGoalCount,
      );
      print : null;

      // TODO: Save the custom habit data (name, category, goal type, goal count)
      print('Saving custom habit: Name=$habitName, Category=$_selectedCategory, IsCountGoal=$_isCountGoal, GoalCount=$dailyGoalCount');
      // After saving, navigate back or to the Daily Tracker
      Navigator.pop(context); // Go back to the previous screen (Habit Selection?)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Custom Habit'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _habitNameController,
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                value: _selectedCategory,
                items: _categories.map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                )).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Row(
                children: <Widget>[
                  Text('Set a daily goal with a count?'),
                  Switch(
                    value: _isCountGoal,
                    onChanged: _toggleGoalType,
                    activeColor: Colors.blue.shade600,
                  ),
                ],
              ),
              if (_isCountGoal)
                TextFormField(
                  controller: _goalCountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Daily Goal Count',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_isCountGoal) {
                      if (value == null || value.isEmpty || int.tryParse(value) == null || int.parse(value) < 1) {
                        return 'Please enter a valid goal count (at least 1)';
                      }
                    }
                    return null;
                  },
                ),
              SizedBox(height: 24.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Cancel and go back
                    },
                    child: Text('Cancel', style: TextStyle(fontSize: 16.0)),
                  ),
                  SizedBox(width: 16.0),
                  ElevatedButton(
                    onPressed: _saveCustomHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade600,
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      textStyle: TextStyle(fontSize: 16.0),
                    ),
                    child: Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
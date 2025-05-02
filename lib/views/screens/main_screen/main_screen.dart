import 'package:flutter/material.dart';
import 'package:project/views/screens/habits/daily_habit_tracker_screen.dart';
import 'package:project/views/screens/habits/habit_selection_screen.dart';
import 'package:project/views/screens/leaderboard/leaderboard_screen.dart';
import 'package:project/views/screens/main_screen/dashboard_screen.dart';
import 'package:project/views/screens/profile/profile_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    DashboardScreen(),
    DailyHabitTrackerScreen(),
    HabitSelectionScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // Use IndexedStack to keep all screens alive
        index: _selectedIndex, // Show only the selected screen
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Example icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_box), // Example icon
            label: 'Daily',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list), // Example icon
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard), // Example icon
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person), // Example icon
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade600,
        unselectedItemColor: Colors.grey.shade600,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // If you have more than 3 items
      ),
    );
  }
}
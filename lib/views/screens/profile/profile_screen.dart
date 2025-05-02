import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For theme persistence

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  int _totalPoints = 0; // Placeholder
  int _completionStreak = 0; // Placeholder
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Get the current user from Firebase Auth
    _currentUser = FirebaseAuth.instance.currentUser;
    // TODO: Fetch total points and completion streak from Firebase
    // For now, we'll use placeholders
    setState(() {
      // Example values
      _totalPoints = 150;
      _completionStreak = 7;
    });
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    // TODO: Implement theme change in the app (using Provider or setState in the main app widget)
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navigate back to the Login Screen after signing out
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error signing out: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              _currentUser?.displayName ?? 'Guest User',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
            SizedBox(height: 8.0),
            Text(
              _currentUser?.email ?? 'No email available',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            SizedBox(height: 24.0),
            Text(
              'Total Points: $_totalPoints',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.0),
            Text(
              'Completion Streak: $_completionStreak days',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Dark Theme', style: TextStyle(fontSize: 16.0)),
                Switch(
                  value: _isDarkMode,
                  onChanged: (bool newValue) {
                    _saveThemePreference(newValue);
                  },
                  activeColor: Colors.blue.shade600,
                ),
              ],
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade400,
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                textStyle: TextStyle(fontSize: 18.0, color: Colors.white),
              ),
              child: Text('Sign Out'),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project/services/habit_service.dart'; // Import HabitService
import 'package:flutter/widgets.dart'; // Import widgets

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  User? _currentUser;
  int _totalPoints = 0;
  bool _isDarkMode = false;
  final HabitService _habitService = HabitService(); // Instantiate HabitService

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
    _fetchUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _fetchUserData(); // Refresh data when the screen becomes visible again
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      try {
        DocumentSnapshot<Map<String, dynamic>> userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentUser!.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _totalPoints = userDoc.data()?['totalPoints'] as int? ?? 0;
            // TODO: Implement fetching completion streak later
          });
        } else {
          print('Error: User document not found for UID: ${_currentUser!.uid}');
        }
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
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
    setState(() {
      _isDarkMode = isDarkMode;
    });
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
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
              'Completion Streak: 0 days', // Placeholder for now
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Dark Theme', style: TextStyle(fontSize: 16.0)),
                Switch(
                  value: _isDarkMode,
                  onChanged: (bool newValue) => _saveThemePreference(newValue),
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
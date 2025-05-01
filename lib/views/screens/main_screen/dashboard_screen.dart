import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'), // Or a more descriptive title
        backgroundColor: Colors.blue.shade400,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Welcome, ${currentUser?.displayName ?? 'User'}!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'What do you want to do?',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            // You can add more widgets here later for progress summaries, etc.
          ],
        ),
      ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}
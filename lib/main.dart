import 'package:flutter/material.dart';
import 'package:project/views/screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:project/views/screens/habits/habit_selection_screen.dart';

// void main() {
//   runApp(const MyApp());
// }



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), 
      routes: {
        '/login': (context) => LoginScreen(), // Define the login route (optional as it's the home)
        '/habit_selection': (context) => HabitSelectionScreen(), 
      },
    );
  }
}

class HabitSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Habits'),
      ),
      body: Center(
        child: Text('Habit Selection Screen'),
      ),
    );
  }
}
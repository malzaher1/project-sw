import 'package:flutter/material.dart';
import 'package:project/views/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:project/views/screens/auth/signup_screen.dart';
import 'package:project/views/screens/habits/add_custom_habit_screen.dart';
import 'package:project/views/screens/habits/daily_habit_tracker_screen.dart';
import 'package:project/views/screens/leaderboard/leaderboard_screen.dart';
import 'package:project/views/screens/main_screen/dashboard_screen.dart';
import 'package:project/views/screens/main_screen/main_screen.dart';
import 'package:project/views/screens/profile/profile_screen.dart';
import 'firebase_options.dart';
import 'package:project/views/screens/habits/habit_selection_screen.dart';

// void main() {
//   runApp(const MyApp());
// }
// 

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habits Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginScreen(), 
      // home: LeaderboardScreen(), 
      routes: {
        '/login': (context) => LoginScreen(), // Define the login route (optional as it's the home)
        '/habit_selection': (context) => HabitSelectionScreen(), 
        '/add_custom_habit': (context) => AddCustomHabitScreen(), 
        '/daily_tracker': (context) => DailyHabitTrackerScreen(),
        '/profile': (context) => ProfileScreen(), 
        '/leaderboard': (context) => LeaderboardScreen(), 
        '/signup': (context) => SignupScreen(),
        '/main': (context) => MainScreen(), 
        '/dashboard': (context) => DashboardScreen(), 






      },
      navigatorObservers: [routeObserver], 

    );
  }
}


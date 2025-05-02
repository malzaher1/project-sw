import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/services/habit_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  List<LeaderboardEntry> _leaderboardData = [];
  bool _isLoading = false;
  final HabitService _habitService = HabitService(); 

  @override
  void initState() {
    super.initState();
    print('Current User UID in Leaderboard: $_currentUserUid'); 
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _leaderboardData.clear();
    });
    // _leaderboardData = await _habitService.getLeaderboardData();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshLeaderboard() async {
    await _fetchLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leaderboard'),
        backgroundColor: Colors.blue.shade400,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshLeaderboard,
              child: ListView.builder(
                itemCount: _leaderboardData.length,
                itemBuilder: (context, index) {
                  final entry = _leaderboardData[index];
                  final isCurrentUser = entry.userId == _currentUserUid;
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    color: isCurrentUser ? Colors.blue.shade100 : null,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            '${index + 1}. ${entry.displayName}',
                            style: TextStyle(
                              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                              fontSize: 16.0,
                            ),
                          ),
                          Text(
                            '${entry.points} Points', // Display totalPoints
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
      backgroundColor: Colors.blue.shade50,
    );
  }
}

class LeaderboardEntry {
  final String userId;
  final String displayName;
  final int points;

  LeaderboardEntry({required this.userId, required this.displayName, required this.points});
}
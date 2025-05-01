import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderboardScreen extends StatefulWidget {
  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _currentUserUid = FirebaseAuth.instance.currentUser?.uid;
  List<LeaderboardEntry> _leaderboardData = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardData();
  }

  Future<void> _fetchLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _leaderboardData.clear(); // Clear previous data
    });
    // TODO: Fetch leaderboard data from Firebase (order by points)
    // For now, we'll use sample data
    await Future.delayed(Duration(seconds: 1)); // Simulate loading delay
    setState(() {
      _leaderboardData = [
        LeaderboardEntry(userId: 'user1', displayName: 'Alice', points: 250),
        LeaderboardEntry(userId: 'user2', displayName: 'Bob', points: 310),
        LeaderboardEntry(userId: _currentUserUid ?? 'me', displayName: 'You', points: 280),
        LeaderboardEntry(userId: 'user3', displayName: 'Charlie', points: 200),
        LeaderboardEntry(userId: 'user4', displayName: 'David', points: 350),
      ]..sort((a, b) => b.points.compareTo(a.points)); // Sort by points descending
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
                    color: isCurrentUser ? Colors.blue.shade100 : null, // Highlight current user
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
                            '${entry.points} Points',
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
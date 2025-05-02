import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/main.dart';
import 'package:project/services/habit_service.dart';
import 'package:flutter/widgets.dart'; 


class LeaderboardScreen extends StatefulWidget{
  const LeaderboardScreen({super.key});

  @override
  _LeaderboardScreenState createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with RouteAware {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  List<LeaderboardEntry> _leaderboardData = [];
  bool _isLoading = true;
  bool _hasError = false;
  final HabitService _habitService = HabitService();

  @override
  void initState() {
    super.initState();
    if (_currentUser != null) {
      print('Current User UID in Leaderboard: ${_currentUser!.uid}');
    }
    _fetchLeaderboardData();
  }


    @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute); // Subscribe to route changes
  }

  @override
  void didPopNext() {
    // Called when the top route has been popped off, and the current route shows again.
    _fetchLeaderboardData(); // Refresh data when the screen becomes visible
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this); // Unsubscribe when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchLeaderboardData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    try {
      final data = await _habitService.getLeaderboardData();
      if (mounted) {
        setState(() {
          _leaderboardData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching leaderboard: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Future<void> _refreshLeaderboard() async {
    setState(() {
      _isLoading = true;
      _leaderboardData.clear();
    });
    _leaderboardData = await _habitService.getLeaderboardData();
    setState(() {
      _isLoading = false;
    });
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry, int index) {
    final isCurrentUser = entry.userId == _currentUser?.uid;
    final rank = index + 1;
    final rankColor = rank == 1
        ? Colors.amber
        : rank == 2
            ? Colors.grey
            : rank == 3
                ? Colors.brown
                : Colors.blue;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: isCurrentUser ? Colors.blue.shade100 : null,
      elevation: isCurrentUser ? 4.0 : 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: isCurrentUser
            ? BorderSide(color: Colors.blue.shade400, width: 2.0)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: <Widget>[
            // Rank indicator
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3 ? rankColor : Colors.blue.shade50,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? Colors.white : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16.0),
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style: TextStyle(
                      fontWeight:
                          isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16.0,
                    ),
                  ),
                  if (entry.displayName != null && entry.displayName!.isNotEmpty)
                    Text(
                      entry.displayName!,
                      style: const TextStyle(
                        fontSize: 12.0,
                        color: Colors.grey,
                      ),
                    ),
                ]),
            ),
            // Points
            Chip(
              backgroundColor: Colors.blue.shade50,
              label: Text(
                '${entry.points} pts',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.leaderboard_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'No leaderboard data available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Complete habits to appear on the leaderboard',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLeaderboardData,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Failed to load leaderboard',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your internet connection and try again',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchLeaderboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        backgroundColor: Colors.blue.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchLeaderboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _leaderboardData.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshLeaderboard,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount: _leaderboardData.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 4.0),
                        itemBuilder: (context, index) =>
                            _buildLeaderboardItem(_leaderboardData[index], index),
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
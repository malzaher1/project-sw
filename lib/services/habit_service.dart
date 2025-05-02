import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/habit_model.dart';
import 'package:project/views/screens/leaderboard/leaderboard_screen.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Habit>> getTodayUserHabits() async {
    User? user = _auth.currentUser;
    if (user == null) {
      return [];
    }

    List<Habit> habits = [];
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
        habits.add(Habit.fromJson(doc.data(), doc.id));
        }
    } catch (e) {
      print('Error fetching user habits: $e');
      return [];
    }
    return habits;
  }


  Future<void> saveSelectedHabitsWithCategory(Map<String, String?> habitsWithCategory) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot save habits.');
      return;
    }

    try {
      CollectionReference<Map<String, dynamic>> habitsRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits');

      for (var entry in habitsWithCategory.entries) {
        String habitName = entry.key;
        String? category = entry.value;

        QuerySnapshot<Map<String, dynamic>> existingHabit = await habitsRef
            .where('name', isEqualTo: habitName)
            .get();

        if (existingHabit.docs.isEmpty) {
          await habitsRef.add({
            'name': habitName,
            'category': category,
            'isCompleted': false,
            'progress': 0,
          });
          print('Saved habit: $habitName with category: $category');
        } else {
          print('Habit "$habitName" already exists for this user.');
        }
      }
    } catch (e) {
      print('Error saving selected habits with category: $e');
    }
  }

  

  Future<void> saveCustomHabit({
    required String name,
    String? category,
    bool isCountGoal = false,
    int? goalCount,
  }) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot save custom habit.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .add({
        'name': name,
        'category': category,
        'isCompleted': false,
        'goalCount': goalCount,
        'progress': 0,
      });
      print('Saved custom habit: $name');
    } catch (e) {
      print('Error saving custom habit: $e');
    }
  }

  Future<void> updateHabitCompletion(String habitId, bool isCompleted) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot update habit completion.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId) // We need the document ID of the habit
          .update({'isCompleted': isCompleted});
      print('Updated habit completion for $habitId to $isCompleted');
    } catch (e) {
      print('Error updating habit completion: $e');
      // Optionally handle the error
    }
  }

  Future<void> updateHabitProgress(String habitId, int progress) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot update habit progress.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId) // We need the document ID of the habit
          .update({'progress': progress});
      print('Updated habit progress for $habitId to $progress');
    } catch (e) {
      print('Error updating habit progress: $e');
      // Optionally handle the error
    }
  }



  Future<void> deleteHabit(String habitId) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot delete habit.');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .delete();
      print('Deleted habit: $habitId');
    } catch (e) {
      print('Error deleting habit: $e');
      // Optionally handle the error
    }
  }


  Future<void> updateUserTotalPoints(String userId, int pointsToAdd) async {
  try {
    final userDocRef = _firestore.collection('users').doc(userId);
    await _firestore.runTransaction((transaction) async {
      try {
        final snapshot = await transaction.get(userDocRef);
        if (!snapshot.exists) {
          throw Exception("User does not exist!");
        }
        final currentPoints = snapshot.data()?['totalPoints'] as int? ?? 0;
        final newTotalPoints = currentPoints + pointsToAdd;
        transaction.update(userDocRef, {'totalPoints': newTotalPoints});
      } catch (innerError) {
        print('Inner transaction error: ${innerError.toString()}'); // Catch specific transaction error
        return Future.error(innerError); // Propagate the error
      }
    }).catchError((error) {
      print('Transaction failed with error: ${error.toString()}'); // Catch error from runTransaction
    });
    print('Attempted to add $pointsToAdd points to user $userId.');
  } catch (e) {
    print('Outer error: ${e.toString()}'); // Catch any other errors
  }
}


Future<List<LeaderboardEntry>> getLeaderboardData() async {
    print('getLeaderboardData() called'); 


User? user = _auth.currentUser;
  if (user == null) {
    print('No user logged in, cannot fetch leaderboard data.');
    return [];
  }

  List<LeaderboardEntry> leaderboardData = [];
  try {
    QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection('users')
        // .orderBy('totalPoints', descending: true)
        .get();

    print('Number of users fetched: ${snapshot.docs.length}'); // ADD THIS

    for (QueryDocumentSnapshot<Map<String, dynamic>> doc in snapshot.docs) {
      final data = doc.data();
      print('User data: ${doc.id} - ${data.toString()}'); // ADD THIS
      leaderboardData.add(
        LeaderboardEntry(
          userId: doc.id,
          displayName: data['displayName'] as String? ?? 'Anonymous',
          points: data['totalPoints'] as int? ?? 0,
        ),
      );
    }
  } catch (e) {
    print('Error fetching leaderboard data: $e');
    // Handle error
  }
  return leaderboardData;
}


}



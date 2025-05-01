import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/models/habit_model.dart';

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

  Future<void> updateHabitCompletion(String habitId, bool isCompletedToday) async {
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
          .doc(habitId)
          .update({'isCompletedToday': isCompletedToday});
      print('Updated habit completion for $habitId to $isCompletedToday');
    } catch (e) {
      print('Error updating habit completion: $e');
      // Optionally handle the error
    }
  }

  Future<void> updateHabitProgress(String habitId, int progressToday) async {
    User? user = _auth.currentUser;
    if (user == null) {
      print('No user logged in, cannot update habit progress.');
      return;
    }
    try{
    await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('habits')
          .doc(habitId)
          .update({'progressToday': progressToday});
      print('Updated habit progress for $habitId to $progressToday');
  }
    catch (e) {
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



}
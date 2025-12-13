import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/goal_model.dart';

class GoalService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> addGoal(GoalModel goal) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      final uid = user.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goal.id)
          .set({
        'name': goal.name,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'deadline': goal.deadline?.toIso8601String(),
        'notes': goal.notes,
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      return 'Failed to add goal: ${e.toString()}';
    }
  }

  Future<String?> updateGoal(GoalModel goal) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      final uid = user.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('goals')
          .doc(goal.id)
          .update({
        'name': goal.name,
        'targetAmount': goal.targetAmount,
        'currentAmount': goal.currentAmount,
        'deadline': goal.deadline?.toIso8601String(),
        'notes': goal.notes,
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      return 'Failed to update goal: ${e.toString()}';
    }
  }

  Stream<List<GoalModel>> fetchGoals() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    final uid = user.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return GoalModel(
          id: doc.id,
          name: data['name'],
          targetAmount: (data['targetAmount'] as num).toDouble(),
          currentAmount: (data['currentAmount'] as num).toDouble(),
          deadline: data['deadline'] != null
              ? DateTime.parse(data['deadline'])
              : null,
          notes: data['notes'],
        );
      }).toList();
    }).handleError((error) {
      print('Error fetching goals: $error');
      return <GoalModel>[];
    });
  }
}

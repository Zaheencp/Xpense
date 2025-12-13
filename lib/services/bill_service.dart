import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill_model.dart';

class BillService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> addBill(BillModel bill) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      final uid = user.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(bill.id)
          .set({
        'name': bill.name,
        'amount': bill.amount,
        'dueDate': bill.dueDate.toIso8601String(),
        'isPaid': bill.isPaid,
        'notes': bill.notes,
        'recurrence': bill.recurrence,
        'reminderDays': bill.reminderDays,
        'calendarEventId': bill.calendarEventId,
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      return 'Failed to add bill: ${e.toString()}';
    }
  }

  Future<String?> updateBill(BillModel bill) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      final uid = user.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(bill.id)
          .update({
        'name': bill.name,
        'amount': bill.amount,
        'dueDate': bill.dueDate.toIso8601String(),
        'isPaid': bill.isPaid,
        'notes': bill.notes,
        'recurrence': bill.recurrence,
        'reminderDays': bill.reminderDays,
        'calendarEventId': bill.calendarEventId,
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      return 'Failed to update bill: ${e.toString()}';
    }
  }

  Future<String?> markBillPaid(String billId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      final uid = user.uid;
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('bills')
          .doc(billId)
          .update({
        'isPaid': true,
      });
      return null;
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      return 'Failed to mark bill as paid: ${e.toString()}';
    }
  }

  Stream<List<BillModel>> fetchBills() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }
    final uid = user.uid;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('bills')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BillModel(
          id: doc.id,
          name: data['name'],
          amount: (data['amount'] as num).toDouble(),
          dueDate: DateTime.parse(data['dueDate']),
          isPaid: data['isPaid'] ?? false,
          notes: data['notes'],
          recurrence: data['recurrence'],
          reminderDays: data['reminderDays'] ?? 1,
          calendarEventId: data['calendarEventId'],
        );
      }).toList();
    }).handleError((error) {
      print('Error fetching bills: $error');
      return <BillModel>[];
    });
  }
}

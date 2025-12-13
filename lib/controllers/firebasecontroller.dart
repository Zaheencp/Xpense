import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:xpense/controllers/cardprovider.dart';
import 'package:xpense/models/chartmodel.dart';
import 'package:xpense/models/transactionmodel.dart';
import '../services/encryption_service.dart';
import '../models/budget_model.dart';

typedef BudgetAlertCallback = void Function(String msg);

class FirebaseController extends ChangeNotifier {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late TransactionModel transmodel;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference transactioncollection;
  late CollectionReference subcollection;
  late CollectionReference fetchcollection;
  String? documentid;

  TransactionProvider provider = TransactionProvider();

  final List<TransactionModel> _transactiondata = [];
  List<TransactionModel> get transactiondata => _transactiondata;

  Future<String?> addData(
      String category, String amount, String date, String memo,
      {String? location,
      String? paymentMethod,
      BudgetAlertCallback? onBudgetAlert}) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      String uid = user.uid;

      transactioncollection = firestore.collection('users');
      // subcollection=transactioncollection.doc().collection('daily_transaction');

      await transactioncollection.doc(uid).collection('transactions').add({
        'category': EncryptionService.encryptText(category),
        'amount': EncryptionService.encryptText(amount),
        'date': EncryptionService.encryptText(date),
        'memo': EncryptionService.encryptText(memo),
        'location': location != null && location.isNotEmpty
            ? EncryptionService.encryptText(location)
            : null,
        'paymentMethod': paymentMethod != null && paymentMethod.isNotEmpty
            ? EncryptionService.encryptText(paymentMethod)
            : null,
      });
      // Check budget after adding transaction
      _checkBudgetAlert(uid, category, double.tryParse(amount) ?? 0,
          onBudgetAlert: onBudgetAlert);
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      debugPrint('Error adding data: $e');
      return 'Failed to add transaction: ${e.toString()}';
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? fetchdata() {
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    String uid = user.uid;
    // CollectionReference<Map<String, dynamic>> subcollection =
    //     firestore.collection('users').doc(uid).collection('transactions');

    return firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .snapshots()
        .handleError((error) {
      debugPrint('Error fetching transactions: $error');
      if (error is FirebaseException && error.code == 'permission-denied') {
        debugPrint(
            'Permission denied. Please check your Firestore security rules.');
      }
      throw error;
    });
  }

  Stream<List<ChartModel>>? fetchdatachart() {
    final user = auth.currentUser;
    if (user == null) {
      return null;
    }
    String uid = user.uid;
    CollectionReference<Map<String, dynamic>> subcollection =
        firestore.collection('users').doc(uid).collection('transactions');

    return subcollection.snapshots().map(
      (querySnapshot) {
        return querySnapshot.docs.map((doc) {
          return ChartModel.fromfirebase(doc.data());
        }).toList();
      },
    ).handleError((error) {
      debugPrint('Error fetching chart data: $error');
      if (error is FirebaseException && error.code == 'permission-denied') {
        debugPrint(
            'Permission denied. Please check your Firestore security rules.');
      }
      return <ChartModel>[];
    });
  }

  Future<String?> getcollectiondocumentid(String transacid) async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        return 'User not authenticated';
      }
      String uid = user.uid;
      await firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc(transacid)
          .delete();
      return null;
    } on FirebaseException catch (e) {
      debugPrint('Firestore error: ${e.code} - ${e.message}');
      if (e.code == 'permission-denied') {
        return 'Permission denied. Please check your Firestore security rules.';
      }
      return 'Database error: ${e.message}';
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      return 'Failed to delete transaction: ${e.toString()}';
    }
  }

  Future<void> _checkBudgetAlert(String uid, String category, double newAmount,
      {BudgetAlertCallback? onBudgetAlert}) async {
    try {
      // Get budget for this category
      final budgetSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('budgets')
          .where('category', isEqualTo: category)
          .get();
      if (budgetSnap.docs.isEmpty) return;
      final budget = BudgetModel(
        id: budgetSnap.docs.first.id,
        name: budgetSnap.docs.first['name'],
        amount: budgetSnap.docs.first['amount'].toDouble(),
        category: budgetSnap.docs.first['category'],
      );
      // Sum all transactions for this category this month
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final txSnap = await firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .where('category', isEqualTo: EncryptionService.encryptText(category))
          .get();
      double total = 0;
      for (var doc in txSnap.docs) {
        final txDate =
            DateTime.tryParse(EncryptionService.decryptText(doc['date']));
        if (txDate != null &&
            txDate.isAfter(startOfMonth.subtract(const Duration(days: 1)))) {
          total +=
              double.tryParse(EncryptionService.decryptText(doc['amount'])) ??
                  0;
        }
      }
      final percent = total / budget.amount;
      if (percent >= 1.0) {
        _showBudgetAlert(
            'Overspending! You have exceeded your budget for $category.',
            onBudgetAlert);
      } else if (percent >= 0.8) {
        _showBudgetAlert(
            'Warning: You are approaching your budget limit for $category.',
            onBudgetAlert);
      }
    } on FirebaseException catch (e) {
      debugPrint('Error checking budget: ${e.code} - ${e.message}');
      // Silently fail budget check - don't block transaction addition
    } catch (e) {
      debugPrint('Error checking budget: $e');
      // Silently fail budget check - don't block transaction addition
    }
  }

  void _showBudgetAlert(String message, [BudgetAlertCallback? onBudgetAlert]) {
    if (onBudgetAlert != null) {
      onBudgetAlert(message);
    } else {
      debugPrint(message);
    }
  }
}

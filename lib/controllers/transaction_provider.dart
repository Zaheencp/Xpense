import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _availableBalance = 0.0;
  double _income = 0.0;
  double _expenses = 0.0;

  List<TransactionModel> get transactions => _transactions;
  double get availableBalance => _availableBalance;
  double get income => _income;
  double get expenses => _expenses;

  // Initialize from shared preferences
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _availableBalance = prefs.getDouble('available_balance') ?? 0.0;
    _income = prefs.getDouble('income') ?? 0.0;
    _expenses = prefs.getDouble('expenses') ?? 0.0;
    notifyListeners();
  }

  // Update balances when a transaction is removed
  void updateBalancesOnDelete(double amount, bool isExpense) {
    if (isExpense) {
      _expenses += amount; // amount is negative for expenses
    } else {
      _income -= amount;
    }
    _availableBalance = _income - _expenses;
    _saveToPrefs();
    notifyListeners();
  }

  // Save to shared preferences
  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('available_balance', _availableBalance);
    await prefs.setDouble('income', _income);
    await prefs.setDouble('expenses', _expenses);
  }

  void setTransactions(List<TransactionModel> transactions) {
    _transactions = transactions;
    _recalculateBalances();
    notifyListeners();
  }

  void addTransaction(TransactionModel transaction) {
    _transactions.add(transaction);
    _updateBalances(transaction, isAdding: true);
    notifyListeners();
    _saveToPrefs();
  }

  void removeTransaction(String id) {
    final transactionIndex = _transactions.indexWhere((t) => t.id == id);
    if (transactionIndex != -1) {
      final transaction = _transactions[transactionIndex];
      final isExpense = transaction.amount < 0;

      // Update balances
      if (isExpense) {
        _expenses += transaction.amount; // amount is negative for expenses
      } else {
        _income -= transaction.amount;
      }
      _availableBalance = _income - _expenses;

      // Remove the transaction
      _transactions.removeAt(transactionIndex);

      // Save changes and notify listeners
      _saveToPrefs();
      notifyListeners();
    }
  }

  void _updateBalances(TransactionModel transaction, {required bool isAdding}) {
    final amount = transaction.amount;
    final isIncome = ![
      'food',
      'transportation',
      'bills',
      'home',
      'car',
      'entertainment',
      'shopping',
      'clothing',
      'insurance',
      'cigarette',
      'telephone',
      'health',
      'sports',
      'baby',
      'pet',
      'education',
      'travel',
      'gift'
    ].contains(transaction.category.toLowerCase());

    if (isAdding) {
      if (isIncome) {
        _income += amount;
        _availableBalance += amount;
      } else {
        _expenses += amount;
        _availableBalance -= amount;
      }
    } else {
      if (isIncome) {
        _income -= amount;
        _availableBalance -= amount;
      } else {
        _expenses -= amount;
        _availableBalance += amount;
      }
    }
  }

  void _recalculateBalances() {
    _income = 0.0;
    _expenses = 0.0;

    for (var transaction in _transactions) {
      final amount = transaction.amount;
      final isIncome = ![
        'food',
        'transportation',
        'bills',
        'home',
        'car',
        'entertainment',
        'shopping',
        'clothing',
        'insurance',
        'cigarette',
        'telephone',
        'health',
        'sports',
        'baby',
        'pet',
        'education',
        'travel',
        'gift'
      ].contains(transaction.category.toLowerCase());

      if (isIncome) {
        _income += amount;
      } else {
        _expenses += amount;
      }
    }

    _availableBalance = _income - _expenses;
  }

  void clearTransactions() {
    _transactions.clear();
    _availableBalance = 0.0;
    _income = 0.0;
    _expenses = 0.0;
    _saveToPrefs();
    notifyListeners();
  }

  // Method to update balances when a transaction is deleted
  void deleteAndUpdateBalances(bool isEmpty) {
    if (isEmpty) {
      _availableBalance = 0.0;
      _expenses = 0.0;
      _income = 0.0;
    }
    _saveToPrefs();
    notifyListeners();
  }
}

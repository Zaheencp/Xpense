import 'package:flutter/material.dart';
import '../models/bank_account_model.dart';

class BankAccountProvider extends ChangeNotifier {
  List<BankAccountModel> _accounts = [];

  List<BankAccountModel> get accounts => _accounts;

  void setAccounts(List<BankAccountModel> accounts) {
    _accounts = accounts;
    notifyListeners();
  }

  void addAccount(BankAccountModel account) {
    _accounts.add(account);
    notifyListeners();
  }

  void removeAccount(String accountId) {
    _accounts.removeWhere((acc) => acc.id == accountId);
    notifyListeners();
  }
}

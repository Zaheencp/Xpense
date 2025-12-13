import 'package:flutter/material.dart';

class BankAccountTile extends StatelessWidget {
  final String accountName;
  final String accountNumber;

  const BankAccountTile(
      {super.key, required this.accountName, required this.accountNumber});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(accountName),
      subtitle: Text('Account: $accountNumber'),
    );
  }
}

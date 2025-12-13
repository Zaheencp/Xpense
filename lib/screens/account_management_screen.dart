import 'package:flutter/material.dart';
// SMS auto-expense feature removed

class AccountManagementScreen extends StatelessWidget {
  const AccountManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Accounts')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Manage account settings'),
          ],
        ),
      ),
    );
  }
}

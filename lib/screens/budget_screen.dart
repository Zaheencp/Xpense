import 'package:flutter/material.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgeting Tools')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet,
                size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text('Set your budget goals',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Create Budget'),
            ),
          ],
        ),
      ),
    );
  }
}

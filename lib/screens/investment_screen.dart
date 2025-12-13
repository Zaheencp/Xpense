import 'package:flutter/material.dart';

class InvestmentScreen extends StatelessWidget {
  const InvestmentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Investments')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.trending_up, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            const Text('Track your investments',
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
              child: const Text('Link Investment Account'),
            ),
          ],
        ),
      ),
    );
  }
}

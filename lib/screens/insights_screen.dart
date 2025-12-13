import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.insights, size: 80, color: Colors.pinkAccent),
            const SizedBox(height: 20),
            const Text('Personalized Insights',
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
              child: const Text('Get Recommendations'),
            ),
          ],
        ),
      ),
    );
  }
}

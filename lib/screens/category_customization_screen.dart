import 'package:flutter/material.dart';

class CategoryCustomizationScreen extends StatelessWidget {
  const CategoryCustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom Categories')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.category, size: 80, color: Colors.teal),
            const SizedBox(height: 20),
            const Text('Create your own categories',
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
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }
}

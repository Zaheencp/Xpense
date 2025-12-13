import 'package:flutter/material.dart';

class Heading extends StatelessWidget {
  final String title;

  const Heading({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';

class Textbuttonwidget extends StatelessWidget {
  final String firsttext;
  final VoidCallback ontap;
  final String buttontext;

  const Textbuttonwidget({
    super.key,
    required this.firsttext,
    required this.ontap,
    required this.buttontext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(firsttext, style: const TextStyle(color: Colors.white)),
        TextButton(
            onPressed: ontap,
            child: Text(
              buttontext,
              style: const TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}

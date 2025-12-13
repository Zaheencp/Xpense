import 'package:flutter/material.dart';

class Button extends StatelessWidget {
  final VoidCallback ontap;
  final IconData icon;
  final Color colors;
  final String title;

  const Button(
      {super.key,
      required this.ontap,
      required this.colors,
      required this.icon,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 40,
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 9, 236, 206),
          borderRadius: BorderRadius.circular(20)),
      child: ElevatedButton(
        onPressed: ontap,
        style: ElevatedButton.styleFrom(backgroundColor: colors),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.black, fontSize: 18),
            ),
            const SizedBox(
              width: 20,
            ),
            Icon(
              icon,
              color: Colors.black,
              size: 30,
            )
          ],
        ),
      ),
    );
  }
}

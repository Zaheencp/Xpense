import 'package:flutter/material.dart';

class Drawertile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback ontap;

  const Drawertile({
    super.key,
    required this.title,
    required this.icon,
    required this.ontap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: ontap,
        tileColor: const Color.fromARGB(255, 26, 25, 25),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        trailing: Icon(
          icon,
          color: Colors.white,
        ),
      ),
    );
  }
}

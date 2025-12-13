import 'package:flutter/material.dart';

class Googlebutton extends StatelessWidget {
  final VoidCallback onclick;

  const Googlebutton({
    super.key,
    required this.onclick,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onclick,
      child: Container(
        width: 50,
        height: 40,
        decoration: BoxDecoration(
            color: Colors.black, borderRadius: BorderRadius.circular(4)),
        child: Center(child: Image.asset('assets/images/g.png')),
      ),
    );
  }
}

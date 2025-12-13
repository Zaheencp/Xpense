import 'package:flutter/material.dart';

class Textfieldwidget extends StatelessWidget {
  final String hinttext;
  final TextEditingController? controller;

  const Textfieldwidget({
    super.key,
    required this.hinttext,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      cursorColor: Colors.black,
      decoration: InputDecoration(
          filled: true,
          fillColor: Colors.grey,
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(30)),
          hintText: hinttext,
          hintStyle: const TextStyle(color: Colors.white),
          border: OutlineInputBorder(
              borderSide: const BorderSide(),
              borderRadius: BorderRadius.circular(30))),
    );
  }
}

import 'package:flutter/material.dart';

class Transactions extends StatelessWidget {
  final String hintText;
  final VoidCallback onclick;
  final IconData icons;
  final TextInputType? type;
  final TextEditingController? controller;
  final String? initialvalue;

  const Transactions({
    super.key,
    required this.onclick,
    required this.icons,
    required this.hintText,
    this.type,
    required this.controller,
    this.initialvalue,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: type,
      cursorColor: Colors.black,
      decoration: InputDecoration(
          //  helperStyle: TextStyle(color: Colors.white),
          //  focusColor: Colors.amber,
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.transparent),
              borderRadius: BorderRadius.circular(20)),
          hoverColor: Colors.transparent,
          fillColor: Colors.blueGrey[900],
          filled: true,
          suffixIconColor: Colors.black,
          // suffix: InkWell(
          //     onTap: onclick,
          //     child: Icon(
          //       icons,
          //       color: Colors.white,
          //     )),
          suffixIcon: InkWell(onTap: onclick, child: Icon(icons)),
          //  suffixIconConstraints: BoxConstraints(),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.green, width: 3)),
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white)),
    );
  }
}

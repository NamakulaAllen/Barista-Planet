import 'package:flutter/material.dart';

class TextInputWidget extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final FocusNode? focusNode;

  const TextInputWidget({
    super.key,
    this.focusNode,
    this.controller,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20), gapPadding: 8),
        hintText: hintText,
        filled: true,
        fillColor: Colors.blueGrey,
      ),
    );
  }
}

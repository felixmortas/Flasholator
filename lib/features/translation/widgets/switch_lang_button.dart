import 'package:flutter/material.dart';

class SwitchLangButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SwitchLangButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.swap_horiz),
    );
  }
}

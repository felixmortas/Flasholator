import 'package:flutter/material.dart';

class SwitchLangButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SwitchLangButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.swap_horiz),
    );
  }
}

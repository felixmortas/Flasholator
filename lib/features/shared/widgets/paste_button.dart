import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PasteButton extends StatelessWidget {
  final TextEditingController controller;

  const PasteButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        backgroundColor: Colors.blue.shade100, // couleur de fond
        foregroundColor: Colors.black, // couleur du texte & icône
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      onPressed: () async {
        final data = await Clipboard.getData(Clipboard.kTextPlain);
        if (data != null) {
          controller.text = data.text ?? '';
        }
      },
      icon: const Icon(Icons.paste),
      label: const Text("Coller"),
    );

  }
}

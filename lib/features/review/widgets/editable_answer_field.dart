import 'package:flutter/material.dart';

class EditableAnswerField extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final TextEditingController controller;

  const EditableAnswerField({
    Key? key,
    required this.isEditing,
    required this.onToggleEditing,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (isEditing)
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Votre réponse...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        IconButton(
          icon: Icon(isEditing ? Icons.close : Icons.edit),
          onPressed: onToggleEditing,
        ),
      ],
    );
  }
}

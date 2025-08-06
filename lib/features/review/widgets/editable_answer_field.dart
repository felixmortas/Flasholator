import 'package:flutter/material.dart';

import 'package:flasholator/l10n/app_localizations.dart';

class EditableAnswerField extends StatelessWidget {
  final bool isDue;
  final bool isEditing;
  final VoidCallback onToggleEditing;
  final TextEditingController controller;

  const EditableAnswerField({
    Key? key,
    required this.isDue,
    required this.isEditing,
    required this.onToggleEditing,
    required this.controller,
  }) : super(key: key);

  @override
Widget build(BuildContext context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      if (isDue) ...[
        if (isEditing)
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.writeYourResponseHere,
                border: OutlineInputBorder(),
              ),
            ),
          ),
        IconButton(
          icon: Icon(isEditing ? Icons.close : Icons.edit),
          onPressed: onToggleEditing,
        ),
      ],
    ],
  );
}

}
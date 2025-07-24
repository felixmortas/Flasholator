import 'package:flasholator/l10n/app_localizations_en.dart';

import '../../../l10n/app_localizations.dart';
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
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
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
  );
}

}
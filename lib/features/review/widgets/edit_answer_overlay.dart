import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class EditAnswerOverlay extends StatelessWidget {
  final bool isExpanded;
  final TextEditingController controller;

  const EditAnswerOverlay({
    Key? key,
    required this.isExpanded,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isExpanded ? 120 : 20,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 5,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: Colors.grey[400],
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // TextField (affiché seulement si expanded)
          if (isExpanded)
            Expanded(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!.writeYourResponseHere,
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 18.0),
                  maxLines: null, // Permet plusieurs lignes
                  textInputAction: TextInputAction.done,
                  onTap: () {
                    // S'assurer que le TextField est focalisé correctement
                    FocusScope.of(context).requestFocus();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
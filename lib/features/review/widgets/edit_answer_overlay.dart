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
      curve: Curves.easeOut,
      constraints: BoxConstraints(
        minHeight: 20,
        maxHeight: isExpanded ? 120 : 20,
      ),
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
      child: SafeArea(
        top: false,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Barre de drag handle
          Center(
            child: Container(
              width: 40,
              height: 5,
              margin: EdgeInsets.only(top: 8, bottom: isExpanded ? 16 : 7),
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          
          if (isExpanded) ...[
            Flexible(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.writeYourResponseHere,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                ),
                style: const TextStyle(fontSize: 18.0),
              ),
            ),),
          ],
        ],
      ),),
    );
  }
}
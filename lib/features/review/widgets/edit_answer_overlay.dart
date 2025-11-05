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
      height: isExpanded ? 100 : 0,
      width: double.infinity,
      child: isExpanded
          ? Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),                
              ),
              child: TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,  
                  enabledBorder: InputBorder.none,
                  hintText: AppLocalizations.of(context)!.writeYourResponseHere,
                  hintStyle: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                  ),
                  isDense: true,
                ),
                style: const TextStyle(fontSize: 18.0),
                maxLines: null,
                textInputAction: TextInputAction.done,
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}
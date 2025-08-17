import 'package:flutter/material.dart';

class BottomBlock extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String translatedWord;
  final bool isTranslateButtonDisabled;
  final bool isAddButtonDisabled;
  final VoidCallback onClear;
  final VoidCallback onTranslate;
  final VoidCallback onAdd;

  const BottomBlock({
    super.key,
    required this.controller,
    required this.hintText,
    required this.translatedWord,
    required this.isTranslateButtonDisabled,
    required this.isAddButtonDisabled,
    required this.onClear,
    required this.onTranslate,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      child: Container(
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Barre de drag handle
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // --- Input avec bouton clear
            Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  textAlign: TextAlign.left,
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                    hintStyle: TextStyle(
                      color: Colors.grey.withOpacity(0.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  maxLength: 100,
                ),
                IconButton(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --- Texte traduit
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                translatedWord,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: isTranslateButtonDisabled ? null : onTranslate,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Traduire"),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isAddButtonDisabled ? null : onAdd,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Ajouter"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class AllLanguagesSwitch extends StatelessWidget {
  final ValueNotifier<bool> isAllLanguagesToggledNotifier;
  final void Function(bool) onToggle;

  const AllLanguagesSwitch({
    Key? key,
    required this.isAllLanguagesToggledNotifier,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isAllLanguagesToggledNotifier,
      builder: (context, value, child) {
        return GestureDetector(
          onTap: () => onToggle(!value),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              boxShadow: value
                  ? [
                      // Ombre réduite pour l'effet enfoncé
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ]
                  : [],
            ),
            child: Icon(
              Icons.language,
              color: value ? Colors.blue.shade700 : Colors.grey.shade600,
              size: 24,
            ),
          ),
        );
      },
    );
  }
}
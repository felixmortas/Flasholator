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
        return Switch(
          value: value,
          onChanged: onToggle,
        );
      },
    );
  }
}

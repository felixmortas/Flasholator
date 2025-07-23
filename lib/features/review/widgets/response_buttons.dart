import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ResponseButtons extends StatelessWidget {
  final bool isResponseHidden;
  final bool isDue;
  final VoidCallback onDisplayAnswer;
  final void Function(int) onQualityPress;

  const ResponseButtons({
    Key? key,
    required this.isResponseHidden,
    required this.isDue,
    required this.onDisplayAnswer,
    required this.onQualityPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isResponseHidden && isDue)
          ElevatedButton(
            onPressed: onDisplayAnswer,
            child: Text(AppLocalizations.of(context)!.displayAnswer),
          ),
        if (!isResponseHidden)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.again,
                Colors.red,
                () => onQualityPress(2),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.hard,
                Colors.grey,
                () => onQualityPress(3),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.correct,
                Colors.green,
                () => onQualityPress(4),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.easy,
                Colors.blue,
                () => onQualityPress(5),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildQualityButton(
      BuildContext context, String label, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(backgroundColor: color),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white),
          softWrap: false,
          overflow: TextOverflow.visible,
          maxLines: 1,
        ),
      ),
    );
  }
}

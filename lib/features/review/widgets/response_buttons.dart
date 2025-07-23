import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

import 'package:flutter/material.dart';

class ReviewControls extends StatelessWidget {
  final bool isResponseHidden;
  final bool isDue;
  final bool overrideDisplayWithResult;
  final int? overrideQuality;
  final VoidCallback onDisplayAnswer;
  final void Function(int) onQualityPress;

  const ReviewControls({
    Key? key,
    required this.isResponseHidden,
    required this.isDue,
    required this.overrideDisplayWithResult,
    required this.overrideQuality,
    required this.onDisplayAnswer,
    required this.onQualityPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (isResponseHidden && isDue && !overrideDisplayWithResult)
          ElevatedButton(
            onPressed: onDisplayAnswer,
            child: Text(AppLocalizations.of(context)!.displayAnswer),
          ),
        if (overrideDisplayWithResult && overrideQuality != null)
          ElevatedButton(
            onPressed: () => onQualityPress(overrideQuality!),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getColorForQuality(overrideQuality!),
            ),
            child: Text(_getLabelForQuality(context, overrideQuality!)),
          ),
        if (!isResponseHidden && !overrideDisplayWithResult)
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
    BuildContext context,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
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

  Color _getColorForQuality(int quality) {
    switch (quality) {
      case 2:
        return Colors.red;
      case 3:
        return Colors.grey;
      case 4:
        return Colors.green;
      case 5:
        return Colors.blue;
      default:
        return Colors.black;
    }
  }

  String _getLabelForQuality(BuildContext context, int quality) {
    switch (quality) {
      case 2:
        return AppLocalizations.of(context)!.again;
      case 3:
        return AppLocalizations.of(context)!.hard;
      case 4:
        return AppLocalizations.of(context)!.correct;
      case 5:
        return AppLocalizations.of(context)!.easy;
      default:
        return '';
    }
  }
}

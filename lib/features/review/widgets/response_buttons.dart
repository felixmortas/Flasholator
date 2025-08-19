import 'package:flutter/material.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class ReviewControls extends StatefulWidget {
  final bool isResponseHidden;
  final bool overrideDisplayWithResult;
  final int? overrideQuality;
  final void Function(int) onQualityPress;


  const ReviewControls({
    Key? key,
    required this.isResponseHidden,
    required this.overrideDisplayWithResult,
    required this.overrideQuality,
    required this.onQualityPress,

  }) : super(key: key);

  @override
  State<ReviewControls> createState() => _ReviewControlsState();
}

class _ReviewControlsState extends State<ReviewControls> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.overrideDisplayWithResult && widget.overrideQuality != null)
          // Case: Written answer is incorrect
          if (widget.overrideQuality == 2)
            ElevatedButton(
              onPressed: () => widget.onQualityPress(widget.overrideQuality!),
              style: ElevatedButton.styleFrom(
                backgroundColor: _getColorForQuality(widget.overrideQuality!),
              ),
              child: Text(_getLabelForQuality(context, widget.overrideQuality!)),
            )
          // Case: Written answer is correct
          else if (widget.overrideQuality == 4)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQualityButton(
                  context,
                  AppLocalizations.of(context)!.hard,
                  Colors.grey,
                  () => widget.onQualityPress(3), // Quality 3 for 'hard'
                ),
                _buildQualityButton(
                  context,
                  AppLocalizations.of(context)!.correct,
                  Colors.green,
                  () => widget.onQualityPress(4), // Quality 4 for 'correct'
                ),
                _buildQualityButton(
                  context,
                  AppLocalizations.of(context)!.easy,
                  Colors.blue,
                  () => widget.onQualityPress(5), // Quality 5 for 'easy'
                ),
              ],
            ),

        if (!widget.isResponseHidden && !widget.overrideDisplayWithResult)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.again,
                Colors.red,
                () => widget.onQualityPress(2),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.hard,
                Colors.grey,
                () => widget.onQualityPress(3),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.correct,
                Colors.green,
                () => widget.onQualityPress(4),
              ),
              _buildQualityButton(
                context,
                AppLocalizations.of(context)!.easy,
                Colors.blue,
                () => widget.onQualityPress(5),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
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

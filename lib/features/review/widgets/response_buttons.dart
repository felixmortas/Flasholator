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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQualityButton(
                  context,
                  AppLocalizations.of(context)!.again,
                  Colors.red,
                  () => widget.onQualityPress(2),
                ),
              ],
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
      child: DragTarget<int>(
        onWillAccept: (data) => data == 1, // accepte seulement les cartes réponses
        onAccept: (_) => onPressed(),
        builder: (context, candidateData, rejectedData) {
          final isHovered = candidateData.isNotEmpty;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isHovered ? color.withOpacity(0.7) : color,
              ),
              child: Text(
                label,
                style: const TextStyle(color: Colors.white),
                softWrap: false,
                overflow: TextOverflow.visible,
                maxLines: 1,
              ),
            ),
          );
        },
      ),
    );
  }
}
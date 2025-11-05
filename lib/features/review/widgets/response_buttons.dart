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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          if (widget.overrideDisplayWithResult && widget.overrideQuality != null)
            // Case: Written answer is incorrect
            if (widget.overrideQuality == 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEraserQualityButton(
                    context,
                    AppLocalizations.of(context)!.again,
                    [Colors.red.shade300, Colors.red.shade200],
                    Colors.red.shade700,
                    Colors.red.shade900,
                    () => widget.onQualityPress(2),
                  ),
                ],
              )
            // Case: Written answer is correct
            else if (widget.overrideQuality == 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEraserQualityButton(
                    context,
                    AppLocalizations.of(context)!.hard,
                    [Colors.grey.shade300, Colors.grey.shade200],
                    Colors.grey.shade700,
                    Colors.grey.shade900,
                    () => widget.onQualityPress(3), // Quality 3 for 'hard'
                  ),
                  _buildEraserQualityButton(
                    context,
                    AppLocalizations.of(context)!.correct,
                    [Colors.green.shade300, Colors.green.shade200],
                    Colors.green.shade700,
                    Colors.green.shade900,
                    () => widget.onQualityPress(4), // Quality 4 for 'correct'
                  ),
                  _buildEraserQualityButton(
                    context,
                    AppLocalizations.of(context)!.easy,
                    [Colors.blue.shade300, Colors.blue.shade200],
                    Colors.blue.shade700,
                    Colors.blue.shade900,
                    () => widget.onQualityPress(5), // Quality 5 for 'easy'
                  ),
                ],
              ),

          if (!widget.isResponseHidden && !widget.overrideDisplayWithResult)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildEraserQualityButton(
                  context,
                  AppLocalizations.of(context)!.again,
                  [Colors.red.shade300, Colors.red.shade200],
                  Colors.red.shade700,
                  Colors.red.shade900,
                  () => widget.onQualityPress(2),
                ),
                _buildEraserQualityButton(
                  context,
                  AppLocalizations.of(context)!.hard,
                  [Colors.grey.shade300, Colors.grey.shade200],
                  Colors.grey.shade700,
                  Colors.grey.shade900,
                  () => widget.onQualityPress(3),
                ),
                _buildEraserQualityButton(
                  context,
                  AppLocalizations.of(context)!.correct,
                  [Colors.green.shade300, Colors.green.shade200],
                  Colors.green.shade700,
                  Colors.green.shade900,
                  () => widget.onQualityPress(4),
                ),
                _buildEraserQualityButton(
                  context,
                  AppLocalizations.of(context)!.easy,
                  [Colors.blue.shade300, Colors.blue.shade200],
                  Colors.blue.shade700,
                  Colors.blue.shade900,
                  () => widget.onQualityPress(5),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildEraserQualityButton(
    BuildContext context,
    String label,
    List<Color> gradientColors,
    Color iconColor,
    Color textColor,
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
            child: Container(
              decoration: BoxDecoration(
                // Dégradé de couleur pastel comme une gomme
                gradient: LinearGradient(
                  colors: isHovered
                      ? gradientColors.map((c) => c.withOpacity(0.7)).toList()
                      : gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Bordure arrondie douce
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPressed,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    alignment: Alignment.center,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                      softWrap: false,
                      overflow: TextOverflow.visible,
                      maxLines: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
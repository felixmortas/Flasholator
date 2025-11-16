import 'package:flutter/material.dart';

import 'package:flasholator/config/constants.dart';
import 'package:flasholator/features/shared/widgets/eraser_button.dart';
import 'package:flasholator/features/shared/widgets/bottom_overlay.dart';
import 'package:flasholator/features/shared/widgets/big_post_it.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/style/grid_background_painter.dart';

class ReviewPageEmpty extends StatelessWidget {
  const ReviewPageEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return GridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24 * GOLDEN_NUMBER),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    // Un seul gros post-it avec les 3 textes
                    BigPostIt(
                      title: AppLocalizations.of(context)!.congratulationsOnYourWork,
                      subtitle: AppLocalizations.of(context)!.noCardsToReview,
                      callToAction: AppLocalizations.of(context)!.keepProgressing,
                      postItColor: Colors.yellow.shade100,
                      width: screenWidth * 0.85,
                      height: 280,
                    ),
                    const SizedBox(height: 30),
                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: EraserButton(
                            onPressed: () {},
                            label: AppLocalizations.of(context)!.translate,
                            gradientColors: [
                              Colors.pink.shade200,
                              Colors.pink.shade100,
                            ],
                            iconColor: Colors.pink.shade700,
                            textColor: Colors.pink.shade900,
                            isDisabled: false,
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: EraserButton(
                            onPressed: () {},
                            label: AppLocalizations.of(context)!.add,
                            gradientColors: [
                              Colors.blue.shade200,
                              Colors.blue.shade100,
                            ],
                            iconColor: Colors.blue.shade700,
                            textColor: Colors.blue.shade900,
                            isDisabled: false,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
            // Bloc bas
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: 100,
                  maxHeight: screenHeight * 0.2,
                ),
                child: BottomBlock(
                  showDragHandle: true,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 20 * GOLDEN_NUMBER)
                                .copyWith(bottom: 20 * GOLDEN_NUMBER),
                        child: Text(
                          AppLocalizations.of(context)!.coolAIFeatureComingSoon,
                          style: const TextStyle(
                            fontSize: 16 * GOLDEN_NUMBER,
                            color: Colors.black87,
                            height: 1.4,
                            fontFamily: 'MomoSignature',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
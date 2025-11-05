import 'package:flasholator/style/grid_background_painter.dart';
import 'package:flutter/material.dart';
import 'package:flasholator/features/shared/widgets/bottom_overlay.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class ReviewPageEmpty extends StatelessWidget {
  const ReviewPageEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return GridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24 * GOLDEN_NUMBER),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Message encourageant
                    Text(
                      AppLocalizations.of(context)!.congratulationsOnYourWork,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),
                    // Annonce pas de carte
                    Text(
                      AppLocalizations.of(context)!.noCardsToReview,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Call to action
                    Text(
                      AppLocalizations.of(context)!.keepProgressing,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    // Boutons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.translate,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            backgroundColor: Colors.orangeAccent,
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.add,
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    Spacer(), // pousse tout vers le haut pour le bloc bas
                  ],
                ),
              ),
            ),
            // Bloc bas
            Align(
              alignment: Alignment.bottomCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // minHeight pour qu’il soit visible
                  minHeight: 100,
                  // maxHeight = 32% de l’écran
                  maxHeight: screenHeight * 0.35,
                ),
                child: BottomBlock(
                  showDragHandle: true,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20 * GOLDEN_NUMBER)
                                .copyWith(bottom: 20 * GOLDEN_NUMBER),
                        child: Text(
                          AppLocalizations.of(context)!.coolAIFeatureComingSoon,
                          style: TextStyle(
                            fontSize: 16 * GOLDEN_NUMBER,
                            color: Colors.black87,
                            height: 1.4,
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
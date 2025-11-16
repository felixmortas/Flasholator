import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                  maxHeight: screenHeight * 0.333,
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

  Widget _buildBigPostIt(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String callToAction,
    required Color postItColor,
    required double width,
    required double height,
  }) {
    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.015)
        ..rotateZ(-0.03),
      alignment: Alignment.bottomCenter,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: postItColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, 1),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 4,
              offset: const Offset(2, 3),
              spreadRadius: -1,
            ),
          ],
        ),
        child: Column(
          children: [
            // Bande adhésive en haut
            Container(
              height: 12,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _getDarkerShade(postItColor, 0.4),
                    _getDarkerShade(postItColor, 0.25),
                    _getDarkerShade(postItColor, 0.1),
                  ],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getDarkerShade(postItColor, 0.15),
                    blurRadius: 1,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
            ),
            // Contenu du post-it
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 24.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Titre (première phrase)
                    Text(
                      title,
                      style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                            fontFamily: 'MomoSignature',
                            height: 1.3,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Sous-titre (deuxième phrase)
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey.shade700,
                        letterSpacing: 0.2,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Call to action (troisième phrase)
                    Text(
                      callToAction,
                      style: GoogleFonts.poppins(
                        fontSize: 15.0,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                        letterSpacing: 0.2,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
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

  Color _getDarkerShade(Color color, double opacity) {
    final hsl = HSLColor.fromColor(color);
    final darkened = hsl.withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0));
    return darkened.toColor().withOpacity(opacity);
  }
}
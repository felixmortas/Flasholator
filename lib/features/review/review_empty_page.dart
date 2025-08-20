import 'package:flutter/material.dart';
import 'widgets/bottom_overlay_block.dart';

import 'package:flasholator/config/constants.dart';

class ReviewPageEmpty extends StatelessWidget {
  const ReviewPageEmpty({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * GOLDEN_NUMBER),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 40 * GOLDEN_NUMBER),
                  // Message encourageant
                  Text(
                    "Bravo pour ton travail !",
                    style: TextStyle(
                      fontSize: 28 * GOLDEN_NUMBER,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20 * GOLDEN_NUMBER),
                  // Annonce pas de carte
                  Text(
                    "Tu n'as plus de carte à réviser pour le moment.",
                    style: TextStyle(
                      fontSize: 18 * GOLDEN_NUMBER,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30 * GOLDEN_NUMBER),
                  // Call to action
                  Text(
                    "Continue à progresser : traduis et ajoute de nouveaux mots !",
                    style: TextStyle(
                      fontSize: 16 * GOLDEN_NUMBER,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30 * GOLDEN_NUMBER),
                  // Boutons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24 * GOLDEN_NUMBER,
                              vertical: 14 * GOLDEN_NUMBER),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Traduire",
                          style: TextStyle(fontSize: 16 * GOLDEN_NUMBER),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 24 * GOLDEN_NUMBER,
                              vertical: 14 * GOLDEN_NUMBER),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                        child: Text(
                          "Ajouter des mots",
                          style: TextStyle(fontSize: 16 * GOLDEN_NUMBER),
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
          const BottomEmptyReviewOverlay(
            content:
                "Ce bloc te permet de voir les détails ou conseils pour améliorer ton apprentissage.",
          ),
        ],
      ),
    );
  }
}

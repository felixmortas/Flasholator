import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';

class WordsDisplay extends StatelessWidget {
  final String questionLang;
  final String questionText;
  final String responseLang;
  final String responseText;
  final bool isResponseHidden;
  final bool isDue;

  const WordsDisplay({
    Key? key,
    required this.questionLang,
    required this.questionText,
    required this.responseLang,
    required this.responseText,
    required this.isResponseHidden,
    required this.isDue,
  }) : super(key: key);

@override
Widget build(BuildContext context) {
  // Calculer la largeur optimale basée sur le ratio d'or
  final screenWidth = MediaQuery.of(context).size.width;
  final cardWidth = screenWidth / GOLDEN_NUMBER;
  
  // Proportions d'une carte à jouer standard (environ 2.5:3.5 ou 5:7)
  final cardHeight = cardWidth / 1.4;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Card(
            child: Stack(
              children: [
                // langTag positionné en haut à gauche, peu visible
                Positioned(
                  top: 8.0,
                  left: 8.0,
                  child: Text(
                    questionLang,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Arial',
                      color: Color.fromARGB(100, 150, 150, 150), // Très peu visible
                    ),
                  ),
                ),
                // Mot centré au milieu de la carte
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      questionText,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
  
      const SizedBox(height: 16.0),
      Container(height: 1.0, color: Colors.grey),
      const SizedBox(height: 16.0),
      Center(
        child: SizedBox(
          width: cardWidth,
          height: cardHeight,
          child: Card(
            child: Stack(
              children: [
                // langTag positionné en haut à gauche, peu visible
                Visibility(
                  visible: isDue,
                  child: Positioned(
                    top: 8.0,
                    left: 8.0,
                    child: Text(
                      responseLang,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'Arial',
                      color: Color.fromARGB(100, 150, 150, 150), // Très peu visible
                    ),
                  ),
                ),
                ),
                // Mot centré au milieu de la carte
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Visibility(
                      visible: !isResponseHidden,
                      child:Text(
                        responseText,
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      ],
    );
  }
}

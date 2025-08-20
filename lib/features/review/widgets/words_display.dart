import 'package:flutter/material.dart';
import 'package:flasholator/config/constants.dart';

class WordsDisplay extends StatelessWidget {
  final String questionLang;
  final String questionText;
  final String responseLang;
  final String responseText;
  final bool isResponseHidden;
  final VoidCallback onDisplayAnswer;

  const WordsDisplay({
    Key? key,
    required this.questionLang,
    required this.questionText,
    required this.responseLang,
    required this.responseText,
    required this.isResponseHidden,
    required this.onDisplayAnswer,
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
            child: Draggable<int>(
              data: 1, // identifiant générique, peu importe ici
              maxSimultaneousDrags: isResponseHidden ? 0 : 1,
              feedback: Material(
                color: Colors.transparent,
                child: Card(
                  elevation: 8,
                  child: SizedBox(
                    width: cardWidth,
                    height: cardHeight,
                    child: Center(
                      child: Text(
                        responseText,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
              childWhenDragging: const Opacity(
                opacity: 0.3,
                child: Card(
                  child: Center(
                    child: Icon(
                      Icons.touch_app,
                      size: 48.0,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              child: GestureDetector( // Ajout du GestureDetector
                onTap: isResponseHidden ? onDisplayAnswer : null,
                child: Card(
                  child: Stack(
                    children: [
                      // langTag positionné en haut à gauche, peu visible
                      Positioned(
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
                      if (isResponseHidden)
                        const Center(
                          child: Icon(
                            Icons.touch_app,
                            size: 48.0,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

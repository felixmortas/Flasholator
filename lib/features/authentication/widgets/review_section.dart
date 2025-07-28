import 'package:flutter/material.dart';

import 'review_card.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Témoignages :',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        ReviewCard(
          author: 'Marie',
          role: 'Étudiante en langues',
          content: "Flasholator a transformé mon apprentissage de l'espagnol. Grâce à la révision quotidienne et à l'IA qui s'adapte à mes difficultés, j'ai vu une amélioration significative en seulement quelques semaines. C'est comme avoir un professeur personnel dans ma poche !",
        ),
        ReviewCard(
          author: 'Thomas',
          role: 'Voyageur fréquent',
          content: "En tant que voyageur, apprendre les bases des langues locales est crucial. Flasholator m'a permis de traduire et mémoriser des phrases essentielles rapidement. La fonction de groupe de mots est particulièrement utile pour organiser mon vocabulaire par thème, comme \"restaurant\" ou \"transport\".",
        ),
        ReviewCard(
          author: 'Sophie',
          role: 'Professionnelle',
          content: "Je dois souvent lire des documents en anglais pour mon travail. Flasholator m'aide à traduire et retenir le vocabulaire technique rapidement. La synchronisation avec Google Drive signifie que je peux accéder à mes cartes de n'importe où, ce qui est indispensable pour moi.",
        ),
        ReviewCard(
          author: 'Émilie',
          role: 'Cuisinière passionnée',
          content: "J'utilise Flasholator pour apprendre l'italien en cuisinant avec des recettes italiennes. Pouvoir traduire instantanément les ingrédients et les techniques culinaires a rendu l'apprentissage de la langue aussi savoureux que les plats que je prépare !",
        ),
        ReviewCard(
          author: 'Julien',
          role: 'Fan de cinéma',
          content: "Regarder des films en version originale est bien plus agréable maintenant que je peux utiliser Flasholator pour traduire et mémoriser les dialogues. L'application a rendu l'apprentissage de l'anglais bien plus interactif et amusant.",
        ),
        ReviewCard(
          author: 'Camille',
          role: 'Étudiante ERASMUS',
          content: "Flasholator a été un compagnon indispensable pendant mon séjour Erasmus en Espagne. L'application m'a aidée à surmonter la barrière de la langue rapidement, me permettant de me faire des amis locaux et de profiter pleinement de mon expérience à l'étranger.",
        ),        // Ajoutez d'autres ReviewCard ici pour plus d'avis
      ],
    );
  }
}

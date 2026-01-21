# Flasholator

## Description

Vous êtes en voyage, à l'école, au travail, en train de regarder un film, de lire un livre ou les paroles d'une musique. Vous comprenez déjà un peu la langue, mais il vous manque du vocabulaire pour tout saisir. Votre premier réflexe ? Vous traduisez ! Et après ? Soit vous avez une très bonne mémoire et vous retenez tout après une lecture, soit, comme moi, vous avez besoin de répétition pour retenir.

Avec Flasholator, vous pouvez traduire les mots que vous ne connaissez pas et les ajouter à un jeu de cartes virtuelles. Ensuite, tous les jours, vous pouvez réviser les mots que vous avez traduits vous-même. C'est rapide, il suffit d'un clic, et l'IA vous propose de réviser plus souvent les mots sur lesquels vous avez du mal, et moins souvent ceux que vous maîtrisez facilement.

## Fonctionnalités

- **Traduction instantanée** : Traduisez rapidement les mots que vous ne connaissez pas avec DeepL.
- **Jeu de cartes virtuelles** : Ajoutez les traductions à un jeu de cartes pour une révision facile.
- **Révision quotidienne** : Réviser les mots tous les jours pour améliorer votre mémoire.
- **Apprentissage personnalisé** : L'application utilise un algortihme de révision à répétitions espacées pour vous proposer de réviser plus souvent les mots difficiles et moins souvent ceux que vous maîtrisez.

## Utilisation

1. Ouvrez l'application.
2. Traduisez les mots que vous ne connaissez pas.
3. Ajoutez les traductions à votre jeu de cartes virtuelles.
4. Réviser les mots tous les jours pour améliorer votre mémoire.

## Fonctionnalités premium 
- Pas de publicités
- Tous les couples de langues disponibles (vs 1 max)
- Réviser en vérifiant la réponse à l'écrit (vs dans sa tête)
- Créer des groupes de mots pour les révisions (ex. : vacances, bureau, cuisine).
- Import/Export des données de l'utilisateur.
- Synchronisation régulière des données de l'utilisateur sur son Google Drive

__[Ajouter captures d'écran et tuto]__

## Roadmap :
### Fonctionnalités :
- Barre de progression pour les cartes à réviser aujourd'hui
- Système de récompense quand cartes révisées tous les jours (jetons ? streak ?)
- Notifications de rappel cartes à réviser
- Achat de paquets de carte pré-fait par thème avec monnaie virtuelle
- Plusieurs résultats lors de la traduction.
- Prononciation

### Expérience utilisateur :
- Ajout indicateur carte nouvelle ou déjà révisée
- Tutoriel long et engageant pour l'utilisateur
- Améliorer fonction Android native traduire avec Flasholator et ajouter une carte depuis une autre appliation avec un popup comme DeepL ou Google Traduction

### Interface utilisateur :
- Ajouter une image dans l’onglet de révision pour inciter l’utilisateur à prononcer le mot (ex. : emoji qui pense ou parle).
- Ajouter un dark mode
- Ajouter des sons et animations à forte intensité (style Candy Crush)

## 🛠 Stack Technique & Architecture

L'application est construite avec une approche modulaire et scalable :

* **Framework (Multi-plateforme iOS/Android):** [Flutter](https://flutter.dev/) (v3.22.5)
* **Architecture :** **MVVM (Model-View-ViewModel)** pour une séparation claire de la logique métier et de l'interface utilisateur.
* **Traduction des contenus :** Intégration de l'API **DeepL** pour une précision linguistique maximale lors de la création des cartes.
* **Base de données :** * **Locale :** SQLite (via `drift`) pour une réactivité hors-ligne optimale.
* **Cloud :** Firebase Firestore pour la synchronisation des données utilisateur mise en cache locale (`shared_preferences`) du statut utilisateur (réduction du coût et de la latence).
* **Authentification :** Firebase Auth.
* **Paiements & Premium :** Intégration de **RevenueCat** pour la gestion des abonnements multi-plateformes.
* **Publicités :** Google AdMob (Bannières & Interstitiels).

## 🧠 Algorithme d'Apprentissage

Flasholator utilise une implémentation personnalisée en **Dart** de l'algorithme **SuperMemo-2 (SM-2)**. 

Le système calcule l'intervalle optimal pour la prochaine révision en fonction de deux facteurs :
1.  **La qualité de réponse de l'utilisateur :** Difficulté ressentie par l'utilisateur.
2.  **Le nombre de répétitions successives.**

Cela permet de maximiser la mémorisation à long terme en minimisant le temps passé sur les mots déjà acquis.

## 🌍 Internationalisation (l10n)

L'application supporte le Français, l'Anglais et l'Espagnol. 
La gestion des traductions est automatisée via **Auto L10n Generator** ([https://marketplace.visualstudio.com/items?itemName=felixmortas.generate-l10n](https://marketplace.visualstudio.com/items?itemName=felixmortas.generate-l10n)), une extension VSCode développée sur mesure qui intègre un LLM pour traduire et générer les fichiers `.arb` de manière contextuelle.

## 🚀 Pipeline CI/CD

Le déploiement est automatisé pour garantir une stabilité maximale :
* **GitHub Actions :** Build automatique et publication sur le **Google Play Store**.
* **Codemagic :** Pipeline dédié pour la compilation macOS et la soumission sur **AppStore Connect** (en cours).
* **Gestion de la confidentialité :** Intégration de l'UMP (User Messaging Platform) de Google pour le respect du RGPD (fonctionnel )et les exigences de l'App Tracking Transparency (ATT) sur iOS (en cours).

## 📂 Structure du Projet

```text
lib/
├── config/          # Constantes
├── core/            # Composants partagés (Models, Services, Utils)
│   ├── services/    # Logique API (DeepL, Firebase, RevenueCat, Database, Consent manager, AdMob, Flashcards, SRS, Cache)
│   ├── models/      # Modèles de flashcard et d'état de l'utilisateur
│   └── providers/   # Gestion d'état globale
├── features/        # Architecture orientée "Features"
│   ├── authentication/
│   ├── data/
│   ├── profile/
│   ├── shared/         # Shared widgets
│   ├── review/         # Logique de l'algorithme SRS
│   ├── stats/          # Logique de calcul des statistiques
│   ├── translation/    # Interface de traduction
│   └── home_page.dart  # Page principale
├── l10n/               # Fichiers de localisation (Générés via Auto L10n)
├── style/              # Styles des widgets
└── main.dart           # Point d'entrée de l'application
```

## Configuration

### Prérequis
- Flutter SDK `^3.22.5`
- Un compte Firebase (avec fichiers `google-services.json` et `GoogleService-Info.plist`)
- Clé API DeepL
- Configuration RevenueCat

### Setup
1. Cloner le projet : `git clone https://github.com/votre-username/flasholator.git`
2. Installer les dépendances : `flutter pub get`
3. Lancer la génération des fichiers (si utilisation de build_runner) : `flutter pub run build_runner build`
4. Exécuter l'application : `flutter run`

## Contribution

Les contributions sont les bienvenues ! Pour contribuer, veuillez suivre ces étapes :

1. Forker le dépôt.
2. Créer une branche pour votre fonctionnalité (`git checkout -b feature/NouvelleFonctionnalité`).
3. Committer vos modifications (`git commit -am 'Ajout de la nouvelle fonctionnalité'`).
4. Pousser la branche (`git push origin feature/NouvelleFonctionnalité`).
5. Ouvrir une Pull Request.


## Licence

Ce projet est sous licence MIT. 

The MIT License (MIT)
Copyright (c) 2024 Félix MORTAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

Pour toute question ou suggestion, n'hésitez pas à me contacter à [felix.mortas@hotmail.fr](mailto:felix.mortas@hotmail.fr).

---

Merci d'utiliser Flasholator !

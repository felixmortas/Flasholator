# Executive summary

### 🧠 Flasholator – Spaced Repetition Flashcards & Instant Translation

Flasholator is a mobile application designed to bridge the gap between instant translation and long-term vocabulary retention. It allows users to translate unknown words on the fly and instantly convert them into a personalized study deck.

**The concept:** A seamless workflow where **DeepL** handles the translation, and a custom **Spaced Repetition System (SRS)** ensures you never forget what you've learned, optimizing your study time by focusing on your weakest words.

**Technical highlights:**

- **Optimized UI/UX:** Carefully crafted user interface and experience to ensure intuitive navigation and a delightful learning journey.
- **Intelligent Learning Algorithm:** Implementation of the **SuperMemo-2 (SM-2)** algorithm in Dart. It dynamically calculates optimal review intervals based on user-reported difficulty and repetition history to maximize memory retention.
- **Deep API Integrations:** Leveraging the **DeepL API** for high-accuracy linguistic translations.
- **Robust Offline-First Architecture:** Built using **MVVM** with a local-first approach. It utilizes **SQLite (Drift)** for high-performance offline access.
- **Authentication & Authorization:** Secure user authentication and authorization using **Firebase Authentication** and **Firestore Security Rules**.
- **Monetization & Privacy Integration:** Production-ready setup featuring **RevenueCat** for multi-platform subscriptions, **Google AdMob** for ads, and full **GDPR/UMP** compliance for user data privacy.
- **Automated Localization:** Leveraging my custom-built **"Generate L10n"** VSCode extension to manage multilingual support (French, English, Spanish) via LLM-generated ARB files.
- **Modern CI/CD Pipeline:** Automated build and distribution flows using **GitHub Actions** for Google Play Store and **Codemagic** for iOS App Store Connect.

**Result:** A scalable, production-grade Flutter application that provides a frictionless learning experience, turning a simple translation tool into a powerful personal tutor.

[Download on Playstore](https://play.google.com/store/apps/details?id=com.felinx18.flasholator)
[Download on Appstore (soon)]()

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

## Limites de l'offre gratuite

Les plafonds développeur sont définis dans `lib/config/free_plan_limits.dart` et fournis par `freePlanLimitsProvider`. Par défaut : un couple de langues, 200 traductions et 20 paires de cartes. Chaque valeur peut être changée indépendamment ; `null` désactive le plafond correspondant. Les abonnés premium ne sont pas limités. Il n'existe pas de réglage utilisateur pour ces plafonds.

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

* **Framework (Multi-plateforme iOS/Android):** [Flutter](https://flutter.dev/) (v3.32.5)
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

## Baseline de migration

Avant chaque tranche de migration, exécuter la baseline déterministe :

```sh
flutter test test/core/models test/core/services test/features/translation test/user_preferences_service_test.dart
```

Elle caractérise les paires et la persistance Drift, les vecteurs SM-2, les
statistiques, l’authentification et les préférences, ainsi que l’invalidation
des réponses de traduction tardives. La suite complète reste `flutter test`.

## Convention MVVM et Riverpod

Les nouvelles migrations sont organisées par fonctionnalité. Une vue
`*_view.dart` ne fait que rendre un état UI immuable et transmettre les
intentions utilisateur à son `*_view_model.dart`. Chaque état expose une phase
explicite (`initial`, `loading`, `data` ou `error`) et les erreurs rendues sont
des erreurs applicatives typées, afin que la vue ne dépende pas des détails
techniques.

Les dépendances sont composées par des providers Riverpod publics et
surchargeables en test (`<feature><Role>Provider`). L'exemple exécutable se
trouve dans `lib/features/mvvm_example/`. Les providers historiques restent en
place jusqu'à ce que tous leurs consommateurs aient basculé vers leur
remplaçant et que leur comportement soit couvert par des tests.

Les commandes asynchrones d'un ViewModel portent un jeton monotone : seule la
commande encore courante peut publier son résultat ou son erreur, et aucun état
ne doit être écrit après la destruction du ViewModel. Les adaptateurs et
repositories convertissent les erreurs techniques à la frontière de la
présentation en `ApplicationError`, avec une catégorie et un identifiant stables
que la feature associe à ses ressources localisées ; ni la cause technique ni
un texte utilisateur codé en dur ne doivent être rendus par la vue.

## Bootstrap et ressources générées

Le point d’entrée appelle `ApplicationBootstrap.production()` avant l’unique
`ProviderScope`. Cette frontière initialise Flutter, Firebase avec
`DefaultFirebaseOptions`, puis AdMob exactement une fois; elle compose ensuite
le consentement UMP/ATT, le préchargement publicitaire et la restauration de la
session RevenueCat. Les vues et ViewModels ne construisent ni n’initialisent de
SDK. Les contrats de bootstrap sont injectables afin que leurs tests utilisent
des doublures, sans réseau ni plugin réel.

Les fichiers ARB de `lib/l10n/` et `lib/core/services/db_wrapper.dart` sont les
seules sources modifiables pour la localisation et Drift. Ne modifiez jamais
`lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart`
directement. Après une modification de source, régénérez puis vérifiez :

```sh
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
```

Les contributions sont les bienvenues ! Pour contribuer, veuillez suivre ces étapes :

1. Forker le dépôt.
2. Créer une branche pour votre fonctionnalité (`git checkout -b feature/NouvelleFonctionnalité`).
3. Committer vos modifications (`git commit -am 'Ajout de la nouvelle fonctionnalité'`).
4. Pousser la branche (`git push origin feature/NouvelleFonctionnalité`).
5. Ouvrir une Pull Request.


## Licence

Ce projet est sous licence MIT. 

The MIT License (MIT)
Copyright (c) 2026 Félix MORTAS

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

## Contact

Pour toute question ou suggestion, n'hésitez pas à me contacter à [felix.mortas@hotmail.fr](mailto:felix.mortas@hotmail.fr).

---

Merci d'utiliser Flasholator !

# Epic 2 Context: Mémoriser son vocabulaire sans perdre ses cartes

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre aux apprenants de gérer et de réviser leurs paires de flashcards hors ligne sans perte de données ni régression du comportement de répétition espacée. Cet epic rend la collection locale cohérente et partagée afin que les mutations, la révision et les autres projections restent fiables pendant la migration MVVM/Riverpod.

## Stories

- Story 2.1: Gérer atomiquement les paires de flashcards
- Story 2.2: Conserver les cartes hors-ligne et leurs projections
- Story 2.3: Réviser avec le comportement SM-2 caractérisé

## Requirements & Constraints

- Une paire est constituée de deux flashcards dont les rectos et versos sont inversés. Création, modification et suppression doivent toujours cibler exactement la paire concernée, sans jamais persister une seule face.
- Chaque mutation distingue `applied`, `notFound` et `conflict`. En cas d'erreur, conflit ou interruption, aucune modification partielle ne doit subsister et le comportement d'erreur observable doit être préservé.
- Les cartes et leur historique de révision restent disponibles localement hors ligne, sans perte ni changement involontaire du format persistant.
- Les listes de révision, tables et statistiques doivent lire une même collection cohérente après un commit ; une mutation échouée ne publie aucune projection.
- Le parcours de révision conserve la révélation de la réponse, le choix de qualité et les échéances obtenues par le comportement SM-2 existant. Les commandes de score sont sérialisées et ne produisent qu'un effet utilisateur pour la commande acceptée.
- Les tests de caractérisation déterministes des cartes, de la persistance, des erreurs et de SM-2 précèdent tout déplacement de comportement. Les changements intégrés doivent réussir `flutter analyze` et `flutter test` et ne doivent pas introduire de synchronisation cloud des cartes ni de nouvelle fonctionnalité métier.

## Technical Decisions

- Respecter les frontières MVVM par feature : les vues rendent l'état et transmettent les intentions ; les ViewModels orchestrent l'état UI ; les repositories dépendent des adaptateurs et jamais de Flutter UI ou d'un ViewModel.
- Utiliser Riverpod comme graphe unique d'injection. Les dépendances testables sont surchargeables ; l'état partagé a un seul propriétaire et les états temporaires appartiennent au ViewModel. Les états publics sont immuables, avec phases `initial`, `loading`, `data` et `error` et une erreur applicative typée.
- Les modèles de domaine et contrats de repository sont en Dart pur. Les DTO et modèles générés restent derrière le repository ; celui-ci réalise le mapping, la cohérence lecture/écriture et la traduction d'erreurs sans changer le comportement exposé.
- `FlashcardRepository` est l'unique propriétaire de la collection locale. Son adaptateur Drift exécute `addPair`, `editPair` et `deletePair` dans une transaction `AppDatabase.transaction(...)`.
- Tant qu'il n'existe pas de `PairId` dans le schéma, la recherche, les préconditions et la mutation emploient une clé canonique dans la transaction. Les IDs et dates existants sont conservés.
- Le repository publie, après commit uniquement, un snapshot versionné ou un flux invalidé commun à la révision, aux tables et aux statistiques. Toute évolution du schéma est une migration Drift explicite ; ne jamais modifier directement `lib/core/services/db_wrapper.g.dart`.
- Les commandes mutantes sont sérialisées/idempotentes. Préserver les textes et retours d'erreurs existants ; la localisation est résolue dans la présentation ou son adaptateur, jamais dans le domaine.

## Cross-Story Dependencies

- Les fondations de l'epic 1 fournissent les tests de caractérisation, les conventions MVVM/Riverpod et les dépendances injectables requises par cet epic.
- La collection atomique de la story 2.1 est le socle de la persistance et du mécanisme de publication cohérent de la story 2.2, puis de la révision SM-2 de la story 2.3.
- Les tables de l'epic 3 et les statistiques de l'epic 5 consommeront le snapshot partagé de `FlashcardRepository` ; leur migration ne doit pas créer une seconde source de vérité.

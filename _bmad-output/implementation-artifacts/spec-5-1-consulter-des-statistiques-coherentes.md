---
title: 'Consulter des statistiques cohérentes'
type: 'feature'
created: '2026-09-23'
status: 'done'
baseline_commit: 'NO_VCS'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** L'écran de statistiques relit les cartes via `FlashcardsService` et calcule des résultats distincts de la collection partagée. Une mutation ou des doublons legacy peuvent rendre le profil incohérent avec les tables.

**Approach:** Brancher l'écran sur le snapshot partagé et un `StatisticsUseCase` pur. Conserver les périodes et les composants visuels existants, en calculant comptes, séries, moyennes et classements depuis des paires dédoublonnées.

## Boundaries & Constraints

**Always:** Préserver le calcul caractérisé des classements par carte, en ordre décroissant et limité à cinq. Un couple de langues est non orienté. La période filtre des paires entières sur leur date canonique et une erreur de collection reste visible. Les dépendances passent par Riverpod ; l'état des dates est typé et immuable. Ajouter les tests de caractérisation avant de modifier le comportement.

**Ask First:** Aucune décision métier supplémentaire identifiée. L'utilisateur a déjà autorisé l'implémentation sans validation intermédiaire et a réservé l'exécution des commandes Flutter, Dart et Git.

**Never:** Ne pas toucher aux sources générées, à la persistance, aux droits premium ni supprimer le service historique tant que ses autres consommateurs et sa couverture ne sont pas établis.

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Résultat attendu | Erreur |
|----------|---------------|------------------|--------|
| Collection cohérente | Paires inverses, doublons et ligne isolée | Une paire retenue par clé, couples non orientés, séries et moyennes par paire | Ligne isolée ignorée |
| Période choisie | Dates de deux cartes d'une paire différentes | Paire incluse ou exclue entière selon la date canonique | Période inversée rejetée |
| Classement | Plus de cinq cartes classables | Valeurs décroissantes, cinq lignes au plus | Aucune mutation du snapshot |
| Collection vide ou en erreur | Aucun couple ou échec du flux | Totaux nuls ou message d'erreur existant | Pas de données inventées |

</frozen-after-approval>

## Code Map

- `lib/features/stats/stats_page.dart` — écran actuel : lit directement le service, gère les dates et rend les sections existantes.
- `lib/features/profile/profile_page.dart` — ouvre `StatsPage` et lui transmet le service legacy.
- `lib/features/flashcards/flashcard_providers.dart` — `flashcardCollectionProvider` et projection statistique Riverpod sur la même version que tables et review.
- `lib/features/flashcards/application/flashcard_collection_projections.dart` — sélection canonique des paires et calcul statistique existant ; point de réutilisation.
- `lib/core/services/stats_service.dart` et `test/core/services/stats_service_test.dart` — baseline historique à conserver, sans suppression immédiate.
- `test/features/flashcards/application/flashcard_collection_projections_test.dart` — tests de cohérence et de dédoublonnage déjà présents.
- `lib/core/models/stats_model.dart` — données consommées par les sections et règles de couples non orientés.

## Tasks & Acceptance

**Execution:**
- [x] `test/features/stats/statistics_use_case_test.dart` — caractériser période, doublons, séries, moyennes, classement et collection vide.
- [x] `test/features/stats/stats_page_test.dart` — vérifier les états de chargement et d'erreur de l'écran.
- [x] `lib/features/stats/statistics_use_case.dart` et `lib/features/flashcards/application/flashcard_collection_projections.dart` — exposer le calcul pur filtré par paire, sans changer la projection non filtrée des autres lecteurs.
- [x] `lib/features/stats/stats_view_model.dart` — fournir dates immuables et résultat dérivé du snapshot via providers surchargeables.
- [x] `lib/features/stats/stats_page.dart` et `lib/features/profile/profile_page.dart` — relier l'écran au ViewModel et garder les composants et états visuels.

**Acceptance Criteria:**
- Given une mutation visible dans le snapshot partagé, when l'écran de profil affiche les statistiques, then il reflète cette version sans relecture du service legacy.
- Given une sélection de dates valide, when le snapshot change, then les statistiques gardent la période choisie et se recalculent.
- Given une erreur ou un chargement du flux de cartes, when l'écran est affiché, then l'état correspondant est rendu.

## Spec Change Log

## Verification

**Commands:**
- `flutter test test/features/stats/statistics_use_case_test.dart test/features/stats/stats_page_test.dart test/features/flashcards/application/flashcard_collection_projections_test.dart` — tests de caractérisation, du flux et de l'écran réussis.
- `flutter analyze` — aucune erreur d'analyse.

## Suggested Review Order

**Branchement de l'écran**

- L'écran consomme l'état dérivé de la collection partagée et conserve ses sections visuelles.
  [stats_page.dart:12](../../lib/features/stats/stats_page.dart#L12)

- Le profil ouvre l'écran sans lui injecter le service historique.
  [profile_page.dart:356](../../lib/features/profile/profile_page.dart#L356)

**Calcul et période**

- Le provider combine période immuable, snapshot et calcul pur, puis suit ses nouvelles versions.
  [stats_view_model.dart:50](../../lib/features/stats/stats_view_model.dart#L50)

- Le ViewModel valide les dates choisies sans logique métier dans la vue.
  [stats_view_model.dart:25](../../lib/features/stats/stats_view_model.dart#L25)

- Le cas d'usage rejette une période inversée et réutilise la projection canonique.
  [statistics_use_case.dart:5](../../lib/features/stats/statistics_use_case.dart#L5)

- La projection filtre les paires entières sur leur date canonique avant les agrégats.
  [flashcard_collection_projections.dart:66](../../lib/features/flashcards/application/flashcard_collection_projections.dart#L66)

**Vérification**

- Les tests couvrent doublons, période, classements et changement de snapshot.
  [statistics_use_case_test.dart:31](../../test/features/stats/statistics_use_case_test.dart#L31)

- Les tests d'écran couvrent chargement et erreur.
  [stats_page_test.dart:17](../../test/features/stats/stats_page_test.dart#L17)

---
title: 'Story 2.3 — Réviser avec le comportement SM-2 caractérisé'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: 'c5f17731a0457f5f2fbf4974f8de2e298ac9c8ec'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le parcours de révision historique mélange état mutable de vue, lecture locale et écriture SM-2. Deux actions de score rapprochées peuvent réviser deux fois la même carte, et les lecteurs Riverpod ne reçoivent pas la collection cohérente publiée par le repository.

**Approach:** Migrer le parcours de révision vers un ViewModel Riverpod et une commande de score du repository, tout en caractérisant et en conservant exactement les vecteurs SM-2, la révélation de réponse et les interactions utilisateur existantes.

## Boundaries & Constraints

**Always:** garder le calcul de `Flashcard.review`/`SMTwo`, dont le recul d'un jour pour la qualité 2 ; identifier la carte par son identifiant persistant ; écrire et publier le snapshot seulement après succès ; exposer un état de révision immuable et des erreurs typées ; sérialiser les scores et n'émettre l'effet utilisateur qu'une fois pour la commande effectivement acceptée ; rendre horloge, repository et effets surchargeables dans les tests ; préserver les textes, contrôles et règles d'évaluation écrite de l'UI actuelle.

**Ask First:** modifier le schéma Drift, changer les vecteurs SM-2 ou leurs conventions de date, modifier les qualités proposées, ou migrer une autre feature que `review`.

**Never:** modifier directement `lib/core/services/db_wrapper.g.dart` ; supprimer `FlashcardsService` ou ses consommateurs legacy ; instancier Drift, Firebase ou RevenueCat dans une vue ou un ViewModel ; ajouter de synchronisation cloud ou de règle métier de révision.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|----------------------------|----------------|
| Carte due, réponse masquée | Snapshot avec carte due | Le recto est affiché, puis une intention révèle le verso sans écrire | N/A |
| Score accepté | Carte révélée, qualité valide, horloge fixe | Un unique calcul SM-2 est persisté ; le snapshot suivant retire/actualise la carte selon son échéance | L'effet de succès est unique |
| Deux scores concurrents | Un score déjà en cours pour la carte courante | La seconde intention n'écrit ni ne produit d'effet ; la première reste la seule acceptée | État cohérent après terminaison |
| Écriture ou chargement échoué | Repository lève une erreur | Aucune transition locale fictive ; état `error` typé observable | L'UI conserve un parcours récupérable |

</frozen-after-approval>

## Code Map

- `lib/features/review/review_tab.dart:18-274` -- écran legacy Stateful à remplacer par le rendu d'état/intention ; conserver révélation, saisie écrite, drag et boutons.
- `lib/features/review/widgets/words_display.dart:176-214` -- cache le verso et ne permet le drag qu'après révélation ; réutiliser son contrat visuel.
- `lib/features/review/widgets/response_buttons.dart:25-115` -- qualités et restrictions de la réponse écrite à préserver.
- `lib/core/models/flashcard.dart:114-136` et `lib/core/services/sm_two.dart:36-74` -- baseline SM-2 et particularité qualité 2 à caractériser, sans modifier l'algorithme.
- `lib/features/flashcards/data/flashcard_repository.dart:8-160` -- contrat, queue `_serial` et publication post-commit à étendre par une commande de score précise.
- `lib/features/flashcards/domain/flashcard_collection.dart:1-36` -- snapshot immutable contenant les treize champs persistants, dont l'identifiant de la carte.
- `lib/features/flashcards/flashcard_providers.dart:9-32` et `application/flashcard_collection_projections.dart:47-52` -- source de collection, horloge injectable et projection des cartes dues.
- `test/core/services/sm_two_test.dart:6-23`, `test/core/models/flashcard_test.dart:25-30`, `test/features/flashcards/data/flashcard_repository_test.dart:294-450` -- baseline existante et modèles de tests de queue/publication à compléter.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/flashcards/data/flashcard_repository.dart` et domaine associé -- ajouter une commande de révision par ID, transactionnelle et sérialisée, qui applique la baseline SM-2, préserve les champs non concernés et publie après commit -- faire du repository l'unique auteur local.
- [x] `lib/features/review/application/` et `lib/features/review/review_providers.dart` -- créer état UI immuable, erreur/effet typés et ViewModel injecté qui charge la projection due, révèle, puis accepte un seul score à la fois -- sortir orchestration et état temporaire de la vue.
- [x] `lib/features/review/review_tab.dart` -- composer le ViewModel Riverpod et ne garder que rendu/intention ; adapter les widgets existants sans modifier les retours visibles -- préserver le parcours utilisateur.
- [x] `test/core/services/sm_two_test.dart`, `test/features/flashcards/data/flashcard_repository_test.dart` et `test/features/review/` -- ajouter vecteurs déterministes première répétition, échec, répétitions ultérieures, écriture/publish, reveal puis score, double score et erreur -- verrouiller la matrice et la sérialisation.

**Acceptance Criteria:**
- Given une carte due, when l'utilisateur révèle sa réponse puis choisit une qualité, then l'état de révision, les champs persistés et l'échéance sont conformes aux vecteurs SM-2 caractérisés.
- Given un score en cours, when l'utilisateur tente un second score, then la seconde commande n'occasionne aucune écriture ni effet utilisateur et la commande acceptée n'émet qu'un seul effet.
- Given un commit de score réussi, when les projections sont relues, then elles observent une unique nouvelle version cohérente ; given une erreur, when elle remonte, then aucun snapshot de succès n'est publié.
- Given un test de feature, when il surcharge repository, horloge ou canal d'effets, then il vérifie le parcours sans base Drift réelle ni temporisation réelle.

## Spec Change Log

## Design Notes

La commande de repository doit dériver le résultat depuis la ligne immuable lue dans sa transaction et une horloge injectée, plutôt que d'utiliser `DateTime.now()` dans le ViewModel. Le ViewModel garde un verrou de commande et une identité/génération de carte courante : un résultat de chargement ancien ne peut donc pas remplacer la carte après le score accepté. Les effets ponctuels restent hors de l'état réhydratable afin qu'un rebuild ne relance ni publicité ni retour de succès.

## Verification

**Commands:**
- `flutter test test/core/services/sm_two_test.dart test/features/flashcards/data/flashcard_repository_test.dart test/features/review` -- expected: vecteurs, transaction, reveal et concurrence au vert.
- `flutter analyze` -- expected: aucune erreur ou avertissement d'analyse.
- `flutter test` -- expected: suite complète au vert.

## Suggested Review Order

**Commande de révision et cohérence locale**

- La commande sérialisée applique SM-2 puis publie seulement après commit.
  [`flashcard_repository.dart:168`](../../lib/features/flashcards/data/flashcard_repository.dart#L168)

- Une lecture explicite observe aussi les mutations legacy durant la migration.
  [`flashcard_repository.dart:43`](../../lib/features/flashcards/data/flashcard_repository.dart#L43)

**État et concurrence de révision**

- Le ViewModel conserve le filtre, ignore les résultats obsolètes et verrouille le score.
  [`review_view_model.dart:22`](../../lib/features/review/application/review_view_model.dart#L22)

- Les effets ponctuels restent séparés de l'état réhydratable.
  [`review_state.dart:68`](../../lib/features/review/application/review_state.dart#L68)

**Composition UI et compatibilité**

- La vue rend l'état Riverpod et conserve le pont legacy temporaire.
  [`review_tab.dart:20`](../../lib/features/review/review_tab.dart#L20)

- Les producteurs historiques peuvent toujours déclencher une actualisation.
  [`home_page.dart:187`](../../lib/features/home_page.dart#L187)

**Preuves de comportement**

- La persistance, le rollback et la publication sont caractérisés.
  [`flashcard_repository_test.dart:447`](../../test/features/flashcards/data/flashcard_repository_test.dart#L447)

- Reveal, score concurrent, filtre et `notFound` sont vérifiés sans Drift.
  [`review_view_model_test.dart:58`](../../test/features/review/review_view_model_test.dart#L58)

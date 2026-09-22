---
title: 'Story 3.2 — Enregistrer et corriger une traduction dans les tables'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: 'dddea0096551184821dda1d7db0a269307d687e8'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-3-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** La sauvegarde d’une traduction et la gestion des tables restent dans des widgets legacy : elles effectuent des écritures séparées, parfois doublées, et ne reflètent pas forcément la collection partagée. L’édition ne sait pas représenter une paire absente, un conflit ou une erreur sans modifier localement l’affichage.

**Approach:** Introduire des commandes MVVM/Riverpod injectables pour enregistrer le résultat de traduction et corriger une paire sélectionnée, toutes deux déléguées au `FlashcardRepository`. Les tables liront la projection cohérente du repository et conserveront les parcours, popups et retours visuels existants.

## Boundaries & Constraints

**Always:** créer ou modifier les deux faces exclusivement via les opérations atomiques de `FlashcardRepository` ; exposer des états UI immuables et des issues typées `applied`, `notFound` et `conflict` ; revalider un résultat de traduction courant avant et après les opérations asynchrones ; rendre repository, contrôles d’accès existants et ViewModels surchargeables en test ; rafraîchir les tables à partir de `flashcardCollectionProvider` seulement après commit ; préserver les langues, métadonnées et comportements SM-2 d’une paire existante.

**Ask First:** changer le schéma Drift ou `FlashcardPair`, les règles premium ou les limites de cartes/traductions, les textes générés de localisation, ou le parcours fonctionnel des popups.

**Never:** modifier directement `app_localizations*.dart` ou `db_wrapper.g.dart` ; appeler Drift, `FlashcardsService`, Firebase ou RevenueCat depuis une vue ou un ViewModel ; effectuer une double écriture legacy ; ajouter synchronisation cloud, refonte UX ou quota de la story 3.3 ; supprimer les services legacy avant l’adoption du remplaçant et sa couverture de tests.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Sauvegarde courante | Résultat de traduction valide et autorisation existante accordée | `addPair` reçoit une paire réversible avec langues ; succès uniquement après `applied` | Aucune écriture doublée ; tables projetées après commit |
| Résultat périmé | Nouvelle traduction, changement de langues/session ou dispose pendant la commande | Aucune commande ni publication de succès obsolète | L’intention récente reste intacte |
| Correction d’une paire | Paire complète visible dans la projection du couple | `editPair` conserve identité, dates et données SM-2 ; les deux faces changent ensemble | La projection mise à jour devient la seule source de la table |
| Paire absente ou conflit | Sélection supprimée, modifiée ou devenue ambiguë avant commit | État/retour explicite sans mutation locale optimiste | Aucun faux succès ni demi-paire ; l’utilisateur peut relire la table |
| Échec technique | Repository lève une erreur | État/retour d’erreur récupérable | Aucune modification UI ou données partielle |

</frozen-after-approval>

## Code Map

- `lib/features/translation/translate_tab.dart:_checkIfCanAddFlashcard,_addFlashcard` -- remplacer l’orchestration/persistance legacy et sa double écriture par l’intention du ViewModel, tout en conservant les contrôles d’accès et le rendu.
- `lib/features/translation/application/translation_view_model.dart` et `translation_ui_state.dart` -- flux de résultat courant et garde de contexte à prolonger ou à coordonner avec une commande de sauvegarde distincte.
- `lib/features/translation/translation_providers.dart` -- point d’injection Riverpod de la feature ; y raccorder la commande/repository sans SDK dans la vue.
- `lib/features/data/data_table_tab.dart:_fetchData,addRow,editRow,removeRow` -- remplacer la liste mutable et les écritures `FlashcardsService` pour les actions de cette story par projection et ViewModel injectables.
- `lib/features/data/widgets/edit_flashcard_popup.dart:_setConfirmButton` -- conserver le dialogue de saisie comme vue passive ; typer/adapater ses intentions de correction sans fermer ou annoncer un succès prématurément.
- `lib/features/data/widgets/all_languages_table.dart` et `couple_languages_table.dart` -- réutiliser le rendu de table avec un adaptateur depuis `FlashcardTablePair`.
- `lib/features/flashcards/data/flashcard_repository.dart:DriftFlashcardRepository.addPair,editPair` -- contrat transactionnel à utiliser sans le dupliquer ; publie les snapshots seulement après commit.
- `lib/features/flashcards/domain/flashcard_pair.dart` et `flashcard_pair_mutation_result.dart` -- modèles purs, clé canonique, validation et résultats typés à conserver.
- `lib/features/flashcards/flashcard_providers.dart` et `application/flashcard_collection_projections.dart` -- repository, collection versionnée et projection de tables cohérente à observer.
- `test/features/flashcards/data/flashcard_repository_test.dart` et `application/flashcard_collection_projections_test.dart` -- contrats d’atomicité/projection déjà caractérisés, à préserver.
- `test/features/translation/translation_view_model_test.dart` -- modèle de fakes, `ProviderContainer` et complétions asynchrones pour la sauvegarde.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/translation/application/` et `translation_providers.dart` -- ajouter une commande de sauvegarde, son état immutable et ses providers injectables ; construire une `FlashcardPair` depuis le seul résultat courant et interpréter les résultats de mutation -- retirer toute persistance de la vue.
- [x] `lib/features/translation/translate_tab.dart` et `lib/features/home_page.dart` -- transmettre l’intention de sauvegarde, rendre les états/retours existants, éliminer la chaîne callback + `FlashcardsService` doublée -- garder le pont Android et les contrôles d’accès hors quota 3.3.
- [x] `lib/features/data/application/`, `lib/features/data/data_table_tab.dart` et `lib/features/data/*` -- créer l’état/ViewModel de tables et adapter les widgets/popup existants à la projection `FlashcardTablePair` ; lancer `editPair` avec la clé/version attendue et rendre les issues -- un seul propriétaire de l’état partagé après mutation.
- [x] `test/features/translation/` et `test/features/data/` -- ajouter des tests de caractérisation avec fakes repository/collection pour sauvegarde, correction, ordre de projection, absence, conflit, erreur et résultat périmé -- prouver qu’aucune écriture partielle, doublée ou publication optimiste n’est possible.
- [x] `test/features/flashcards/` -- compléter seulement les tests de contrat nécessaires à l’intégration (clé/langues ou issue exposée) -- préserver l’atomicité établie par l’Epic 2.

**Acceptance Criteria:**
- Given une traduction affichée et encore courante, when l’utilisateur l’enregistre, then une unique commande `addPair` atomique est effectuée et les tables se mettent à jour depuis le snapshot publié après commit.
- Given une traduction devenue obsolète ou un ViewModel détruit, when une sauvegarde est demandée ou se termine, then aucune écriture ni retour de succès périmé n’est visible.
- Given une paire listée pour un couple de langues, when l’utilisateur confirme sa correction, then `editPair` modifie les deux faces tout en préservant les métadonnées de révision et la collection cohérente est reprojetée.
- Given une correction absente, conflictuelle ou techniquement échouée, when le repository répond, then l’issue est rendue de manière récupérable sans mutation locale ni persistance partielle.
- Given les tests de feature, when repository, collection et contrôles d’accès sont surchargés, then ils s’exécutent sans Drift réel, Firebase, RevenueCat ni temporisation réelle.

## Spec Change Log

## Design Notes

La sauvegarde est une commande séparée de la requête DeepL : elle capture le résultat courant et vérifie à nouveau qu’il correspond au contexte vivant avant tout effet visible. La table ne tient pas de copie optimiste ; elle observe la projection versionnée de la collection. Cela élimine la double écriture actuelle et fait de la transaction Drift le seul point de vérité pour les deux faces.

## Verification

**Commands:**
- `flutter test test/features/translation test/features/data test/features/flashcards` -- expected: sauvegarde, correction, erreurs/conflits et projections cohérentes au vert.
- `flutter analyze` -- expected: aucune erreur ni avertissement d’analyse.
- `flutter test` -- expected: suite complète au vert.

## Suggested Review Order

**Sauvegarde de traduction**

- La commande protège résultat, session et cycle de vie avant toute publication.
  [`translation_save_view_model.dart:21`](../../lib/features/translation/application/translation_save_view_model.dart#L21)

- La vue n’écrit plus directement et rend les issues de mutation.
  [`translate_tab.dart:211`](../../lib/features/translation/translate_tab.dart#L211)

**Tables cohérentes**

- La table observe la projection partagée et délègue chaque mutation au ViewModel.
  [`data_table_tab.dart:52`](../../lib/features/data/data_table_tab.dart#L52)

- Les commandes utilisent exclusivement le contrat transactionnel de paires.
  [`data_table_view_model.dart:11`](../../lib/features/data/application/data_table_view_model.dart#L11)

- Le popup attend le commit avant de se fermer.
  [`edit_flashcard_popup.dart:54`](../../lib/features/data/widgets/edit_flashcard_popup.dart#L54)

**Caractérisation**

- Les tests couvrent succès, erreur et résultats périmés de sauvegarde.
  [`translation_save_view_model_test.dart:58`](../../test/features/translation/translation_save_view_model_test.dart#L58)

- Les tests couvrent les issues conflit et paire absente lors d’une correction.
  [`data_table_view_model_test.dart:50`](../../test/features/data/data_table_view_model_test.dart#L50)

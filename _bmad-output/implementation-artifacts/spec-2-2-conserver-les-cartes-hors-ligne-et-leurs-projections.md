---
title: 'Story 2.2 — Conserver les cartes hors-ligne et leurs projections'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: '3bbdfc2d191f32266975b14e7840415fef9f115d'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le repository transactionnel de la story 2.1 ne fournit pas encore de lecture ni de publication commune. Les écrans legacy relisent donc séparément Drift, ce qui ne garantit pas que review, tables et statistiques observent la même collection après une mutation.

**Approach:** Faire du repository local le propriétaire d’un snapshot immuable de cartes persistées et de sa publication post-commit, puis proposer des projections pures consommables par les futures migrations MVVM. La coexistence avec les écrans/services legacy reste intacte dans cette story.

## Boundaries & Constraints

**Always:** préserver exactement les 13 champs persistés, les IDs, dates et historique SM-2 ; lire hors-ligne sans migration de schéma ; publier une nouvelle version uniquement après une mutation `applied` effectivement commitée ; conserver le snapshot et ne produire aucun événement pour `notFound`, `conflict` ou exception ; rendre contrats, sources de temps et providers surchargeables en test ; calculer toute projection à partir du même snapshot immuable reçu.

**Ask First:** migrer un écran legacy, modifier le schéma Drift, introduire un `PairId`, changer les règles de dédoublonnage/statistiques existantes, ou retirer `FlashcardsService`.

**Never:** modifier `lib/core/services/db_wrapper.g.dart`, altérer les formules SM-2, normaliser/supprimer des lignes legacy invalides pendant une lecture, ajouter une synchronisation cloud, ou instancier Drift/Firebase/RevenueCat dans une vue ou un ViewModel.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Lecture locale | Base Drift préremplie de cartes historiques | Snapshot immuable contenant les mêmes valeurs persistées, disponible sans réseau | Les lignes non appariées restent lisibles et inchangées |
| Commit appliqué | Ajout, édition ou suppression retourne `applied` | Un unique snapshot de version supérieure est publié après commit ; review, tables et statistiques peuvent le projeter | Aucune donnée intermédiaire n’est exposée |
| Mutation refusée ou échouée | `notFound`, `conflict` ou exception transactionnelle | Snapshot/version précédents restent la dernière publication | L’issue métier ou l’exception reste observable |
| Projection de paire | Snapshot avec paires complètes et lignes legacy isolées | Chaque paire complète est dédoublonnée une fois, indépendamment de son orientation | Une ligne invalide ne fait ni disparaître ni modifier les autres |

</frozen-after-approval>

## Code Map

- `lib/features/flashcards/data/flashcard_repository.dart:6-130` -- contrat actuel limité aux mutations et adaptateur Drift transactionnel ; point d’extension pour lecture, version et publication post-commit.
- `lib/features/flashcards/domain/flashcard_pair.dart:1-95` -- identité canonique orientation-indépendante déjà disponible pour reconnaître les paires sans inférer depuis l’ordre Drift.
- `lib/features/flashcards/flashcard_providers.dart:1-10` -- provider Riverpod surchargeable du repository ; y composer les dépendances de lecture/projection sans créer de SDK dans UI/ViewModel.
- `lib/core/services/db_wrapper.dart:7-45` -- schéma Drift v1 et champs à préserver ; aucune modification de schéma requise. `db_wrapper.g.dart` est en lecture seule.
- `lib/core/models/flashcard.dart:7-106` -- mapping legacy exhaustif entre `FlashcardData` et modèle, à préserver pendant la coexistence.
- `lib/core/services/flashcards_service.dart:27-209` -- chemin legacy de lecture/mutation/révision à conserver, non migré ici.
- `lib/features/review/review_tab.dart:68-147`, `lib/features/data/data_table_tab.dart:43-120`, `lib/core/services/stats_service.dart:20-49` -- consommateurs actuels de lectures indépendantes ; références de comportement, pas de bascule UI dans cette story.
- `test/features/flashcards/data/flashcard_repository_test.dart:40-281` et `test/core/services/stats_service_test.dart:10-71` -- suite 2.1 et règles de statistiques à étendre par des preuves de lecture/publication/projections.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/flashcards/domain/flashcard_collection.dart` -- introduire des modèles Dart purs, immuables et testables pour une carte persistée, un snapshot versionné et les projections de collection -- isoler Drift des consommateurs métier.
- [x] `lib/features/flashcards/data/flashcard_repository.dart` -- étendre le contrat par lecture/souscription de snapshot ; mapper exhaustivement Drift vers le domaine ; sérialiser publication et mutations ; recharger et publier seulement après le commit `applied` -- instaurer la source locale unique sans perdre l’observabilité des erreurs.
- [x] `lib/features/flashcards/application/flashcard_collection_projections.dart` -- fournir les projections pures review, tables et statistiques à partir d’un snapshot explicitement passé -- garantir que tous les calculs partent de la même version et qu’une paire est reconnue par sa clé canonique.
- [x] `lib/features/flashcards/flashcard_providers.dart` -- exposer la collection et les projections via providers Riverpod dérivés et surchargeables -- préparer l’adoption MVVM sans toucher les vues legacy.
- [x] `test/features/flashcards/data/flashcard_repository_test.dart` -- couvrir round-trip d’une base locale préexistante, version/publication après commit, absence de publication sur conflit et rollback, et injection provider -- prouver offline et cohérence transactionnelle.
- [x] `test/features/flashcards/application/flashcard_collection_projections_test.dart` -- couvrir les mêmes données/version pour review, tables et statistiques, orientations inverses, lignes isolées et invariants de statistiques existants -- verrouiller les projections pures.

**Acceptance Criteria:**
- Given des cartes et leur historique déjà présents dans Drift, when le repository charge la collection sans réseau, then chaque champ persistant est restitué sans changement de format ni écriture.
- Given une mutation appliquée, when le commit se termine, then les lecteurs de review, tables et statistiques reçoivent ou peuvent dériver les résultats d’un même snapshot versionné.
- Given une mutation `notFound`, `conflict` ou en erreur, when elle se termine, then aucune nouvelle version n’est publiée et le dernier snapshot reste inchangé.
- Given une paire complète, when une projection la rencontre dans l’une ou l’autre orientation, then elle est représentée une seule fois sans dépendre de l’ordre des lignes Drift.

## Spec Change Log

## Design Notes

Le snapshot est la frontière de cohérence : une projection ne relit jamais Drift et ne déclenche jamais une mutation. Les lignes legacy incomplètes ou invalides restent dans le snapshot de persistance ; seules les projections par paires les ignorent localement pour éviter de réparer ou masquer des données historiques hors périmètre.

## Verification

**Commands:**
- `flutter test test/features/flashcards/data/flashcard_repository_test.dart test/features/flashcards/application/flashcard_collection_projections_test.dart test/core/services/stats_service_test.dart` -- expected: lecture, publication et projections déterministes au vert.
- `flutter analyze` -- expected: aucune erreur ou avertissement d’analyse.
- `flutter test` -- expected: suite complète au vert.

## Suggested Review Order

**Snapshot et publication**

- Le repository sérialise lecture, mutations et diffusion après commit.
  [`flashcard_repository.dart:38`](../../../lib/features/flashcards/data/flashcard_repository.dart#L38)

- Le flux inscrit l’abonné avant l’état initial pour éviter toute perte.
  [`flashcard_repository.dart:47`](../../../lib/features/flashcards/data/flashcard_repository.dart#L47)

**Projections partagées**

- Les projections restent pures et portent explicitement la version reçue.
  [`flashcard_collection_projections.dart:25`](../../../lib/features/flashcards/application/flashcard_collection_projections.dart#L25)

- Le snapshot isole entièrement les lignes Drift des consommateurs métier.
  [`flashcard_collection.dart:1`](../../../lib/features/flashcards/domain/flashcard_collection.dart#L1)

- Riverpod dérive chaque lecture depuis une unique collection injectable.
  [`flashcard_providers.dart:19`](../../../lib/features/flashcards/flashcard_providers.dart#L19)

**Preuves de comportement**

- Les tests couvrent historique offline, erreurs et publications transactionnelles.
  [`flashcard_repository_test.dart:293`](../../../test/features/flashcards/data/flashcard_repository_test.dart#L293)

- Les projections vérifient version, orientation, échéances et statistiques déterministes.
  [`flashcard_collection_projections_test.dart:31`](../../../test/features/flashcards/application/flashcard_collection_projections_test.dart#L31)

## Suggested Review Order

**Collection et publication**

- Sérialise lectures et commits avant de publier une version immuable.
  [`flashcard_repository.dart:38`](../../../lib/features/flashcards/data/flashcard_repository.dart#L38)

- Rend l'abonnement initial et la fermeture sûrs face aux opérations en attente.
  [`flashcard_repository.dart:47`](../../../lib/features/flashcards/data/flashcard_repository.dart#L47)

**Projections cohérentes**

- Déduit review, tables et statistiques exclusivement du snapshot reçu.
  [`flashcard_collection_projections.dart:43`](../../../lib/features/flashcards/application/flashcard_collection_projections.dart#L43)

- Isole une paire réciproque valide sans modifier les données legacy.
  [`flashcard_collection_projections.dart:107`](../../../lib/features/flashcards/application/flashcard_collection_projections.dart#L107)

**Injection et preuves**

- Expose le flux commun et ses projections dérivées via Riverpod.
  [`flashcard_providers.dart:19`](../../../lib/features/flashcards/flashcard_providers.dart#L19)

- Prouve persistance offline, publication et erreurs transactionnelles.
  [`flashcard_repository_test.dart:312`](../../../test/features/flashcards/data/flashcard_repository_test.dart#L312)

- Prouve les cas de projection, doublons et échéances.
  [`flashcard_collection_projections_test.dart:32`](../../../test/features/flashcards/application/flashcard_collection_projections_test.dart#L32)

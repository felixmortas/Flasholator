---
title: 'Story 2.1 — Gérer atomiquement les paires de flashcards'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: '79797622a1bb8c17536dc49fd903eb429df0cf73'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-2-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le service historique écrit, modifie et supprime les deux faces d'une paire séparément. Une erreur, une paire incomplète ou une collision peut donc laisser des cartes incohérentes, et les appelants ne peuvent pas distinguer une application, une absence ou un conflit.

**Approach:** Introduire un contrat de repository de paires, indépendant de Drift, et son adaptateur transactionnel local. Il constituera le point d'adoption futur sans retirer les consommateurs du service historique dans cette story.

## Boundaries & Constraints

**Always:** créer, modifier et supprimer exactement deux faces inversées dans une unique transaction comprenant recherche, préconditions et écriture ; retourner `applied`, `notFound` ou `conflict` pour les issues métier ; conserver identifiants, dates et données SM-2 lors d'une modification ; propager les erreurs techniques sans publier de mutation partielle ; employer une clé canonique incluant textes et langues tant qu'il n'existe pas de `PairId` ; rendre l'infrastructure injectable pour les tests.

**Ask First:** ajouter un `PairId`, modifier le schéma Drift ou migrer les consommateurs UI existants vers le repository.

**Never:** modifier directement `lib/core/services/db_wrapper.g.dart`, supprimer `FlashcardsService`, ajouter une synchronisation cloud, changer le comportement SM-2, ou traiter une paire ambiguë/incomplète comme une réussite.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|----------------------------|----------------|
| Ajout valide | Deux textes et deux langues, aucune paire de même clé | Deux cartes inversées, même date, puis `applied` | N/A |
| Paire existante ou ambiguë | Clé canonique déjà représentée, doublon ou faces incohérentes | Collection strictement inchangée, `conflict` | Aucun commit partiel |
| Modification/suppression absente | Aucune paire complète pour la clé source | `notFound`, collection inchangée | N/A |
| Écriture défaillante | Échec pendant la transaction | Exception technique observable et snapshot initial restauré | Rollback intégral |

</frozen-after-approval>

## Code Map

- `lib/core/services/db_wrapper.dart:11-45` -- schéma Drift sans `PairId` et `AppDatabase` à employer pour la transaction ; le fichier généré associé est strictement en lecture seule.
- `lib/core/services/db_wrapper.dart:50-130` -- wrapper historique, aujourd'hui sans primitive transactionnelle ni accès adapté au repository ; à faire évoluer de façon compatible ou à entourer d'un adaptateur injecté.
- `lib/core/models/flashcard.dart:7-76` -- modèle legacy mutable et conversions Drift qui préservent ID, dates et état SRS ; ne pas le faire dépendre du nouveau domaine pur.
- `lib/core/services/flashcards_service.dart:39-149` -- comportement legacy non atomique à préserver pour ses clients jusqu'à leur migration ; source de caractérisation des deux orientations et de l'horloge commune.
- `lib/features/mvvm_example/mvvm_example_repository.dart:1-10` et `lib/features/mvvm_example/mvvm_example_providers.dart:7-17` -- modèle de contrat/implémentation locale et provider Riverpod surchargeable à reprendre.
- `test/core/services/flashcards_service_test.dart:6-49` -- fake et tests de caractérisation existants pour l'ajout bidirectionnel ; insuffisants pour transaction et rollback.
- `test/core/models/flashcard_test.dart:12-30` -- protection du round-trip des champs persistés.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/flashcards/domain/` -- créer les modèles Dart purs d'une paire, de sa clé canonique et du résultat de mutation, avec validation des entrées et égalité testable -- isoler le contrat métier de Drift.
- [x] `lib/features/flashcards/data/flashcard_repository.dart` -- définir l'interface `FlashcardRepository` et l'adaptateur Drift injectable ; effectuer lookup, détection d'absence/conflit et les deux écritures dans `AppDatabase.transaction` -- garantir l'atomicité et des résultats explicites.
- [x] `lib/core/services/db_wrapper.dart` -- exposer uniquement l'abstraction ou le point de composition nécessaire à l'adaptateur transactionnel, sans changer le schéma ni le comportement des méthodes legacy -- préserver les consommateurs actuels.
- [x] `lib/features/flashcards/flashcard_providers.dart` -- fournir le repository local par un provider Riverpod surchargeable -- préparer l'adoption MVVM sans instanciation SDK dans une vue ou un ViewModel.
- [x] `test/features/flashcards/data/flashcard_repository_test.dart` -- ajouter des tests déterministes d'ajout, modification et suppression appliqués, `notFound`, conflit, ambiguïté, conservation des métadonnées et rollback lors d'un échec à la seconde écriture -- couvrir toute la matrice I/O.
- [x] `test/core/services/flashcards_service_test.dart` -- conserver/adapter uniquement les doubles nécessaires pour que les tests de caractérisation historiques restent valides -- éviter toute régression involontaire du legacy durant la coexistence.

**Acceptance Criteria:**
- Given une demande d'ajout, de modification ou de suppression d'une paire complète, when le repository local la traite, then les deux faces inversées sont décidées et écrites dans une seule transaction Drift et le résultat est `applied`.
- Given une paire source absente, incomplète, dupliquée ou ambiguë, when une mutation est demandée, then le repository retourne `notFound` ou `conflict` selon le cas et ne modifie aucune carte.
- Given un conflit ou une exception pendant une mutation, when la transaction se termine, then le snapshot de cartes est identique à celui d'avant l'appel et l'erreur technique reste observable.
- Given une modification appliquée, when les deux faces sont relues, then elles sont inverses et leurs identifiants, dates et données de répétition espacée d'origine sont conservés.
- Given un test consommateur, when il surcharge la dépendance Riverpod, then il peut fournir un faux repository sans créer de base Drift réelle.

## Spec Change Log

## Design Notes

La clé canonique doit représenter les deux orientations de manière stable : trier les deux descripteurs `(front, back, sourceLang, targetLang)` plutôt que se fier à l'orientation envoyée par l'UI. Une clé qui correspond à zéro face est absente ; elle doit correspondre à une unique paire de deux faces exactement inversées. Toute autre cardinalité ou composition est un conflit afin de ne jamais deviner quelle donnée legacy corriger.

## Verification

**Commands:**
- `flutter test test/features/flashcards/data/flashcard_repository_test.dart test/core/services/flashcards_service_test.dart` -- expected: tests de mutation atomique et baseline legacy au vert.
- `flutter analyze` -- expected: aucune erreur ou avertissement d'analyse.
- `flutter test` -- expected: suite complète au vert.

## Suggested Review Order

**Contrat et atomicité**

- Le repository regroupe préconditions et deux écritures dans chaque transaction.
  [`flashcard_repository.dart:19`](../../lib/features/flashcards/data/flashcard_repository.dart#L19)

- L'édition détecte les conflits et déclenche un rollback si une face échoue.
  [`flashcard_repository.dart:42`](../../lib/features/flashcards/data/flashcard_repository.dart#L42)

- La suppression confirme que deux enregistrements ont réellement disparu.
  [`flashcard_repository.dart:87`](../../lib/features/flashcards/data/flashcard_repository.dart#L87)

**Identité métier**

- La clé canonique traite les orientations inverses comme une même paire.
  [`flashcard_pair.dart:41`](../../lib/features/flashcards/domain/flashcard_pair.dart#L41)

- Les lignes legacy invalides restent isolées des mutations non concernées.
  [`flashcard_repository.dart:103`](../../lib/features/flashcards/data/flashcard_repository.dart#L103)

**Composition et preuves**

- Le provider Riverpod fournit un repository remplaçable en test.
  [`flashcard_providers.dart:6`](../../lib/features/flashcards/flashcard_providers.dart#L6)

- Les tests couvrent succès, conflits, absence et rollbacks transactionnels.
  [`flashcard_repository_test.dart:51`](../../test/features/flashcards/data/flashcard_repository_test.dart#L51)

---
title: 'Story 1.4 — Retirer le legacy seulement après bascule prouvée'
type: 'chore'
created: '2026-09-22'
status: 'done'
review_loop_iteration: 0
baseline_commit: 'b79d634890fb025091094f63212dd3d8c44d36da'
context:
  - '{project-root}/AGENTS.md'
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** L’inventaire initial des composants legacy indique des remplaçants cibles et des preuves générales, mais ne permet pas encore d’attester, pour chaque candidat, quels consommateurs ont réellement basculé, quels tests le couvrent ou si l’audit de références autorise une suppression.

**Approach:** Faire de l’inventaire un registre de retrait vérifiable et exploitable à chaque migration. La story n’efface aucun composant : elle documente l’état observé actuel, les preuves attendues et le protocole qui bloque toute suppression prématurée.

## Boundaries & Constraints

**Always:** Conserver Firebase, Drift, RevenueCat, la localisation générée et tous les parcours de production ; déclarer chaque candidat avec son remplaçant, ses consommateurs observés et migrés, ses tests, son audit de références, son statut et ses preuves de suppression ; ne marquer `supprimable` qu’après audit sans référence et vérifications Flutter vertes dans un commit isolé et réversible.

**Ask First:** Toute suppression de fichier, de service ou de provider legacy, tout changement de parcours ou de règle métier, ou toute correction d’un consommateur découverte pendant l’inventaire.

**Never:** Ne pas présenter les adaptations du bootstrap comme une bascule complète d’Ads, consentement ou RevenueCat ; ne pas modifier `lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart` ; ne pas déclarer migrés des consommateurs des Epics 2 à 5 non encore réalisés.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Candidat encore utilisé | Une recherche localise des imports ou usages de production | La ligne conserve `legacy actif`, liste les consommateurs et interdit la suppression | La preuve de retrait reste incomplète, sans changement de code |
| Candidat basculé | Remplaçant adopté, consommateurs migrés et tests de remplacement présents | Le registre exige une commande `rg` sans résultat, un commit isolé et les résultats Flutter avant `supprimable` | Toute preuve manquante maintient le statut hors `supprimable` |

</frozen-after-approval>

## Code Map

- `_bmad-output/specs/spec-migration-mvvm-riverpod/legacy-inventory.md` — registre existant à convertir en preuve par candidat ; il contient l’inventaire initial, mais pas les consommateurs migrés, tests nommés ni audit daté.
- `_bmad-output/specs/spec-migration-mvvm-riverpod/migration-contract.md` — contrat de sortie : zéro référence exécutable, tests verts, puis suppression dédiée et réversible.
- `_bmad-output/implementation-artifacts/epic-1-context.md` — interdit le retrait avant l’adoption complète du remplaçant et la couverture.
- `README.md` — convention publique : les providers historiques survivent jusqu’à la bascule de tous leurs consommateurs.
- `lib/main.dart:30`, `lib/features/home_page.dart:35-37`, `lib/features/stats/stats_page.dart:55`, `lib/features/authentication/widgets/unsubscribe_dialog.dart:18` — preuves de consommateurs encore actifs ; à reporter sans les modifier.
- `lib/core/bootstrap/application_bootstrap.dart:121` et `lib/features/profile/profile_page.dart:46` — usages actuels de consentement, à corriger dans l’inventaire après la story 1.3.
- `test/core/services/`, `test/features/translation/translate_tab_test.dart`, `test/core/bootstrap/application_bootstrap_test.dart` — suites de caractérisation à associer aux candidats, sans prétendre qu’elles prouvent une suppression future.
- `lib/l10n/app_localizations*.dart` et `lib/core/services/db_wrapper.g.dart` — générés, lecture seule et exclus du registre de suppression manuelle.

## Tasks & Acceptance

**Execution:**
- [x] `_bmad-output/specs/spec-migration-mvvm-riverpod/legacy-inventory.md` — remplacer la matrice de pilotage par un registre de preuve par candidat : remplaçant concret ou cible explicite, consommateurs observés/migrés, tests de caractérisation, commande et résultat d’audit, état, commit isolé et résultats de vérification ; actualiser les consommateurs issus du bootstrap sans supprimer de code.
- [x] `_bmad-output/specs/spec-migration-mvvm-riverpod/legacy-inventory.md` — ajouter le protocole d’usage : audit avant/après avec `rg`, critères stricts de passage à `supprimable`, vérification `flutter analyze`/`flutter test` et consignation du commit réversible.
- [x] `_bmad-output/specs/spec-migration-mvvm-riverpod/legacy-inventory.md` — relier chaque domaine aux tests existants pertinents et conserver tous les candidats actuels à `legacy actif` ou équivalent tant que les Epics 2 à 5 ne sont pas migrés.

**Acceptance Criteria:**
- Given un composant legacy candidat au retrait, when son remplacement est proposé, then le registre indique le remplaçant, les consommateurs observés et migrés, les tests associés et l’audit de références requis, et le retrait reste bloqué tant qu’une preuve manque.
- Given une suppression legacy, when elle est intégrée ultérieurement, then le registre exige une modification isolée et réversible, une recherche sans référence restante et les résultats verts de `flutter analyze` et `flutter test` avant de la déclarer achevée.

## Spec Change Log

- 2026-09-22 — Matrice remplacée par un registre de preuve exhaustif ; tous les candidats restent `legacy actif`, sans suppression ni bascule déclarée.

## Design Notes

Le registre est le garde-fou de processus, pas un mécanisme qui simule des bascules inexistantes. Les lignes de la migration actuelle restent explicitement non supprimables ; les colonnes de preuve rendent un futur retrait révisable sans réinterpréter l’historique.

## Verification

**Commands:**
- `rg -n "<symbole-ou-import-du-candidat>" lib test` — attendu : relevé des références à consigner avant un retrait ; zéro référence exécutable seulement après bascule complète.
- `flutter analyze` — attendu, après toute suppression future : aucune erreur d’analyse.
- `flutter test` — attendu, après toute suppression future : suite complète verte.

**Manual checks:**
- Vérifier que chaque ligne active comporte les champs de preuve et qu’aucun candidat n’est `supprimable` à ce stade.

## Suggested Review Order

**Registre et garde-fous**

- Le registre expose toute preuve exigée, sans simuler une bascule.
  [`legacy-inventory.md:1`](../specs/spec-migration-mvvm-riverpod/legacy-inventory.md#L1)

- Chaque candidat reste explicitement actif tant que ses consommateurs existent.
  [`legacy-inventory.md:27`](../specs/spec-migration-mvvm-riverpod/legacy-inventory.md#L27)

- Le protocole impose audit, commit isolé et vérification avant retrait.
  [`legacy-inventory.md:47`](../specs/spec-migration-mvvm-riverpod/legacy-inventory.md#L47)

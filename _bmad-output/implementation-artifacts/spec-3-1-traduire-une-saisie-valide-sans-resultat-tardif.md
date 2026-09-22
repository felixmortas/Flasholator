---
title: 'Story 3.1 — Traduire une saisie valide sans résultat tardif'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: 'b92beaf80fd63c9ef56fce5ca18a1693cbc9a776'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-3-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** `TranslateTab` concentre le rendu, l'état mutable, l'appel DeepL et la protection partielle contre les réponses tardives. Il ne rend pas une phase de chargement ni une erreur typée, et une réponse d'une session précédente ne peut pas être distinguée d'une réponse courante.

**Approach:** Extraire la demande de traduction dans une feature MVVM/Riverpod : contrat de repository pur, adaptateur DeepL, état UI immuable et ViewModel injectable. L'identité de la requête, les langues et le contexte de session sont capturés au lancement afin d'ignorer toute complétion périmée ; la vue ne fait que rendre l'état et transmettre les intentions.

## Boundaries & Constraints

**Always:** accepter seulement une saisie non vide après `trim` et un couple source/cible valide ; exposer `initial`, chargement, résultat ou erreur applicative typée ; rendre repository et contexte de session surchargeables dans les tests ; invalider une requête lors d'une nouvelle saisie, d'un changement de langues, de couple ou de session, et vérifier que le ViewModel est encore monté avant publication ; conserver les widgets, textes et parcours de saisie existants ; préserver DeepL, la localisation générée et la compatibilité mobile.

**Ask First:** modifier le schéma Drift, le contrat public DeepL, les textes générés de localisation, les règles de quota ou de premium, ou migrer l'enregistrement/correction des cartes.

**Never:** modifier directement `app_localizations*.dart` ou `db_wrapper.g.dart` ; placer un SDK, une clé ou du réseau dans la vue/ViewModel ; supprimer `FlashcardsService`, `DeeplTranslator` ou un consommateur legacy hors du périmètre de traduction ; ajouter une synchronisation cloud, annuler le transport HTTP comme prérequis, ou changer l'UX métier.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|----------------------------|----------------|
| Traduction valide | Saisie élaguée, langues distinctes, session courante | `loading`, puis résultat associé à la saisie et au contexte capturés | N/A |
| Entrée ou couple invalide | Vide après `trim`, source/cible identiques ou contexte absent | Aucun appel repository ; état de la dernière intention invalidé | Aucun faux résultat ni appel réseau |
| Erreur DeepL | Requête courante, repository en erreur | État `error` avec erreur applicative typée et rendu récupérable | L'ancienne réussite n'est pas publiée comme actuelle |
| Réponse obsolète | Deux requêtes, changement de texte/langues/couple/session, ou dispose | La complétion ancienne est ignorée | Elle ne remplace ni résultat, ni erreur, ni futur état courant |

</frozen-after-approval>

## Code Map

- `lib/features/translation/translate_tab.dart:25-250` -- écran legacy Stateful, appel DeepL et garde de requête ; conserver le rendu et les parcours hors sauvegarde, déplacer l'orchestration de traduction.
- `lib/features/translation/translation_request_guard.dart:3-22` -- compteur monotone existant à préserver conceptuellement ou remplacer par le contexte immutable complet.
- `lib/core/services/deepl_translator.dart:4-36` -- adaptateur legacy HTTP et comportements d'échec observables à encapsuler ; aucun secret ne doit remonter vers la feature.
- `lib/features/home_page.dart:31-35,250-255` -- composition legacy injectant `DeeplTranslator` dans la vue ; basculer la vue vers les providers sans perturber le pont Android existant.
- `lib/features/review/application/review_view_model.dart:10-47,125-130` et `lib/features/review/review_providers.dart:6-12` -- modèle local de `StateNotifier`, état immutable, génération et injection Riverpod.
- `lib/features/mvvm_example/mvvm_example_view_model.dart:8-40` et `test/features/mvvm_example/mvvm_example_view_model_test.dart:35-148` -- convention de phase UI, erreurs et tests avec `ProviderContainer`/`Completer`.
- `lib/core/providers/user_data_provider.dart:3-42` et `lib/core/services/user_manager.dart:117-129` -- état/session legacy sans génération : ne pas le lire directement depuis le ViewModel ; fournir un contexte feature injectable.
- `test/features/translation/translate_tab_test.dart:5-40` -- caractérisation minimale de la garde et du quota ; compléter la couverture MVVM sans faire migrer le quota de la story 3.3.

## Tasks & Acceptance

**Execution:**
- [x] `lib/features/translation/domain/` et `data/` -- définir requête, résultat/erreurs et contrat `TranslationRepository` Dart pur, puis un adaptateur encapsulant DeepL -- isoler SDK, réseau et comportements d'échec de la feature.
- [x] `lib/features/translation/application/` et `translation_providers.dart` -- créer contexte de session/langues immutable, état UI, ViewModel `StateNotifier` et providers overrideables -- capturer un token/context à chaque commande et publier seulement si courant et monté.
- [x] `lib/features/translation/translate_tab.dart` et `lib/features/home_page.dart` -- composer les providers et réduire la vue au rendu/intention du flux de traduction ; conserver les éléments de sauvegarde legacy pour la story 3.2 et le pont Android -- retirer l'instanciation/injection DeepL de ce parcours UI.
- [x] `test/features/translation/` -- caractériser validation, chargement, résultat, erreur, ordre inverse de deux réponses, changements de saisie/langues/couple/session et dispose -- prouver l'absence d'appel ou de publication obsolète avec fakes et `Completer`.

**Acceptance Criteria:**
- Given une saisie valide et un couple de langues actif, when l'utilisateur lance la traduction, then le ViewModel publie chargement puis le résultat ou une erreur DeepL typée, sans appel DeepL depuis la vue.
- Given une saisie vide ou un couple invalide, when une intention de traduction est envoyée, then le repository n'est pas appelé et aucun état de succès artificiel n'est publié.
- Given plusieurs requêtes successives, when une réponse de la première arrive après la seconde, then seul le résultat ou l'erreur correspondant au dernier contexte est visible.
- Given un changement de session, de couple de langues ou la destruction du ViewModel pendant une requête, when elle se termine, then elle est ignorée et ne modifie aucun état visible.
- Given les tests de feature, when repository et session sont surchargés, then les scénarios s'exécutent sans Firebase, HTTP réel ni temporisation réelle.

## Spec Change Log

## Design Notes

Le transport DeepL n'a pas besoin d'être annulé pour satisfaire le contrat : une identité monotone de requête, associée à la saisie normalisée, aux langues et au contexte `(sessionId, generation)`, rend une complétion inoffensive lorsqu'elle ne correspond plus à l'intention active. Cette identité doit être contrôlée à la fois après `await` et avant toute publication ; l'état reste réhydratable et les actions ponctuelles n'y sont pas encodées.

## Verification

**Commands:**
- `flutter test test/features/translation` -- expected: validation, phases, erreurs et réponses/session obsolètes au vert.
- `flutter analyze` -- expected: aucune erreur ni avertissement d'analyse.
- `flutter test` -- expected: suite complète au vert.

## Suggested Review Order

**Orchestration et concurrence**

- Le token lie chaque complétion à son intention et à sa session courante.
  [`translation_view_model.dart:25`](../../lib/features/translation/application/translation_view_model.dart#L25)

- Les providers séparent l'adaptateur DeepL et le contexte session surchargeable.
  [`translation_providers.dart:13`](../../lib/features/translation/translation_providers.dart#L13)

**Intégration de l'écran**

- Le couple de langues est observé hors rendu et invalide l'intention obsolète.
  [`translate_tab.dart:55`](../../lib/features/translation/translate_tab.dart#L55)

- La vue transmet l'intention et ne rend que l'état Riverpod courant.
  [`translate_tab.dart:169`](../../lib/features/translation/translate_tab.dart#L169)

- La sauvegarde legacy revalide le résultat après chaque opération asynchrone.
  [`translate_tab.dart:221`](../../lib/features/translation/translate_tab.dart#L221)

**Frontière DeepL et preuves**

- Le client legacy transforme son message historique en erreur de domaine.
  [`legacy_deepl_translation_client.dart:4`](../../lib/features/translation/data/legacy_deepl_translation_client.dart#L4)

- Les tests verrouillent phases, erreurs, concurrence, session et injection.
  [`translation_view_model_test.dart:49`](../../test/features/translation/translation_view_model_test.dart#L49)

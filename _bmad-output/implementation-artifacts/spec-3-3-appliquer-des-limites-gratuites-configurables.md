---
title: 'Story 3.3 — Appliquer des limites gratuites configurables'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: '6a543121a792a25c374c28311c16b730e86963c5'
review_loop_iteration: 0
context:
  - '_bmad-output/implementation-artifacts/epic-3-context.md'
---

<frozen-after-approval reason="intention autorisée explicitement par l’utilisateur sans validation intermédiaire">

## Intent

**Problem:** Le quota gratuit de traduction vaut 10 000 dans le code et les limites de l’offre sont dispersées. Une ancienne interdiction persistée peut aussi survivre à une hausse ou désactivation de limite.

**Approach:** Centraliser les plafonds développeur injectables (un couple, 200 traductions, 20 paires par défaut ; `null` désactive un plafond), puis appliquer le quota de traduction aux parcours existants avec premium illimité et consommation uniquement après résultat courant réussi.

## Boundaries & Constraints

**Always:** préserver le paywall et les retours existants ; traiter le compteur comme source du seuil configurable ; isoler les effets asynchrones par session ; surcharger la configuration et les accès en test ; conserver les paires atomiques et la localisation.

**Ask First:** modification du schéma Drift ou des contrats de paiement.

**Never:** réglage utilisateur, nouveau texte localisé, écriture dans les fichiers générés, secret ou SDK dans le domaine.

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Sortie attendue | Erreur |
|---|---|---|---|
| Gratuit au seuil | compteur 199 puis succès courant | 200e autorisée, 201e bloquée | paywall existant |
| Premium | compteur au-dessus du seuil | traduction autorisée, compteur inchangé | — |
| Limite surchargée | plafond plus haut ou `null`, ancien `canTranslate=false` | accès selon nouveau plafond | aucun blocage hérité |
| Réponse périmée/erreur | DeepL échoue ou session/requête change | compteur inchangé | état existant |
| Autres limites | valeurs individuelles surchargées ou `null` | couples/cartes suivent leur configuration | premium illimité |

</frozen-after-approval>

## Code Map

- `lib/config/constants.dart` — plafonds historiques 10 000 traductions et 200 paires ; remplacer par une configuration centralisée.
- `lib/config/free_plan_limits.dart` et `lib/core/providers/free_plan_limits_provider.dart` — plafonds indépendants et point de surcharge Riverpod.
- `lib/core/providers/user_data_provider.dart` — compteur, abonnement et drapeau legacy ; dériver l’accès du compteur et de la configuration.
- `lib/core/services/user_manager.dart:incrementCounter` — incrément local et interdiction Firestore ; rendre le seuil configurable et éviter les effets d’une session remplacée.
- `lib/features/translation/translate_tab.dart:_checkIfCanTranslate,_translate` — paywall et consommation après résultat ; ne consommer que la commande courante.
- `lib/features/translation/application/translation_view_model.dart:translate` — distinguer la complétion courante d’une complétion ignorée.
- `lib/features/home_page.dart:_handleTextIntent` — chemin Android distinct à protéger avec le même quota.
- `lib/core/services/user_preferences_service.dart` — persistance des couples déjà utilisés pour les plafonds supérieurs à un.
- `lib/core/services/flashcards_service.dart:canAddCard` et `lib/features/translation/translation_providers.dart` — limite de paires via accès injectable.
- `lib/features/flashcards/data/flashcard_repository.dart:addPair` — contrôle transactionnel final des paires pour empêcher un dépassement après ouverture du formulaire.
- `test/features/translation/` — fakes Riverpod et cas de réponse tardive existants à étendre.

## Tasks & Acceptance

**Execution:**
- [x] `lib/config/` et providers — fournir la configuration immuable 1/200/20, chaque plafond nullable et surchargeable ; appliquer les seuils sans flag persistant périmé.
- [x] `lib/features/translation/` et `lib/core/services/user_manager.dart` — compter uniquement les succès courants gratuits ; protéger l’effet de session et conserver le paywall.
- [x] `lib/features/home_page.dart`, `lib/core/services/flashcards_service.dart` — harmoniser les autres entrées et le plafond de paires/couples.
- [x] `test/` — écrire les caractérisations des défauts, surcharges, désactivation, premium, seuil, erreur et complétion périmée avec fakes.

**Acceptance Criteria:**
- Given un utilisateur gratuit avec 199 traductions, when une traduction courante réussit, then son compteur atteint 200 et l’intention suivante ouvre le parcours premium.
- Given un premium, when il traduit au-delà du seuil, then aucune limite ni consommation gratuite ne lui est appliquée.
- Given une configuration développeur surchargée, when un plafond change ou devient `null`, then l’accès reflète immédiatement cette configuration sans réglage utilisateur.

## Spec Change Log

## Design Notes

Le champ `canTranslate` historique ne suffit pas à exprimer un plafond qui change. Le compteur conservé sert à évaluer le seuil courant ; les autres usages éventuels du drapeau restent à inspecter avant retrait.

## Verification

**Résultat communiqué par l’utilisateur :**
- `flutter test` — suite complète au vert après les derniers correctifs.
- `dart analyze` — les diagnostics introduits par cette story ont disparu ; les diagnostics préexistants, hors périmètre, restent présents.

## Suggested Review Order

**Accès et quotas**

- La configuration développeur fournit les trois plafonds indépendants.
  [`free_plan_limits.dart:2`](../../lib/config/free_plan_limits.dart#L2)

- L’accès à la traduction dépend du compteur courant et du droit premium.
  [`user_data_provider.dart:9`](../../lib/core/providers/user_data_provider.dart#L9)

- Le compteur est sérialisé et ignore les intentions périmées.
  [`user_manager.dart:94`](../../lib/core/services/user_manager.dart#L94)

**Intégrité des paires**

- La transaction empêche un ajout après atteinte du plafond.
  [`flashcard_repository.dart:97`](../../lib/features/flashcards/data/flashcard_repository.dart#L97)

- Les couples déjà utilisés sont mémorisés après validation de l’accès.
  [`user_manager.dart:47`](../../lib/core/services/user_manager.dart#L47)

**Parcours et tests**

- Seul le résultat de traduction courant consomme le quota.
  [`translate_tab.dart:168`](../../lib/features/translation/translate_tab.dart#L168)

- Les tests couvrent les seuils, le premium et les surcharges.
  [`free_plan_limits_test.dart:7`](../../test/config/free_plan_limits_test.dart#L7)

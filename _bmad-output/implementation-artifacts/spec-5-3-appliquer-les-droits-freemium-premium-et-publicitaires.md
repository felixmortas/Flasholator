---
title: 'Appliquer les droits freemium, premium et publicitaires'
type: 'feature'
created: '2026-09-23'
status: 'done'
baseline_commit: 'e247eadab7f026131c57b44b56dc1f8018516ee3'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="intention utilisateur autorisant directement l’implémentation sans validation">

## Intent

**Problem:** Les plafonds gratuits et plusieurs capacités premium existent déjà, mais la publicité peut être chargée ou affichée sans consentement courant, et une révision globale peut rester active après expiration du premium.

**Approach:** Préserver les plafonds configurables et les droits confirmés par RevenueCat. Centraliser une décision publicitaire réactive fondée sur le statut premium, UMP et ATT, puis l’appliquer aux bannières et interstitiels, y compris après un changement de droits ou de consentement.

## Boundaries & Constraints

**Always:** Offre gratuite : un couple, 200 traductions et 20 paires par défaut, chacun configurable. Premium confirmé : langues, traductions et révisions sans plafond, révision globale et saisie de réponse. Aucune publicité sans toutes les autorisations requises au moment de charger et d’afficher. Les erreurs de consentement ferment l’accès publicitaire ; les données utilisateur restent intactes. Dépendances surchargeables en test, états UI typés et immuables.

**Ask First:** Aucune décision métier additionnelle identifiée ; l’utilisateur a autorisé l’exécution sans validation.

**Never:** Modifier directement les fichiers générés, supprimer Firebase, Drift ou RevenueCat, afficher une publicité avec une autorisation inconnue, réinitialiser les données lors d’une perte de premium.

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Résultat | Erreur |
|----------|---------------|----------|--------|
| Gratuit autorisé | UMP autorise, ATT autorise si requis | Bannière et interstitiel éligibles | Échec SDK : aucune publicité |
| Refus ou retrait | UMP ou ATT refusé, indisponible ou retiré | Aucun chargement ni affichage ; publicité chargée libérée | Accès fermé |
| Premium | Droit `pro` confirmé ou restauré | Aucune publicité ; plafonds levés | Aucune perte de données |
| Expiration | Droit premium retiré | Plafonds gratuits actifs ; révision globale et réponse écrite désactivées | Aucune perte de données |

</frozen-after-approval>

## Code Map

- `lib/config/free_plan_limits.dart`, `lib/core/providers/free_plan_limits_provider.dart` — plafonds 1/200/20 déjà centralisés, conserver.
- `lib/core/services/user_manager.dart`, `lib/features/flashcards/flashcard_providers.dart`, `lib/features/translation/` — application existante des plafonds et droits ; caractériser avant modification.
- `lib/core/providers/user_data_provider.dart` — `isSubscribedProvider`, droit réconcilié par la story 5.2.
- `lib/core/bootstrap/application_bootstrap.dart:113`, `lib/core/services/consent_manager.dart` — flux UMP/ATT initial ; ATT n’est pas pris en compte pour le préchargement.
- `lib/core/services/ad_service.dart`, `lib/core/providers/ad_provider.dart`, `lib/features/shared/widgets/ad_banner_widget.dart` — chargement et affichage ; la bannière ne vérifie que le premium.
- `lib/features/review/review_tab.dart`, `lib/features/data/data_table_tab.dart`, `lib/features/home_page.dart` — interstitiel et commandes premium ; révision globale conservée après déclassement.
- `lib/features/profile/profile_page.dart:180` — formulaire de confidentialité à relier au rafraîchissement du droit publicitaire.
- `test/config/free_plan_limits_test.dart`, `test/core/bootstrap/application_bootstrap_test.dart`, `test/features/review/review_view_model_test.dart` — baselines et modèles de tests.

## Tasks & Acceptance

**Execution:**
- [x] `test/` — caractériser les plafonds existants, la révision globale au déclassement et les accès publicitaires refusés, inconnus, retirés ou premium.
- [x] `lib/core/services/ad_authorization.dart`, `lib/core/providers/ad_provider.dart` — fournir une décision publicitaire injectable fondée sur UMP, ATT et le droit premium.
- [x] `lib/core/bootstrap/application_bootstrap.dart`, `lib/features/profile/profile_page.dart`, `lib/features/home_page.dart` — réévaluer après démarrage, options de confidentialité et retour au premier plan.
- [x] `lib/core/services/ad_service.dart`, `lib/core/providers/ad_provider.dart`, `lib/features/shared/widgets/ad_banner_widget.dart`, `lib/features/review/review_tab.dart` — appliquer la décision à chaque chargement et affichage, libérer les annonces invalidées.
- [x] `lib/features/review/`, `lib/features/data/`, `lib/features/home_page.dart` — empêcher les commandes et projections premium après déclassement.

**Acceptance Criteria:**
- Given un compte gratuit, when chaque plafond configuré est atteint, then seule l’action concernée est refusée.
- Given un droit `pro` confirmé, when l’utilisateur traduit ou révise, then les plafonds sont levés et les fonctions premium accessibles sans publicité.
- Given une autorisation UMP ou ATT refusée, inconnue ou retirée, when une publicité gratuite est évaluée, then elle n’est ni chargée ni affichée.
- Given une expiration premium, when les droits se réconcilient, then les fonctions premium se ferment et les données restent conservées.

## Spec Change Log

## Verification

**Commands:**
- `flutter test` — scénarios de droits, quotas et consentement réussis.
- `flutter analyze` — aucun diagnostic.

**Résultats:** tests ciblés : 13 réussis avant l'ajout du test de bannière ; suite complète : 157 réussis, 7 échecs préexistants concentrés dans `test/firestore_users_dao_test.dart` (mocks Firestore retournant `null` pour un `Future`). Analyse ciblée : aucune erreur, 9 informations de style préexistantes ; analyse globale : 120 diagnostics préexistants.

## Suggested Review Order

**Décision publicitaire**

- Centralise le droit publicitaire réévalué selon premium, UMP et ATT.
  [ad_provider.dart:11](../../lib/core/providers/ad_provider.dart#L11)

- Relit les autorisations système et ferme l'accès si elles sont indisponibles.
  [ad_authorization.dart:12](../../lib/core/services/ad_authorization.dart#L12)

- Précharge seulement après confirmation et réévalue au retour dans l’application.
  [home_page.dart:262](../../lib/features/home_page.dart#L262)

**Chargement et affichage**

- Vérifie l'autorisation avant de charger ou montrer un interstitiel.
  [ad_service.dart:52](../../lib/core/services/ad_service.dart#L52)

- Libère les bannières invalidées et revérifie leur autorisation.
  [ad_provider.dart:24](../../lib/core/providers/ad_provider.dart#L24)

- Rafraîchit les droits après le formulaire de confidentialité.
  [profile_page.dart:181](../../lib/features/profile/profile_page.dart#L181)

**Perte du premium**

- Ferme la réponse écrite et revient à la révision par couple.
  [review_tab.dart:93](../../lib/features/review/review_tab.dart#L93)

- Empêche la projection globale des tables après expiration.
  [data_table_tab.dart:188](../../lib/features/data/data_table_tab.dart#L188)

**Tests**

- Couvre les refus, retraits et changements de statut premium.
  [ad_provider_test.dart:30](../../test/core/providers/ad_provider_test.dart#L30)

- Vérifie la garde de chargement des interstitiels.
  [ad_service_test.dart:13](../../test/core/services/ad_service_test.dart#L13)

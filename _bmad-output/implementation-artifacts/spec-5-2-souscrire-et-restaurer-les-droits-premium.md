---
title: 'Souscrire et restaurer les droits premium'
type: 'feature'
created: '2026-09-23'
status: 'done'
baseline_commit: '6b8c7c2d89b55e963489de47d7024e84596365e8'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="intention utilisateur autorisant directement l'implémentation">

## Intent

**Problem:** Le profil ne réconcilie l'abonnement après le paywall que si l'utilisateur était gratuit. Une restauration, une expiration ou un retour tardif peut laisser le profil et ses capacités dans un état erroné.

**Approach:** Caractériser puis centraliser les transitions d'achat et de restauration. Un droit premium est exposé uniquement après confirmation de l'entitlement `pro` par RevenueCat pour la session Firebase courante. Le profil conserve son parcours existant et propose la restauration.

## Boundaries & Constraints

**Always:** Conserver les données de cartes, traductions, préférences et compte pour tous les résultats. Garder le contrôle uid/génération avant toute mutation du cache et de l'état. Une annulation, une attente ou un échec ne crée pas de droit premium. Une expiration confirmée retire les droits affichés sans supprimer les données. Les dépendances sont injectables par Riverpod et les états UI sont typés et immuables.

**Ask First:** Aucune décision métier additionnelle identifiée. L'utilisateur a autorisé l'implémentation sans validation ; les commandes Flutter, Dart et Git lui sont réservées.

**Never:** Modifier les sources générées, supprimer RevenueCat ou la logique de session historique, modifier les limites gratuites de la story 5.3.

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Résultat | Erreur |
|----------|---------------|----------|--------|
| Achat ou restauration | Résultat positif et entitlement `pro` actif | Premium dans le profil et le cache de la session | Aucun |
| Annulation ou attente | Pas d'entitlement confirmé | Pas de nouveau droit, données conservées | Retour UI non bloquant |
| Échec réseau | Consultation RevenueCat échoue | Droits précédents conservés, erreur visible | Réessai possible |
| Expiration | Entitlement absent lors d'une réconciliation réussie | Droits retirés, données conservées | Aucun |
| Changement de compte | Retour tardif de l'ancien achat | Aucun droit appliqué au nouveau compte | Résultat ignoré |

</frozen-after-approval>

## Code Map

- `lib/core/services/revenuecat_service.dart` — identité RevenueCat sérialisée, paywall et lecture de `pro`; SDK `PaywallResult` permet de distinguer achat/restauration/annulation.
- `lib/core/services/user_manager.dart` — orchestration actuelle du paywall et synchronisation cache/notifier protégée par uid et génération.
- `lib/core/providers/user_data_provider.dart` — `isSubscribedProvider` consommé par le profil et les capacités.
- `lib/features/profile/profile_page.dart` — bouton de souscription et statut ; doit consommer un état UI typé.
- `lib/features/authentication/auth_session_repository.dart` — hydratation de la session au démarrage, appelle déjà RevenueCat.
- `test/core/services/user_manager_test.dart`, `test/core/services/revenuecat_service_test.dart` — baselines et points de tests des transitions.
- `lib/l10n/app_*.arb` — chaînes traduites ; les fichiers `app_localizations*.dart` sont générés et intouchables.

## Tasks & Acceptance

**Execution:**
- [x] `test/core/services/user_manager_test.dart` — caractériser achat, restauration, annulation, échec, expiration et retour tardif avant modification.
- [x] `lib/core/services/revenuecat_service.dart` et `test/core/services/revenuecat_service_test.dart` — exposer résultat du paywall et restauration ainsi que confirmation d'entitlement.
- [x] `lib/core/services/user_manager.dart` — réconcilier les droits à chaque résultat pertinent sous garde de session.
- [x] `lib/features/profile/` — fournir ViewModel et état immutable injectables ; relier le profil à l'achat et à la restauration.
- [x] `lib/l10n/app_*.arb` — ajouter les libellés nécessaires ; faire régénérer la localisation par l'utilisateur.

**Acceptance Criteria:**
- Given un achat ou une restauration et `pro` confirmé, when l'opération aboutit, then le profil expose immédiatement premium.
- Given un achat annulé, en attente ou échoué, when l'opération se termine, then aucun droit nouveau n'est accordé et les données sont conservées.
- Given un entitlement expiré, when RevenueCat confirme l'absence de `pro`, then le profil revient au statut gratuit sans effacer les données.
- Given un changement de session, when une ancienne opération RevenueCat se termine, then elle ne modifie pas le nouveau profil.

## Spec Change Log

## Verification

**Commands:**
- `flutter test test/core/services/user_manager_test.dart test/core/services/revenuecat_service_test.dart` — transitions et gardes de session couvertes.
- `flutter gen-l10n` — localisations régénérées depuis les ARB.
- `flutter analyze` — aucune erreur d'analyse.

**Résultats transmis par l'utilisateur :** `flutter gen-l10n` réussi ; tests ciblés initiaux (27) réussis ; tests des quatre fichiers modifiés ou créés réussis ; analyse des fichiers Dart suivis sans diagnostic. Le seul diagnostic des fichiers non suivis (`prefer_const_constructors`) a été corrigé ensuite dans le test widget, sans nouvelle exécution de l'analyse.

## Suggested Review Order

**Réconciliation des droits**

- Contrôle les retours d'achat et de restauration par session et ordre d'opération.
  [user_manager.dart:219](../../lib/core/services/user_manager.dart#L219)

- Confirme l'entitlement `pro` et distingue les résultats du paywall.
  [revenuecat_service.dart:98](../../lib/core/services/revenuecat_service.dart#L98)

- Rafraîchit les droits au retour d'un paiement web.
  [main.dart:44](../../lib/main.dart#L44)

**Profil et autres accès au paywall**

- Expose les actions et retours localisés dans le profil.
  [profile_subscription_section.dart:8](../../lib/features/profile/profile_subscription_section.dart#L8)

- Maintient un état UI typé et synchronisé avec les droits.
  [profile_subscription_view_model.dart:31](../../lib/features/profile/profile_subscription_view_model.dart#L31)

- Traite les erreurs d'achat depuis les tables et la traduction.
  [data_table_tab.dart:98](../../lib/features/data/data_table_tab.dart#L98)

- Applique le même traitement au parcours de traduction.
  [translate_tab.dart:155](../../lib/features/translation/translate_tab.dart#L155)

**Vérification**

- Couvre les transitions, expirations et réponses tardives.
  [user_manager_test.dart:41](../../test/core/services/user_manager_test.dart#L41)

- Vérifie l'action de restauration et le statut affiché.
  [profile_subscription_section_test.dart:14](../../test/features/profile/profile_subscription_section_test.dart#L14)

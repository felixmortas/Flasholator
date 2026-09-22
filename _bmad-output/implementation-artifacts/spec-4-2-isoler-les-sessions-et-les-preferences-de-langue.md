---
title: 'Story 4.2 — Isoler les sessions et les préférences de langue'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: 'NO_VCS'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="intention utilisateur — modification sur instruction explicite seulement">

## Intent

**Problem:** Le cache et l'état utilisateur sont globaux. Une réponse tardive de l'ancien compte peut réécrire son couple de langues ou ses droits après une déconnexion ou un changement de compte.

**Approach:** Faire porter l'uid et la génération par les opérations de session, purger les données de l'ancienne session avant de publier la suivante, et restaurer le couple de langues du compte courant depuis Firestore.

## Boundaries & Constraints

**Always:** Conserver Firebase, Firestore, RevenueCat et les parcours visibles. Garder les dépendances surchargeables en test, les états UI immuables, et caractériser les transitions avant de modifier les services. Préserver les préférences hors session.

**Ask First:** Aucune décision supplémentaire prévue.

**Never:** Modifier les fichiers générés, initialiser un SDK dans une vue ou un ViewModel, ou supprimer un service legacy encore consommé. Ne pas étendre à la gestion des abonnements de l'epic 5.

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Comportement attendu | Erreur |
|---|---|---|---|
| Préférence | A choisit un couple, puis revient | Le couple de A est restauré | Échec persistance : état antérieur conservé |
| Changement | A se déconnecte puis B arrive | Cache et droits de A effacés avant B | Erreur purge : aucun état prêt de B |
| Réponse tardive | Hydratation ou mutation de A finit après transition | Aucun cache, droit ou couple de A ne devient visible | Résultat ignoré |
| Même uid | A sort puis revient | La nouvelle génération invalide les anciennes opérations | Résultat ignoré |

</frozen-after-approval>

## Code Map

- `lib/features/authentication/auth_session_repository.dart` — `_accept`, `signOut`, état et génération ; la garde actuelle protège `ready` mais pas les écritures internes.
- `lib/core/services/user_manager.dart` — hydratation, mutations, déconnexion et effacement ; `syncLocalFromFirestore` et `syncNotifierFromCache` écrivent sans garde interne.
- `lib/core/services/user_preferences_service.dart` — clés de cache globales ; `clearUserData` efface actuellement tout SharedPreferences.
- `lib/core/providers/user_data_provider.dart` — état partagé couple, compteur et droits ; conserver ses consommateurs pendant la migration.
- `lib/features/translation/translation_providers.dart` — contexte de traduction actuellement dissocié de la génération de session réelle.
- `lib/core/services/db_wrapper.dart`, `lib/features/flashcards/flashcard_providers.dart` — Drift utilise une base globale sans uid ; isoler les cartes et leurs projections par compte sans éditer le fichier généré.
- `lib/features/home_page.dart`, `lib/features/translation/translate_tab.dart`, `lib/features/shared/utils/language_selection.dart` — sélection et restitution du couple ; singleton à réinitialiser entre comptes.
- `test/features/authentication/auth_session_repository_test.dart`, `test/core/services/user_manager_test.dart` — points de caractérisation des courses et des préférences.
- `lib/l10n/app_localizations*.dart`, `lib/core/services/db_wrapper.g.dart` — générés, lecture seule.

## Tasks & Acceptance

**Execution:**
- [x] `test/features/authentication/auth_session_repository_test.dart`, `test/core/services/user_manager_test.dart` — caractériser la restauration, la purge et les réponses tardives avec `Completer` avant modification.
- [x] `lib/features/authentication/auth_session_repository.dart` — sérialiser les transitions, invalider l'ancienne génération immédiatement et attendre la purge avant l'état suivant.
- [x] `lib/core/services/user_manager.dart`, `lib/core/services/user_preferences_service.dart` — borner les écritures par uid/génération, persister le couple du compte courant et effacer uniquement le cache utilisateur.
- [x] `lib/features/translation/translation_providers.dart`, composants de choix de langue — propager la génération réelle et réinitialiser l'état de choix lors des transitions.
- [x] `lib/core/services/db_wrapper.dart`, `lib/features/flashcards/flashcard_providers.dart` et consommateurs — empêcher qu'un compte voie les cartes Drift d'un autre, tout en préservant les données du compte précédent.
- [x] `test/` — couvrir le changement de compte, le même uid reconnecté, les erreurs de purge et la conservation des préférences hors session.

**Acceptance Criteria:**
- Given un utilisateur authentifié, when il choisit un couple de langues puis rouvre sa session, then son couple est restauré.
- Given une déconnexion ou un changement de compte, when une ancienne opération aboutit, then elle n'altère ni le cache ni les données ou droits du compte courant.
- Given un changement de session, when l'état suivant devient visible, then le cache de la session précédente est déjà purgé.
- Given des cartes enregistrées par A, when B se connecte puis A revient, then B ne voit pas les cartes de A et A les retrouve.

## Spec Change Log

## Design Notes

La génération protège l'écriture effective, pas seulement la publication finale du repository. La purge est ordonnée avec les écritures en cours. Le cache local porte l'uid propriétaire pour conserver le compteur lors d'une restauration du même compte.

La base Drift historique globale ne porte aucun uid. Elle reste intacte mais isolée des sessions par compte : attribuer automatiquement ses cartes à un compte risquerait de montrer les cartes d'un autre utilisateur.

## Verification

**Commandes à faire exécuter par l'utilisateur :**
- `flutter analyze` — aucune erreur.
- `flutter test` — suite verte.

**Résultats transmis le 2026-09-23 :** analyse ciblée sans erreur bloquante (21 diagnostics info/warning avant la dernière correction) ; cinq fichiers de tests modifiés verts ; suite complète `flutter test` verte après les ajouts. Les revues automatisées parallèles ont échoué sur une limite d'usage de l'outil ; revue directe effectuée et corrections intégrées.

## Suggested Review Order

**Transitions de session**

- Le repository invalide la génération et purge avant de publier le compte suivant.
  [`auth_session_repository.dart:39`](../../lib/features/authentication/auth_session_repository.dart#L39)

- Le profil passe par le propriétaire de session pour la déconnexion.
  [`profile_page.dart:71`](../../lib/features/profile/profile_page.dart#L71)

- Les écritures et le cache suivent l'uid et la génération courants.
  [`user_manager.dart:37`](../../lib/core/services/user_manager.dart#L37)

- RevenueCat ordonne les changements d'identité concurrents.
  [`revenuecat_service.dart:24`](../../lib/core/services/revenuecat_service.dart#L24)

**Données personnelles**

- Les préférences locales conservent le propriétaire du cache.
  [`user_preferences_service.dart:7`](../../lib/core/services/user_preferences_service.dart#L7)

- Le fichier Drift est nommé par uid sans changer le schéma généré.
  [`db_wrapper.dart:40`](../../lib/core/services/db_wrapper.dart#L40)

- La collection de cartes suit la session authentifiée.
  [`flashcard_providers.dart:13`](../../lib/features/flashcards/flashcard_providers.dart#L13)

- La traduction emploie la génération de session réelle.
  [`translation_providers.dart:37`](../../lib/features/translation/translation_providers.dart#L37)

**Vérification**

- La reconnexion restaure le couple de langues choisi.
  [`user_manager_test.dart:199`](../../test/core/services/user_manager_test.dart#L199)

- Les cartes de A restent séparées de B après réouverture.
  [`db_wrapper_session_test.dart:18`](../../test/core/services/db_wrapper_session_test.dart#L18)

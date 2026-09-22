---
title: 'Story 4.1 — Authentifier et restaurer une session utilisateur'
type: 'feature'
created: '2026-09-22'
status: 'done'
baseline_commit: '29899a72043bb78bd67c3476e690ca8b02fae991'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="intention utilisateur — ne modifier que sur instruction explicite">

## Intent

**Problem:** La session Firebase restaurée ouvre l’accueil avant la synchronisation du profil, alors que l’identification RevenueCat dépend de plusieurs chemins. Les erreurs de connexion Firebase sont absorbées, ce qui masque l’échec réel.

**Approach:** Donner à la fonctionnalité authentification un état de session unique et testable, alimenté par Firebase et hydraté avant l’accès à l’espace utilisateur. Conserver les parcours visibles d’inscription, de vérification et de connexion, avec leurs erreurs, et identifier RevenueCat une fois la session connue.

## Boundaries & Constraints

**Always:** Préserver Firebase, Firestore, RevenueCat, les traductions et le bootstrap existant ; injecter les dépendances via Riverpod ; exposer un état UI typé et immuable ; caractériser les comportements avant leur remplacement. La session restaurée doit être reconnue sans ressaisie et RevenueCat ne doit être configuré qu’une fois par processus.

**Ask First:** Aucune décision prévue dans ce périmètre.

**Never:** Modifier les fichiers générés, déplacer l’initialisation des SDK dans une vue ou un ViewModel, supprimer un service historique encore consommé, ou étendre cette story à la persistance du couple de langues et à l’isolation complète des comptes (story 4.2).

## I/O & Edge-Case Matrix

| Scénario | Entrée / état | Comportement attendu | Erreur |
|---|---|---|---|
| Restauration | Firebase émet un utilisateur vérifié | Attente pendant l’hydratation, puis accueil avec profil et droits de cet utilisateur | État d’erreur récupérable ; aucun accueil avec état incomplet |
| Connexion | Identifiants valides ou invalides | Session hydratée si succès ; message d’erreur si échec | Erreur Firebase conservée pour l’UI |
| Inscription | Formulaire valide | Création, nom et courriel de vérification ; retour visible existant | Erreur affichée, chargement terminé |
| Vérification | Courriel confirmé ou non | Accès après actualisation ; sinon message existant | Erreur affichée, action réessayable |
| RevenueCat | Démarrage avec session puis connexion | Configuration unique et identification de l’uid courant | Échec signalé sans fausse session prête |

</frozen-after-approval>

## Code Map

- `lib/core/services/auth_service.dart` — adaptateur Firebase ; `login` absorbe actuellement l’exception, comportement fixé par `test/core/services/auth_service_test.dart`.
- `lib/core/services/auth_gate.dart` — route selon `authStateChanges` et `userSyncStateProvider` initialement vrai ; l’accueil peut apparaître avant hydratation.
- `lib/core/services/user_manager.dart` — inscription, connexion, vérification, hydratation Firestore/cache et RevenueCat ; conserver ses autres consommateurs.
- `lib/core/bootstrap/application_bootstrap.dart` — `RevenueCatSessionBootstrapStep` initialise RevenueCat pour `currentUser` ; `main.dart` attend le bootstrap.
- `lib/core/services/revenuecat_service.dart` — garde statique de configuration et identification via `Purchases.logIn`.
- `lib/features/authentication/{login_page,register_page,email_verification_pending_page}.dart` — rendus et interactions actuels ; `lib/features/home_page.dart` charge le cache après entrée.
- `lib/core/providers/{auth_service_provider,user_manager_provider,revenuecat_provider}.dart` — frontières Riverpod surchargeables.
- `test/core/services/{auth_service_test,user_manager_test}.dart`, `test/core/bootstrap/application_bootstrap_test.dart` — baseline et points d’extension.
- `lib/l10n/app_localizations*.dart`, `lib/core/services/db_wrapper.g.dart` — fichiers générés en lecture seule.

## Tasks & Acceptance

**Execution:**
- [x] `test/core/services/auth_service_test.dart`, nouveaux tests de session — caractériser erreurs, restauration et identification avant modification.
- [x] `lib/core/services/auth_service.dart`, `lib/core/services/user_manager.dart` — faire remonter l’échec Firebase et fiabiliser la séquence d’hydratation sans casser les autres opérations.
- [x] `lib/features/authentication/` et providers associés — introduire repository de session et ViewModels injectables ; raccorder portail et écrans aux états typés.
- [x] `lib/core/bootstrap/application_bootstrap.dart`, `lib/core/services/revenuecat_service.dart` — centraliser la transition RevenueCat et éviter une configuration doublée.
- [x] `test/` — vérifier les états, erreurs et transitions pertinentes avec dépendances surchargées.

**Acceptance Criteria:**
- Given une session Firebase valide au démarrage, when elle est restaurée, then l’application expose l’utilisateur authentifié après hydratation sans nouvelle connexion.
- Given une inscription, une vérification ou une connexion Firebase, when elle réussit ou échoue, then les états et erreurs visibles restent cohérents avec le parcours existant.
- Given une session restaurée ou une connexion, when RevenueCat est préparé, then sa configuration est unique et l’uid courant est identifié.

## Spec Change Log

## Design Notes

Le repository est le propriétaire de l’état de session. La story 4.1 prépare l’uid et la génération nécessaires à la story 4.2 sans revendiquer ici l’isolation complète du cache global existant. Les vues ne reçoivent que des états et intentions ; les SDK restent derrière les adaptateurs.

## Verification

**Commands à faire exécuter par l’utilisateur :**
- `flutter analyze` — aucune erreur.
- `flutter test` — suite verte.

**Résultats transmis le 2026-09-22 :** les tests ciblés de l’authentification passent ; l’analyse ciblée ne signale aucune erreur (9 diagnostics de niveau info/warning).

## Suggested Review Order

**Entrée et restauration**

- Le portail attend la session prête avant de rendre l’accueil.
  [`auth_gate.dart:10`](../../lib/core/services/auth_gate.dart#L10)

- Le repository possède les transitions et l’hydratation du compte restauré.
  [`auth_session_repository.dart:38`](../../lib/features/authentication/auth_session_repository.dart#L38)

- La séquence protège l’état prêt contre une réponse périmée.
  [`auth_session_repository.dart:62`](../../lib/features/authentication/auth_session_repository.dart#L62)

**Actions et intégrations**

- Les actions UI exposent chargement, succès et erreur sans SDK.
  [`auth_view_model.dart:14`](../../lib/features/authentication/auth_view_model.dart#L14)

- La connexion et la vérification réutilisent la session hydratée.
  [`auth_session_repository.dart:124`](../../lib/features/authentication/auth_session_repository.dart#L124)

- RevenueCat garde une configuration unique et traite la déconnexion précoce.
  [`revenuecat_service.dart:24`](../../lib/core/services/revenuecat_service.dart#L24)

**Vérification**

- Les tests couvrent restauration, erreurs et courses de session.
  [`auth_session_repository_test.dart:41`](../../test/features/authentication/auth_session_repository_test.dart#L41)

- Le test du portail vérifie attente, erreur et reprise.
  [`auth_gate_test.dart:28`](../../test/core/services/auth_gate_test.dart#L28)

- Les tests RevenueCat vérifient configuration et identification par uid.
  [`revenuecat_service_test.dart:15`](../../test/core/services/revenuecat_service_test.dart#L15)

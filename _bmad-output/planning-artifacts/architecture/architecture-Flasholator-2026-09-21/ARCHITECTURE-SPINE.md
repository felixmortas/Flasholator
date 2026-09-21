---
name: 'Flasholator — migration MVVM/Riverpod'
type: architecture-spine
purpose: build-substrate
altitude: initiative
paradigm: 'MVVM par fonctionnalité, architecture en couches et ports-adaptateurs'
scope: 'Migration comportementale progressive de Flasholator vers MVVM/Riverpod : cartes, review, traduction, tables, authentification, profil, statistiques et monétisation.'
status: final
created: '2026-09-21'
updated: '2026-09-21'
binds: [CAP-1, CAP-2, CAP-3, CAP-4, CAP-5, CAP-6]
sources:
  - '_bmad-output/specs/spec-migration-mvvm-riverpod/.memlog.md'
  - 'AGENTS.md'
  - 'README.md'
companions: ['_bmad-output/specs/spec-migration-mvvm-riverpod/.memlog.md']
---

# Architecture Spine — Flasholator

## Design Paradigm

**MVVM par fonctionnalité, avec couches data et domaine optionnelle.** Une feature possède sa vue, son ViewModel et son état UI ; elle consomme ses contrats de repository. Les services/adaptateurs encapsulent exactement une intégration externe. Un cas d'usage est ajouté seulement pour une règle métier complexe ou partagée.

~~~mermaid
flowchart LR
  V[Vue / widgets] --> VM[ViewModel + état UI]
  VM --> U[Cas d'usage facultatif]
  VM --> R[Repository / port]
  U --> R
  R --> S[Service / adaptateur]
  S --> X[(SDK, réseau, stockage, plateforme)]
  P[Providers Riverpod] -. compose / injecte .-> VM
  P -. compose / injecte .-> R
  P -. compose / injecte .-> S
~~~

## Invariants & Rules

### AD-1 — Frontières MVVM par feature [ADOPTED]

- **Binds:** CAP-2 à CAP-5 ; toutes les features migrées.
- **Prevents:** widgets qui lisent Drift/Firebase/DeepL/RevenueCat/AdMob ou services qui font de la présentation.
- **Rule:** Une vue rend l'état et transmet des intentions. Un ViewModel orchestre l'état UI et dépend de cas d'usage ou repositories. Un repository dépend de services/adaptateurs, jamais de Flutter UI ni d'un ViewModel. Toute dépendance va de gauche à droite dans le diagramme ; les dépendances inverses sont interdites.

### AD-2 — Riverpod : graphe unique d'injection et d'état [ADOPTED]

- **Binds:** CAP-1 à CAP-5 ; `lib/main.dart`, `lib/core/`, toutes les features.
- **Prevents:** instanciations concrètes dans les vues, singletons cachés, `Map<String, dynamic>` partagé et providers concurrents pour la même donnée.
- **Rule:** `ProviderScope` est la racine. Les providers créent les adaptateurs, repositories, cas d'usage et ViewModels de leur propriétaire ; chaque dépendance testable est surchargeable. Un état partagé a un seul repository propriétaire ; les états temporaires d'écran appartiennent à son ViewModel. Les providers legacy ne sont supprimés qu'après bascule de leurs consommateurs.

### AD-3 — États UI immuables et erreurs préservées

- **Binds:** CAP-1, CAP-2, CAP-3, CAP-4, CAP-5.
- **Prevents:** logique métier dans `StatefulWidget`, états partiels incompatibles et changement involontaire de feedback utilisateur.
- **Rule:** Chaque ViewModel public expose un état immuable aux phases `initial`, `loading`, `data` et `error`, avec erreur applicative typée. Les commandes mutantes sont sérialisées/idempotentes ; une requête remplaçable porte un contexte ou `requestId` et n'applique son résultat que s'il reste courant. Les effets uniques ne sont émis qu'une fois par commande acceptée. Les vues n'ont que layout, animation, navigation simple et rendu conditionnel. Pendant cette migration, les erreurs visibles conservent leur comportement existant.

### AD-4 — Contrats de domaine et adaptateurs de données

- **Binds:** CAP-1 à CAP-5 ; modèles, persistance, réseau et SDK.
- **Prevents:** DTO `FlashcardData`, `DocumentSnapshot`, `CustomerInfo` ou API Flutter dans les contrats consommés par les features.
- **Rule:** Les modèles de domaine et interfaces de repository sont purs Dart. Les services encapsulent une seule source externe (Drift, Firebase Auth, Firestore, SharedPreferences, DeepL, RevenueCat, AdMob, UMP/ATT ou channel de plateforme). Les repositories possèdent mapping, cache, cohérence lecture/écriture et traduction d'erreurs sans changer leur comportement exposé pendant migration.

### AD-5 — Collection de cartes et paire réversible atomiques

- **Binds:** CAP-1, CAP-3, CAP-4 ; flashcards, review, tables et statistiques.
- **Prevents:** ajout, édition ou suppression d'un seul côté d'une paire ; contournement de SM-2 ; lecture de données Drift hors repository.
- **Rule:** `FlashcardRepository` est l'unique propriétaire de la collection locale. Son adaptateur Drift réalise `addPair`, `editPair` et `deletePair` dans un `AppDatabase.transaction(...)`. Tant que le schéma ne fournit pas de `PairId`, recherche, précondition et mutation utilisent dans cette transaction une clé canonique et ciblent exactement une paire ; le résultat est `applied`, `notFound` ou `conflict`. Il expose un snapshot versionné ou flux invalidé après commit, commun aux projections review/tables/stats. Les règles SM-2 et la compatibilité des enregistrements existants sont caractérisées avant déplacement. Toute évolution du schéma est une migration Drift explicite, avec régénération de `db_wrapper.g.dart` depuis sa source.

### AD-6 — Session utilisateur : un propriétaire, des adaptateurs

- **Binds:** CAP-1, CAP-2, CAP-5 ; authentification, profil, limite de traduction et premium.
- **Prevents:** plusieurs sources de vérité entre Firebase, cache local, RevenueCat et `userDataProvider`.
- **Rule:** `UserSessionRepository` possède `anonymous`, `hydrating(uid,generation)`, `authenticated(snapshot)` ou `signingOut`. Firebase Auth est maître ; Firestore est la source profil/droits, SharedPreferences un accélérateur et RevenueCat la source entitlement. Toute opération porte le `uid` et la `generation` capturés : un résultat tardif est ignoré. Logout/changement de compte invalide les opérations, purge le cache, réconcilie RevenueCat, puis expose `anonymous`. Les états UI utilisent des types dédiés, jamais une `Map<String, dynamic>`.

### AD-7 — Bootstrap et secrets hors UI

- **Binds:** CAP-2, CAP-5 ; `main.dart`, configuration native, adaptateurs externes.
- **Prevents:** initialisations SDK répétées depuis les écrans, clés dans le domaine/UI et cycles de vie contradictoires.
- **Rule:** Le bootstrap initialise Flutter, Firebase via `DefaultFirebaseOptions` et Ads avant `ProviderScope`. L'adaptateur de session configure RevenueCat une fois après restauration Firebase, puis applique identification/déconnexion aux transitions. La migration ne déplace ni ne crée de secret dans la vue, le ViewModel ou le domaine. Ni une vue ni un ViewModel n'initialisent ces SDK.

### AD-8 — Migration caractérisée, bascule complète, retrait vérifié

- **Binds:** CAP-1 à CAP-6 ; toutes les tranches de migration.
- **Prevents:** régressions comportementales et suppression prématurée du legacy.
- **Rule:** Chaque tranche ajoute d'abord ses tests de caractérisation déterministes, migre ensuite une feature complète vers le chemin cible, puis vérifie `flutter analyze` et `flutter test`. Le registre de retrait consigne par legacy : remplaçant, consommateurs migrés, tests et recherche de références. Sa suppression est un changement Git dédié et réversible.

### AD-9 — Sources générées et localisation [ADOPTED]

- **Binds:** CAP-2 à CAP-5 ; `lib/l10n/`, Drift.
- **Prevents:** divergence entre ARB et Dart généré, ou texte localisé couplé au domaine.
- **Rule:** Les fichiers ARB sont la source de vérité. `lib/l10n/app_localizations*.dart` et `lib/core/services/db_wrapper.g.dart` ne sont jamais modifiés directement ; leurs sources changent puis sont régénérées. Les clés localisées sont résolues dans la présentation ou un adaptateur de présentation, jamais dans le domaine.

### AD-10 — Enveloppe d'exploitation conservée

- **Binds:** CAP-1 à CAP-6 ; iOS, Android, CI et intégrations distantes.
- **Prevents:** changement d'environnement ou de synchronisation implicite sous couvert de migration.
- **Rule:** La cible reste iOS/Android. GitHub Actions exécute `flutter analyze` et `flutter test` avec Flutter 3.32.5 à chaque `push` et `pull_request`. Les versions Stack sont les résolutions du lockfile au 2026-09-21 ; toute mise à jour est un changement de compatibilité testé. Le mode offline local des cartes est conservé ; aucune synchronisation cloud des cartes ni évolution produit n'est introduite par ce chantier.

### AD-11 — Projections statistiques uniques

- **Binds:** CAP-1, CAP-5 ; statistiques et futurs consommateurs de métriques de cartes.
- **Prevents:** comptage incohérent des paires, couples de langues incompatibles ou classements divergents.
- **Rule:** `StatisticsUseCase` possède les projections sur le snapshot de `FlashcardRepository` : dédoublonnage des paires, couples de langues non orientés, séries/moyennes par paire et classements décroissants limités à cinq. Les ViewModels de statistiques ne consomment que son résultat typé.

## Consistency Conventions

| Concern | Convention |
| --- | --- |
| Nommage | `*_view.dart`, `*_view_model.dart`, `*_ui_state.dart`, `*_repository.dart`, `*_service.dart`; une feature est nommée d'après le parcours utilisateur. |
| Providers | `<feature><Role>Provider`; les providers d'infrastructure restent privés à leur module sauf contrat nécessaire ailleurs. |
| Données | Les IDs et dates restent ceux de la persistance existante. DTO et modèles générés ne franchissent pas la frontière du repository. |
| État et mutations | Intentions de vue → méthode du ViewModel → cas d'usage/repository. Aucun widget n'écrit directement un état partagé. |
| Erreurs | Préserver les sorties observables actuelles ; normaliser seulement à l'intérieur d'un repository/adaptateur, sans modifier la présentation avant une SPEC dédiée. |
| Tests | Domaine/cas d'usage : unitaires purs ; repositories/adaptateurs : doublures ou base temporaire ; ViewModels : `ProviderContainer` avec overrides ; vues : widget tests ciblés. |

## Stack

| Name | Version |
| --- | --- |
| Flutter / Dart SDK CI (résolu au 2026-09-21) | 3.32.5 / SDK `>=3.0.3 <4.0.0` |
| flutter_riverpod | 2.6.1 |
| Drift / drift_flutter | 2.28.1 / 0.2.5 |
| Firebase Core / Auth / Firestore | 3.15.2 / 5.7.0 / 5.6.12 |
| RevenueCat Flutter / UI | 9.2.0 / 9.2.0 |
| Google Mobile Ads | 6.0.0 |

## Structural Seed

~~~text
lib/
  app/                         # bootstrap, composition et navigation racine
  core/
    infrastructure/             # adaptateurs SDK et configuration de plateforme
    shared/                     # domaine transverse minimal et utilitaires sans feature
  features/
    flashcards/                 # repository cartes, domaine et sources Drift
    review/                     # view, viewmodel, état UI ; utilise flashcards
    translation/                # view, viewmodel, état UI ; DeepL via adaptateur
    data/                       # tables de cartes et actions de collection
    authentication/             # session auth et écrans dédiés
    profile/                    # profil, cache session et premium
    stats/                      # calculs et rendu de statistiques
    shared/                     # widgets réutilisables sans logique de feature
  l10n/                         # ARB source et code généré
~~~

~~~mermaid
flowchart TB
  App[app/bootstrap] --> Firebase[Firebase options + Firebase Core]
  App --> Scope[ProviderScope]
  Scope --> Features[Features MVVM]
  Features --> CardRepo[FlashcardRepository]
  Features --> SessionRepo[UserSessionRepository]
  Features --> TranslateRepo[TranslationRepository]
  CardRepo --> Drift[(SQLite / Drift)]
  SessionRepo --> Auth[Firebase Auth]
  SessionRepo --> Firestore[Cloud Firestore]
  SessionRepo --> Prefs[SharedPreferences]
  SessionRepo --> RC[RevenueCat]
  TranslateRepo --> DeepL[DeepL API]
  Features --> Ads[AdMob / UMP / ATT adapter]
  Features --> Platform[Android method channel]
~~~

## Capability → Architecture Map

| Capability / Area | Lives in | Governed by |
| --- | --- | --- |
| CAP-1 — Tests de caractérisation | `test/` par feature, domaine et repositories | AD-2, AD-5, AD-6, AD-8 |
| CAP-2 — Conventions MVVM/Riverpod | `app/`, `core/`, chaque feature | AD-1, AD-2, AD-3, AD-4 |
| CAP-3 — Flashcards/review | `features/flashcards/`, `features/review/` | AD-3, AD-4, AD-5, AD-8 |
| CAP-4 — Traduction/tables | `features/translation/`, `features/data/` | AD-1, AD-3, AD-4, AD-8 |
| CAP-5 — Auth/profil/stats/monétisation | `features/authentication/`, `profile/`, `stats/`, adaptateurs | AD-3, AD-4, AD-6, AD-7, AD-10 |
| CAP-6 — Retrait legacy | modules legacy ciblés après bascule | AD-2, AD-8, AD-9 |

## Deferred

- **Mise à niveau Riverpod 3.x et Flutter courant :** hors migration comportementale ; à planifier comme chantier de compatibilité dédié après stabilisation sur les versions verrouillées.
- **Identifiant de paire persistant et remaniement du schéma Flashcards :** non requis pour préserver les données actuelles ; à décider seulement si une évolution produit impose une relation durable explicite.
- **Synchronisation cloud des cartes, import/export, groupes et autres éléments de roadmap :** évolution produit, pas migration d'architecture.
- **Politique détaillée de télémétrie, observabilité et crash reporting :** l'exploitation actuelle ne l'exige pas ; décider avant d'ajouter un nouvel opérateur ou SDK.
- **Évolution du feedback utilisateur et des erreurs :** suspendue jusqu'à une SPEC produit dédiée ; les comportements existants restent le contrat de migration.
- **Relais et rotation DeepL :** dette de sécurité critique constatée dans le client existant, hors périmètre brownfield car aucun backend, ownership ni déploiement ne sont définis. À traiter dans une architecture dédiée avant toute nouvelle exposition ; la migration ne doit pas propager ce secret.

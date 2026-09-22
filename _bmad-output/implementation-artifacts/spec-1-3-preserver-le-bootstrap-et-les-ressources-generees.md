---
title: 'Story 1.3 — Préserver le bootstrap et les ressources générées'
type: 'feature'
created: '2026-09-21'
status: 'done'
review_loop_iteration: 0
baseline_commit: 'b79d634'
context:
  - '{project-root}/AGENTS.md'
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le démarrage initialise actuellement Ads avant Firebase, appelle une initialisation Ads non vérifiable depuis `main`, et déclenche consentement, préchargement publicitaire et RevenueCat depuis `HomePage`. Ces initialisations SDK dans une vue ne garantissent ni une composition unique ni une base testable.

**Approach:** Centraliser le bootstrap de production derrière des dépendances injectables, l’exécuter dans l’ordre Flutter, Firebase, Ads avant `ProviderScope`, puis déplacer les initialisations SDK qui sont aujourd’hui portées par la vue vers cette composition. Conserver les ARB et la source Drift comme seules sources modifiables, et prouver la disponibilité FR/EN/ES.

## Boundaries & Constraints

**Always:** Préserver Firebase, Drift, RevenueCat, AdMob/UMP/ATT et le comportement utilisateur ; initialiser Flutter, Firebase avec `DefaultFirebaseOptions`, puis Ads exactement une fois avant `ProviderScope` ; ne construire aucun SDK dans une vue ou un ViewModel ; utiliser les ARB et `db_wrapper.dart` comme sources de vérité ; rendre la composition Riverpod surchargeable dans les tests sans réseau ni SDK réel.

**Ask First:** Toute modification de clé, d’offre RevenueCat, de consentement visible, de texte localisé, de schéma Drift ou de parcours d’authentification.

**Never:** Ne pas modifier directement `lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart` ; ne pas migrer les écrans flashcards, traduction, auth/profil ou statistiques au-delà du retrait de leurs initialisations SDK ; ne pas introduire de nouvelle règle métier ou de synchronisation cloud.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| Démarrage nominal | Bootstrap de production | Binding, Firebase puis Ads s’exécutent une fois, puis `ProviderScope` reçoit l’application | Une erreur du bootstrap remonte sans lancer une application partiellement composée |
| Test isolé | Bootstrap avec adaptateurs fake | L’ordre et l’unicité sont observables sans plugin, réseau ni SDK | Le fake en échec arrête la séquence avant l’étape suivante |
| Localisation générée | Une locale `fr`, `en` ou `es` | `MyApp` expose les délégués et locales de `AppLocalizations` générés depuis les ARB | Toute locale hors contrat reste traitée par Flutter comme aujourd’hui |

</frozen-after-approval>

## Code Map

- `lib/main.dart` — point d’entrée actuel : binding, Ads puis Firebase et `ProviderScope`; remplacer l’orchestration statique par le bootstrap et réutiliser les listes générées de `AppLocalizations`.
- `lib/core/services/ad_service.dart` — encapsule `MobileAds.instance.initialize` et sa configuration ; conserver l’adaptateur, rendre l’initialisation déléguée et idempotente par le bootstrap.
- `lib/core/services/consent_manager.dart` — adaptateur UMP appelé aujourd’hui depuis la vue ; composer son initialisation hors UI sans modifier le consentement rendu.
- `lib/core/services/revenuecat_service.dart` et `lib/core/services/user_manager.dart` — configuration RevenueCat aujourd’hui déclenchée depuis `HomePage` et au login ; centraliser son cycle de session dans un service/provider testable, sans changer droits ni offres.
- `lib/features/home_page.dart` — retirer `ConsentManager.initialize`, préchargement Ads et `initRevenueCat` de l’initialisation de la vue ; conserver les interactions Android et la synchronisation de cache.
- `lib/core/providers/ad_provider.dart`, `lib/core/providers/revenuecat_provider.dart`, `lib/core/providers/user_manager_provider.dart` — points de composition à compléter et surcharger ; préserver les consumers legacy.
- `lib/l10n/app_en.arb`, `lib/l10n/app_fr.arb`, `lib/l10n/app_es.arb`, `l10n.yaml` — sources l10n ; les quatre `app_localizations*.dart` sont générés en lecture seule.
- `lib/core/services/db_wrapper.dart` — source Drift ; `lib/core/services/db_wrapper.g.dart` est généré en lecture seule.
- `test/widget_test.dart` — test racine existant à adapter au `ProviderScope` et aux locales générées.
- `test/core/services/flashcards_service_test.dart` — référence de test isolé Drift avec `MemoryDatabase`, sans modifier le généré.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/bootstrap/` — créer les contrats/adaptateurs et l’orchestrateur de bootstrap injectables, idempotents et testables ; séquencer binding, Firebase et Ads avant toute construction de `ProviderScope`.
- [x] `lib/main.dart` — appeler le bootstrap de production puis lancer l’app sous un unique `ProviderScope`; déclarer les délégués et locales directement depuis `AppLocalizations` généré.
- [x] `lib/core/services/ad_service.dart` et `lib/core/providers/ad_provider.dart` — garder l’intégration Ads derrière une dépendance injectable et empêcher une double initialisation sur le même cycle de processus.
- [x] `lib/core/services/consent_manager.dart`, `lib/core/services/revenuecat_service.dart`, `lib/core/services/user_manager.dart`, `lib/core/providers/` et `lib/features/home_page.dart` — extraire de la vue les initialisations Consent/Ads/RevenueCat vers la composition appropriée, sans modifier les actions et données utilisateur existantes.
- [x] `test/core/bootstrap/` et `test/widget_test.dart` — couvrir ordre, unicité, arrêt sur erreur et absence de SDK réel avec fakes ; vérifier les locales FR/EN/ES et la racine `ProviderScope`.
- [x] `README.md` — documenter la frontière bootstrap, les sources générées et les commandes de régénération l10n/Drift.

**Acceptance Criteria:**
- Given le démarrage de l’application, when les services sont composés, then Flutter, Firebase et Ads sont initialisés dans cet ordre une seule fois avant `ProviderScope`.
- Given une vue ou un ViewModel, when son code est inspecté ou exécuté, then il ne déclenche ni initialisation Firebase, Ads/consentement ou RevenueCat, et les interactions utilisateur conservées passent par une dépendance composée.
- Given une modification future Drift ou l10n, when elle est intégrée selon la documentation, then seules les sources sont modifiées, les artefacts sont régénérés, et les localisations française, anglaise et espagnole restent disponibles.

## Spec Change Log

## Design Notes

Le bootstrap doit rester une frontière d’infrastructure : son test injecte de petits adaptateurs ordonnés plutôt que d’essayer de simuler les plugins Firebase ou Ads. La composition post-bootstrap liée à la session doit préserver les transitions existantes ; elle ne doit pas devancer la future migration auth/profil.

## Verification

**Commands:**
- `flutter analyze` — attendu : aucune erreur d’analyse.
- `flutter test test/core/bootstrap test/widget_test.dart` — attendu : ordre, unicité, fakes et locales passent sans SDK réel.
- `flutter test` — attendu : baseline et suite existante restent vertes.
- `flutter gen-l10n` et `dart run build_runner build --delete-conflicting-outputs` — attendu : les artefacts générés sont reproductibles uniquement depuis leurs sources.

## Suggested Review Order

**Démarrage et composition**

- Le point d’entrée attend le bootstrap avant l’unique racine Riverpod.
  [`main.dart:9`](../../lib/main.dart#L9)

- L’orchestrateur injectable impose l’ordre et protège chaque cycle de démarrage.
  [`application_bootstrap.dart:19`](../../lib/core/bootstrap/application_bootstrap.dart#L19)

- La composition de production ajoute consentement, Ads et session RevenueCat hors des vues.
  [`application_bootstrap.dart:49`](../../lib/core/bootstrap/application_bootstrap.dart#L49)

**Intégrations SDK**

- Le consentement devient observable avant toute demande d’interstitiel.
  [`consent_manager.dart:6`](../../lib/core/services/consent_manager.dart#L6)

- Le même service Ads porte préchargement et consommateurs Riverpod.
  [`ad_service.dart:7`](../../lib/core/services/ad_service.dart#L7)

- La session RevenueCat est idempotente et gère les changements d’identité.
  [`revenuecat_service.dart:6`](../../lib/core/services/revenuecat_service.dart#L6)

- La sortie Firebase et le nettoyage local survivent à une erreur RevenueCat.
  [`user_manager.dart:113`](../../lib/core/services/user_manager.dart#L113)

**Ressources générées et preuves**

- L’application tire directement ses locales et délégués depuis le généré.
  [`main.dart:23`](../../lib/main.dart#L23)

- Les fakes couvrent ordre, unicité, échec et reprise du bootstrap.
  [`application_bootstrap_test.dart:36`](../../test/core/bootstrap/application_bootstrap_test.dart#L36)

- Chaque locale ARB générée est chargée sous `ProviderScope`.
  [`widget_test.dart:16`](../../test/widget_test.dart#L16)

- La déconnexion conserve Firebase même si RevenueCat échoue.
  [`user_manager_test.dart:18`](../../test/core/services/user_manager_test.dart#L18)

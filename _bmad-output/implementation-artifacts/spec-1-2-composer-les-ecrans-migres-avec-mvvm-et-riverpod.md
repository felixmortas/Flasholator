---
title: 'Story 1.2 — Composer les écrans migrés avec MVVM et Riverpod'
type: 'feature'
created: '2026-09-21'
status: 'done'
review_loop_iteration: 0
baseline_commit: '15693f68fe670ec4e0d6be909b832a2b21cba165'
context:
  - '{project-root}/AGENTS.md'
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le projet emploie déjà Riverpod, mais les écrans historiques concentrent l'état mutable, les règles et les accès aux services. La migration ne possède pas encore de socle vérifiable qui distingue une vue de son état UI et de ses dépendances.

**Approach:** Établir les conventions et primitives MVVM/Riverpod réutilisables avec un exemple vertical de composition testé, sans basculer prématurément les parcours flashcards, traduction, authentification ou statistiques qui ont leurs stories dédiées.

## Boundaries & Constraints

**Always:** Exposer des états UI Dart immuables avec les phases `initial`, `loading`, `data` et `error`, ainsi qu'une erreur applicative typée ; composer les dépendances par providers surchargeables ; garder les vues limitées au rendu et à la transmission d'intentions ; écrire les tests sans réseau, SDK ni stockage applicatif.

**Ask First:** Toute migration d'un parcours de production complet, modification de règle métier, changement de texte ou interaction visible, changement de bootstrap, ou remplacement/suppression d'un provider legacy.

**Never:** Ne pas déplacer les migrations flashcards/review, traduction/tables, auth/profil ou statistiques/monétisation hors de leur ordre ; ne pas instancier Firebase, Drift, RevenueCat, DeepL ou AdMob dans une vue/ViewModel ; ne pas modifier directement `lib/l10n/app_localizations*.dart` ou `lib/core/services/db_wrapper.g.dart`.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|---------------------------|----------------|
| Commande réussie | Une intention est envoyée au ViewModel avec une dépendance fake | La phase passe de `initial` à `loading`, puis `data`, et publie une nouvelle instance immuable | Aucun SDK ni effet caché n'est appelé |
| Commande en échec | La dépendance injectée lève une erreur attendue | Le ViewModel publie `error` avec une erreur applicative typée | L'écran peut rendre l'erreur sans état ambigu |
| Override de test | Un `ProviderContainer` remplace la dépendance de production | Le ViewModel utilise exclusivement le fake fourni | Les tests restent déterministes et isolés |

</frozen-after-approval>

## Code Map

- `lib/main.dart:12-24` — `ProviderScope` est déjà la racine ; ne pas modifier le bootstrap, réservé à la story 1.3.
- `lib/core/providers/user_data_provider.dart` — état historique `Map<String, dynamic>` à préserver jusqu'à migration de ses consommateurs ; il sert de contre-exemple, pas de cible de refactor dans cette story.
- `lib/features/translation/translate_tab.dart:25-235` — écran historique qui mêle état, service DeepL, quota et cartes ; ne pas le migrer ici afin de conserver l'ordre de migration.
- `lib/features/translation/translation_request_guard.dart` et `test/features/translation/translate_tab_test.dart` — baseline asynchrone existante à ne pas régresser.
- `lib/core/services/deepl_translator.dart` — adaptateur historique, à conserver pour la story traduction/tables.
- `lib/features/` — emplacement des nouvelles conventions de présentation par fonctionnalité ; utiliser les noms `*_view.dart`, `*_view_model.dart`, `*_ui_state.dart` et providers `<feature><Role>Provider`.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/presentation/` — ajouter les types purs et immuables communs de phase et d'erreur applicative, sans dépendance Flutter ou SDK, afin que chaque feature puisse représenter `initial/loading/data/error` de manière typée.
- [x] `lib/features/mvvm_example/` — créer un exemple vertical minimal (contrat injecté, état UI, ViewModel et vue) qui applique la convention de nommage ; la vue observe l'état et délègue uniquement l'intention au ViewModel.
- [x] `lib/features/mvvm_example/mvvm_example_providers.dart` — composer le contrat et le ViewModel via Riverpod, avec les providers publics surchargeables depuis un `ProviderContainer` ou `ProviderScope`.
- [x] `test/core/presentation/` et `test/features/mvvm_example/` — tester les transitions immuables succès/erreur, l'override de dépendance et le widget de vue sans SDK, réseau ni disque.
- [x] `README.md` — consigner la convention d'adoption MVVM/Riverpod et indiquer que les providers legacy demeurent en place jusqu'à bascule intégrale de leurs consommateurs.

**Acceptance Criteria:**
- Given un écran qui adopte la convention, when il est exécuté ou testé, then la vue ne fait que rendre l'état et transmettre les intentions au ViewModel.
- Given une commande du ViewModel réussit ou échoue, when son état est publié, then elle expose une phase immuable explicite et une erreur applicative typée en cas d'échec.
- Given un test de ViewModel, when un provider de dépendance est surchargé, then le fake est utilisé sans initialiser de SDK ou de service de production.

## Spec Change Log

## Design Notes

L'exemple vertical est un socle de conventions, non une nouvelle fonctionnalité accessible dans la navigation. Il évite d'entamer les migrations prévues par les stories suivantes tout en donnant une référence exécutable aux prochaines bascules. Les futures features réutiliseront les types et le schéma de providers sans que ces abstractions imposent leurs règles métier.

## Verification

**Commands:**
- `flutter analyze` — attendu : aucune erreur d'analyse.
- `flutter test test/core/presentation test/features/mvvm_example` — attendu : états, overrides et vue mince passent sans accès externe.
- `flutter test` — attendu : la baseline de caractérisation et la suite existante restent vertes.

## Suggested Review Order

**Orchestration asynchrone**

- Le ViewModel écarte les réponses périmées et les écritures après destruction.
  [`mvvm_example_view_model.dart:16`](../../lib/features/mvvm_example/mvvm_example_view_model.dart#L16)

- Les providers composent le contrat remplaçable et l'état de feature.
  [`mvvm_example_providers.dart:7`](../../lib/features/mvvm_example/mvvm_example_providers.dart#L7)

**Contrat de présentation**

- L'erreur stable sépare le détail technique du texte localisé.
  [`application_error.dart:1`](../../lib/core/presentation/application_error.dart#L1)

- La vue se limite au rendu d'état et à la délégation d'intention.
  [`mvvm_example_view.dart:21`](../../lib/features/mvvm_example/mvvm_example_view.dart#L21)

**Preuves et adoption**

- Les tests couvrent phases, override, concurrence, erreurs et destruction.
  [`mvvm_example_view_model_test.dart:35`](../../test/features/mvvm_example/mvvm_example_view_model_test.dart#L35)

- Les tests widget couvrent rendu initial, chargement et erreur.
  [`mvvm_example_view_test.dart:44`](../../test/features/mvvm_example/mvvm_example_view_test.dart#L44)

- La convention indique l'adoption progressive et la politique d'exécution.
  [`README.md:162`](../../README.md#L162)

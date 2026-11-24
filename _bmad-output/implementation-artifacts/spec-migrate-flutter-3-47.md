---
title: 'Migration du projet vers Flutter 3.47.9 / Dart 3.13.7'
type: 'chore'
created: '2026-11-24'
status: 'in-progress'
baseline_commit: '0c86adee84778f21e9c2bb102099559becf5a71c'
route: 'dispatch'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problème :** Le projet cible `sdk: '>=3.0.3 <4.0.0'` avec 94 dépendances en retard et une chaîne native ancienne (AGP 8.5.1, Kotlin 2.0.10, Gradle 8.7), alors que l'appareil a Flutter 3.47.9 (Dart 3.13.7). `flutter analyze` remonte 157 problèmes, dont des erreurs de tests.

**Approche :** Aligner le projet sur Flutter 3.47.9 : contrainte SDK, dépendances (mises à jour compatibles, plus les versions majeures seulement pour les paquets qui bloquent la compilation), chaîne Android/iOS, code déprécié et tests cassés.

## Boundaries & Constraints

**Always :** Conserver le comportement fonctionnel de l'app. Régénérer le code drift/l10n avec `build_runner`/`flutter gen-l10n` si les versions changent. Documenter chaque montée de version majeure dans Implementation Notes.

**Never :** Pas de `pub upgrade --major-versions` global. Pas de nouvelle fonctionnalité. Ne pas toucher à `service-account.json.base64`, `google-services.json`, ni aux clés de signature. Pas de commit sans demande.

## Décisions

- Dépendances : option C (majeures uniquement pour les paquets bloquants).
- Chaîne Android/iOS : montée incluse (AGP, Kotlin, Gradle, deployment target iOS, Podfile).
- Tests cassés : corrigés dans le périmètre.

</frozen-after-approval>

## Code Map

- `pubspec.yaml` -- contrainte SDK, dépendances, `dependency_overrides: win32`
- `android/settings.gradle`, `android/gradle/wrapper/gradle-wrapper.properties`, `android/app/build.gradle` -- AGP 8.5.1, Kotlin 2.0.10, Gradle 8.7, Java 1.8, compile/targetSdk 35
- `ios/Podfile`, `ios/Runner.xcodeproj/project.pbxproj` -- platform 13.0 vs IPHONEOS_DEPLOYMENT_TARGET 12.0/15.6 (incohérent)
- `lib/style/app_theme.dart:59,88,92`, `lib/style/bottom_overlay_styles.dart:31,137` -- `withOpacity`, `background`/`onBackground` dépréciés
- `test/user_preferences_service_test.dart` -- importe `local_user_data_notifier.dart` inexistant
- `test/firestore_users_dao_test.dart` -- mocks de classes scellées Firestore
- `test/deepl_extension.dart` -- imports inutilisés

## Tasks & Acceptance

**Execution :**
- [ ] `pubspec.yaml` -- SDK `^3.13.0` ; `flutter pub upgrade` ; majeures ciblées si bloquantes ; réévaluer l'override `win32`
- [ ] `android/*` -- monter AGP/Kotlin/Gradle/Java selon exigences Flutter 3.47 et warnings de build
- [ ] `ios/*` -- aligner deployment target et Podfile avec les exigences des plugins
- [ ] `lib/**` -- corriger erreurs de compilation et dépréciations (`withValues`, `surface`/`onSurface`, super parameters)
- [ ] `test/**` -- réparer les 2 erreurs et les mocks scellés, retirer imports inutilisés

**Acceptance Criteria :**
- Given le projet migré, when `flutter analyze`, then 0 erreur et 0 warning.
- Given le projet migré, when `flutter test`, then tous les tests passent.
- Given un appareil/émulateur Android, when `flutter build apk --debug`, then le build réussit.

## Implementation Notes

## Spec Change Log

## Review Triage Log

## Verification

**Commands :**
- `flutter pub get && dart run build_runner build -d` -- expected: succès
- `flutter analyze` -- expected: aucune erreur ni warning
- `flutter test` -- expected: tous verts
- `flutter build apk --debug` -- expected: succès

**Manual checks :**
- Build iOS non vérifiable sous Linux : relire Podfile/pbxproj.

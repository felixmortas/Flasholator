---
title: 'Migrer le projet vers Flutter 3.47.9'
type: 'chore'
created: '2026-11-25'
status: 'done'
route: 'oneshot'
review_loop_iteration: 0
context: []
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Le projet est épinglé sur Flutter 3.32.5 (CI, README, pubspec) alors que l'appareil du développeur utilise Flutter 3.47.9 (Dart 3.13.7).

**Approach:** Aligner toutes les références de version sur 3.47.9 et conserver les artefacts régénérés par l'outillage (pubspec.lock, fichiers de plugins générés). Vérifier avec `flutter analyze` et `flutter test`.

</frozen-after-approval>

## Implementation Notes

- Investigation : `flutter pub get` (10 dépendances changées) et `flutter analyze` : aucun problème avec 3.47.9.
- `flutter test` : 143 réussis, 19 échecs, tous dus à `libsqlite3.so` absent de la machine (environnement, sans lien avec la version de Flutter).
- L'outillage a régénéré `analysis_options.yaml` (exclusions de plateformes), `pubspec.lock` et les fichiers de plugins linux/macos/windows : conservés.
- Versions épinglées à mettre à jour : 6 workflows `.github/workflows/*.yml`, `README.md`, commentaire de `pubspec.yaml`.

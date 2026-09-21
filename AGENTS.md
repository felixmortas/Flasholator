<!-- bmad:context -->
<!-- Verified 2026-09-21 against 096dbf3eee8100f574b3a15387dd0a4ec45ed60c. Managed by bmad-project-context; edits inside this block are replaced on refresh. Keep anything you want preserved outside the markers. -->

## Flasholator

Application mobile (iOS & Android) Flutter de traduction et de répétition espacée. La migration vise une architecture MVVM par fonctionnalité, avec Riverpod pour l’injection et les états UI. La documentation d’architecture et de produit vit dans `README.md`.

## Policy

- Préserver Firebase, Drift, RevenueCat et la localisation générée pendant la migration.
- Ne modifiez jamais directement `lib/l10n/app_localizations*.dart` ou `lib/core/services/db_wrapper.g.dart` ; modifiez leurs sources puis régénérez-les.
- Migrez dans cet ordre : tests de caractérisation (cartes, statistiques, authentification, persistance) ; conventions MVVM/Riverpod ; flashcards/review ; traduction/tables ; auth/profil ; statistiques/monétisation ; retrait progressif du legacy.
- Supprimez un service ou provider historique seulement après l’adoption de son remplaçant et la couverture de son comportement par des tests.

## Where things are

- Démarrage et composition de l’application : `lib/main.dart`
- Logique métier, intégrations et providers Riverpod actuels : `lib/core/`
- Écrans par fonctionnalité : `lib/features/`
- Localisation : `lib/l10n/`; configuration : `l10n.yaml`

## Running and verifying

- La CI exécute l’analyse Flutter et les tests à chaque push et pull request.

## Conventions that differ from defaults

- Avant de migrer une tranche, ajoutez des tests de caractérisation ; adaptez les objets pour les rendre testables si nécessaire.
- Les vues ne portent que le rendu et les interactions UI ; les ViewModels exposent des états UI typés et immuables.
- Fournissez les dépendances métier et d’infrastructure par providers Riverpod injectables et surchargeables en test ; n’instanciez pas Firebase, Drift ou RevenueCat dans une vue ou un ViewModel.
<!-- /bmad:context -->

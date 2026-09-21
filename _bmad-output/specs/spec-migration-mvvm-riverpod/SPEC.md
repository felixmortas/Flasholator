---
id: SPEC-migration-mvvm-riverpod
companions:
  - migration-contract.md
  - legacy-inventory.md
  - ../../planning-artifacts/architecture/architecture-Flasholator-2026-09-21/ARCHITECTURE-SPINE.md
sources: []
---

> **Contrat canonique.** Ce SPEC et les fichiers de `companions:` définissent complètement ce qui doit être migré, préservé et vérifié.

# Migration MVVM par fonctionnalité avec Riverpod

## Why

Ce mandat de refactoring rend Flasholator évolutif et testable sans altérer l'expérience de traduction et de répétition espacée livrée aux utilisateurs. La logique métier et les intégrations sont mêlées à des services et providers historiques ; la migration progressive établit des frontières vérifiables avant chaque remplacement.

## Capabilities

- **CAP-1**
  - **intent:** L'équipe peut caractériser les calculs de cartes et de statistiques, les flux d'authentification et la persistance avant de migrer la tranche concernée.
  - **success:** Des tests déterministes exécutables hors des services distants couvrent les comportements inventoriés dans `migration-contract.md` et restent verts pendant chaque tranche qui les touche.
- **CAP-2**
  - **intent:** Chaque fonctionnalité migrée peut présenter et modifier son état UI à travers un ViewModel MVVM typé et immuable, alimenté par des dépendances Riverpod remplaçables.
  - **success:** Les vues migrées ne contiennent ni logique métier ni instanciation d'infrastructure ; les ViewModels exposent explicitement les états de chargement, données et erreur.
- **CAP-3**
  - **intent:** L'utilisateur peut créer, modifier, supprimer et réviser ses flashcards avec les mêmes résultats métier qu'avant la migration du cœur flashcards/review.
  - **success:** La suite de caractérisation confirme notamment les paires réversibles, l'éligibilité à la révision et les transitions SM-2 pour les qualités représentatives.
- **CAP-4**
  - **intent:** L'utilisateur peut traduire et administrer ses données et couples de langues à travers les fonctionnalités migrées de traduction et tables.
  - **success:** Les flux existants de traduction, sélection de langues et opérations sur les cartes restent démontrables, avec les chaînes localisées générées intactes.
- **CAP-5**
  - **intent:** L'utilisateur peut s'authentifier, gérer son profil, consulter ses statistiques et accéder aux comportements de monétisation existants après leur migration.
  - **success:** Les contrats Firebase, cache local, RevenueCat, consentement et publicité sont conservés et chacun est couvert par les tests ou doubles d'infrastructure appropriés.
- **CAP-6**
  - **intent:** L'équipe peut retirer progressivement les services et providers historiques devenus redondants.
  - **success:** Chaque suppression référence un remplaçant adopté par tous ses consommateurs et les tests qui verrouillent son comportement préservé.

## Constraints

- Le spine d'architecture adopté est bindant pour les frontières MVVM, les propriétaires d'état et de données, les cycles de session, les opérations de paire et la CI.
- Préserver Firebase, Drift, RevenueCat et la localisation générée ; ne jamais modifier directement `lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart`.
- Respecter l'ordre de migration et le seuil de sortie de chaque tranche définis dans `migration-contract.md`.
- Les dépendances métier et d'infrastructure passent par des providers Riverpod injectables et surchargeables en test ; aucune vue ni ViewModel n'instancie Firebase, Drift ou RevenueCat.
- La CI exécute l'analyse Flutter et les tests à chaque push et pull request.
- Les erreurs visibles existantes sont préservées pendant la migration ; leur évolution exige une spécification produit distincte.

## Non-goals

- Ajouter des fonctionnalités de roadmap, modifier l'offre premium ou changer les règles métier de répétition espacée pendant ce chantier.
- Remplacer Firebase, Drift, RevenueCat, DeepL, AdMob ou le système de génération de localisation.
- Réécrire le dépôt en une seule livraison ou supprimer du legacy avant sa substitution complète.
- Résoudre la dette de sécurité DeepL par un backend non spécifié dans ce chantier.

## Success signal

Une exécution de `flutter analyze` et `flutter test` est verte après chaque tranche, et les scénarios caractérisés — de la persistance d'une paire jusqu'à sa révision, ses statistiques et les états de compte — produisent les résultats de référence. À la fin, chaque fonctionnalité ciblée est composée par Riverpod autour d'une vue mince et d'un ViewModel testable, sans consommateur du legacy retiré.

## Assumptions

- Le chantier est comportemental : les écarts de comportement découverts par caractérisation ne sont corrigés que par une décision distincte, explicitement spécifiée.

## Open Questions

- Quand et avec quelle architecture de relais, ownership et déploiement le secret DeepL existant sera-t-il retiré ou roté sans étendre la migration brownfield ?

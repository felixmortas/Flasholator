# Epic 5 Context: Suivre ses progrès et bénéficier du premium

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Les utilisateurs consultent leurs progrès et reçoivent des droits, limites et publicités cohérents avec leur statut. Les documents de planification disponibles se limitent au découpage des epics ; aucun contrat UX distinct n'est fourni.

## Stories

- Story 5.1: Consulter des statistiques cohérentes
- Story 5.2: Souscrire et restaurer les droits premium
- Story 5.3: Appliquer les droits freemium, premium et publicitaires

## Requirements & Constraints

- Les statistiques de profil reposent sur la collection de cartes partagée. Préserver le dédoublonnage, les couples de langues non orientés, les séries et moyennes par paire et le classement décroissant limité à cinq entrées.
- Préserver les transitions de droits entre Firebase, cache et RevenueCat, les limites configurables du compte gratuit et les capacités premium.
- Préserver la publicité gratuite et les conditions de consentement UMP/RGPD et ATT ; aucune publicité ne doit paraître sans l'autorisation requise.
- Ajouter les tests de caractérisation avant la migration de chaque tranche. L'analyse Flutter et les tests doivent réussir ; la consultation hors ligne, les langues localisées et les intégrations existantes restent compatibles.

## Technical Decisions

- Les statistiques proviennent d'un `StatisticsUseCase` qui applique la projection de référence au snapshot de cartes partagé.
- Une fonctionnalité suit la chaîne vue, ViewModel, cas d'usage facultatif, repository, adaptateur. Les dépendances métier et d'infrastructure passent par des providers Riverpod surchargeables ; les états UI sont immuables et typés.
- Firebase Auth est maître de session ; Firestore porte profil et droits, le cache local accélère et RevenueCat porte les entitlements. Les opérations sont protégées par uid et génération.
- Les limites gratuites ont une configuration développeur centralisée, injectée et surchargeable, avec défauts de un couple, 200 traductions et 20 paires.

## UX & Interaction Patterns

Préserver les comportements et retours utilisateur existants, sans refonte UX.

## Cross-Story Dependencies

- La cohérence du snapshot de cartes vient de l'epic 2 ; les statistiques doivent lire cette même projection.
- La gestion des sessions de l'epic 4 protège le profil et les droits utilisés par les stories 5.2 et 5.3.

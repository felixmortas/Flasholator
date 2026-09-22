# Epic 4 Context: Accéder à son espace personnel en toute sécurité

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Permettre aux utilisateurs de retrouver leur compte, leur couple de langues par défaut et leurs droits après un redémarrage, sans fuite de données ou de droits lors d'une déconnexion ou d'un changement de compte. La migration conserve les parcours et les retours visibles de l'authentification existante tout en donnant un propriétaire unique à la session.

## Stories

- Story 4.1: Authentifier et restaurer une session utilisateur
- Story 4.2: Isoler les sessions et les préférences de langue

## Requirements & Constraints

- Conserver l'inscription, la vérification de l'adresse e-mail, la connexion, la déconnexion et la restauration d'une session valide sans nouvelle connexion. Préserver les états et erreurs visibles des flux existants.
- Permettre à l'utilisateur authentifié de définir puis retrouver son couple de langues par défaut dans sa session.
- À la déconnexion ou au changement de compte, annuler ou invalider les opérations de l'ancienne session, purger son cache local avant d'exposer le nouvel état et empêcher qu'un résultat tardif affiche ses données ou ses droits.
- Maintenir la cohérence de la session, du profil et des droits malgré les réponses asynchrones des services externes et du cache. Les données et droits restent isolés par utilisateur.
- Préserver les intégrations Firebase, Firestore, RevenueCat et la localisation française, anglaise et espagnole. La migration reste compatible iOS et Android sans mise à niveau implicite de la stack ni changement visible du parcours.
- Caractériser les données, états UI et erreurs du parcours avant la bascule. Vérifier les transitions de session, y compris les réponses tardives, avec des tests déterministes ; l'analyse et les tests Flutter sont les portes de validation du changement.

## Technical Decisions

- La feature suit le flux vue → ViewModel → repository → adaptateurs. La vue rend l'état et transmet les intentions ; le ViewModel orchestre un état UI typé et immuable. Les contrats de domaine et de repository restent en Dart pur. Aucun SDK, secret ou DTO externe ne traverse les vues, ViewModels ou contrats de domaine.
- Riverpod compose et injecte les dépendances, toutes surchargeables en test. Un seul `UserSessionRepository` possède l'état partagé ; les providers historiques restent jusqu'à la bascule de leurs consommateurs et la couverture de leur comportement.
- Le repository de session expose des états distincts `anonymous`, `hydrating(uid,generation)`, `authenticated(snapshot)` et `signingOut`. Firebase Auth est la source de vérité de la session ; Firestore porte profil et droits ; le cache local accélère la lecture ; RevenueCat porte les entitlements.
- Chaque opération asynchrone capture l'uid et la génération de session. Son résultat est ignoré si ce contexte n'est plus courant. Une déconnexion ou un changement de compte invalide les opérations, purge le cache et réconcilie RevenueCat avant l'état anonyme.
- Le bootstrap initialise Flutter, Firebase et Ads une seule fois avant `ProviderScope`. L'adaptateur de session configure RevenueCat une fois après la restauration Firebase, puis l'identifie ou le déconnecte à chaque transition de session. Les vues et ViewModels n'initialisent aucun de ces SDK.
- Les ViewModels exposent les phases `initial`, `loading`, `data` et `error` avec des erreurs applicatives typées ; les mutations sont sérialisées ou idempotentes et les effets uniques ne sont émis qu'une fois par commande acceptée.

## UX & Interaction Patterns

- Conserver les retours utilisateur actuels lors de l'inscription, de la vérification e-mail, de la connexion, de la restauration et des erreurs. Aucune refonte UX n'est prévue.
- Après une restauration de session valide, l'utilisateur retrouve directement son espace et ses préférences sans ressaisir ses identifiants.

## Cross-Story Dependencies

- La restauration et le propriétaire unique de session de la story 4.1 fournissent le contexte uid/génération nécessaire à l'isolation et aux préférences de la story 4.2.
- Les fonctionnalités de traduction, de profil et de monétisation consomment l'identité et les droits issus de la session ; leurs résultats asynchrones doivent respecter les transitions de compte. La configuration et les transitions RevenueCat préparent la gestion premium de l'epic 5.

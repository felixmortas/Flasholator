# Inventaire de retrait du legacy

_État initial — 2026-09-21. Cet inventaire est une matrice de pilotage : un élément n’est supprimable que lorsque son remplacement, ses consommateurs migrés et ses preuves de caractérisation sont tous renseignés._

## Règle de décision

Un candidat ne passe à **supprimable** que si :

1. son remplaçant est intégré et utilisé par tous ses consommateurs de production ;
2. les invariants listés dans `migration-contract.md` sont couverts pour son domaine ;
3. `rg` ne trouve plus d’import ou référence exécutable vers le candidat ;
4. `flutter analyze` et `flutter test` sont verts après sa suppression dans un changement dédié.

Le code généré Drift et l10n ne sont jamais des candidats de retrait manuel.

## Matrice initiale

| Candidat actuel | Consommateurs de production observés | Remplaçant cible | Tranche | État | Preuve manquante avant retrait |
|---|---|---|---|---|---|
| `core/services/sm_two.dart` | `Flashcard` | Règle de planification du domaine review, avec horloge injectable | 3 | À migrer, pas à supprimer sans relogement | Cas SM-2 figés : première revue, succès, échec, borne 1,3 |
| `core/services/db_wrapper.dart` | `Flashcard`, `FlashcardsService` | Adaptateur Drift derrière un contrat de dépôt de cartes | 3 | À encapsuler | Aller-retour complet Drift et opérations de paire |
| `core/services/flashcards_service.dart` | `HomePage`, `ReviewTab`, `DataTableTab`, `ProfilePage`, `TranslateTab`, `StatsService` | Cas d’usage/repository flashcards injecté par provider de fonctionnalité | 3 | Legacy actif | Tous les consommateurs basculés ; tests ajout/modification/suppression/due/review |
| `core/services/stats_service.dart` | `StatsPage` | Cas d’usage statistiques + `StatsViewModel` | 5 | Legacy actif | Totaux dédoublonnés, séries, moyennes, couples et classements |
| `core/services/deepl_translator.dart` | `HomePage`, `TranslateTab` | Adaptateur DeepL injecté + cas d’usage traduction | 4 | Legacy actif | Réponses succès/échec caractérisées avec client HTTP fake ; clé sortie du code source |
| `core/services/auth_gate.dart` | `main.dart` | Vue de routage/session de la feature authentication | 5 | Legacy actif | États anonyme, vérification en attente, utilisateur vérifié, synchronisation |
| `core/services/auth_service.dart` + `auth_service_provider.dart` + `firebase_auth_provider.dart` | `UserManager`, `UserManagerProvider`, pages d’authentification via manager | Port/auth adapter Firebase + `AuthViewModel` et providers de feature | 5 | Legacy actif | Flux auth et traitement exact des erreurs existantes |
| `core/services/firestore_users_dao.dart` + providers Firestore/DAO | `UserManager`, `UserManagerProvider` | Repository de profil, adaptateur Firestore injecté | 5 | Legacy actif | Création/mise à jour/suppression/lire utilisateur avec fake Firestore |
| `core/services/user_preferences_service.dart` | `UserManager`, tests | Port de préférences + adaptateur SharedPreferences injecté | 5 | Legacy actif | Valeurs par défaut, cache, mises à jour et nettoyage |
| `core/services/user_manager.dart` + `user_manager_provider.dart` | AuthGate, login, register, email verification, profile, data table, translation, home | ViewModels séparés : session/auth, profil/préférences, abonnement ; cas d’usage dédiés | 5 | Legacy actif, composant pivot | Tous les consommateurs migrés et tests de coordination auth/cache/abonnement |
| `core/providers/user_data_provider.dart` + `user_sync_provider.dart` | Home, profile, review, translation, data, auth gate, ad provider | États UI typés et immuables par feature ; état session dédié | 2 puis 5 | Legacy actif | Overrides Riverpod et états chargement/données/erreur vérifiés |
| `core/services/revenuecat_service.dart` + `revenuecat_provider.dart` | `UserManager` | Port abonnement + adaptateur RevenueCat injecté | 5 | Legacy actif | Initialisation, statut, paywall, achat/restauration avec fake |
| `core/services/ad_service.dart` + `ad_provider.dart` | `main.dart`, home, review, bannière partagée | Adaptateur publicité/consentement injecté ; providers de présentation | 5 | Legacy actif | Décision abonné/non abonné, web/mobile, échecs de chargement |
| `core/services/consent_manager.dart` | Home, profile | Adaptateur consentement injecté | 5 | Legacy actif | Consentement, options de confidentialité, erreurs de SDK |
| `core/services/feedback_service.dart` | `UnsubscribeDialog` | Repository feedback injecté dans la feature profile/authentication | 5 | Legacy actif | Envoi, échec propagé et absence de SDK dans le widget |

## Constats qui conditionnent la première tranche

- `FlashcardsService` instancie `DatabaseWrapper`, et `DeeplTranslator`, `FeedbackService`, `ConsentManager` ainsi que `AdService` exposent encore des accès directs aux SDK ou méthodes statiques : ce sont les premières frontières à rendre injectables.
- `UserManager` dépend de `Ref`, de `BuildContext` dans certaines actions, de Firebase, Firestore, RevenueCat et préférences : il doit être découpé, pas déplacé tel quel.
- Le constructeur de production de `FirestoreUsersDAO` ignore le `FirebaseFirestore` fourni et utilise `FirebaseFirestore.instance` ; ce comportement doit être caractérisé puis corrigé dans l’adaptateur de remplacement, via une décision explicite.
- `test/user_preferences_service_test.dart` importe `local_user_data_notifier.dart`, fichier absent de l’arborescence observée. La première tranche doit rétablir une base de tests exécutable avant d’en déduire une couverture.

## Prochaine passe opérationnelle

1. Rétablir et exécuter les tests existants sans toucher au comportement produit.
2. Écrire les tests de caractérisation flashcards/review, statistiques, auth et persistance.
3. Après chaque tranche, remplacer l’état de chaque ligne par `migré`, `bloqué` ou `supprimable`, et consigner les imports restants.

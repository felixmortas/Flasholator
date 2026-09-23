# Registre de preuve de retrait du legacy

_État réaudité le 2026-09-23. Ce document est un registre de preuve : il ne
prouve pas une bascule qui n'a pas eu lieu et n'autorise aucune suppression à
lui seul._

## Statuts et champs obligatoires

Chaque candidat conserve les champs suivants jusqu'à son retrait : remplaçant,
consommateurs observés et migrés, tests associés, audit de références, état,
preuves de vérification et commit de retrait. Une valeur `aucun` signifie qu'une
preuve est absente, pas qu'elle est acquise.

- **legacy actif** : le composant ou au moins un de ses consommateurs de
  production est encore en place ; sa suppression est interdite.
- **migré, en attente de retrait** : tous les consommateurs connus ont basculé,
  mais l'audit après bascule, les vérifications ou le commit isolé manquent.
- **supprimable** : statut réservé à un candidat dont les critères du protocole
  ci-dessous sont consignés.
- **retrait préparé** : fichiers supprimés dans l'arbre de travail ; les
  vérifications et le commit isolé restent à consigner.

Les fichiers générés `lib/l10n/app_localizations*.dart` et
`lib/core/services/db_wrapper.g.dart` sont exclus de tout retrait manuel.

## Registre courant

| Candidat | Remplaçant concret ou cible explicite | Consommateurs observés de production (2026-09-22) | Consommateurs migrés | Tests de caractérisation associés | Audit de références requis et résultat actuel | État | Commit isolé et vérifications de retrait |
|---|---|---|---|---|---|---|---|
| `core/services/sm_two.dart` | Règle de planification review du domaine avec horloge injectable | `lib/core/models/flashcard.dart` | Aucun | `test/core/services/sm_two_test.dart` ; `test/core/services/flashcards_service_test.dart` | `rg -n "sm_two" lib test` : références exécutables dans `flashcard.dart` ; tests également présents | legacy actif | Aucun ; retrait bloqué |
| `core/services/db_wrapper.dart` | Adaptateur Drift derrière un contrat de dépôt de cartes | `lib/core/models/flashcard.dart`, `lib/core/services/flashcards_service.dart` | Aucun | `test/core/models/flashcard_test.dart` ; `test/core/services/flashcards_service_test.dart` | `rg -n "db_wrapper" lib test` : imports exécutables dans le modèle et le service | legacy actif | Aucun ; retrait bloqué. Le généré `db_wrapper.g.dart` n'est jamais supprimé manuellement. |
| `core/services/flashcards_service.dart` | Cas d'usage/repository flashcards injecté par provider de fonctionnalité | `lib/features/home_page.dart`, `review/review_tab.dart`, `data/data_table_tab.dart`, `profile/profile_page.dart`, `translation/translate_tab.dart`, `core/services/stats_service.dart` | Aucun | `test/core/services/flashcards_service_test.dart` ; `test/core/models/flashcard_test.dart` | `rg -n "flashcards_service" lib test` : imports exécutables dans tous les consommateurs listés | legacy actif | Aucun ; retrait bloqué |
| `core/services/stats_service.dart` | `features/stats/statistics_use_case.dart` + `stats_view_model.dart` | `lib/features/stats/stats_page.dart` (ancien consommateur) | `lib/features/stats/stats_page.dart` via `statsViewDataProvider` | `test/features/stats/statistics_use_case_test.dart` ; `test/features/stats/stats_page_test.dart` : 7 tests verts | `rg -n "stats_service\|StatsService" lib test` : aucune référence après retrait | retrait préparé | Retrait dans `dfb0e3c43751e921d0d9738efbd9a4727d03546f` (`git revert dfb0e3c43751e921d0d9738efbd9a4727d03546f`) ; `flutter test` : 162 tests verts le 2026-09-23 ; `flutter analyze` : 112 diagnostics, aucun bloquant avec `--no-fatal-infos --no-fatal-warnings` |
| `core/services/deepl_translator.dart` | Adaptateur DeepL injecté + cas d'usage traduction | `lib/features/home_page.dart`, `features/translation/translate_tab.dart` | Aucun | `test/features/translation/translate_tab_test.dart` (invalidations de requêtes) ; aucun test d'adaptateur DeepL dédié observé | `rg -n "deepl_translator" lib test` : imports exécutables dans home et traduction | legacy actif | Aucun ; retrait bloqué |
| `core/services/auth_gate.dart` | Vue de routage/session de la feature authentication | `lib/main.dart` | Aucun | Aucun test dédié observé | `rg -n "auth_gate" lib test` : import exécutable dans `main.dart` | legacy actif | Aucun ; retrait bloqué |
| `core/services/auth_service.dart`, `auth_service_provider.dart`, `firebase_auth_provider.dart` | Port/auth adapter Firebase + `AuthViewModel` et providers de feature | `core/services/user_manager.dart`, `core/providers/user_manager_provider.dart` ; pages `login_page.dart`, `register_page.dart`, `email_verification_pending_page.dart` via le manager | Aucun | `test/core/services/auth_service_test.dart` ; `test/core/services/user_manager_test.dart` | `rg -n "auth_service_provider\|firebase_auth_provider\|auth_service" lib test` : imports exécutables dans providers et `user_manager.dart` | legacy actif | Aucun ; retrait bloqué |
| `core/services/firestore_users_dao.dart` et providers Firestore/DAO | Repository de profil + adaptateur Firestore injecté | `core/services/user_manager.dart`, `core/providers/user_manager_provider.dart` | Aucun | `test/firestore_users_dao_test.dart` ; `test/core/services/user_manager_test.dart` | `rg -n "firestore_users_dao\|firebase_firestore_provider" lib test` : imports exécutables dans le manager et ses providers | legacy actif | Aucun ; retrait bloqué |
| `core/services/user_preferences_service.dart` | Port de préférences + adaptateur SharedPreferences injecté | `lib/core/services/user_manager.dart` | Aucun | `test/user_preferences_service_test.dart` ; `test/core/services/user_manager_test.dart` | `rg -n "user_preferences_service" lib test` : import exécutable dans `user_manager.dart` | legacy actif | Aucun ; retrait bloqué |
| `core/services/user_manager.dart` et `user_manager_provider.dart` | ViewModels séparés session/auth, profil/préférences et abonnement ; cas d'usage dédiés | `auth_gate.dart`, `home_page.dart`, `profile_page.dart`, `review/review_tab.dart`, `data/data_table_tab.dart`, `translation/translate_tab.dart`, pages d'authentification ; `user_sync_provider.dart` | Aucun | `test/core/services/user_manager_test.dart` | `rg -n "user_manager_provider\|user_manager" lib test` : imports exécutables dans les écrans et providers listés | legacy actif (composant pivot) | Aucun ; retrait bloqué |
| `core/providers/user_data_provider.dart` | États UI typés et immuables par feature ; état de session dédié | `home_page.dart`, `profile_page.dart`, `review/review_tab.dart`, `data/data_table_tab.dart`, `translation/translate_tab.dart`, `auth_gate.dart`, `ad_provider.dart`, `user_manager.dart` | Partiel | `test/core/services/user_manager_test.dart` | `rg -n "user_data_provider" lib test` : imports exécutables persistants | legacy actif | Aucun ; retrait bloqué |
| `core/providers/user_sync_provider.dart` | `features/authentication/auth_session_repository.dart` | Aucun lors du réaudit ; `userSyncStateProvider` n'avait aucun lecteur | Aucun consommateur à migrer | `test/features/authentication/auth_session_repository_test.dart` : 13 tests verts | `rg -n "user_sync_provider\|userSyncStateProvider" lib test` : aucune référence après retrait | retrait préparé | Retrait dans `dfb0e3c43751e921d0d9738efbd9a4727d03546f` (`git revert dfb0e3c43751e921d0d9738efbd9a4727d03546f`) ; `flutter test` : 162 tests verts le 2026-09-23 ; `flutter analyze` : 112 diagnostics, aucun bloquant avec `--no-fatal-infos --no-fatal-warnings` |
| `core/services/revenuecat_service.dart` et `revenuecat_provider.dart` | Port abonnement + adaptateur RevenueCat injecté | `core/bootstrap/application_bootstrap.dart`, `core/services/user_manager.dart`, `core/providers/user_manager_provider.dart` | Aucun | `test/core/bootstrap/application_bootstrap_test.dart` ; `test/core/services/user_manager_test.dart` | `rg -n "revenuecat_service\|revenuecat_provider" lib test` : imports exécutables dans bootstrap, manager et provider | legacy actif | Aucun ; retrait bloqué |
| `core/services/ad_service.dart` et `ad_provider.dart` | Adaptateur publicité/consentement injecté ; providers de présentation | `core/bootstrap/application_bootstrap.dart`, `features/review/review_tab.dart`, `features/shared/widgets/ad_banner_widget.dart` | Aucun | `test/core/bootstrap/application_bootstrap_test.dart` ; aucun test de décision publicitaire dédié observé | `rg -n "ad_service\|ad_provider" lib test` : imports exécutables dans bootstrap, review et bannière | legacy actif | Aucun ; retrait bloqué |
| `core/services/consent_manager.dart` | Adaptateur consentement injecté | `lib/core/bootstrap/application_bootstrap.dart`, `lib/features/profile/profile_page.dart` | Aucun | `test/core/bootstrap/application_bootstrap_test.dart` (séquence injectable, pas le SDK de consentement) | `rg -n "consent_manager\|ConsentManager" lib test` : usages exécutables dans bootstrap et profil | legacy actif | Aucun ; retrait bloqué. Les adaptations du bootstrap ne constituent pas une bascule complète. |
| `core/services/feedback_service.dart` | Repository feedback injecté dans la feature profile/authentication | `lib/features/authentication/widgets/unsubscribe_dialog.dart` | Aucun | Aucun test dédié observé | `rg -n "feedback_service\|FeedbackService" lib test` : import et usage exécutables dans `unsubscribe_dialog.dart` | legacy actif | Aucun ; retrait bloqué |

## Protocole de retrait, à appliquer candidat par candidat

1. **Avant la migration**, exécuter et consigner `rg -n
   "<symbole-ou-import-du-candidat>" lib test`. Le résultat doit lister les
   consommateurs de production observés, les tests et les références internes ;
   il ne justifie jamais une suppression.
2. **Migrer tous les consommateurs** vers le remplaçant indiqué, sans modifier
   de parcours ni de règle métier. Renseigner leurs chemins dans la colonne
   « Consommateurs migrés » et associer les tests de caractérisation qui
   couvrent le comportement remplacé.
3. **Auditer après bascule** avec la même commande `rg`. Seules les références
   de documentation, commentaires ou artefacts générés explicitement exclus
   peuvent subsister ; toute référence exécutable maintient le statut `legacy
   actif`.
4. **Préparer une suppression dédiée et réversible** : un seul candidat (et ses
   fichiers indissociables) par commit, sans migration fonctionnelle mêlée.
   Consigner le SHA complet du commit et la manière de le revenir dans la
   colonne de preuve.
5. **Vérifier dans ce commit** : exécuter `flutter analyze` puis `flutter test`
   après la suppression. Consigner la date et les résultats verts, ainsi que le
   résultat `rg` sans référence exécutable.
6. **Seulement alors**, remplacer l'état par `supprimable`, puis par `retiré`
   après intégration. L'absence d'un seul consommateur migré, test, audit,
   résultat Flutter ou commit réversible interdit les deux statuts.

## Lecture des preuves actuelles

Les suites existantes caractérisent déjà une partie des cartes/review,
statistiques, authentification, préférences, traduction asynchrone et bootstrap.
Elles ne constituent pas, à elles seules, la preuve de retrait d'un candidat :
les migrations des Epics 2 à 5 et l'audit sans référence exécutable restent à
faire. Le retrait de `StatsService` et du provider de synchronisation inutilisé
est préparé ; tous les autres candidats demeurent `legacy actif`.

---
title: 'Story 1.1 — Établir la baseline des comportements critiques'
type: 'feature'
created: '2026-09-21'
status: 'done'
review_loop_iteration: 0
baseline_commit: 'ba1719a462e87b161056718290dcad6aed4f6abc'
context:
  - '{project-root}/AGENTS.md'
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** La migration MVVM/Riverpod ne dispose pas encore de tests déterministes pour les comportements qui risquent de perdre des cartes, de fausser les statistiques, de casser une session ou de publier une réponse asynchrone périmée. Le projet ne peut donc pas prouver qu’une bascule préserve la production.

**Approach:** Créer une baseline de caractérisation focalisée sur les cartes/SM-2 et leur persistance, les statistiques, l’authentification et les préférences de session, puis rendre testable et sûr le chemin de traduction asynchrone qui peut aujourd’hui écraser l’état courant.

## Boundaries & Constraints

**Always:** Préserver les comportements métier et les intégrations existantes ; écrire des tests déterministes sans réseau ni SDK réel ; injecter les dépendances, l’horloge ou les réponses contrôlées seulement aux frontières nécessaires aux tests ; conserver les tests dans `test/` et garder Flutter/Riverpod compatibles avec les versions verrouillées. Les réponses de traduction devenues obsolètes après une nouvelle demande, une modification de saisie ou de langues ne doivent ni mettre à jour l’UI ni incrémenter le quota.

**Ask First:** Toute correction révélée par les caractérisations qui changerait une règle métier établie (notamment le dédoublonnage des paires, les statistiques ou les règles SM-2), toute migration de schéma Drift, ou tout changement de parcours/texte utilisateur.

**Never:** Ne pas modifier directement `lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart`; ne pas supprimer le legacy, ajouter une synchronisation cloud, modifier les limites freemium ou remplacer une intégration Firebase, Drift, RevenueCat ou DeepL.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|---------------------------|----------------|
| Paire et révision | Une paire dans un stockage de test, qualité SM-2 déterminée et horloge fixée | Les deux directions, tous les champs Drift, l’échéance et les compteurs correspondent à la baseline | Une paire vide ou déjà existante n’est pas ajoutée ; une carte absente ne produit pas de mutation |
| Snapshot statistiques | Paires bidirectionnelles, langues inversées, dates et compteurs connus | Totaux, séries, moyennes et classements sont calculés depuis le même snapshot et limités à cinq | Une période sans carte retourne des totaux et séries cohérents |
| Session et préférences | FirebaseAuth/SharedPreferences simulés, utilisateur présent ou absent | Les opérations AuthService et le cache de préférences conservent leurs contrats observables | Les erreurs actuellement absorbées ou propagées restent caractérisées |
| Réponse DeepL tardive | Deux requêtes contrôlées, ou une modification de saisie/langues avant résolution | Seule la requête encore courante peut afficher un résultat et consommer un quota | Une réponse périmée ou une erreur n’écrit ni état affiché ni donnée |

</frozen-after-approval>

## Code Map

- `lib/core/models/flashcard.dart` — conversion Drift, échéance et application SM-2 ; isoler l’horloge si nécessaire pour des vecteurs déterministes.
- `lib/core/services/sm_two.dart` — algorithme de planification à couvrir avec des dates et qualités fixes.
- `lib/core/services/flashcards_service.dart` — porte les opérations paire, lecture, échéance et review ; rendre sa frontière de persistance testable sans toucher au schéma généré.
- `lib/core/services/db_wrapper.dart` — adaptateur Drift à réutiliser via une instance/executor de test, sans modifier `db_wrapper.g.dart`.
- `lib/core/services/stats_service.dart` et `lib/core/models/stats_model.dart` — calcul des totaux, séries, moyennes, couples et top 5 à caractériser sur un snapshot fixe.
- `lib/core/services/auth_service.dart`, `lib/core/services/user_preferences_service.dart` — contrats FirebaseAuth et SharedPreferences testables avec mocktail/valeurs en mémoire.
- `lib/features/translation/translate_tab.dart` — `_translate`, saisie et changement de langues : introduire un jeton de requête ou contrôleur testable qui invalide une réponse DeepL périmée avant UI/quota.
- `test/firestore_users_dao_test.dart`, `test/user_preferences_service_test.dart` — conventions existantes de doublures et baseline des préférences à corriger/étendre.

## Tasks & Acceptance

**Execution:**
- [x] `lib/core/models/flashcard.dart`, `lib/core/services/sm_two.dart`, `lib/core/services/flashcards_service.dart`, `lib/core/services/db_wrapper.dart` — introduire les seams minimales (horloge et persistance) qui permettent de caractériser sans SDK réel les conversions, paires, échéances et reviews ; ne changer aucun contrat de production.
- [x] `test/core/models/flashcard_test.dart`, `test/core/services/sm_two_test.dart`, `test/core/services/flashcards_service_test.dart` — couvrir paires bidirectionnelles, refus vide/doublon, round-trip Drift de tous les champs, due null/avant/à/après maintenant et vecteurs SM-2 persistés.
- [x] `lib/core/services/stats_service.dart`, `test/core/services/stats_service_test.dart` — rendre l’entrée de collection substituable et caractériser totaux, dédoublonnage des paires, couples non orientés, séries/moyennes par paire et trois classements décroissants plafonnés à cinq ; documenter tout écart fonctionnel avant correction.
- [x] `test/core/services/auth_service_test.dart`, `test/user_preferences_service_test.dart` — caractériser inscription, connexion, déconnexion, état utilisateur, vérification/réinitialisation, utilisateur absent, erreurs observables et valeurs/cycle de cache des préférences avec doublures contrôlées.
- [x] `lib/features/translation/translate_tab.dart` et `test/features/translation/translate_tab_test.dart` — isoler ou injecter le contrôle de requête nécessaire, invalider les résultats DeepL périmés et vérifier que seul le résultat courant actualise l’UI et le compteur.
- [x] `README.md` ou un fichier de documentation de test existant — consigner la commande de baseline et les catégories couvertes afin qu’elle précède chaque tranche de migration.

**Acceptance Criteria:**
- Given une tranche de migration à préparer, when la suite de baseline est exécutée, then les comportements cartes/persistance, statistiques, auth/préférences et traduction asynchrone sont couverts par des scénarios déterministes sans appel externe.
- Given une réponse de traduction qui n’est plus courante, when elle se résout, then elle ne remplace pas le résultat courant et ne consomme pas le quota.
- Given un test révèle un comportement legacy observable, when il est intégré à la baseline, then la règle est documentée et préservée plutôt que corrigée silencieusement.

## Spec Change Log

## Design Notes

La baseline privilégie les tests purs et les doublures contrôlées : l’adaptateur Drift demeure la seule frontière de stockage, FirebaseAuth et SharedPreferences sont simulés, et DeepL est résolu dans l’ordre choisi par le test. Un identifiant monotone de requête est suffisant pour invalider les résultats tardifs sans déplacer la feature vers MVVM, qui relève de la story 1.2.

## Verification

**Commands:**
- `flutter analyze` — attendu : aucune erreur d’analyse.
- `flutter test` — attendu : toutes les caractérisations existantes et nouvelles réussissent.
- `flutter test test/core/models test/core/services test/features/translation` — attendu : baseline critique isolée réussit sans réseau ni services SDK.

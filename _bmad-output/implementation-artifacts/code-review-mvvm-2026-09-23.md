# Revue de la migration MVVM — 2026-09-23

- Cible : `refactor-flutter-mvvm` comparée à `master`.
- Référence : `_bmad-output/specs/spec-migration-mvvm-riverpod/SPEC.md` et ses compagnons.
- Décision produit : les cartes de l'ancienne base peuvent être supprimées ; la nouvelle base démarre vide. Aucune migration des anciennes cartes n'est demandée.
- Vérification : `flutter analyze` réussi ; `flutter test` réussi (162 tests).

## Actions ouvertes

- [ ] **Élevé — Afficher les paires dans les deux sens de langue.** `lib/features/data/data_table_tab.dart:189` filtre uniquement la première face retenue par la projection. Une paire peut disparaître lorsque l'utilisateur sélectionne le sens inverse.
- [ ] **Élevé — Synchroniser les écritures historiques avec la collection observée.** `lib/features/flashcards/data/flashcard_repository.dart:58` publie seulement les écritures de son instance, alors que `lib/features/home_page.dart:206` enregistre encore via `FlashcardsService`. La table peut rester périmée après l'intention Android.
- [ ] **Élevé — Rendre l'enregistrement d'une traduction idempotent face aux doubles appuis.** `lib/features/translation/application/translation_save_view_model.dart:25` lance deux mutations ; le conflit de la seconde peut masquer le succès de la première.
- [ ] **Élevé — Préserver le compteur de traduction lors de la première restauration de session.** `lib/core/services/user_manager.dart:50` efface un ancien cache sans UID propriétaire, compteur compris, sans restaurer ce compteur depuis Firestore.
- [ ] **Moyen — Conserver le quota de traduction entre appareils.** `lib/core/providers/user_data_provider.dart:9` calcule le droit uniquement depuis le compteur local et ignore `canTranslate` conservé dans Firestore. Une connexion sur un autre appareil peut rouvrir le quota.
- [ ] **Moyen — Afficher une erreur et une action de reprise quand la table ne charge pas.** `lib/features/data/data_table_tab.dart:182` rend un écran vide sur erreur.
- [ ] **Moyen — Corriger et localiser les retours des mutations de table.** `lib/features/data/data_table_tab.dart:59` affiche « carte ajoutée » après une édition ou une suppression et contient de nouveaux messages codés en français.
- [ ] **Moyen — Distinguer commit et rafraîchissement du snapshot.** `lib/features/flashcards/data/flashcard_repository.dart:239` peut signaler un échec après une écriture validée si la relecture échoue ; `loadCollection` à la ligne 49 change le snapshot sans notifier les abonnés ni avancer sa version.
- [ ] **Moyen — Recharger l'interstitiel après son affichage.** `lib/core/services/ad_service.dart:75` le détruit sans lancer le préchargement suivant ; une occasion ultérieure ne fait alors que charger l'annonce.
- [ ] **Moyen — Exécuter la CI à chaque push.** `.github/workflows/quality.yml:3` déclare `pull_request` et `workflow_dispatch`, sans déclencheur `push` requis par le contrat MVVM.

## Portée de la décision

Le changement de nom de la base de cartes n'est pas une anomalie à corriger dans cette revue, compte tenu de la décision de repartir avec une collection vide. Cette décision ne concerne pas les préférences et quotas utilisateur.

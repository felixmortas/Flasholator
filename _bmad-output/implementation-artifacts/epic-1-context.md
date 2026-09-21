# Epic 1 Context: Utiliser Flasholator sans interruption pendant la migration

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Établir les garde-fous de la migration afin que Flasholator reste fiable, localisée et connectée à ses intégrations de production pendant chaque bascule vers MVVM/Riverpod. L’epic fournit une baseline de comportement, des conventions d’architecture et de bootstrap, ainsi qu’un processus de retrait réversible du legacy ; il rend les migrations suivantes testables sans modifier les parcours ni les données existants.

## Stories

- Story 1.1: Établir la baseline des comportements critiques
- Story 1.2: Composer les écrans migrés avec MVVM et Riverpod
- Story 1.3: Préserver le bootstrap et les ressources générées
- Story 1.4: Retirer le legacy seulement après bascule prouvée

## Requirements & Constraints

- Avant toute tranche, ajouter des tests de caractérisation déterministes couvrant les règles métier, la persistance, les états UI, les erreurs et les interactions visibles concernées. La baseline exécutable part du commit `0b2c6437dbc19b5414562428dce3384c20f1e209`.
- Les cas asynchrones obsolètes ne doivent modifier ni les données ni l’état affiché. La baseline couvre notamment cartes, statistiques, authentification et persistance, ainsi que les réponses tardives de traduction, changements de session, achats annulés ou en attente, restauration/perte de droits et consentement publicitaire refusé ou indisponible.
- Préserver tous les comportements fonctionnels et les données existantes pendant la migration, y compris le fonctionnement local-first hors ligne des cartes. Ne pas introduire de fonctionnalité métier, changement UX, synchronisation cloud des cartes ni mise à niveau de stack hors besoin de compatibilité explicite.
- Maintenir les intégrations Firebase, Drift, RevenueCat, DeepL, AdMob, UMP/ATT et la localisation durant les bascules. Aucun secret ne doit être ajouté à l’UI, aux ViewModels ou au domaine.
- Conserver la prise en charge iOS et Android, les configurations de build et les artefacts de distribution. Les localisations française, anglaise et espagnole restent disponibles.
- Chaque changement intégrable doit réussir `flutter analyze` et `flutter test`. Mesurer sur le même scénario et la même cible les temps de démarrage, d’affichage et de réponse aux actions avant/après une tranche ; traiter ou accepter explicitement toute régression avant bascule.
- Ne supprimer un chemin legacy qu’après migration de tous ses consommateurs vers le remplaçant et preuve de couverture. Tenir un registre indiquant le composant, son remplaçant, les consommateurs migrés, les tests associés et l’absence de références restantes. Chaque suppression est isolée dans un changement réversible.

## Technical Decisions

- Adopter une architecture MVVM par fonctionnalité : la vue rend l’état et transmet les intentions ; le ViewModel orchestre un état UI immuable ; un cas d’usage facultatif porte seulement une règle complexe ou partagée ; le repository dépend de services/adaptateurs. Les dépendances vont exclusivement de la présentation vers l’infrastructure, jamais dans le sens inverse.
- Utiliser Riverpod comme graphe unique de composition et d’état : `ProviderScope` est la racine, les dépendances testables sont surchargeables et un état partagé a un seul repository propriétaire. Les états temporaires appartiennent au ViewModel de l’écran. Les providers historiques restent en place jusqu’à la bascule complète de leurs consommateurs.
- Les ViewModels publics exposent des phases immuables `initial`, `loading`, `data` et `error`, avec erreurs applicatives typées. Les commandes mutantes sont sérialisées ou idempotentes ; toute requête remplaçable porte un contexte ou `requestId` et ne publie son résultat que s’il est toujours courant. Un effet unique n’est émis qu’une fois par commande acceptée.
- Conserver les contrats de domaine et repositories en Dart pur. Les adaptateurs encapsulent chacun une source externe ; les repositories effectuent mapping, cache, cohérence lecture/écriture et traduction d’erreurs sans changer le comportement visible. Les DTO, modèles générés et API Flutter ne franchissent pas la frontière du repository.
- Tester le domaine et les cas d’usage par tests unitaires purs, les repositories/adaptateurs avec doublures ou base temporaire, les ViewModels avec un `ProviderContainer` et overrides, et les vues avec des widget tests ciblés.
- Initialiser Flutter, Firebase avec `DefaultFirebaseOptions` et Ads une seule fois avant `ProviderScope`. Configurer RevenueCat une fois après restauration Firebase, puis l’identifier ou déconnecter selon les transitions de session. Aucune vue ni ViewModel n’initialise de SDK.
- Les fichiers ARB sont la source de vérité. Ne jamais modifier directement `lib/l10n/app_localizations*.dart` ni `lib/core/services/db_wrapper.g.dart` : modifier les sources, effectuer une migration Drift explicite si nécessaire, puis régénérer.
- Respecter les conventions de nommage `*_view.dart`, `*_view_model.dart`, `*_ui_state.dart`, `*_repository.dart` et `*_service.dart`, ainsi que les providers `<feature><Role>Provider`. Maintenir les versions de stack verrouillées par le projet ; toute mise à jour est un changement de compatibilité testé.

## Cross-Story Dependencies

- La Story 1.1 fournit la baseline nécessaire avant les migrations de fondation, de flashcards/révision, de traduction/tables, d’authentification/profil et de statistiques/monétisation.
- La Story 1.2 établit les frontières MVVM/Riverpod dont dépendent les écrans migrés des epics 2 à 5 ; la Story 1.3 en impose le point de composition et les règles de génération.
- La Story 1.4 dépend de la couverture de caractérisation et de la bascule complète apportées par les stories de migration ; aucun retrait n’est autorisé avant l’adoption du remplaçant par ses consommateurs.

# Revue technologique — architecture Flasholator

Date : 2026-09-21  
Périmètre : contrôle du spine contre `pubspec.yaml`, `pubspec.lock`, `lib/` et la documentation officielle actuelle des technologies citées.

## Verdict

**À corriger avant finalisation.** Le socle Riverpod, Drift et Firebase est cohérent avec les versions effectivement verrouillées et la stratégie de test par overrides est supportée. Deux règles liant la sécurité et le cycle de vie des SDK ne décrivent toutefois pas assez précisément la réalité à migrer ; une troisième présente un risque de cohérence de données si elle est appliquée sans une primitive transactionnelle concrète.

## Constats

### T-1 — Secret DeepL actuellement embarqué : AD-7 ne doit pas laisser croire que la configuration de plateforme suffit

**Sévérité : haute.** `lib/core/services/deepl_translator.dart` contient une clé DeepL en clair et l'envoie depuis le client. AD-7 prescrit des « clés/options par configuration de plateforme », sans distinguer une clé SDK publique d'un secret serveur. Or une configuration native reste extractible de l'application : elle ne protège pas une clé DeepL.

**Action attendue dans le spine :** compléter AD-7 : les secrets d'API à privilèges (notamment DeepL) ne sont jamais distribués au binaire ; l'adaptateur de traduction appelle un relais serveur authentifié, ou une solution de gestion de secrets explicitement décidée. Révoquer/faire tourner la clé déjà exposée hors du périmètre de cette migration.

La distinction est importante : les clés publiques RevenueCat (`goog_`/web SDK) sont précisément celles destinées à configurer le SDK client ; les clés secrètes RevenueCat ne le sont pas. Sources : [RevenueCat — API keys](https://www.revenuecat.com/docs/projects/authentication), [DeepL API — authentification](https://developers.deepl.com/docs/getting-started/auth).

### T-2 — RevenueCat ne peut pas être placé indifféremment dans le bootstrap « avant ProviderScope »

**Sévérité : moyenne.** AD-7 prévoit que le bootstrap initialise les SDK requis avant `ProviderScope`, alors qu'AD-6 confie à `UserSessionRepository` l'identité et les droits RevenueCat. L'implémentation actuelle configure RevenueCat avec un `userId` ; ce dernier n'est connu qu'après résolution de Firebase Auth. La documentation RevenueCat autorise une configuration unique avec identifiant anonyme, puis l'identification avec `logIn`, ou une configuration avec l'identifiant lorsqu'il est déjà connu.

**Action attendue dans le spine :** préciser l'ordre : Firebase/Ads peuvent être bootstrapés avant la racine ; RevenueCat est configuré une seule fois par l'adaptateur de session après restauration de session, avec identifiant Firebase, ou anonyme puis `logIn`/`logOut` à chaque transition de session. Ne pas reconstruire/reconfigurer le SDK depuis les écrans.

Source : [RevenueCat — configuration du SDK](https://www.revenuecat.com/docs/getting-started/configuring-sdk).

### T-3 — L'atomicité de la paire réversible doit devenir une opération Drift unique, pas seulement une responsabilité de repository

**Sévérité : moyenne.** AD-5 exige une paire atomique, mais la source actuelle effectue deux `insert`, deux `replace`, ou une suppression groupée sans transaction SQL enveloppante (`FlashcardsService.addFlashcard`, `editFlashcard`, `removeFlashcard`). Une migration qui se contente de déplacer ces appels dans `FlashcardRepository` respecte nominalement la frontière tout en conservant le risque d'écriture à moitié appliquée.

**Action attendue dans le spine :** rendre la règle exécutable : le port expose des opérations `addPair`, `editPair`, `deletePair` et leur adaptateur Drift les exécute dans `AppDatabase.transaction(...)` ; un test d'intégration vérifie l'absence de demi-paire lors d'un échec. Établir aussi comment les paires historiques sont reconnues tant qu'aucun identifiant de paire n'existe (point déjà différé, donc à caractériser avant la tranche).

Source : [Drift — transactions](https://drift.simonbinder.eu/docs/advanced-features/transactions/).

### T-4 — Les versions de la table sont des versions verrouillées, pas des bornes de compatibilité déclarées

**Sévérité : faible.** Les valeurs listées dans `Stack` correspondent exactement à `pubspec.lock` au contrôle : Riverpod 2.6.1, Drift 2.28.1/0.2.5, Firebase 3.15.2/5.7.0/5.6.12, RevenueCat 9.2.0 et Google Mobile Ads 6.0.0. Mais `pubspec.yaml` emploie `^` pour ces dépendances et sa contrainte Dart est `>=3.0.3 <4.0.0`. Les numéros du spine ne resteront vrais que tant que le lockfile est le résolveur reproduit par la CI.

**Action attendue dans le spine :** écrire « versions résolues par le lockfile au 2026-09-21 » dans la table, et ajouter que toute mise à jour de dépendances/Flutter est un changement de compatibilité testé ; ou verrouiller réellement les versions si c'est l'invariant recherché. La contrainte actuelle ne garantit pas à elle seule Flutter 3.32.5.

## Éléments ratifiés

- `ProviderScope` racine et les overrides via `ProviderContainer`/`ProviderScope` sont la mécanique Riverpod prévue pour des dépendances substituables en test.
- Les frontières Dart pur pour contrats/modèles et les adaptateurs SDK sont compatibles avec Flutter/Riverpod ; elles ne demandent pas une mise à niveau vers Riverpod 3 pour démarrer la migration.
- Les règles de génération Drift et Flutter l10n correspondent aux fichiers sources observés (`db_wrapper.dart`, ARB/l10n) et évitent de modifier leurs sorties générées.

Source : [Riverpod — testing and overrides](https://riverpod.dev/docs/how_to/testing).

# Revue adversariale — Architecture Spine Flasholator

## Verdict

**À renforcer avant handoff.** Le spine fixe bien les frontières et les propriétaires principaux, mais laisse quatre contrats de cohérence/lifecycle assez ouverts pour que deux tranches conformes produisent des résultats incompatibles. Les corrections proposées restent des précisions aux AD existantes, pas un changement de paradigme.

## Scénarios et constats

### AR-1 — Une paire atomique n'est pas une identité atomique

**Scénario.** La tranche traduction appelle `addPair(A,B)` deux fois rapidement (double toucher ou deux VM actifs), pendant que la tranche tables utilise `editPair(A,B,...)`. Les deux passent par `FlashcardRepository`, effectuent une transaction et appliquent SM-2 : elles respectent donc AD-5. Faute d'identifiant de paire, de contrainte d'unicité et de précondition/version explicite, la transaction peut néanmoins créer deux paires identiques, éditer une paire homonyme non déterministe, ou supprimer toutes les paires qui ont les mêmes faces. Les statistiques continuent ensuite de diviser par deux et deviennent silencieusement fausses.

**Ancrage observé.** Le legacy identifie les cartes par `(front, back)` et sépare actuellement les deux écritures (`FlashcardsService.addFlashcard`), alors que `removeFlashcard` supprime tous les enregistrements inverses correspondants. Drift ne définit ni relation de paire ni index/contrainte d'unicité dans `db_wrapper.dart`.

**Tightening proposé.** Compléter AD-5 : « Les commandes de paire prennent et retournent un `PairId` logique stable *ou*, jusqu'à la migration de schéma explicitement différée, exécutent recherche + précondition + mutation dans **la même transaction** avec une clé canonique `(front normalisé, back normalisé, langues)` et une erreur `conflict/alreadyExists` déterministe. Toute commande d'édition/suppression cible exactement une paire et ne sélectionne jamais par faces seules. » Ajouter des tests de course add/add, add/edit et delete/edit ainsi que les jeux de données legacy ambigus.

### AR-2 — Le propriétaire de session n'a pas de contrat de transition ni de révocation

**Scénario.** Une tranche Auth réagit à `authStateChanges` et reconstruit une session pour U2 ; en parallèle, une tranche Profil finit un `refresh` lancé pour U1, ou RevenueCat finit une requête d'entitlement de U1. Toutes deux utilisent exclusivement `UserSessionRepository` et ses adaptateurs, donc respectent AD-6, mais une réponse tardive peut réinjecter profil, quota ou premium de U1 dans l'état U2. Au logout, une vue de traduction déjà ouverte peut aussi finaliser son incrément de quota après la révocation.

**Ancrage observé.** `UserManager.login` séquence Firebase, RevenueCat et Firestore manuellement ; `signOut` ne déconnecte pas RevenueCat ; `AuthGate` écoute Firebase indépendamment du booléen de synchronisation. Ces chemins peuvent déjà s'entrelacer via des `Future` distincts.

**Tightening proposé.** Compléter AD-6 : « La session est une machine à états (`anonymous`, `hydrating(uid,generation)`, `authenticated(snapshot)`, `signingOut`) pilotée par un unique flux d'authentification. Chaque lecture/écriture asynchrone porte le `uid` et le `generation` capturés ; un résultat qui ne correspond plus à la session courante est ignoré. Logout/switch de compte invalide les opérations en cours, vide l'état, révoque/retire l'identité RevenueCat selon le comportement caractérisé, puis seulement expose `anonymous`. » Caractériser connexion U1 → déconnexion → connexion U2 pendant refresh, et quota/premium en vol.

### AR-3 — Les états UI immuables n'empêchent pas les résultats asynchrones périmés

**Scénario.** Deux implémenteurs créent chacun un `TranslationViewModel` conforme à AD-3 : chaque intention produit un état immuable. L'utilisateur lance traduction « chat », change langue ou texte, puis la première requête, plus lente, revient après la seconde : elle écrase correctement mais obsolètement le résultat. Le même phénomène existe pour review : le chargement des cartes dues revient après un changement de filtre ou après l'évaluation d'une carte et remet une carte déjà consommée. Aucun AD ne définit l'ordonnancement, l'annulation ou la validité d'un résultat.

**Ancrage observé.** `TranslateTab._translate` capture du texte et les langues dans des champs mutables puis appelle `setState` au retour ; `ReviewTab.updateQuestionText` est async et peut être invoquée après plusieurs actions sans jeton de requête.

**Tightening proposé.** Compléter AD-3 : « Chaque ViewModel définit la politique de concurrence de ses intentions : commande mutante sérialisée/idempotente ; requête remplaçable associée à un `requestId` ou annulable ; résultat appliqué seulement s'il correspond au dernier contexte (entrée, filtre, session et état non disposed). Les effets uniques (toast, navigation, paywall) sont émis une seule fois par commande acceptée, hors de l'état rejoué. » Exiger des tests de réponses inversées, double validation de review et départ de vue pendant requête.

### AR-4 — La frontière repository ne donne pas de snapshot commun aux consommateurs des cartes

**Scénario.** Review lit les cartes dues, Stats lit toutes les cartes, et Tables supprime une paire. Chaque feature dépend uniquement du `FlashcardRepository` et reste conforme aux AD-1/2/5. Pourtant le repository peut exposer trois lectures indépendantes : Review peut évaluer une carte supprimée, Stats calculer avec une moitié de paire selon l'instant de lecture, et Tables afficher une liste qui ne se rafraîchit jamais. L'unicité du propriétaire ne suffit pas à rendre cohérents ses lecteurs ni à définir le traitement d'un conflit d'écriture.

**Ancrage observé.** Le legacy charge des listes ponctuelles (`loadAllFlashcards`, `dueFlashcards`) ; `StatsService` et `ReviewTab` en dérivent des vues séparées. Il n'existe pas de contrat de stream/snapshot ni de résultat « carte absente » pour `review`.

**Tightening proposé.** Compléter AD-5 : « Le repository expose un contrat explicite de lecture cohérente : snapshot versionné ou flux invalidé après commit, et toutes les projections review/tables/stats proviennent de cette même source. Une mutation retourne un résultat typé (`applied`, `notFound`, `conflict`) ; review ne transforme jamais silencieusement `notFound` en succès. Après commit, les projections concernées sont invalidées/recalculées dans l'ordre défini par le repository. » Ajouter les tests suppression pendant review, mutation suivie de rafraîchissement des trois projections et migration d'une paire incomplète.

## Non-problèmes confirmés

- La séparation vue → ViewModel → repository/adaptateur et l'interdiction des SDK dans la UI sont explicites (AD-1, AD-4).
- L'initialisation centralisée des SDK et l'interdiction de modifier les sources générées répondent aux dérives les plus probables de bootstrap et de génération (AD-7, AD-9).

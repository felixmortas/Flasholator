---
title: "PRD — Migration MVVM/Riverpod de Flasholator"
status: final
created: "2026-09-21"
updated: "2026-09-21"
---

# PRD — Migration MVVM/Riverpod de Flasholator


## Vision et périmètre

Faire évoluer Flasholator vers une architecture MVVM par fonctionnalité avec Riverpod, sans régression visible pour l'utilisateur ni perte de données, afin que le parcours traduction → flashcards → révision → premium devienne maintenable, testable et prêt pour la production iOS et Android.

**Dans le périmètre.** La migration couvre les fonctions existantes employées dans le parcours de référence : bootstrap, session et authentification, traduction, gestion des flashcards, révision espacée, tables, profil, statistiques et monétisation.

**Hors périmètre.** Le chantier n'introduit pas de fonctionnalité métier, de changement de conception UX, ni de synchronisation cloud des cartes. Les groupes de mots, l'import/export et la synchronisation Google Drive relèvent de la roadmap et sont exclus. Il ne met pas non plus à niveau Flutter ou Riverpod hors besoin de compatibilité directement créé par la migration.

## Critères de succès

- Tous les parcours existants concernés — cartes, révision, traduction, tables, authentification, profil, statistiques et monétisation — utilisent l'architecture MVVM/Riverpod cible.
- Les comportements fonctionnels et les données existantes sont préservés, y compris le SRS, les limites freemium et les droits premium.
- Les vues et ViewModels n'instancient ni Firebase, Drift, RevenueCat, DeepL, AdMob ou UMP ; leurs dépendances sont injectables et surchargeables en test.
- Chaque tranche est précédée de tests de caractérisation et validée par `flutter analyze` et `flutter test`.
- Les composants legacy ne sont supprimés qu'après migration complète de leurs consommateurs et preuve de couverture.

## Groupes de capacités

1. **Fondations :** tests de caractérisation, bootstrap et conventions MVVM/Riverpod.
2. **Flashcards et révision :** paires, persistance locale et algorithme SM-2.
3. **Traduction et tables :** DeepL, sauvegarde/correction et liste des cartes.
4. **Session et compte :** inscription, vérification e-mail, connexion persistante et déconnexion.
5. **Profil, statistiques et premium :** limites freemium, RevenueCat, droits et statistiques.
6. **Retrait progressif du legacy :** suppression après la bascule complète de chaque consommateur.

## Exigences fonctionnelles

### Fondations

- **FR1.** Avant chaque migration de tranche, l'équipe doit disposer de tests de caractérisation couvrant les règles métier, la persistance et les interactions visibles affectées.
- **FR2.** Chaque écran migré doit séparer le rendu et les interactions de l'état UI immuable et de l'orchestration métier ; ses dépendances doivent pouvoir être remplacées en test.
- **FR3.** Le démarrage de l'application doit conserver l'initialisation unique des services nécessaires et ne pas exposer de secrets ni de SDK externes aux écrans.
- **FR4.** La migration doit préserver les sources générées et la localisation : seules leurs sources sont modifiées puis régénérées.

### Flashcards et révision

- **FR5.** L'utilisateur peut créer, consulter, modifier et supprimer une paire de cartes sans créer d'état partiel entre ses deux faces. Chaque mutation cible exactement la paire concernée, est atomique et retourne un résultat permettant de distinguer l'application de la mutation, l'absence de la paire ou un conflit.
- **FR6.** Les cartes et leur historique de révision restent disponibles hors-ligne après migration, sans perte ni changement non intentionnel de format.
- **FR7.** L'utilisateur peut lancer une révision, révéler la réponse, choisir la qualité de sa réponse et obtenir une date de prochaine révision calculée selon le comportement SM-2 actuel.
- **FR8.** Les listes de cartes à réviser, les tables et les statistiques s'appuient sur une même collection cohérente après chaque modification.
- **FR9.** Les erreurs de lecture, écriture ou révision restent compréhensibles et se comportent comme avant la migration.

### Traduction et tables

- **FR10.** L'utilisateur peut saisir ou coller un mot ou une courte phrase, puis lancer une traduction via DeepL seulement lorsque la saisie est valide.
- **FR11.** L'utilisateur peut consulter le résultat d'une traduction et l'enregistrer comme paire de flashcards.
- **FR12.** L'utilisateur peut retrouver ses cartes par couple de langues dans les tables et corriger une traduction enregistrée pour son contexte.
- **FR13.** Les erreurs, l'état de chargement et les résultats tardifs de traduction ne doivent ni masquer une action ultérieure ni modifier une carte de façon inattendue.
- **FR14.** La migration conserve le comportement actuel de la limite gratuite de traductions. Sa valeur peut être modifiée et la limite peut être désactivée facilement par un développeur, sans ajouter de réglage utilisateur et sans changer le parcours premium.

### Session et compte

- **FR15.** Un nouvel utilisateur peut s'inscrire, vérifier son adresse e-mail et se connecter pour utiliser l'application.
- **FR16.** L'utilisateur authentifié peut définir et retrouver son couple de langues par défaut.
- **FR17.** Au retour dans l'application, une session valide est restaurée sans nouvelle connexion ; une déconnexion ou un changement de compte annule les opérations en cours de la session précédente, purge le cache local de cette session et ne peut pas exposer ses données ou ses droits.
- **FR18.** Les états de session, profil et droits sont cohérents malgré les retours asynchrones de Firebase, du cache local et de RevenueCat.
- **FR19.** Les erreurs d'authentification et de session conservent leur comportement visible existant.

### Profil, statistiques et premium

- **FR20.** L'utilisateur peut consulter dans son profil des statistiques calculées à partir de la même collection de cartes que la révision et les tables.
- **FR21.** Les statistiques préservent les règles actuelles : dédoublonnement des paires, traitement non orienté des couples de langues, calcul des séries et des moyennes par paire, et classements décroissants limités à cinq entrées.
- **FR22.** L'utilisateur peut souscrire et restaurer ses droits premium via RevenueCat ; l'état premium se reflète de manière fiable dans l'application.
- **FR23.** Un utilisateur gratuit est limité à un couple de langues, 200 traductions et 20 paires de flashcards stockables pour révision ; ces limites sont indépendamment configurables et désactivables par un développeur.
- **FR24.** Un utilisateur premium peut changer de couple de langues, traduire et réviser sans limite, réviser tous les couples ensemble, saisir une réponse pour vérification automatique et utiliser l'application sans publicité.
- **FR25.** Les transitions de droits premium et les erreurs associées ne donnent jamais accès à un état incohérent ou à des fonctions incorrectement verrouillées.
- **FR26.** Les utilisateurs gratuits conservent le comportement publicitaire existant ; le consentement UMP/RGPD et le flux ATT iOS sont préservés, sans afficher d'annonce avant l'autorisation requise.

### Retrait progressif du legacy

- **FR27.** Une tranche n'utilise plus son chemin legacy seulement après que tous ses consommateurs ont basculé vers son remplaçant MVVM/Riverpod.
- **FR28.** Avant suppression, l'équipe maintient un registre indiquant le composant legacy, son remplaçant, les consommateurs migrés et les tests qui couvrent son comportement.
- **FR29.** Chaque suppression legacy est isolée dans un changement réversible et vérifiée par l'analyse et les tests Flutter.
- **FR30.** Les intégrations de production existantes — Firebase, Drift, RevenueCat, DeepL, AdMob, UMP/ATT et la localisation — restent fonctionnelles pendant toute la migration.

## Exigences non fonctionnelles

- **NFR1.** La migration reste compatible iOS et Android avec la version Flutter verrouillée par le projet, sans mise à niveau de stack implicite.
- **NFR2.** Chaque changement destiné à être intégré doit réussir `flutter analyze` et `flutter test` ; la CI les exécute à chaque push et pull request.
- **NFR3.** La consultation des cartes et les révisions restent utilisables hors-ligne, avec le même comportement local-first qu'avant migration.
- **NFR4.** Les données et droits utilisateur restent isolés par session, et aucun secret n'est ajouté dans l'UI, les ViewModels ou le domaine.
- **NFR5.** Les mutations de paires de cartes préservent l'intégrité des données en cas d'erreur, conflit ou interruption.
- **NFR6.** Le français, l'anglais et l'espagnol continuent d'être pris en charge par la chaîne de localisation existante.
- **NFR7.** Avant et après chaque tranche, les temps de démarrage, d'affichage des écrans et de réponse aux actions sont comparés sur le même scénario et la même cible de référence ; toute régression observée est traitée ou explicitement acceptée avant bascule.
- **NFR8.** Les configurations, secrets et artefacts nécessaires aux builds et distributions Android et iOS existants sont préservés ; ce chantier n'en modifie pas le pipeline.

## Contraintes techniques de migration

- Flutter, Firebase à l'aide de `DefaultFirebaseOptions` et Ads sont initialisés une seule fois avant le `ProviderScope`. RevenueCat est configuré une seule fois après la restauration de Firebase. Il est ensuite identifié ou déconnecté à chaque transition de session.
- La collection de flashcards est l'unique source de données des projections de révision, tables et statistiques ; Drift réalise les mutations de paires transactionnellement.
- Firebase Auth est la source de vérité de session ; Firestore porte le profil et les droits, le cache local n'étant qu'un accélérateur. RevenueCat est la source des entitlements.
- Les limites freemium sont définies dans une configuration développeur centralisée, à valeurs par défaut `1` couple de langues, `200` traductions et `20` paires de flashcards. Cette configuration est injectée, surchargeable en test et permet de désactiver chaque limite sans réglage utilisateur.

## Contrat de caractérisation

Avant chaque tranche, les tests de caractérisation produits depuis l'état courant du dépôt — commit de référence `0b2c6437dbc19b5414562428dce3384c20f1e209` — deviennent la baseline exécutable de comportement. Ils couvrent les données de départ, les résultats attendus, les états UI et les erreurs des parcours touchés. Les cas d'achat annulé ou en attente, de restauration ou perte de droits, de consentement publicitaire refusé ou indisponible, de réponse DeepL tardive et de changement de session font partie de cette baseline ; un résultat asynchrone devenu obsolète ne modifie ni les données ni l'état affiché.

## Glossaire

| Terme | Définition normative |
| --- | --- |
| Carte / flashcard | Une carte de révision comportant un recto et un verso. |
| Paire de flashcards | Deux flashcards dont les rectos et versos sont intervertis. Les limites de stockage comptent les paires. |
| Mot stocké | Une paire de mots présente dans la liste de paires de flashcards. |
| Couple de langues | Une association de deux langues, par exemple français/anglais. Il est directionnel pour la traduction et le choix utilisateur ; les statistiques le traitent comme non orienté. |

## Stratégie de migration

La migration est réalisée dans cet ordre :

1. Tests de caractérisation : cartes, statistiques, authentification et persistance.
2. Fondations MVVM/Riverpod.
3. Flashcards et révision.
4. Traduction et tables.
5. Authentification et profil.
6. Statistiques et monétisation.
7. Retrait du legacy après chaque bascule vérifiée.

Chaque tranche suit le cycle : caractériser le comportement → migrer une feature complète → exécuter l'analyse et les tests → consigner les consommateurs migrés → retirer le legacy seulement s'il n'est plus référencé.

## Parcours utilisateur de référence

**UJ-1 — De la première ouverture à la révision et au premium.** Ludovic découvre Flasholator. Il crée un compte, vérifie son adresse e-mail, se connecte puis définit son couple de langues par défaut. Dans l'onglet de traduction, il saisit ou colle un mot ou une courte phrase ; une fois la saisie valide, il lance une requête DeepL. Quand une proposition lui convient, il l'enregistre comme paire de flashcards.

Lorsqu'une traduction ne correspond pas à son contexte, Ludovic peut tout de même enregistrer la paire, ouvrir ensuite la liste de cartes, sélectionner la paire concernée et corriger la traduction. Plus tard, dans l'onglet de révision, il voit une carte, cherche mentalement la réponse, l'affiche, puis indique la qualité de sa réponse. L'algorithme de répétition espacée planifie la prochaine révision.

Lors d'un retour ultérieur, sa session est restaurée. Depuis son profil, Ludovic consulte ses statistiques et s'abonne via RevenueCat. Après le parcours d'abonnement, il accède aux capacités premium : choix des couples de langues, traductions et révisions sans limite, saisie de réponse avec vérification automatique, et révision de cartes de tous les couples de langues.

**Règles freemium : voir FR23.**

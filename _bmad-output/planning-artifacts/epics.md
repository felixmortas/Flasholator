---
stepsCompleted: [1, 2, 3, 4]
inputDocuments:
  - "prds/prd-Flasholator-2026-09-21/prd.md"
  - "architecture/architecture-Flasholator-2026-09-21/ARCHITECTURE-SPINE.md"
---

# Flasholator - Epic Breakdown

## Overview

Découpage des exigences de migration MVVM/Riverpod de Flasholator.

## Requirements Inventory

### Functional Requirements

FR1: Tests de caractérisation avant chaque tranche.
FR2: Séparation vue, état UI immuable et orchestration, avec dépendances testables.
FR3: Bootstrap unique des services sans SDK ou secret dans les écrans.
FR4: Sources générées et localisation modifiées depuis leurs sources puis régénérées.
FR5: CRUD atomique d'une paire de flashcards avec résultat applied/notFound/conflict.
FR6: Cartes et historique disponibles hors ligne sans perte ni changement non intentionnel.
FR7: Révision avec réponse révélée, qualité et échéance SM-2 inchangée.
FR8: Review, tables et statistiques fondées sur une collection cohérente.
FR9: Erreurs de lecture, écriture et révision préservées.
FR10: Saisie valide et traduction via DeepL.
FR11: Sauvegarde du résultat de traduction comme paire de flashcards.
FR12: Consultation par couple de langues et correction d'une traduction enregistrée.
FR13: Chargement, erreur et réponses de traduction tardives sans effet inattendu.
FR14: Limite gratuite de traduction conservée, configurable et désactivable par développeur.
FR15: Inscription, vérification e-mail et connexion.
FR16: Définition et restitution du couple de langues par défaut.
FR17: Restauration et isolation de session, y compris annulation et purge du cache de session.
FR18: Cohérence session, profil et droits entre Firebase, cache et RevenueCat.
FR19: Erreurs d'authentification et de session observables préservées.
FR20: Statistiques de profil fondées sur la collection de cartes partagée.
FR21: Dédoublonnage, couples non orientés, séries/moyennes par paire et top 5 préservés.
FR22: Souscription et restauration des droits premium via RevenueCat.
FR23: Limites gratuites : 1 couple, 200 traductions, 20 paires ; configurables par développeur.
FR24: Droits premium : langues, usages illimités, réponse écrite, révision globale et sans publicité.
FR25: Transitions et erreurs de droits sans état incohérent ni fonctionnalité mal verrouillée.
FR26: Publicité gratuite, UMP/RGPD et ATT iOS préservés sans annonce non autorisée.
FR27: Bascule complète des consommateurs avant abandon d'un chemin legacy.
FR28: Registre de retrait legacy avec remplaçant, consommateurs et tests.
FR29: Suppression legacy réversible, vérifiée par analyse et tests.
FR30: Intégrations Firebase, Drift, RevenueCat, DeepL, AdMob, UMP/ATT et localisation préservées.

### NonFunctional Requirements

NFR1: Compatibilité iOS/Android et stack Flutter verrouillée.
NFR2: `flutter analyze` et `flutter test` réussissent pour chaque changement ; CI à chaque push et PR.
NFR3: Consultation et révision offline local-first préservées.
NFR4: Isolation des données/droits par session et aucun secret dans UI, ViewModels ou domaine.
NFR5: Intégrité des mutations de paires malgré erreur, conflit ou interruption.
NFR6: Localisation française, anglaise et espagnole préservée.
NFR7: Mesure comparative de performance avant/après chaque tranche, avec régression traitée ou acceptée.
NFR8: Configurations, secrets et artefacts des builds/distributions mobiles préservés.

### Additional Requirements

- Une feature suit MVVM : vue → ViewModel → cas d'usage facultatif → repository → adaptateur ; les dépendances inverses sont interdites.
- Riverpod fournit un graphe unique d'injection, des providers surchargeables en test et un propriétaire unique par état partagé.
- Les états UI exposent des phases immuables et des erreurs typées ; commandes mutantes sérialisées, résultats asynchrones obsolètes ignorés.
- Les modèles de domaine et contrats de repository restent en Dart pur ; SDK et DTO restent dans les adaptateurs.
- Drift exécute `addPair`, `editPair` et `deletePair` dans une transaction avec clé canonique jusqu'à une éventuelle migration de schéma explicite.
- Firebase Auth est maître de session ; Firestore porte profil/droits, cache local accélérateur, RevenueCat porte les entitlements ; chaque opération est protégée par uid/génération.
- Bootstrap : Flutter, Firebase et Ads avant `ProviderScope` ; RevenueCat configuré une fois après restauration Firebase.
- La configuration développeur des limites freemium est centralisée, injectée, surchargeable en test, avec défauts 1/200/20 et désactivation individuelle.
- Les tests de caractérisation du commit `0b2c6437dbc19b5414562428dce3384c20f1e209` constituent la baseline exécutable ; ils couvrent également les transitions achat, droits, consentement, traduction tardive et session.
- Ne jamais modifier directement `app_localizations*.dart` ni `db_wrapper.g.dart` ; modifier les sources, migrer Drift explicitement et régénérer.
- La migration n'ajoute ni synchronisation cloud des cartes, ni nouvelle fonctionnalité métier, ni refonte UX, ni mise à niveau de stack hors compatibilité.
- Les statistiques proviennent d'un `StatisticsUseCase` et appliquent la projection de référence sur le snapshot de cartes.

### UX Design Requirements

Aucun contrat UX fourni ; préserver les comportements et retours utilisateur existants.

### FR Coverage Map

FR1: Epic 1 - Baseline de caractérisation.
FR2: Epic 1 - Séparation MVVM et dépendances testables.
FR3: Epic 1 - Bootstrap de production sûr.
FR4: Epic 1 - Sources générées et l10n préservées.
FR5: Epic 2 - Gestion atomique des paires.
FR6: Epic 2 - Persistance offline des cartes et historique.
FR7: Epic 2 - Révision SM-2 préservée.
FR8: Epic 2 - Projections cohérentes de la collection.
FR9: Epic 2 - Erreurs de cartes/révision préservées.
FR10: Epic 3 - Saisie et traduction DeepL valides.
FR11: Epic 3 - Sauvegarde d'une traduction.
FR12: Epic 3 - Tables et correction de paire.
FR13: Epic 3 - États asynchrones de traduction.
FR14: Epic 3 - Limite gratuite de traduction.
FR15: Epic 4 - Inscription, vérification et connexion.
FR16: Epic 4 - Couple de langues par défaut.
FR17: Epic 4 - Restauration et isolation de session.
FR18: Epic 4 - Cohérence session, profil et droits.
FR19: Epic 4 - Erreurs d'authentification préservées.
FR20: Epic 5 - Statistiques de profil.
FR21: Epic 5 - Règles de calcul des statistiques.
FR22: Epic 5 - Souscription/restauration RevenueCat.
FR23: Epic 5 - Limites freemium.
FR24: Epic 5 - Capacités premium, y compris sans publicité.
FR25: Epic 5 - Transitions fiables des droits.
FR26: Epic 5 - Publicité et consentement conformes.
FR27: Epic 1 - Bascule complète avant retrait legacy.
FR28: Epic 1 - Registre de retrait legacy.
FR29: Epic 1 - Suppression legacy réversible et vérifiée.
FR30: Epic 1 - Intégrations de production conservées.

## Epic List

### Epic 1: Utiliser Flasholator sans interruption pendant la migration

Les utilisateurs continuent d'utiliser une application fiable, localisée et connectée à ses services de production pendant que chaque bascule est sécurisée et réversible.

**FRs covered:** FR1, FR2, FR3, FR4, FR27, FR28, FR29, FR30.

### Epic 2: Mémoriser son vocabulaire sans perdre ses cartes

Les utilisateurs créent, gèrent et révisent leurs paires hors-ligne avec la planification SM-2 et les retours d'erreur existants.

**FRs covered:** FR5, FR6, FR7, FR8, FR9.

### Epic 3: Traduire et organiser son vocabulaire

Les utilisateurs traduisent via DeepL, enregistrent et corrigent des paires, avec les protections de quota gratuit existantes.

**FRs covered:** FR10, FR11, FR12, FR13, FR14.

### Epic 4: Accéder à son espace personnel en toute sécurité

Les utilisateurs créent et retrouvent leur compte, leur session et leur couple de langues sans exposition de données ni de droits entre comptes.

**FRs covered:** FR15, FR16, FR17, FR18, FR19.

### Epic 5: Suivre ses progrès et bénéficier du premium

Les utilisateurs consultent leurs statistiques, souscrivent ou restaurent leurs droits premium, et reçoivent les limites et publicités correspondant à leur statut.

**FRs covered:** FR20, FR21, FR22, FR23, FR24, FR25, FR26.

## Epic 1: Utiliser Flasholator sans interruption pendant la migration

Les utilisateurs continuent d'utiliser une application fiable, localisée et connectée à ses services de production pendant les bascules.

### Story 1.1: Établir la baseline des comportements critiques

As a product owner, I want des tests de caractérisation déterministes, So that chaque migration préserve la production.

**Acceptance Criteria:**

**Given** le commit de référence `0b2c6437dbc19b5414562428dce3384c20f1e209` **When** une tranche est préparée **Then** ses scénarios critiques sont testés avant bascule **And** les résultats asynchrones obsolètes ne modifient ni données ni état UI.

### Story 1.2: Composer les écrans migrés avec MVVM et Riverpod

As a utilisateur, I want des écrans fiables, So that mes actions conservent leur comportement durant la migration.

**Acceptance Criteria:**

**Given** un écran migré **When** il est exécuté ou testé **Then** la vue ne fait que rendre l'état et transmettre les intentions **And** son ViewModel expose un état immuable et des dépendances surchargeables.

### Story 1.3: Préserver le bootstrap et les ressources générées

As a utilisateur mobile, I want un démarrage et des textes localisés fiables, So that l'application reste utilisable sur iOS et Android.

**Acceptance Criteria:**

**Given** le démarrage de l'application **When** les services sont composés **Then** Flutter, Firebase et Ads sont initialisés une seule fois avant `ProviderScope` **And** aucune vue ou ViewModel n'initialise de SDK.

**Given** une modification Drift ou l10n **When** elle est intégrée **Then** seules les sources sont modifiées et les fichiers générés sont régénérés **And** les localisations FR/EN/ES restent disponibles.

### Story 1.4: Retirer le legacy seulement après bascule prouvée

As a product owner, I want une trace vérifiable des remplacements, So that aucun parcours de production ne soit supprimé prématurément.

**Acceptance Criteria:**

**Given** un composant legacy candidat au retrait **When** son remplacement est proposé **Then** un registre indique remplaçant, consommateurs migrés et tests associés **And** le retrait ne commence que sans référence restante.

**Given** une suppression legacy **When** elle est intégrée **Then** elle est isolée et réversible **And** `flutter analyze` et `flutter test` réussissent.

## Epic 2: Mémoriser son vocabulaire sans perdre ses cartes

Les utilisateurs gèrent et révisent leurs paires hors-ligne avec le comportement SRS existant.

### Story 2.1: Gérer atomiquement les paires de flashcards

As a apprenant, I want créer, modifier et supprimer une paire complète, So that mes cartes restent cohérentes.

**Acceptance Criteria:**

**Given** une demande d'ajout, modification ou suppression **When** elle est traitée par le repository de cartes **Then** Drift applique les deux flashcards dans une même transaction **And** le résultat est `applied`, `notFound` ou `conflict`.

**Given** une erreur ou un conflit **When** la transaction se termine **Then** aucune demi-paire n'est persistée **And** l'erreur observable est préservée.

### Story 2.2: Conserver les cartes hors-ligne et leurs projections

As a apprenant, I want retrouver mes cartes et leur historique sans réseau, So that je puisse apprendre partout.

**Acceptance Criteria:**

**Given** des données existantes en base locale **When** la collection est lue après migration **Then** cartes et historique restent disponibles sans changement non intentionnel de format.

**Given** une mutation appliquée **When** les projections sont rafraîchies **Then** review, tables et statistiques lisent le même snapshot cohérent **And** aucun résultat d'une mutation échouée n'est publié.

### Story 2.3: Réviser avec le comportement SM-2 caractérisé

As a apprenant, I want révéler une réponse puis évaluer ma réussite, So that la prochaine révision reste correctement planifiée.

**Acceptance Criteria:**

**Given** une carte due **When** l'utilisateur révèle la réponse puis choisit une qualité **Then** l'état de révision et la prochaine échéance correspondent aux vecteurs de caractérisation SM-2.

**Given** une commande de score en cours **When** une seconde commande est tentée **Then** les mutations sont sérialisées **And** un seul effet utilisateur est émis pour la commande acceptée.

## Epic 3: Traduire et organiser son vocabulaire

Les utilisateurs traduisent, enregistrent et corrigent des paires dans les limites de leur statut.

### Story 3.1: Traduire une saisie valide sans résultat tardif

As a apprenant, I want traduire un mot ou une courte phrase, So that je puisse décider de l'apprendre.

**Acceptance Criteria:**

**Given** une saisie valide et un couple de langues actif **When** l'utilisateur lance la traduction **Then** le ViewModel expose chargement puis résultat ou erreur DeepL.

**Given** plusieurs requêtes successives ou un changement de session **When** une réponse ancienne revient **Then** elle est ignorée **And** elle ne remplace pas le résultat courant.

### Story 3.2: Enregistrer et corriger une traduction dans les tables

As a apprenant, I want enregistrer puis corriger une paire, So that mes cartes correspondent à mon contexte.

**Acceptance Criteria:**

**Given** une traduction affichée **When** elle est enregistrée **Then** une paire atomique est créée et les tables sont invalidées après commit.

**Given** une paire listée par couple de langues **When** l'utilisateur la modifie **Then** les deux flashcards restent cohérentes **And** les erreurs et conflits sont rendus sans modification partielle.

### Story 3.3: Appliquer des limites gratuites configurables

As a utilisateur gratuit, I want connaître l'accès disponible, So that mes traductions respectent mon offre.

**Acceptance Criteria:**

**Given** la configuration développeur par défaut **When** un utilisateur gratuit traduit **Then** la limite de 200 est appliquée selon la baseline **And** le premium n'est pas limité.

**Given** un test ou une livraison qui modifie une limite **When** un provider de configuration est surchargé **Then** chaque limite peut être changée ou désactivée sans réglage utilisateur.

## Epic 4: Accéder à son espace personnel en toute sécurité

Les utilisateurs retrouvent leur compte, leurs préférences et leurs droits sans fuite entre sessions.

### Story 4.1: Authentifier et restaurer une session utilisateur

As a nouvel utilisateur, I want m'inscrire, vérifier mon e-mail et me connecter, So that j'accède à mon espace Flasholator.

**Acceptance Criteria:**

**Given** les flux Firebase existants **When** l'utilisateur s'inscrit, vérifie son e-mail ou se connecte **Then** les états et erreurs visibles sont préservés.

**Given** une session Firebase valide au démarrage **When** elle est restaurée **Then** l'application expose l'utilisateur authentifié sans nouvelle connexion **And** RevenueCat est configuré une seule fois puis identifié.

### Story 4.2: Isoler les sessions et les préférences de langue

As a utilisateur authentifié, I want retrouver mon couple de langues sans voir les données d'un autre compte, So that mon espace reste personnel.

**Acceptance Criteria:**

**Given** un utilisateur connecté **When** il choisit un couple de langues par défaut **Then** ce choix est retrouvé dans sa session.

**Given** une déconnexion ou un changement de compte **When** des opérations précédentes reviennent tardivement **Then** elles sont ignorées par uid/génération **And** le cache de cette session est purgé avant exposition de l'état suivant.

## Epic 5: Suivre ses progrès et bénéficier du premium

Les utilisateurs consultent leurs progrès et reçoivent des droits, limites et publicités cohérents avec leur statut.

### Story 5.1: Consulter des statistiques cohérentes

As a apprenant, I want consulter mes statistiques de profil, So that je mesure mes progrès.

**Acceptance Criteria:**

**Given** le snapshot de cartes partagé **When** les statistiques sont calculées **Then** les paires sont dédoublonnées, les couples traités comme non orientés et les séries/moyennes calculées par paire.

**Given** un classement statistique **When** il est affiché **Then** il est décroissant et limité à cinq entrées **And** il correspond à la baseline de caractérisation.

### Story 5.2: Souscrire et restaurer les droits premium

As a utilisateur, I want souscrire ou restaurer mon abonnement, So that les capacités premium se débloquent de façon fiable.

**Acceptance Criteria:**

**Given** un achat ou une restauration RevenueCat **When** un entitlement confirmé est reçu **Then** le profil expose les droits premium correspondants.

**Given** un achat annulé, en attente, échoué ou un entitlement expiré **When** l'état est réconcilié **Then** les données sont conservées et les droits affichés suivent la baseline sans état incohérent.

### Story 5.3: Appliquer les droits freemium, premium et publicitaires

As a utilisateur, I want une offre cohérente avec mon statut, So that les limites et publicités sont prévisibles.

**Acceptance Criteria:**

**Given** un utilisateur gratuit **When** il utilise l'application **Then** un seul couple, 200 traductions et 20 paires sont appliqués selon la configuration active.

**Given** un utilisateur premium **When** ses droits sont confirmés **Then** il peut utiliser les langues, traductions et révisions sans limite, réviser globalement, saisir une réponse et ne voit aucune publicité.

**Given** le consentement UMP/RGPD ou ATT est refusé, indisponible ou retiré **When** l'application évalue une publicité gratuite **Then** elle ne l'affiche pas sans autorisation requise.

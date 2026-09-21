# Revue rubric — Architecture Spine Flasholator

## Verdict

**À corriger avant finalisation.** Le spine donne un bon cadre MVVM/Riverpod et couvre les frontières principales, mais il laisse cinq écarts réels entre les futures features, dont trois portent directement sur des critères transverses du SPEC.

## Périmètre et méthode

Revue indépendante du spine au niveau *initiative*, confrontée à `SPEC.md`, `migration-contract.md`, `AGENTS.md`, `pubspec.yaml`, `.github/workflows/quality.yml` et aux implémentations legacy de cartes, statistiques et session utilisateur.

Le lint déterministe n'a pas pu être exécuté : `uv` ne peut pas initialiser son cache sous `/Users/felix/.cache/uv` dans le sandbox. La revue sémantique a donc été réalisée manuellement ; ce n'est pas un résultat de lint valide.

## Findings

### HIGH — Les invariants statistiques du contrat ne possèdent aucun propriétaire architectural

- **Constat :** CAP-5 est rattachée à AD-3/4/6/7/10, mais aucune AD ne fixe le propriétaire du calcul statistique ni les règles qui doivent rester communes : dédoublonnage d'une paire réversible, couple de langues non orienté, séries et moyennes par paire, classement décroissant limité à cinq. AD-5 dit seulement que les statistiques lisent via `FlashcardRepository`.
- **Preuve :** `migration-contract.md` les rend explicitement caractérisables ; `StatsService` les calcule aujourd'hui à partir de la collection, tandis que le spine ne donne pas de contrat/use case de statistiques.
- **Risque de divergence :** `stats/` et un futur écran/rapport peuvent compter les deux sens d'une paire ou appliquer des règles de classement différentes tout en respectant AD-5.
- **Disposition :** **Autofix.** Ajouter une AD qui désigne un contrat/use case de statistiques comme propriétaire de ces projections, impose les invariants du contrat et autorise les vues à ne consommer que son résultat typé.

### HIGH — La suppression du legacy n'impose pas la matrice de preuve exigée par le SPEC

- **Constat :** AD-8 impose couverture, bascule des appelants et absence de référence exécutable, mais ne lie pas chaque suppression à la matrice durable `ancien composant → remplaçant → consommateurs migrés → tests` ni à un journal de migration.
- **Preuve :** le seuil de sortie 6 et les critères d'acceptation de `migration-contract.md` demandent cette matrice et ce journal ; CAP-6 est donc seulement partiellement gouvernée.
- **Risque de divergence :** chaque tranche peut conclure « tous les appelants ont basculé » avec une preuve différente ou non audit-able.
- **Disposition :** **Autofix.** Compléter AD-8 avec l'emplacement et le contenu minimal du registre par retrait, plus l'exigence d'une suppression dans un changement Git dédié et réversible.

### HIGH — AD-6 concentre quatre sources de session sans règle de réconciliation ni de cycle de vie

- **Constat :** `UserSessionRepository` est déclaré unique propriétaire de l'identité, profil cache, droits de traduction, abonnement et couple de langues, mais AD-6 ne fixe ni l'ordre de synchronisation/login/logout, ni la précédence Firestore/cache/RevenueCat, ni l'invalidation lors d'un changement d'utilisateur ou d'échec partiel.
- **Preuve :** le legacy `UserManager.login` enchaîne Auth → RevenueCat → Firestore → cache et maintient `userSyncStateProvider`/`userDataProvider`; il révèle précisément les décisions de cohérence que les modules enfants auraient autrement à réinventer.
- **Risque de divergence :** les parcours profil, traduction et premium peuvent publier des droits ou une paire de langues contradictoires après reconnexion, achat, déconnexion ou échec de synchronisation.
- **Disposition :** **Autofix.** Étendre AD-6 par une machine de transition minimale (démarrage, auth, sync, prêt, échec, logout), une priorité de sources par champ et la règle de purge/invalidation de cache et RevenueCat.

### HIGH — L'invariant CI ne garantit pas le déclenchement à chaque push

- **Constat :** AD-10 affirme que GitHub Actions exécute l'analyse et les tests, sans rendre obligatoire le déclenchement sur `push` et `pull_request`.
- **Preuve :** `AGENTS.md` et le SPEC l'exigent à chaque push et pull request ; `.github/workflows/quality.yml` ne déclare actuellement que `workflow_dispatch` et `pull_request`.
- **Risque de divergence :** une tranche peut déclarer la règle respectée tout en laissant des branches poussées sans garde-fou CI.
- **Disposition :** **Autofix.** Modifier AD-10 pour exiger `push` et `pull_request` pour `flutter analyze` et `flutter test`, puis aligner le workflow dans la tranche de socle/CI correspondante.

### MEDIUM — Le contrat d'état UI n'est pas assez précis pour les tests inter-features

- **Constat :** AD-3 demande un état « exhaustif (données, chargement, erreur, actions) », mais ne rend pas obligatoire une phase `initial/loading/data/error` ni une erreur applicative typée à la frontière, comme le requiert le contrat de migration.
- **Risque de divergence :** deux ViewModels peuvent publier des `AsyncValue`, sealed states ou drapeaux booléens incompatibles, et mapper/afficher les erreurs d'infrastructure différemment.
- **Disposition :** **Autofix.** Énoncer la forme minimale commune de phase et le type d'erreur applicative, en laissant la représentation Dart concrète libre.

## Éléments ratifiés

- Les frontières Vue → ViewModel → domaine/repository → adaptateur et les overrides Riverpod correspondent au SPEC et au besoin de découpler le legacy.
- AD-5 traite correctement l'atomicité des paires, les migrations Drift explicites et l'interdiction de laisser les DTO Drift franchir le repository.
- AD-7, AD-9 et AD-10 préservent les SDK, les sources générées, les plateformes mobiles et l'enveloppe offline sans transformer la migration en évolution produit.
- Les versions nommées correspondent aux contraintes déclarées dans `pubspec.yaml` et la version Flutter de `quality.yml` ; l'absence de validation web indépendante ne permet toutefois pas d'attester qu'elles sont les versions actuellement les plus récentes.

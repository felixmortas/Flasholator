# PRD Quality Review — PRD — Migration MVVM/Riverpod de Flasholator

## Overall verdict

Le PRD donne une direction de migration nette et un périmètre honnête : il préserve explicitement les parcours de production, les données locales, les services existants et les droits premium. Il est toutefois **conditionnellement prêt** à alimenter un découpage en stories : les critères de fin restent trop souvent formulés comme « comportement actuel » ou « fiable », sans oracle de caractérisation ni bornes mesurables. Les premières stories doivent donc transformer ces attentes en scénarios de référence exécutables avant toute bascule.

## Decision-readiness — adequate

Les décisions structurantes sont visibles : migration sans évolution fonctionnelle, absence de synchronisation cloud des cartes, ordre des tranches, source de vérité de session et entitlements RevenueCat (« Vision et périmètre », « Contraintes techniques de migration »). Les concessions sont en majorité explicites, notamment l’exclusion de groupes, import/export et Google Drive.

Le document ne contient ni questions ouvertes, ni tensions signalées. C’est recevable si les décisions sont bien closes, mais deux arbitrages opérationnels restent cachés dans des termes ambigus : quelle référence fige le comportement historique, et quelle configuration développeur porte les limites freemium.

### Findings

- **high** Référence de comportement non décidée (§ FR6, FR7, FR9, FR14, FR19, NFR3) — « actuel », « comme avant migration » et « comportement SM-2 actuel » ne désignent ni version, ni tests, ni jeux de données de référence. *Fix:* déclarer la baseline (commit/release) et les scénarios de caractérisation faisant foi, y compris les écarts connus acceptés.
- **medium** Mécanisme de configuration freemium indéterminé (§ FR14, FR23, « Règles freemium confirmées ») — les limites doivent être facilement modifiables/désactivables « par un développeur », sans indiquer la source de configuration, le moment de lecture ou les valeurs par défaut. *Fix:* choisir et documenter le mécanisme (constantes centralisées, Remote Config, build config, etc.), les valeurs de défaut et l’effet d’une désactivation.

## Substance over theater — adequate

La vision est spécifique au brownfield Flasholator : elle nomme MVVM/Riverpod, le parcours traduction → cartes → révision → premium et les plateformes cibles. Le seul parcours UJ, avec Ludovic, sert concrètement les capacités et non une persona décorative. Les NFR évitent pour l’essentiel les slogans génériques et ancrent les contraintes dans Drift, Firebase, RevenueCat, UMP/ATT et la localisation.

La faiblesse est que certaines qualités sont présentées comme exigences sans mesure ni observable. Elles risquent de devenir du langage de conformité plutôt que des critères de validation.

### Findings

- **medium** Qualités non observables (§ FR9, FR18, FR22, FR25, NFR7) — « compréhensibles », « cohérents », « fiable », « état incohérent » et « de façon perceptible » ne permettent pas un verdict de test partagé. *Fix:* remplacer chaque terme par des états UI attendus, invariants ou seuils mesurés.

## Strategic coherence — strong

La thèse est cohérente : préserver le produit livré tout en rendant son parcours central maintenable et testable par migration MVVM/Riverpod. Les groupes de capacités et l’ordre de migration servent cette thèse : d’abord caractériser, puis basculer les domaines à forte valeur et, enfin, supprimer le legacy. Les critères de succès mesurent correctement la réussite d’une migration plutôt que l’activité utilisateur ; l’absence de métriques d’adoption ou de revenus n’est pas un défaut pour ce chantier sans nouveauté produit.

## Done-ness clarity — thin

Le PRD fournit beaucoup de conditions utiles : atomicité et résultats de mutation (FR5), droits gratuits et premium chiffrés (FR23–FR24), classement limité à cinq (FR21), absence de publicité premium (FR24), et commandes CI (NFR2). Ces points sont directement traduisibles en critères d’acceptation.

Mais une part importante des FR impose la préservation d’un comportement non spécifié. Sans tables de cas, états UI, erreurs attendues ou jeux de données, deux équipes peuvent déclarer la même tranche terminée tout en ayant migré des comportements différents.

### Findings

- **high** Invariants de répétition espacée insuffisamment définis (§ FR7) — la qualité de réponse, les valeurs de départ, les règles SM-2, les arrondis et les cas limites ne sont pas spécifiés ; « actuel » ne suffit pas pour reproduire l’algorithme. *Fix:* référencer des tests de caractérisation et inclure une matrice entrée → prochaine échéance/état pour les cas représentatifs et limites.
- **high** Contrat d’erreur et d’asynchronisme incomplet (§ FR9, FR13, FR18, FR19, FR22, FR25) — les situations sont nommées, mais ni les états UI, ni les actions de reprise, ni les règles de priorité des réponses tardives ne le sont. *Fix:* ajouter des scénarios Given/When/Then pour erreur réseau, annulation/session changée, réponse DeepL tardive, achat/restauration échoué et entitlement mis à jour.
- **medium** Performance non vérifiable (§ NFR7) — aucune version de référence, appareil/cible, métrique ni tolérance n’est fournie. *Fix:* soit définir des mesures et une tolérance, soit convertir NFR7 en comparaison de benchmarks de référence exécutée avant/après migration.

## Scope honesty — adequate

Le périmètre et les exclusions sont explicites et utiles, y compris l’absence de nouveau métier, de redesign, de synchronisation cloud des cartes et de changement de pipeline. La stratégie interdit également une suppression prématurée du legacy. Il n’y a pas d’inférence marquée `[ASSUMPTION]` ni de décision présentée comme encore ouverte.

L’honnêteté de périmètre serait plus robuste si le PRD distinguait explicitement les comportements existants qui doivent seulement être conservés de ceux qui doivent être refactorés dans la tranche concernée ; aujourd’hui la couverture exacte des intégrations dans chaque tranche reste implicite.

### Findings

- **medium** Frontières de tranche non traçables (§ « Stratégie de migration », FR27–FR30) — l’ordre est clair, mais aucun tableau n’associe chaque service legacy/consommateur à une tranche et à son test de conservation. *Fix:* intégrer ou référencer le registre exigé par FR28 dès la planification, avec propriétaire, tranche, remplaçant et preuve de bascule.

## Downstream usability — thin

Les IDs FR1–FR30 et NFR1–NFR8 sont uniques et continus, le parcours UJ-1 possède un protagoniste nommé, et la plupart des termes techniques sont constants. Cela donne une bonne ossature pour les epics et stories.

En revanche, il n’y a pas de glossaire ni de définition des unités métier déterminantes. « mot », « paire », « flashcard », « carte », « couple de langues », « mots stockables » et « cartes à réviser » sont employés sans relation explicite. Cela rend périlleux le découpage de FR5, FR7, FR12, FR20–FR24 et les métriques de limite.

### Findings

- **high** Glossaire et unités de comptage absents (§ document entier ; notamment FR5, FR7, FR12, FR20–FR24) — un downstream ne peut pas déterminer de façon sûre si une limite de 20 « mots » compte faces, paires, cartes dues, ou toutes les cartes, ni le sens exact de « couple de langues ». *Fix:* ajouter un glossaire normatif avec les relations carte/flashcard/paire, l’orientation ou non des langues et les unités de chacune des limites.
- **medium** Traçabilité des exigences vers le parcours incomplète (§ UJ-1, FR1–FR30) — le parcours raconte les capacités, sans référencer les FR/NFR qui le réalisent ; inversement, certains FR de fondation et legacy n’ont pas de scénario de validation apparent. *Fix:* ajouter une courte matrice UJ/FR/NFR ou des références croisées dans les critères d’acceptation des stories.

## Shape fit — adequate

La forme convient à un brownfield mobile grand public destiné à la production : un UJ central, un périmètre de migration, des FR organisés par domaines et des contraintes d’intégration. Le niveau de formalisation est proportionné au fait que le produit existe déjà, et le parcours de Ludovic rend visibles les transitions importantes (première connexion, persistance, paywall).

Le document serait pleinement adapté au rôle de contrat de migration s’il liait plus fermement le code existant et les tests de caractérisation aux exigences ; les références de code n’apparaissent qu’indirectement via les technologies.

### Findings

- **medium** Ancrage brownfield insuffisant (§ « Contraintes techniques de migration », « Stratégie de migration ») — les composants et comportements existants à conserver ne sont pas référencés par modules, services ou suites de tests actuels. *Fix:* ajouter une annexe de cartographie existant → cible par feature, avec les risques de compatibilité associés.

## Mechanical notes

- Aucun `addendum.md` n’est présent dans le dossier du PRD.
- IDs : FR1–FR30 et NFR1–NFR8 sont continus et sans doublon ; UJ-1 est unique et Ludovic est un protagoniste nommé.
- Les références internes vers les sections sont absentes, donc aucune n’est cassée ; une matrice de traçabilité améliorerait néanmoins l’extraction downstream.
- Aucun marqueur inline `[ASSUMPTION]` ni `[NOTE FOR PM]` n’est présent : aucun index d’hypothèses n’est requis, mais les deux décisions signalées ci-dessus méritent une explicitation.
- Glossaire absent. Risque de dérive terminologique entre « cartes », « flashcards », « paires », « mots », « révision » et « couple de langues ».
- Sections attendues pour un PRD de migration de production présentes : vision/périmètre, succès, exigences, contraintes, stratégie et parcours utilisateur. Une section dédiée aux critères d’acceptation/baselines de caractérisation fait défaut.

# Revue de prose — PRD Flasholator

## Lecture éditoriale

Ce document existe pour aider le product owner et l’équipe d’ingénierie à cadrer, planifier et vérifier une migration de production vers MVVM/Riverpod sans altérer le parcours utilisateur existant.

**Public visé :** lecteurs humains — product owner, responsables techniques et développeurs.  
**Guide de style :** Microsoft Writing Style Guide.  
**Modèle structurel pris en compte :** Strategic/Context Pyramid, retenu par la revue structurelle.

La prose est concise, normative et adaptée à un PRD technique. Préserver le vocabulaire établi du produit et de la plateforme (`Riverpod`, `ViewModels`, `DeepL`, `RevenueCat`, `Flutter`, `Drift`, `SM-2`) ainsi que le ton direct des exigences. Les recommandations ci-dessous appliquent les modifications les plus petites possibles. Elles excluent le préambule marqué **CUT** par la revue structurelle. La règle freemium marquée **MERGE** est traitée à son emplacement de destination, FR23.

## Constats

| Pass | Original Text | Revised Text | Changes |
| --- | --- | --- | --- |
| prose | **FR2** — « Chaque écran migré doit séparer rendu et interactions, état UI immuable et orchestration métier ; ses dépendances doivent pouvoir être remplacées en test. » | « Chaque écran migré doit séparer le rendu et les interactions de l’état UI immuable et de l’orchestration métier ; ses dépendances doivent pouvoir être remplacées en test. » | Rétablit les liens grammaticaux entre les trois éléments séparés. |
| prose | **FR5** — « … retourne un résultat permettant de distinguer une application, une absence ou un conflit. » | « … retourne un résultat permettant de distinguer l’application de la mutation, l’absence de la paire ou un conflit. » | Précise les trois résultats sans modifier le contrat de mutation. |
| prose | **FR10** — « … lancer une traduction DeepL seulement lorsque la saisie est valide. » | « … lancer une traduction via DeepL seulement lorsque la saisie est valide. » | Clarifie que DeepL est le service utilisé, plutôt qu’un type de traduction. |
| prose | **FR14** — « Sa valeur et son activation peuvent être modifiées ou désactivées facilement par un développeur… » | « Sa valeur peut être modifiée et la limite peut être désactivée facilement par un développeur… » | Évite de dire qu’une « activation » peut être désactivée et rend les deux opérations distinctes. |
| prose | **FR17** — « … annule les opérations en cours de la session précédente, purge son cache local et ne peut pas exposer ses données ou droits. » | « … annule les opérations en cours de la session précédente, purge le cache local de cette session et ne peut pas exposer ses données ou ses droits. » | Lève l’ambiguïté du possessif « son » et maintient le parallélisme. |
| prose | **FR21** — « Les statistiques préservent les règles actuelles : paires dédoublonnées, couples de langues non orientés, séries et moyennes calculées par paire… » | « Les statistiques préservent les règles actuelles : dédoublonnement des paires, traitement non orienté des couples de langues, calcul des séries et des moyennes par paire… » | Rend la liste parallèle et plus facile à lire. |
| prose | **FR26** — « … sans diffusion d’annonce avant l’autorisation requise. » | « … sans afficher d’annonce avant l’autorisation requise. » | Emploie un verbe concret et plus naturel pour une exigence de comportement applicatif. |
| prose | **Contraintes techniques de migration** — « Flutter, Firebase via `DefaultFirebaseOptions` et Ads sont initialisés une seule fois avant le `ProviderScope`. RevenueCat est configuré une seule fois après restauration Firebase, puis identifié ou déconnecté à chaque transition de session. » | « Flutter, Firebase à l’aide de `DefaultFirebaseOptions` et Ads sont initialisés une seule fois avant le `ProviderScope`. RevenueCat est configuré une seule fois après la restauration de Firebase. Il est ensuite identifié ou déconnecté à chaque transition de session. » | Désambiguïse la relation entre Firebase et sa configuration, puis scinde une phrase dense. |
| prose | **Stratégie de migration** — « … migrer une feature complète… » | « … migrer une fonctionnalité complète… » | Remplace l’anglicisme par le terme déjà employé ailleurs dans le PRD. |

## Résultat

**9 recommandations de prose**. Elles préservent le contenu, les exigences et la structure du PRD. La recommandation liée aux règles freemium ne crée pas de ligne distincte : la revue structurelle prévoit de déplacer cette information vers **FR23**, qui est déjà formulée clairement.

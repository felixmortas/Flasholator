# Revue structurelle — PRD Flasholator

## Lecture éditoriale

Ce document existe pour aider le product owner et l’équipe d’ingénierie à cadrer, planifier et vérifier une migration de production vers MVVM/Riverpod sans altérer le parcours utilisateur existant.

**Public visé :** lecteurs humains — product owner, responsables techniques et développeurs qui doivent lire le document de façon séquentielle puis s’y référer pendant la migration.  
**Guide de style :** Microsoft Writing Style Guide.  
**Modèle retenu :** **Strategic/Context Pyramid**. Le PRD ouvre bien sur la vision et le périmètre, puis descend vers les critères, les capacités, les exigences et le plan d’exécution.  
**Mesure de référence :** 1 707 mots au total, obtenus avec `word_metrics.py`. Les sections les plus longues sont « Parcours utilisateur de référence » (219 mots), « Profil, statistiques et premium » (191 mots) et « Exigences non fonctionnelles » (184 mots).

## Constats

| Pass | Original Text | Revised Text | Changes |
| --- | --- | --- | --- |
| structure | Preambule — « Document en cours d'élaboration, section par section. » | **CUT** — supprimer cette ligne ; le front matter `status: draft` porte déjà ce statut. | Redondance de statut et interruption avant la vision ; économise 8 mots. |
| structure | §Contraintes techniques de migration (88 mots), après les exigences non fonctionnelles | **MOVE** — placer cette section après §Vision et périmètre, avant §Critères de succès. | Ces décisions de source de vérité, d’initialisation et de transaction donnent le contexte nécessaire pour lire les exigences ; impact : 0 mot. |
| structure | §Parcours utilisateur de référence — brouillon à valider | **CONDENSE** — renommer « Parcours utilisateur de référence ». | Le qualificatif « brouillon à valider » répète le statut global et affaiblit le parcours comme référence de lecture ; économise 4 mots. |
| structure | §Règles freemium confirmées (35 mots), à la fin de UJ-1 | **MERGE** — remplacer par « **Règles freemium : voir FR23.** » | FR23 contient déjà les trois plafonds et leur configurabilité. Le renvoi conserve l’orientation du lecteur sans répéter la règle ; économise 30 mots. |
| structure | §Groupes de capacités (70 mots), suivi des groupes identiques dans les exigences | **PRESERVE** — conserver ce résumé avant les exigences. | Pour des lecteurs humains, il fournit une carte de lecture et une progression mentale avant les détails ; impact : 0 mot. |

## Résumé de réduction

**5 recommandations** au total, dont une recommandation explicite de préservation. Si les coupes et condensations sont acceptées, le document passe de **1 707 à environ 1 665 mots** : **42 mots** en moins (**2,5 %**). Aucun objectif de longueur n’a été fourni, donc aucune cible chiffrée n’est à évaluer. La seule réduction qui enlève du texte utile est la règle freemium récapitulée dans UJ-1 ; le renvoi vers FR23 conserve toutefois l’accès immédiat à l’exigence normative. Le déplacement des contraintes améliore l’enchaînement sans sacrifier de contenu.

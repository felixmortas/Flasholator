# Revue adversariale — PRD Flasholator

```json
[
  {
    "lens": "adversarial",
    "location": "Critères de succès ; FR1",
    "trigger_condition": "« Sans régression visible » et les tests de caractérisation ne définissent ni la version de référence, ni la matrice des comportements à comparer, ni les assertions attendues.",
    "guard_snippet": "Créer avant chaque tranche une baseline versionnée : parcours, données de départ, résultats attendus, captures/états et tests de non-régression associés.",
    "potential_consequence": "Deux implémentations peuvent toutes deux prétendre préserver le comportement alors que l’une modifie silencieusement un flux de production."
  },
  {
    "lens": "adversarial",
    "location": "FR5 ; contraintes techniques",
    "trigger_condition": "Le PRD appelle une « paire de cartes » et exige une mutation atomique sans définir son modèle persistant ni l’invariant qui relie les deux directions de la paire.",
    "guard_snippet": "Définir l’identité d’une paire, ses deux cartes directionnelles, les clés/identifiants concernés et les opérations atomiques de création, édition et suppression.",
    "potential_consequence": "Une migration peut conserver une seule direction, créer des doublons ou modifier une face sans synchroniser l’autre."
  },
  {
    "lens": "adversarial",
    "location": "FR5 ; NFR5",
    "trigger_condition": "Les résultats `applied`/`notFound`/`conflict` sont exigés sans préciser la version de concurrence, le déclencheur d’un conflit ni le comportement utilisateur pour chacun.",
    "guard_snippet": "Spécifier le jeton de version ou la précondition de mutation, les cas qui produisent chaque résultat et les états UI/réessais autorisés.",
    "potential_consequence": "Les adaptateurs peuvent signaler des conflits incompatibles ou écraser une modification récente sans que la vue sache quoi faire."
  },
  {
    "lens": "adversarial",
    "location": "FR7",
    "trigger_condition": "« Le comportement SM-2 actuel » ne fournit aucun jeu de vecteurs de référence pour les qualités, l’état initial, les échecs, les dates échues et les limites de l’algorithme.",
    "guard_snippet": "Ajouter des vecteurs versionnés entrée → état SRS → prochaine date, avec une horloge injectée et le fuseau/calendrier de référence.",
    "potential_consequence": "La formule peut sembler SM-2 tout en changeant les intervalles et les échéances des cartes existantes."
  },
  {
    "lens": "adversarial",
    "location": "FR8 ; FR20–FR21",
    "trigger_condition": "La « même collection cohérente » ne définit pas l’instant de cohérence, les projections invalidées ni la réaction des statistiques et listes à une mutation qui échoue ou arrive hors ordre.",
    "guard_snippet": "Définir le contrat de projection : source, ordre de publication, état de rafraîchissement et résultat attendu après succès, conflit et échec de chaque mutation.",
    "potential_consequence": "Les tableaux, le compteur de révision et le profil peuvent afficher durablement des valeurs contradictoires."
  },
  {
    "lens": "adversarial",
    "location": "FR10",
    "trigger_condition": "La validité d’une saisie DeepL n’est pas définie : vide/blancs, longueur maximale, langues source/cible, texte identique, caractères non pris en charge et nettoyage du collage restent ambigus.",
    "guard_snippet": "Énoncer un prédicat de validation et ses messages/localisations pour chaque cas, puis le couvrir par tests de ViewModel.",
    "potential_consequence": "Le bouton peut être activé différemment après migration et des requêtes invalides ou facturables peuvent atteindre DeepL."
  },
  {
    "lens": "adversarial",
    "location": "FR11–FR13",
    "trigger_condition": "Le contrat ne traite ni le double-clic/réessai d’enregistrement ni la règle de dédoublonnage quand une traduction identique ou inversée existe déjà.",
    "guard_snippet": "Définir l’identité de doublon par paire et langues, l’idempotence de sauvegarde, ainsi que le retour UI pour une paire déjà présente.",
    "potential_consequence": "Une latence réseau ou un double appui crée des cartes en double et fausse limites, révision et statistiques."
  },
  {
    "lens": "adversarial",
    "location": "FR14 ; FR23 ; règles freemium confirmées",
    "trigger_condition": "La limite de 200 traductions ne précise pas ce qui consomme une unité (clic, requête réussie, résultat affiché ou carte sauvegardée), ni si/quand le compteur se réinitialise et se synchronise entre appareils.",
    "guard_snippet": "Documenter l’événement de comptage, la période et persistance du quota, les règles de réinitialisation et la gestion d’un échec/cancellement ou d’un appareil hors-ligne.",
    "potential_consequence": "Des utilisateurs gratuits peuvent être bloqués trop tôt, contourner le quota ou perdre un quota après changement de session."
  },
  {
    "lens": "adversarial",
    "location": "FR23",
    "trigger_condition": "« 20 mots stockables » est ambigu par rapport aux paires et aux deux cartes directionnelles, et aucune règle atomique ne lie le contrôle de capacité à l’insertion concurrente.",
    "guard_snippet": "Définir l’unité comptée, les données existantes au-dessus du plafond, le seuil d’autorisation et une insertion transactionnelle qui vérifie puis réserve la capacité.",
    "potential_consequence": "La limite peut être divisée par deux, dépassée par des actions simultanées ou bloquer des utilisateurs déjà au-dessus du nouveau plafond."
  },
  {
    "lens": "adversarial",
    "location": "FR16 ; FR21 ; FR23–FR24",
    "trigger_condition": "Le PRD ne tranche pas si un couple de langues est directionnel alors que les statistiques le déclarent non orienté et que la limite gratuite/premium dépend des couples.",
    "guard_snippet": "Définir explicitement la normalisation de `source → cible`, la règle pour `EN→FR` versus `FR→EN`, et l’effet sur sélection, quota, tables, révision globale et statistiques.",
    "potential_consequence": "Un utilisateur peut contourner la limite d’un couple ou voir des cartes et compteurs différents selon l’écran."
  },
  {
    "lens": "adversarial",
    "location": "FR17 ; NFR3–NFR4",
    "trigger_condition": "La purge du cache à la déconnexion ne distingue pas les données de profil des cartes hors-ligne, ni leur partitionnement par utilisateur ou le sort des données d’un compte supprimé.",
    "guard_snippet": "Définir le stockage propriétaire de chaque donnée, les données purgées/conservées par événement de session et le protocole de fermeture/effacement avant ouverture d’une autre session.",
    "potential_consequence": "Une déconnexion peut effacer des cartes légitimes ou, inversement, exposer les cartes et statistiques d’un compte au suivant."
  },
  {
    "lens": "adversarial",
    "location": "FR17–FR18",
    "trigger_condition": "L’annulation des opérations de l’ancienne session ne définit pas de garde contre un retour non annulable (Firebase, RevenueCat, Drift) après une nouvelle connexion.",
    "guard_snippet": "Associer chaque opération asynchrone à un identifiant/génération de session et ignorer tout résultat dont la génération ne correspond plus avant toute écriture ou émission d’état.",
    "potential_consequence": "Un retour tardif peut restaurer le profil, les droits premium ou l’état de chargement de l’ancien utilisateur."
  },
  {
    "lens": "adversarial",
    "location": "FR22 ; FR25 ; contraintes techniques",
    "trigger_condition": "Firestore est présenté comme portant les droits tandis que RevenueCat est présenté comme source des entitlements, sans règle de priorité, fraîcheur, cache, restauration, expiration ou indisponibilité réseau.",
    "guard_snippet": "Définir une source de décision unique par droit, la durée/invalidité du cache, les transitions d’achat/restauration/expiration et le comportement hors-ligne sûr.",
    "potential_consequence": "Un même utilisateur peut être premium dans un écran et gratuit dans un autre, ou conserver indûment un accès après expiration."
  },
  {
    "lens": "adversarial",
    "location": "FR24",
    "trigger_condition": "La vérification automatique d’une réponse écrite ne définit ni normalisation (casse, accents, espaces, ponctuation), ni réponses alternatives, ni correspondance avec les langues prises en charge, ni conversion vers une qualité SM-2.",
    "guard_snippet": "Spécifier la règle de comparaison par langue, les variantes acceptées, le retour éditable à l’utilisateur et la règle qui transforme le verdict en score de révision.",
    "potential_consequence": "Des réponses correctes seront rejetées, ou la notation SRS variera arbitrairement entre plateformes."
  },
  {
    "lens": "adversarial",
    "location": "FR24 ; FR26",
    "trigger_condition": "L’absence de publicité premium n’indique pas quand une bannière/interstitiel déjà chargé ou planifié doit disparaître après un achat/restauration, ni le comportement lors d’un échec de rafraîchissement des droits.",
    "guard_snippet": "Définir les points de réévaluation des droits et l’invalidation immédiate des placements et files d’annonces lors de chaque transition premium.",
    "potential_consequence": "Un utilisateur qui vient de payer peut encore voir ou déclencher des annonces, ce qui contredit la promesse premium."
  },
  {
    "lens": "adversarial",
    "location": "FR26",
    "trigger_condition": "Le traitement du consentement UMP/RGPD et d’ATT ne couvre pas les décisions refusées, indéterminées, révoquées, les erreurs UMP ni le type d’annonce autorisé dans chaque état.",
    "guard_snippet": "Ajouter une table d’états consentement/ATT → publicité autorisée ou bloquée, avec persistance, nouvel affichage du consentement et tests des transitions.",
    "potential_consequence": "La migration peut diffuser une publicité non conforme ou bloquer indûment toute monétisation après un retour d’application."
  },
  {
    "lens": "adversarial",
    "location": "Périmètre ; FR15–FR19",
    "trigger_condition": "Le périmètre annonce la préservation de l’authentification et du profil mais omet les parcours existants de réinitialisation/changement de mot de passe et de suppression de compte.",
    "guard_snippet": "Ajouter ces parcours au périmètre avec leurs états d’erreur, réauthentification, suppression des données locales/distantes et tests de caractérisation, ou les exclure explicitement avec justification.",
    "potential_consequence": "Des capacités déjà exposées en production peuvent rester sur un chemin legacy non couvert ou se casser lors du retrait de dépendances."
  },
  {
    "lens": "adversarial",
    "location": "NFR7",
    "trigger_condition": "« Sans dégrader de façon perceptible » n’offre aucun seuil, appareil de référence, scénario, méthode de mesure ni tolérance de variance.",
    "guard_snippet": "Définir des budgets mesurables pour démarrage, premier affichage et actions critiques, avec protocole de comparaison reproductible sur iOS et Android.",
    "potential_consequence": "Une régression sensible pour les utilisateurs réels peut être déclarée conforme faute de critère d’acceptation testable."
  }
]
```

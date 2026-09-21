# Réconciliation README ↔ PRD

## Verdict

Le PRD couvre le parcours principal et les contraintes de migration, mais quatre écarts matériels du README doivent être arbitrés ou ajoutés avant le découpage en stories.

1. **Synchronisation cloud : contradiction de périmètre.** Le README présente Firestore comme mécanisme de synchronisation des données utilisateur, alors que le PRD exclut explicitement la synchronisation cloud des cartes. Il faut confirmer si cette synchronisation existe en production et doit être préservée ; sinon, consigner que la description README est obsolète. Cette décision conditionne notamment l'isolation de session, la persistance et les tests de non-régression.

2. **Capacités premium documentées mais absentes du PRD.** Le README liste la création de groupes de mots pour la révision, l'import/export des données et la synchronisation Google Drive. Le PRD ne les inclut pas parmi les droits premium ni ne les exclut explicitement. Pour chacune, préciser si elle est actuellement livrée (donc à migrer) ou seulement prévue (donc hors périmètre).

3. **Publicité, consentement et confidentialité.** Le PRD garantit seulement l'absence de publicité pour le premium et le maintien technique d'AdMob/UMP/ATT. Le README décrit aussi les bannières/interstitiels et la conformité RGPD. Ajouter une exigence de préservation du comportement des annonces pour le gratuit, du recueil/stockage du consentement UMP et du flux ATT iOS, sans affichage publicitaire avant l'autorisation requise.

4. **Chaîne de livraison mobile.** Le README annonce GitHub Actions pour Google Play et Codemagic pour App Store Connect. NFR2 ne couvre que l'analyse et les tests. Ajouter la préservation des builds/distributions Android et iOS (configuration, secrets et artefacts), ou les déclarer explicitement hors périmètre de cette migration.

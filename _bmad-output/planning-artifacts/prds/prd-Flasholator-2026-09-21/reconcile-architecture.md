# Réconciliation PRD ↔ architecture

Architecture comparée : `ARCHITECTURE-SPINE.md` (2026-09-21). Le PRD est globalement cohérent, mais les écarts matériels suivants doivent être tranchés ou ajoutés avant le découpage en stories.

1. **Atomicité et conflits des paires.** FR5 et NFR5 demandent l’intégrité, sans définir le contrat observable : `addPair`, `editPair` et `deletePair` doivent être transactionnels Drift, cibler exactement une paire via la clé canonique existante et retourner `applied`, `notFound` ou `conflict`. Sans cela, les stories ne pourront pas caractériser les collisions ni l’édition/suppression concurrente.
2. **Isolation de session opérationnelle.** FR17–18 énoncent le résultat attendu mais pas les garanties de bascule : Firebase Auth est maître ; logout/changement de compte invalide les opérations asynchrones du `uid` précédent, purge le cache local, réconcilie RevenueCat, puis seulement expose l’état anonyme. Cette séquence prévient une fuite de profil ou d’entitlement entre comptes.
3. **Contrat statistique précis.** FR21 mentionne des règles actuelles sans les rendre vérifiables : les couples de langues sont non orientés, les paires sont dédoublonnées, les séries/moyennes sont calculées par paire, et les classements sont décroissants avec un maximum de cinq entrées. Ces règles doivent figurer dans les exigences ou les tests de caractérisation de référence.
4. **Bootstrap de production et cycle RevenueCat.** FR3/FR22 ne spécifient pas l’ordre ni le responsable : le bootstrap initialise Flutter, Firebase (`DefaultFirebaseOptions`) et Ads avant `ProviderScope`; l’adaptateur de session configure RevenueCat une seule fois après restauration Firebase, puis applique identification/déconnexion sur les transitions. Cela protège des initialisations répétées et d’un entitlement rattaché au mauvais utilisateur.

## Verdict

Réconciliation **conditionnellement favorable** : aucune contradiction majeure, mais ces quatre contrats d’architecture doivent être intégrés ou explicitement acceptés comme critères techniques de stories avant l’implémentation.

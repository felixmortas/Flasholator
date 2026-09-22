- source_spec: `_bmad-output/implementation-artifacts/spec-1-4-retirer-le-legacy-seulement-apres-bascule-prouvee.md`
  summary: Réparer les doublures Firestore incomplètes qui font échouer sept scénarios de `test/firestore_users_dao_test.dart`.
  evidence: L’exécution manuelle de `flutter test` du 2026-09-22 échoue avec des retours `Null is not a subtype of Future` dans les mocks de `DocumentReference.get` et `update`, sans changement de code dans cette story documentaire.
- source_spec: `_bmad-output/implementation-artifacts/spec-2-2-conserver-les-cartes-hors-ligne-et-leurs-projections.md`
  summary: Composer les lecteurs legacy et le repository autour d'une même instance de base et d'une invalidation des écritures legacy.
  evidence: La coexistence impose encore deux chemins de mutation ; cette story ne migre aucun consommateur legacy et ne peut donc pas observer ses écritures sans élargir son périmètre.
- source_spec: `_bmad-output/implementation-artifacts/spec-2-2-conserver-les-cartes-hors-ligne-et-leurs-projections.md`
  summary: Déclencher une actualisation de la projection de révision lorsque l'échéance d'une carte est atteinte sans mutation de collection.
  evidence: La projection pure respecte le snapshot reçu ; l'orchestration temporelle relève de la migration du parcours de révision de la story 2.3.
- source_spec: `_bmad-output/implementation-artifacts/spec-2-3-reviser-avec-le-comportement-sm-2-caracterise.md`
  summary: Réparer les doublures Firestore incomplètes qui font échouer sept scénarios de `test/firestore_users_dao_test.dart`.
  evidence: La suite complète échoue sur les mocks `DocumentReference.get` et `update`, sans lien avec les fichiers de révision modifiés par cette story.
- source_spec: `_bmad-output/implementation-artifacts/spec-4-1-authentifier-et-restaurer-une-session-utilisateur.md`
  summary: Sérialiser les transitions entre comptes et invalider chaque écriture tardive dans le cache, le profil et les droits.
  evidence: Le cache et le notifier historiques sont globaux ; une réponse de l'ancien compte peut encore écrire après une déconnexion ou un changement d'uid. L'isolation complète est le critère explicite de la story 4.2.

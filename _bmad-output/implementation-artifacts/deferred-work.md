- source_spec: `_bmad-output/implementation-artifacts/spec-1-4-retirer-le-legacy-seulement-apres-bascule-prouvee.md`
  summary: Réparer les doublures Firestore incomplètes qui font échouer sept scénarios de `test/firestore_users_dao_test.dart`.
  evidence: L’exécution manuelle de `flutter test` du 2026-09-22 échoue avec des retours `Null is not a subtype of Future` dans les mocks de `DocumentReference.get` et `update`, sans changement de code dans cette story documentaire.

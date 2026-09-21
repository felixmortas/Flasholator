/// Contrat minimal servant de référence pour une dépendance de feature.
abstract interface class MvvmExampleRepository {
  Future<String> loadMessage();
}

/// Implémentation locale volontairement sans SDK ni effet externe.
final class LocalMvvmExampleRepository implements MvvmExampleRepository {
  @override
  Future<String> loadMessage() => Future.value('Exemple chargé');
}

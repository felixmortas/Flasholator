/// Catégorie stable que la présentation peut associer à un texte localisé.
enum ApplicationErrorCategory {
  unexpected,
}

/// Erreur attendue par la présentation, indépendante des détails techniques.
abstract interface class ApplicationError implements Exception {
  ApplicationErrorCategory get category;

  /// Identifiant stable utilisable pour choisir un message localisé.
  String get code;
}

/// Erreur utilisée lorsqu'une dépendance remonte une erreur non typée.
final class UnexpectedApplicationError implements ApplicationError {
  const UnexpectedApplicationError(this.cause);

  final Object cause;

  @override
  ApplicationErrorCategory get category => ApplicationErrorCategory.unexpected;

  @override
  String get code => 'unexpected';
}

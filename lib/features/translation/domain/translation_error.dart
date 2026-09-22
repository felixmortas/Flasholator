import 'package:flasholator/core/presentation/application_error.dart';

enum TranslationErrorKind { deepl, unexpected }

/// Erreur applicative stable que la vue peut rendre sans connaître DeepL.
final class TranslationError implements ApplicationError {
  const TranslationError(this.kind, [this.cause]);

  final TranslationErrorKind kind;
  final Object? cause;

  @override
  ApplicationErrorCategory get category => ApplicationErrorCategory.unexpected;

  @override
  String get code => kind == TranslationErrorKind.deepl ? 'deepl' : 'unexpected';
}

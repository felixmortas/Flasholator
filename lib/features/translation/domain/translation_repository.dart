import 'package:flasholator/features/translation/domain/translation_request.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';

/// Contrat pur consommé par la feature; DeepL et HTTP restent derrière lui.
abstract interface class TranslationRepository {
  Future<TranslationResult> translate(TranslationRequest request);
}

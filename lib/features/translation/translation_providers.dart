import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/auth_service_provider.dart';
import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/application/translation_ui_state.dart';
import 'package:flasholator/features/translation/application/translation_view_model.dart';
import 'package:flasholator/features/translation/data/deepl_translation_repository.dart';
import 'package:flasholator/features/translation/data/legacy_deepl_translation_client.dart';
import 'package:flasholator/features/translation/domain/translation_repository.dart';

final deeplTranslationClientProvider = Provider<DeeplTranslationClient>((ref) {
  return LegacyDeeplTranslationClient(DeeplTranslator());
});

final translationRepositoryProvider = Provider<TranslationRepository>((ref) {
  return DeeplTranslationRepository(ref.watch(deeplTranslationClientProvider));
});

/// Pont temporaire vers la session legacy. Les tests le surchargent directement.
TranslationSessionContext translationSessionContextFromLegacyUser(
  Map<String, dynamic> user, {
  required String authUserId,
}) {
  return TranslationSessionContext(
    sessionId:
        (user['sessionId'] as String?) ?? (user['uid'] as String?) ?? authUserId,
    generation: user['sessionGeneration'] as int? ?? 0,
  );
}

final translationSessionContextProvider = Provider<TranslationSessionContext>((ref) {
  return translationSessionContextFromLegacyUser(
    ref.watch(userDataProvider),
    authUserId: ref.watch(authServiceProvider).getUserId(),
  );
});

final translationViewModelProvider =
    StateNotifierProvider<TranslationViewModel, TranslationUiState>((ref) {
  final viewModel = TranslationViewModel(
    ref.watch(translationRepositoryProvider),
    () => ref.read(translationSessionContextProvider),
  );
  ref.listen<TranslationSessionContext>(translationSessionContextProvider,
      (_, next) => viewModel.sessionChanged(next));
  return viewModel;
});

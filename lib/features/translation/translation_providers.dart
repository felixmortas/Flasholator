import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/application/translation_ui_state.dart';
import 'package:flasholator/features/translation/application/translation_view_model.dart';
import 'package:flasholator/features/translation/application/translation_save_state.dart';
import 'package:flasholator/features/translation/application/translation_save_view_model.dart';
import 'package:flasholator/features/flashcards/flashcard_providers.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/features/translation/data/deepl_translation_repository.dart';
import 'package:flasholator/features/translation/data/legacy_deepl_translation_client.dart';
import 'package:flasholator/features/translation/domain/translation_repository.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';

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
  final session = ref.watch(authSessionRepositoryProvider);
  return TranslationSessionContext(
    sessionId: session.status == AuthSessionStatus.ready
        ? session.account!.uid : '',
    generation: session.generation,
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

final translationSaveViewModelProvider = StateNotifierProvider<
    TranslationSaveViewModel, TranslationSaveState>((ref) {
  final viewModel = TranslationSaveViewModel(
    ref.watch(flashcardRepositoryProvider),
    () => ref.read(translationSessionContextProvider),
  );
  ref.onDispose(viewModel.invalidate);
  return viewModel;
});

/// Adaptateur des droits legacy, injectable sans le faire fuir dans une vue.
abstract interface class FlashcardAccess {
  Future<bool> canAddCard();
}

final class LegacyFlashcardAccess implements FlashcardAccess {
  LegacyFlashcardAccess(this._service);
  final FlashcardsService _service;
  @override
  Future<bool> canAddCard() => _service.canAddCard();
}

final flashcardAccessProvider = Provider<FlashcardAccess>((ref) =>
    LegacyFlashcardAccess(FlashcardsService(
      userId: ref.watch(authSessionRepositoryProvider).account?.uid,
      limits: ref.watch(freePlanLimitsProvider),
    )));

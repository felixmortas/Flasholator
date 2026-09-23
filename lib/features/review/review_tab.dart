import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flasholator/config/constants.dart';
import 'package:flasholator/core/providers/ad_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/features/review/application/review_state.dart';
import 'package:flasholator/features/review/review_empty_page.dart';
import 'package:flasholator/features/review/review_providers.dart';
import 'package:flasholator/features/review/widgets/editable_answer_section.dart';
import 'package:flasholator/features/review/widgets/response_buttons.dart';
import 'package:flasholator/features/review/widgets/words_display.dart';
import 'package:flasholator/features/shared/utils/language_selection.dart';
import 'package:flasholator/style/grid_background_painter.dart';

/// La vue ne conserve que le contrôleur Flutter ; l'état de révision vit dans
/// [ReviewViewModel].
class ReviewTab extends ConsumerStatefulWidget {
  const ReviewTab({super.key, required this.isAllLanguagesToggledNotifier});

  final ValueNotifier<bool> isAllLanguagesToggledNotifier;

  @override
  ConsumerState<ReviewTab> createState() => ReviewTabState();
}

class ReviewTabState extends ConsumerState<ReviewTab> {
  final _editingController = TextEditingController();
  final _languages = LanguageSelection.getInstance();
  StreamSubscription<ReviewEffect>? _effects;

  @override
  void initState() {
    super.initState();
    _effects =
        ref.read(reviewViewModelProvider.notifier).effects.listen((effect) {
      if (effect is ReviewScoreAcceptedEffect &&
          !ref.read(isSubscribedProvider) &&
          Random().nextInt(INTERSTITIAL_FREQUENCY) == 0) {
        final authorization = ref.read(adAuthorizationProvider);
        final ads = ref.read(adServiceProvider);
        unawaited(ads.showInterstitial(() async =>
            mounted &&
            !ref.read(isSubscribedProvider) &&
            await authorization.canShowAds()));
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _reload(widget.isAllLanguagesToggledNotifier.value);
    });
  }

  @override
  void dispose() {
    _effects?.cancel();
    _editingController.dispose();
    super.dispose();
  }

  void _reload(bool allLanguages) {
    allLanguages = allLanguages && ref.read(isSubscribedProvider);
    widget.isAllLanguagesToggledNotifier.value = allLanguages;
    ref.read(reviewViewModelProvider.notifier).load(
          allLanguages: allLanguages,
          sourceLanguage: _languages.sourceLanguage,
          targetLanguage: _languages.targetLanguage,
        );
  }

  /// Pont de compatibilité temporaire pour les producteurs legacy de cartes.
  void updateQuestionText(bool allLanguages) => _reload(allLanguages);

  /// Synchronise le filtre de langues depuis l'onglet parent.
  void updateSwitchState(bool allLanguages) => _reload(allLanguages);

  Future<void> _reveal(ReviewState state) async {
    final viewModel = ref.read(reviewViewModelProvider.notifier);
    final cardId = state.card?.id;
    if (state.isEditing) {
      FocusScope.of(context).unfocus();
      viewModel.evaluateWrittenAnswer(_editingController.text);
      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
    }
    if (cardId == null || ref.read(reviewViewModelProvider).card?.id != cardId)
      return;
    viewModel.reveal();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isSubscribedProvider, (previous, next) {
      if (!next) {
        ref.read(reviewViewModelProvider.notifier).disablePremiumEditing();
        _reload(false);
      }
      if (next == true && previous == false) _reload(false);
    });
    ref.listen<ReviewState>(reviewViewModelProvider, (previous, next) {
      if (previous?.card?.id != next.card?.id) _editingController.clear();
    });
    final state = ref.watch(reviewViewModelProvider);
    final isSubscribed = ref.watch(isSubscribedProvider);
    final card = state.card;
    if (state.phase == ReviewPhase.loading ||
        state.phase == ReviewPhase.initial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.phase == ReviewPhase.error) {
      return Center(
          child: TextButton(
        onPressed: () => _reload(widget.isAllLanguagesToggledNotifier.value),
        child: const Text('Réessayer'),
      ));
    }
    if (card == null) return const ReviewPageEmpty();

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return GridBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Stack(children: [
            Positioned.fill(
                child: Padding(
              padding: const EdgeInsets.all(16),
              child: WordsDisplay(
                questionLang: card.sourceLang,
                questionText: card.front,
                responseLang: card.targetLang,
                responseText: card.back,
                isResponseHidden: !state.isRevealed,
                onDisplayAnswer: () => _reveal(state),
                isCardConsumed: state.isScoring,
              ),
            )),
            Positioned(
              left: 0,
              right: 0,
              bottom: keyboardHeight,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (state.isRevealed)
                  Container(
                    color: keyboardHeight > 0
                        ? Colors.white.withOpacity(0.95)
                        : Colors.transparent,
                    child: ReviewControls(
                      isResponseHidden: !state.isRevealed,
                      onQualityPress: (quality) => ref
                          .read(reviewViewModelProvider.notifier)
                          .score(quality),
                      overrideDisplayWithResult:
                          state.isEditing && state.overrideQuality != null,
                      overrideQuality: state.overrideQuality,
                    ),
                  ),
                if (isSubscribed)
                  EditableAnswerSection(
                    isEditing: state.isEditing,
                    editingController: _editingController,
                    onToggleEditing: () {
                      ref
                          .read(reviewViewModelProvider.notifier)
                          .toggleEditing();
                      if (state.isEditing) FocusScope.of(context).unfocus();
                    },
                    isAllLanguagesToggledNotifier:
                        widget.isAllLanguagesToggledNotifier,
                    onLanguageToggle: _reload,
                  ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}

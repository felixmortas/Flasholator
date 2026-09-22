import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flasholator/core/presentation/ui_phase.dart';
import 'package:flasholator/features/translation/application/translation_session_context.dart';
import 'package:flasholator/features/translation/application/translation_view_model.dart';
import 'package:flasholator/features/translation/domain/translation_error.dart';
import 'package:flasholator/features/translation/domain/translation_repository.dart';
import 'package:flasholator/features/translation/domain/translation_request.dart';
import 'package:flasholator/features/translation/domain/translation_result.dart';
import 'package:flasholator/features/translation/data/deepl_translation_repository.dart';
import 'package:flasholator/features/translation/translation_providers.dart';

final class _FakeRepository implements TranslationRepository {
  _FakeRepository(this._translate);

  final Future<TranslationResult> Function(TranslationRequest) _translate;
  final requests = <TranslationRequest>[];

  @override
  Future<TranslationResult> translate(TranslationRequest request) {
    requests.add(request);
    return _translate(request);
  }
}

final class _FakeDeeplClient implements DeeplTranslationClient {
  _FakeDeeplClient(this._translate);

  final Future<String> Function() _translate;

  @override
  Future<String> translate({
    required String text,
    required String targetLanguage,
    required String sourceLanguage,
  }) => _translate();
}

TranslationResult _result(TranslationRequest request, [String text = 'Bonjour']) =>
    TranslationResult(
      sourceText: request.text,
      text: text,
      sourceLanguage: request.sourceLanguage,
      targetLanguage: request.targetLanguage,
    );

void main() {
  test('le contexte legacy reste stable après un incrément de quota', () {
    final before = translationSessionContextFromLegacyUser(
      {'sessionId': 'u1', 'counter': 0}, authUserId: 'u1');
    final after = translationSessionContextFromLegacyUser(
      {'sessionId': 'u1', 'counter': 1}, authUserId: 'u1');

    expect(after, before);
  });

  test('le repository DeepL traduit les échecs de son client injectable',
      () async {
    final repository = DeeplTranslationRepository(
      _FakeDeeplClient(() async => throw StateError('network')),
    );

    await expectLater(
      repository.translate(const TranslationRequest(
        text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR')),
      throwsA(isA<TranslationError>()),
    );
  });

  test('les dépendances feature sont surchargeables sans HTTP ni Firebase',
      () async {
    final repository = _FakeRepository((request) async => _result(request));
    const session = TranslationSessionContext(sessionId: 'test', generation: 7);
    final container = ProviderContainer(overrides: [
      translationRepositoryProvider.overrideWithValue(repository),
      translationSessionContextProvider.overrideWithValue(session),
    ]);
    addTearDown(container.dispose);

    await container.read(translationViewModelProvider.notifier).translate(
          text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR');

    expect(container.read(translationViewModelProvider).phase, UiPhase.data);
    expect(repository.requests, hasLength(1));
  });

  test('valide la saisie et publie initial, loading puis résultat', () async {
    final completion = Completer<TranslationResult>();
    final repository = _FakeRepository((_) => completion.future);
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );
    final phases = <UiPhase>[];
    viewModel.addListener((state) => phases.add(state.phase));

    final command = viewModel.translate(
      text: ' hello ', sourceLanguage: 'EN', targetLanguage: 'FR');
    expect(viewModel.state.phase, UiPhase.loading);
    completion.complete(_result(repository.requests.single));
    await command;

    expect(phases, [UiPhase.initial, UiPhase.loading, UiPhase.data]);
    expect(viewModel.state.result!.text, 'Bonjour');
    expect(repository.requests.single.text, 'hello');
  });

  test('ignore les entrées vides et les couples de langues invalides', () async {
    final repository = _FakeRepository((request) async => _result(request));
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    await viewModel.translate(text: '  ', sourceLanguage: 'EN', targetLanguage: 'FR');
    await viewModel.translate(text: 'hello', sourceLanguage: 'EN', targetLanguage: 'EN');

    expect(repository.requests, isEmpty);
    expect(viewModel.state.phase, UiPhase.initial);
  });

  test('publie une erreur DeepL typée', () async {
    const error = TranslationError(TranslationErrorKind.deepl);
    final repository = _FakeRepository((_) async => throw error);
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    await viewModel.translate(text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR');

    expect(viewModel.state.phase, UiPhase.error);
    expect(viewModel.state.error, same(error));
  });

  test('ignore une réponse arrivée après une intention plus récente', () async {
    final first = Completer<TranslationResult>();
    final second = Completer<TranslationResult>();
    var calls = 0;
    final repository = _FakeRepository((_) => ++calls == 1 ? first.future : second.future);
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    final old = viewModel.translate(text: 'first', sourceLanguage: 'EN', targetLanguage: 'FR');
    final current = viewModel.translate(text: 'second', sourceLanguage: 'EN', targetLanguage: 'FR');
    second.complete(_result(repository.requests[1], 'second result'));
    await current;
    first.complete(_result(repository.requests[0], 'old result'));
    await old;

    expect(viewModel.state.result!.text, 'second result');
  });

  test('invalide les réponses après changement de saisie ou de langues', () async {
    final completion = Completer<TranslationResult>();
    final repository = _FakeRepository((_) => completion.future);
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );

    final command = viewModel.translate(text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR');
    viewModel.invalidate();
    completion.complete(_result(repository.requests.single));
    await command;

    expect(viewModel.state.phase, UiPhase.initial);
  });

  test('ignore une réponse d’une session remplacée', () async {
    final completion = Completer<TranslationResult>();
    var session = const TranslationSessionContext(sessionId: 'u1', generation: 1);
    final repository = _FakeRepository((_) => completion.future);
    final viewModel = TranslationViewModel(repository, () => session);

    final command = viewModel.translate(text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR');
    session = const TranslationSessionContext(sessionId: 'u2', generation: 2);
    viewModel.sessionChanged(session);
    completion.complete(_result(repository.requests.single));
    await command;

    expect(viewModel.state.phase, UiPhase.initial);
  });

  test('ne publie pas après destruction du ViewModel', () async {
    final completion = Completer<TranslationResult>();
    final repository = _FakeRepository((_) => completion.future);
    final viewModel = TranslationViewModel(
      repository,
      () => const TranslationSessionContext(sessionId: 'u1', generation: 1),
    );
    final command = viewModel.translate(text: 'hello', sourceLanguage: 'EN', targetLanguage: 'FR');
    viewModel.dispose();
    completion.complete(_result(repository.requests.single));

    await expectLater(command, completes);
  });
}

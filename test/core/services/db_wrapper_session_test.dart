import 'dart:io';

import 'package:drift/native.dart';
import 'package:flasholator/core/services/db_wrapper.dart';
import 'package:flasholator/features/flashcards/data/flashcard_repository.dart';
import 'package:flasholator/features/flashcards/domain/flashcard_pair.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('les bases de A et B sont distinctes et A retrouve son nom', () {
    final a = AppDatabase.databaseNameForUser('A');
    final b = AppDatabase.databaseNameForUser('B');
    expect(a, isNot(b));
    expect(AppDatabase.databaseNameForUser('A'), a);
    expect(AppDatabase.databaseNameForUser(null), 'flashcards_collection');
  });

  test('A retrouve ses cartes après une session B isolée', () async {
    final directory = await Directory.systemTemp.createTemp('flasholator-sessions-');
    addTearDown(() => directory.delete(recursive: true));

    AppDatabase open(String uid) => AppDatabase(NativeDatabase(
          File('${directory.path}/${AppDatabase.databaseNameForUser(uid)}.sqlite'),
        ));

    final firstA = open('A');
    final repository = DriftFlashcardRepository(firstA);
    await repository.addPair(FlashcardPair(
      front: 'bonjour', back: 'hello', sourceLang: 'FR', targetLang: 'EN',
    ));
    await repository.dispose();
    await firstA.close();

    final b = open('B');
    expect(await b.select(b.flashcards).get(), isEmpty);
    await b.close();

    final secondA = open('A');
    expect(await secondA.select(secondA.flashcards).get(), hasLength(2));
    await secondA.close();
  });
}

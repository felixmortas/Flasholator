import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flasholator/core/services/firestore_users_dao.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}

class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

void main() {
  late FirestoreUsersDAO dao;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollection;
  late MockDocumentReference mockDocument;
  late MockDocumentSnapshot mockSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocument = MockDocumentReference();
    mockSnapshot = MockDocumentSnapshot();

    // Stub Firestore.instance
    when(() => mockFirestore.collection('users')).thenReturn(mockCollection);
    when(() => mockCollection.doc(any())).thenReturn(mockDocument);

    dao = FirestoreUsersDAO.test(mockFirestore); // Besoin d’un constructeur de test
  });

  group('FirestoreUsersDAO', () {
    test('registerUser creates user if not exists', () async {
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(false);
      when(() => mockDocument.set(any())).thenAnswer((_) async {});

      await dao.registerUser('user123');

      verify(() => mockDocument.get()).called(1);
      verify(() => mockDocument.set(any())).called(1);
    });

    test('registerUser does nothing if user exists', () async {
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);
      when(() => mockSnapshot.exists).thenReturn(true);

      await dao.registerUser('user123');

      verify(() => mockDocument.get()).called(1);
      verifyNever(() => mockDocument.set(any()));
    });

    test('banTranslation updates canTranslate to false', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await dao.banTranslation('user123');

      verify(() => mockDocument.update({'canTranslate': false})).called(1);
    });

    test('subscribeUser updates subscription fields', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await dao.subscribeUser('user123', '2025-04-01');

      verify(() => mockDocument.update({
        'isSubscribed': true,
        'subscriptionDate': '2025-04-01',
        'subscriptionEndDate': null,
        'canTranslate': true,
      })).called(1);
    });

    test('scheduleSubscriptionRevocation sets subscriptionEndDate', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await dao.scheduleSubscriptionRevocation(
        uid: 'user123',
        expirationStr: '2026-04-01',
      );

      verify(() => mockDocument.update({
        'subscriptionEndDate': '2026-04-01',
      })).called(1);
    });

    test('revokeSubscription sets isSubscribed to false and clears endDate', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      await dao.revokeSubscription('user123');

      verify(() => mockDocument.update({
        'isSubscribed': false,
        'subscriptionEndDate': null,
      })).called(1);
    });

    test('deleteUser deletes document', () async {
      when(() => mockDocument.delete()).thenAnswer((_) async {});

      await dao.deleteUser('user123');

      verify(() => mockDocument.delete()).called(1);
    });

    test('getUser returns document snapshot', () async {
      when(() => mockDocument.get()).thenAnswer((_) async => mockSnapshot);

      final result = await dao.getUser('user123');

      expect(result, mockSnapshot);
      verify(() => mockDocument.get()).called(1);
    });

    test('updateUser calls update with correct data', () async {
      when(() => mockDocument.update(any())).thenAnswer((_) async {});

      final data = {'customField': 'value'};
      await dao.updateUser('user123', data);

      verify(() => mockDocument.update(data)).called(1);
    });
  });
}
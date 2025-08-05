import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreUsersDAO {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Crée un utilisateur s'il n'existe pas déjà
  Future<void> registerUser(String uid) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'isSubscribed': false,
        'canTranslate': true,
        'subscriptionDate': null,
        'subscriptionEndDate': null,
      });
    }
  }

  /// Désactive la traduction pour un utilisateur
  Future<void> banTranslation(String uid) async {
    await _firestore.collection('users').doc(uid).update({'canTranslate': false});
  }

  /// Active l'abonnement d'un utilisateur
  Future<void> subscribeUser(String uid, String dateStr) async {
    await _firestore.collection('users').doc(uid).update({
      'isSubscribed': true,
      'subscriptionDate': dateStr,
      'subscriptionEndDate': null,
      'canTranslate': true,
    });
  }

  /// Planifie la fin de l'abonnement à la prochaine date anniversaire
  Future<void> scheduleSubscriptionRevocation({
    required String uid,
    required String expirationStr,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'subscriptionEndDate': expirationStr,
    });
  }

  /// Révoque l'abonnement si la date est passée
  Future<void> revokeSubscription(String uid) async {
      await _firestore.collection('users').doc(uid).update({
        'isSubscribed': false,
        'subscriptionEndDate': null,
      });
  }

  /// Supprime un utilisateur
  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  /// Récupère les données d'un utilisateur
  Future<DocumentSnapshot<Map<String, dynamic>>> _getUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot;
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    final snapshot = await _getUser(uid);
    return snapshot;
  }

  /// Met à jour dynamiquement un utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }

}
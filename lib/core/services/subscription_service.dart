import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Vérifie si l'utilisateur est abonné
  Future<bool> isUserSubscribed(String uid) async {
    final doc = await _firestore.collection('subscribedUsers').doc(uid).get();

    if (!doc.exists) return false;

    final endDate = doc.data()?['subscriptionEndDate'];

    if (endDate == null) return true;

    final now = DateTime.now();
    final expiration = (endDate as Timestamp).toDate();
    return expiration.isAfter(now);
  }

  /// Ajoute l'utilisateur comme abonné (temporaire pour test)
  Future<void> markUserAsSubscribed(String uid) async {
    await _firestore.collection('subscribedUsers').doc(uid).set({
      'subscriptionEndDate': null,
    });
  }

  /// Résilie un abonnement (définition d'une date de fin)
  Future<void> cancelSubscription(String uid, DateTime endDate) async {
    await _firestore.collection('subscribedUsers').doc(uid).update({
      'subscriptionEndDate': Timestamp.fromDate(endDate),
    });
  }

  /// Supprime complètement l'abonnement
  Future<void> removeSubscription(String uid) async {
    await _firestore.collection('subscribedUsers').doc(uid).delete();
  }
}

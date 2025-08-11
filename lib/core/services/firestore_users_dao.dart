import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUsersDAO {
  final FirebaseFirestore _firestore;

  FirestoreUsersDAO({required FirebaseFirestore firestore}) : _firestore = FirebaseFirestore.instance;

  // Constructeur pour les tests
  FirestoreUsersDAO.test(this._firestore);

  Future<void> deleteUser(String uid) async {
    await _firestore.collection('users').doc(uid).delete();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUser(String uid) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    return snapshot;
  }

  /// Met à jour dynamiquement un utilisateur
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    final userDoc = _firestore.collection('users').doc(uid);
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set(data);
    }
    await _firestore.collection('users').doc(uid).update(data);
  }
}
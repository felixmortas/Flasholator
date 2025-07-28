import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitFeedback(String uid, String feedback, String reason) async {
    try {
      await _firestore.collection('feedbacks').add({
        'userId': uid,
        'feedback': feedback,
        'reason': reason,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Erreur lors de l'envoi du feedback: $e");
      rethrow;
    }
  }
}

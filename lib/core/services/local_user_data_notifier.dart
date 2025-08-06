import 'package:flutter/foundation.dart';

/// Référence globale réactive pour les données utilisateur locales
class LocalUserDataNotifier {
  static final ValueNotifier<Map<String, dynamic>> userDataNotifier =
      ValueNotifier<Map<String, dynamic>>({});

  // Méthode d'initialisation
  static void initialize() {
    userDataNotifier.value = {};
  }

  static void updateUser(Map<String, dynamic> data) {
    userDataNotifier.value = {...userDataNotifier.value, ...data};
  }

  static void clearUserData() {
    userDataNotifier.value = {};
  }

    // Getters pratiques
  static bool get isSubscribed => userDataNotifier.value['isSubscribed'] ?? false;
  static bool get canTranslate => userDataNotifier.value['canTranslate'] ?? false;
  static String get subscriptionDate => userDataNotifier.value['subscriptionDate'] ?? '';
  static String get subscriptionEndDate => userDataNotifier.value['subscriptionEndDate'] ?? '';
}
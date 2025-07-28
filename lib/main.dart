import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'l10n/app_localizations.dart';
import 'core/services/flashcards_collection.dart';
import 'core/services/deepl_translator.dart'; 
import 'core/models/flashcard_adapter.dart';
import 'core/services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the binding

  MobileAds.instance.initialize();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter(); // Initialiser Hive avec Flutter
  // Enregistrer l'adapter personnalisé pour Flashcard (si utilisé)
  Hive.registerAdapter(FlashcardAdapter());

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final flashcardsCollection =
      FlashcardsCollection(); // Create an instance of FlashcardDao
  final deeplTranslator =
      DeeplTranslator(); // Create an instance of DeeplTranslator

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: Locale('en'), // Test UI language
      title: 'Flasholator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('es'), // Spanish
      ],
      home: AuthGate(
        flashcardsCollection: flashcardsCollection,
        deeplTranslator: deeplTranslator,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Import Hive
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/models/flashcard_adapter.dart';
import 'package:flasholator/core/services/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the binding

  MobileAds.instance.initialize();
  final config = RequestConfiguration(
    testDeviceIds: ['E779AA37025CA3C4EE7B28A571BDA15A'],
  );
  MobileAds.instance.updateRequestConfiguration(config);


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter(); // Initialiser Hive avec Flutter
  // Enregistrer l'adapter personnalisé pour Flashcard (si utilisé)
  Hive.registerAdapter(FlashcardAdapter());

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('es'), // Spanish
      ],
      home: const AuthGate(),
    );
  }
}

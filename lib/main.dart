import 'package:flutter/material.dart';
import 'features/home_page.dart';
import 'core/services/flashcards_collection.dart';
import 'core/services/deepl_translator.dart'; // version précédente

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Initialize the binding

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final flashcardsCollection =
      FlashcardsCollection(); // Create an instance of FlashcardDao
  final deeplTranslator =
      DeeplTranslator(); // Create an instance of DeeplTranslator // version précédente

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flasholator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomePage(
        flashcardsCollection: flashcardsCollection,
        deeplTranslator: deeplTranslator, // version précédente
      ),
    );
  }
}

import '../l10n/app_localizations.dart';
import 'dart:io';

import '../core/services/deepl_translator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/services/flashcards_collection.dart';
import 'translation/translate_tab.dart';
import 'review/review_tab.dart';
import 'data/data_table_tab.dart';
import 'stats/stats_page.dart';
import 'shared/widgets/settings_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  final FlashcardsCollection flashcardsCollection;
  final DeeplTranslator deeplTranslator;

  const HomePage({
    Key? key,
    required this.flashcardsCollection,
    required this.deeplTranslator,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final dataTableTabKey = GlobalKey<DataTableTabState>();
  final reviewTabKey = GlobalKey<ReviewTabState>();
  final ValueNotifier<bool> isAllLanguagesToggledNotifier =
      ValueNotifier<bool>(false);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: Navigator.of(context));
    _tabController.addListener(_onTabChange);
    if (Platform.isAndroid) {
      requestPermissions(); // Call the requestPermissions() method here
    }
    _handleTextIntent();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    isAllLanguagesToggledNotifier.dispose(); // Dispose du notifier
    super.dispose();
  }

  void _onTabChange() {
    if (_tabController.indexIsChanging) {
      _synchronizeSwitchState();
    }
  }

  void _synchronizeSwitchState() {
    // Fonction appelée lors du changement d'onglet pour synchroniser l'état du switch
    dataTableTabKey.currentState
        ?.updateSwitchState(isAllLanguagesToggledNotifier.value);
    reviewTabKey.currentState
        ?.updateSwitchState(isAllLanguagesToggledNotifier.value);
  }

  static const MethodChannel _platform =
      MethodChannel('com.felinx18.flasholator.translate_and_add_card');

  Future<void> _handleTextIntent() async {
    try {
      // Récupérer le texte sélectionné
      String? wordToTranslate = await _platform.invokeMethod<String>('getText');
      if (wordToTranslate != null) {
        // Appeler la fonction de traduction
        String translatedWord =
            await widget.deeplTranslator.translate(wordToTranslate, 'FR', 'EN');

        if (wordToTranslate != '' &&
            translatedWord != '' &&
            translatedWord != AppLocalizations.of(context)!.connectionError &&
            !await widget.flashcardsCollection
                .checkIfFlashcardExists(wordToTranslate, translatedWord)) {
          wordToTranslate = wordToTranslate.toLowerCase()[0].toUpperCase() +
              wordToTranslate.toLowerCase().substring(1);
          translatedWord = translatedWord.toLowerCase()[0].toUpperCase() +
              translatedWord.toLowerCase().substring(1);
        }

        Future<bool> isCardAdded = widget.flashcardsCollection
            .addFlashcard(wordToTranslate, translatedWord, "EN", "FR");

        // Confirm that the card was added
        Fluttertoast.showToast(
          msg: await isCardAdded
              ? AppLocalizations.of(context)!.cardAdded
              : AppLocalizations.of(context)!.cardAlreadyAdded,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    } on PlatformException catch (e) {
      print("Failed to get text: '${e.message}'.");
    }
  }

  void dataTableTabFunction(Map<dynamic, dynamic> row) {
    dataTableTabKey.currentState?.addRow(row);
  }

  void reviewTabFunction() {
    reviewTabKey.currentState
        ?.updateQuestionText(isAllLanguagesToggledNotifier.value);
  }

  Future<void> requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage, // for read and write access
    ].request();

    PermissionStatus storageStatus = statuses[Permission.storage]!;
    if (storageStatus.isGranted) {
      // Permission granted, you can proceed with reading and writing
    } else {
      // Permission denied
    }
  }

  void _launchEmail() async {
    String email = Uri.encodeComponent("felix.mortas@hotmail.fr");
    String subject = Uri.encodeComponent("Feedback pour Flasholator");
    String body = Uri.encodeComponent(
        "Bonjour, Les 2 fonctionnalités principales de cette application sont traduire puis réviser ce qu'on a traduit. Nous aimerions avoir ton avis sur l'application: nouveau nom, fonctionnalités, design, bugs, améliorations, zones d'ombre, idées, langues, intégration, accessibilité, lisibilité, ergonomie, etc. Merci d'avance pour ton retour ! L'équipe de Flasholator");
    Uri mail = Uri.parse("mailto:$email?subject=$subject&body=$body");
    if (await launchUrl(mail)) {
      //email app opened
    } else {
      //email app is not opened
    }
  }

  void _openSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsDialog(
        launchEmail: _launchEmail,
        flashcardsCollection: widget.flashcardsCollection,
      ),
    );
  }

  bool checkUserLoggedIn() {
    // Exemple simple (à remplacer par une vraie logique)
    return false;
  }


  void _handleUserButton(BuildContext context) {
    final isConnected = checkUserLoggedIn(); // à adapter selon ta logique d'authentification

    if (isConnected) {
      Navigator.pushNamed(context, '/profile'); // ou Navigator.push(...)
    } else {
      Navigator.pushNamed(context, '/login'); // ou page d'inscription
    }
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flasholator'),
          actions: [
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _openSettings();
                },
              ),
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => _handleUserButton(context),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            TranslateTab(
              flashcardsCollection: widget.flashcardsCollection,
              deeplTranslator: widget.deeplTranslator, // version précédente
              addRow: dataTableTabFunction,
              updateQuestionText: reviewTabFunction,
            ),
            ReviewTab(
              flashcardsCollection: widget.flashcardsCollection,
              key: reviewTabKey,
              isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
            ),
            DataTableTab(
              flashcardsCollection: widget.flashcardsCollection,
              key: dataTableTabKey,
              updateQuestionText: reviewTabFunction,
              isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
            )
          ],
        ),
        bottomNavigationBar: const TabBar(
          tabs: [
            Tab(icon: Icon(Icons.translate)),
            Tab(icon: Icon(Icons.replay)),
            Tab(icon: Icon(Icons.folder)),
          ],
        ),
      ),
    );
  }
}

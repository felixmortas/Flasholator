import 'package:flasholator/core/providers/revenuecat_provider.dart';

import '../l10n/app_localizations.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/ad_provider.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/core/services/flashcards_collection.dart';
import 'package:flasholator/features/translation/translate_tab.dart';
import 'package:flasholator/features/review/review_tab.dart';
import 'package:flasholator/features/data/data_table_tab.dart';
import 'package:flasholator/features/shared/dialogs/settings_dialog.dart';
import 'package:flasholator/features/shared/dialogs/language_selection_popup.dart';
import 'package:flasholator/features/authentication/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {

  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final flashcardsCollection =
      FlashcardsCollection(); // Create an instance of FlashcardDao
  final deeplTranslator =
      DeeplTranslator(); // Create an instance of DeeplTranslator

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

    ref.read(adServiceProvider).loadInterstitial();

    if (!kIsWeb && Platform.isAndroid) {
      requestPermissions();
      _handleTextIntent();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initRevenueCat();
      _initUserState();
    });
  }

  @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      ref.read(adServiceProvider).loadBanner(context);
    }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    isAllLanguagesToggledNotifier.dispose(); // Dispose du notifier
    super.dispose();
  }

  Future<void> _initRevenueCat() async {
    final uid = ref.read(userManagerProvider).getUserId();
    await ref.read(revenueCatServiceProvider).initRevenueCat(uid);
  }


  Future<void> _showLanguageSelectionPopup(String sourceLang, String targetLang) async {
    final userManager = ref.read(userManagerProvider);

    await showDialog(
      context: context,
      barrierDismissible: false, // obligatoire, pour forcer le choix
      builder: (_) {
        return LanguageSelectionPopup(
          onSave: (newSourceLang, newTargetLang) async {
            await userManager.setCoupleLang(newSourceLang, newTargetLang);
          },
        );
      },
    );
  }

  Future<void> _loadUserPrefsAndUpdateNotifier() async {
    final userManager = ref.read(userManagerProvider);
    await userManager.syncNotifierFromLocal();

    final coupleLang = ref.read(coupleLangProvider);
    final sourceLang = coupleLang.contains('-') ? coupleLang.split('-')[0] : '';
    final targetLang = coupleLang.contains('-') ? coupleLang.split('-')[1] : '';

    if (sourceLang == '' || targetLang == '') {
      // Première connexion sans couple de langue
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _showLanguageSelectionPopup(sourceLang, targetLang);
      });
    }
  }

  void checkAndRevokeSubscription(String subscriptionEndDate) async { 
    final userManager = ref.read(userManagerProvider);
    await userManager.checkAndRevokeSubscription(subscriptionEndDate);
  }

  void _initUserState() async {    
    await _loadUserPrefsAndUpdateNotifier();
    final isSubscribed = ref.read(isSubscribedProvider);    
    if (isSubscribed) {
      final subscriptionEndDate = ref.read(subscriptionEndDateProvider);      
      if (subscriptionEndDate != '') {
      checkAndRevokeSubscription(subscriptionEndDate);
      }
    }
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
    final isSubscribed = ref.read(isSubscribedProvider);
    final canTranslate = ref.read(canTranslateProvider);
    final canAddCard = await flashcardsCollection.canAddCard();
    
    if (isSubscribed || (canTranslate && canAddCard)) {
      try {
        // Récupérer le texte sélectionné
        String? wordToTranslate = await _platform.invokeMethod<String>('getText');
        if (wordToTranslate != null) {
          // Appeler la fonction de traduction
          String translatedWord =
              await deeplTranslator.translate(wordToTranslate, 'FR', 'EN');

          if (wordToTranslate != '' &&
              translatedWord != '' &&
              translatedWord != AppLocalizations.of(context)!.connectionError &&
              !await flashcardsCollection
                  .checkIfFlashcardExists(wordToTranslate, translatedWord)) {
            wordToTranslate = wordToTranslate.toLowerCase()[0].toUpperCase() +
                wordToTranslate.toLowerCase().substring(1);
            translatedWord = translatedWord.toLowerCase()[0].toUpperCase() +
                translatedWord.toLowerCase().substring(1);
          }

          Future<bool> isCardAdded = flashcardsCollection
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
    } else {
      // Inform that the card was NOT added
      Fluttertoast.showToast(
        msg: AppLocalizations.of(context)!.freeSubscriptionLimitsExceeded,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
        flashcardsCollection: flashcardsCollection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final adService = ref.read(adServiceProvider);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Flasholator'),
          actions: [
            IconButton(
              icon: const Icon(Icons.account_circle),
              onPressed: () => {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ProfilePage()),
                )
              },
            ),
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {
                  _openSettings();
                },
              ),
          ],
        ),
        body: Column(
          children: [
            if (adService.getBannerWidget() != null)
              adService.getBannerWidget()!,

            Expanded(child: 
              TabBarView(
                children: [
                  TranslateTab(
                    flashcardsCollection: flashcardsCollection,
                    deeplTranslator: deeplTranslator,
                    addRow: dataTableTabFunction,
                    updateQuestionText: reviewTabFunction,
                  ),
                  ReviewTab(
                    flashcardsCollection: flashcardsCollection,
                    key: reviewTabKey,
                    isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                  ),
                  DataTableTab(
                    flashcardsCollection: flashcardsCollection,
                    key: dataTableTabKey,
                    updateQuestionText: reviewTabFunction,
                    isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                  )
                ],
              ),
            )
          ]
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

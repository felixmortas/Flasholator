import 'dart:developer' as developer;
import 'dart:async';
import 'dart:io';
import 'package:flasholator/style/app_colors.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_data_provider.dart';
import 'package:flasholator/core/providers/free_plan_limits_provider.dart';
import 'package:flasholator/core/providers/ad_provider.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/core/services/deepl_translator.dart';
import 'package:flasholator/core/services/flashcards_service.dart';
import 'package:flasholator/features/translation/translate_tab.dart';
import 'package:flasholator/features/translation/translation_providers.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flasholator/features/review/review_tab.dart';
import 'package:flasholator/features/data/data_table_tab.dart';
import 'package:flasholator/features/shared/dialogs/language_selection_popup.dart';
import 'package:flasholator/features/shared/widgets/ad_banner_widget.dart';
import 'package:flasholator/features/profile/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with WidgetsBindingObserver {
  late final FlashcardsService flashcardsService;
  final deeplTranslator =
      DeeplTranslator(); // Create an instance of DeeplTranslator

  final dataTableTabKey = GlobalKey<DataTableTabState>();
  final reviewTabKey = GlobalKey<ReviewTabState>();

  final ValueNotifier<bool> isAllLanguagesToggledNotifier =
      ValueNotifier<bool>(false);
  late TabController _tabController;

  UserDataNotifier get userNotifier => ref.read(userDataProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    flashcardsService = FlashcardsService(
      userId: ref.read(authSessionRepositoryProvider).account?.uid,
      limits: ref.read(freePlanLimitsProvider),
      isPremium: () => ref.read(isSubscribedProvider),
    );
    _tabController = TabController(length: 2, vsync: Navigator.of(context));
    _tabController.addListener(_onTabChange);

    if (!kIsWeb && Platform.isAndroid) {
      _initAndroidIntegration();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _initUserState();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_onTabChange);
    _tabController.dispose();
    isAllLanguagesToggledNotifier.dispose(); // Dispose du notifier
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(adEligibilityProvider);
      ref.invalidate(bannerAdProvider);
      ref.read(adServiceProvider).clearInterstitial();
    }
  }

  Future<void> _initAndroidIntegration() async {
    await requestPermissions();
    await _handleTextIntent();
  }

  Future<void> _showLanguageSelectionPopup(
      String sourceLang, String targetLang) async {
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

  void _initUserState() async {
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
    final session = ref.read(translationSessionContextProvider);
    final isSubscribed = ref.read(isSubscribedProvider);
    final canTranslate = ref.read(canTranslateProvider);
    final canAddCard = await ref.read(flashcardAccessProvider).canAddCard();
    if (!mounted || ref.read(translationSessionContextProvider) != session) {
      return;
    }

    if (isSubscribed || (canTranslate && canAddCard)) {
      try {
        // Récupérer le texte sélectionné
        String? wordToTranslate =
            await _platform.invokeMethod<String>('getText');
        if (wordToTranslate != null &&
            wordToTranslate.trim().isNotEmpty &&
            mounted &&
            ref.read(translationSessionContextProvider) == session) {
          // Appeler la fonction de traduction
          String translatedWord =
              await deeplTranslator.translate(wordToTranslate, 'FR', 'EN');

          if (!mounted ||
              ref.read(translationSessionContextProvider) != session) {
            return;
          }
          if (wordToTranslate.trim().isEmpty ||
              translatedWord.trim().isEmpty ||
              translatedWord == AppLocalizations.of(context)!.connectionError) {
            return;
          }
          if (!isSubscribed) {
            await ref.read(userManagerProvider).incrementCounter(
                  isCurrent: () =>
                      mounted &&
                      ref.read(translationSessionContextProvider) == session,
                );
            if (!mounted ||
                ref.read(translationSessionContextProvider) != session) {
              return;
            }
          }

          if (wordToTranslate != '' &&
              translatedWord != '' &&
              translatedWord != AppLocalizations.of(context)!.connectionError &&
              !await flashcardsService.checkIfFlashcardExists(
                  wordToTranslate, translatedWord)) {
            if (!mounted ||
                ref.read(translationSessionContextProvider) != session) {
              return;
            }
            wordToTranslate = wordToTranslate.toLowerCase()[0].toUpperCase() +
                wordToTranslate.toLowerCase().substring(1);
            translatedWord = translatedWord.toLowerCase()[0].toUpperCase() +
                translatedWord.toLowerCase().substring(1);
          }

          if (!mounted ||
              ref.read(translationSessionContextProvider) != session) {
            return;
          }

          final isCardAdded = await flashcardsService.addFlashcard(
              wordToTranslate, translatedWord, "EN", "FR");
          if (!mounted ||
              ref.read(translationSessionContextProvider) != session) {
            return;
          }

          // Confirm that the card was added
          Fluttertoast.showToast(
            msg: isCardAdded
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
        developer.log("Failed to get text: '${e.message}'.");
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

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(adEligibilityProvider, (previous, next) {
      final ads = ref.read(adServiceProvider);
      if (next.valueOrNull != true) {
        ads.clearInterstitial();
        return;
      }
      unawaited(ads.loadInterstitial(() async =>
          mounted &&
          !ref.read(isSubscribedProvider) &&
          await ref.read(adAuthorizationProvider).canShowAds()));
    });
    ref.listen<bool>(isSubscribedProvider, (previous, next) {
      ref.read(adServiceProvider).clearInterstitial();
      if (!next) isAllLanguagesToggledNotifier.value = false;
    });
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ProfilePage(
                          flashcardsService: flashcardsService,
                        )),
              )
            },
          ),
          title: const Text(
            'Flasholator',
            style: TextStyle(
              fontFamily: 'MomoSignature',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2, // Optionnel
            ),
          ),
          centerTitle: true,
          // actions: [
          // IconButton(
          //   icon: const Icon(Icons.money),
          //   onPressed: () {
          //     // Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(builder: (_) => MoneyPage()),
          //     // );
          //   },
          // ),
          // ],
        ),
        body: Column(children: [
          const AdBannerWidget(),
          Expanded(
            child: TabBarView(
              children: [
                const TranslateTab(),
                ReviewTab(
                  key: reviewTabKey,
                  isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                ),
                DataTableTab(
                  key: dataTableTabKey,
                  isAllLanguagesToggledNotifier: isAllLanguagesToggledNotifier,
                )
              ],
            ),
          )
        ]),
        bottomNavigationBar: const Material(
          color: AppColors.white,
          child: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.translate)),
              Tab(icon: Icon(Icons.replay)),
              Tab(icon: Icon(Icons.folder)),
            ],
          ),
        ),
      ),
    );
  }
}

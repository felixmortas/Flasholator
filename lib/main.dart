import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/bootstrap/application_bootstrap.dart';
import 'package:flasholator/core/services/auth_gate.dart';
import 'package:flasholator/style/app_theme.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';

Future<void> main() async {
  await ApplicationBootstrap.production().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key, this.home, this.locale});

  final Widget? home;
  final Locale? locale;

  // This widget is the root of your application.
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb || state != AppLifecycleState.resumed || !mounted) return;
    if (ref.read(authSessionRepositoryProvider).status != AuthSessionStatus.ready) {
      return;
    }
    // La garde uid/génération et l'ordre des lectures restent dans UserManager.
    unawaited(_refreshSubscription());
  }

  Future<void> _refreshSubscription() async {
    try {
      await ref.read(userManagerProvider).refreshSubscription();
    } catch (_) {
      // Le prochain retour au premier plan pourra réessayer sans retirer le droit.
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: Locale('en'), // Test UI language
      title: 'Flasholator',
      theme: AppTheme.lightTheme,
      locale: widget.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: widget.home ?? const AuthGate(),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/bootstrap/application_bootstrap.dart';
import 'package:flasholator/core/services/auth_gate.dart';
import 'package:flasholator/style/app_theme.dart';

Future<void> main() async {
  await ApplicationBootstrap.production().initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.home, this.locale});

  final Widget? home;
  final Locale? locale;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // locale: Locale('en'), // Test UI language
      title: 'Flasholator',
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: home ?? const AuthGate(),
    );
  }
}

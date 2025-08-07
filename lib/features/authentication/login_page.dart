import 'package:flasholator/core/providers/subscription_service_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/core/providers/firebase_auth_provider.dart';
import 'package:flasholator/features/authentication/register_page.dart';
import 'package:flasholator/l10n/app_localizations.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    debugPrint("##DEBUG## Enter LoginPage.login()");
    try {
      final firebaseAuth = ref.read(firebaseAuthProvider);
      await firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );      

      final subscriptionService = ref.read(subscriptionServiceProvider);
      debugPrint("##DEBUG## Enter subscriptionService.syncUser()");
      await subscriptionService.syncUser();
      
    } on Exception catch (e) {
      setState(() => errorMessage = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseAuth = ref.read(firebaseAuthProvider);

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.logIn)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null) Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(controller: emailController, decoration: InputDecoration(labelText:AppLocalizations.of(context)!.email)),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: login, child: Text(AppLocalizations.of(context)!.logIn)),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterPage(
                initialEmail: emailController.text.trim(),
                initialPassword: passwordController.text,

              ))),
              child: Text(AppLocalizations.of(context)!.signUp),
            ),
            TextButton(
              onPressed: () => firebaseAuth.sendPasswordResetEmail(email: emailController.text.trim()),
              child: Text(AppLocalizations.of(context)!.forgotYourPassword),
            ),
          ],
        ),
      ),
    );
  }
}

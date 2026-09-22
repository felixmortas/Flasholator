import 'package:firebase_auth/firebase_auth.dart';
import 'package:flasholator/features/authentication/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/features/authentication/register_page.dart';
import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/style/grid_background_painter.dart'; // Ajoutez cet import

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool _obscurePassword = true;

  Future<void> login() async {
    await ref.read(authViewModelProvider.notifier).login(
        emailController.text.trim(), passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authViewModelProvider);
    final error = action.error;

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.logIn)),
      body: GridBackground(
        // Ajout du background cahier ici
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AutofillGroup(
            child: Column(
              children: [
                if (error != null)
                  Text(error is FirebaseAuthException
                      ? (error.message ?? AppLocalizations.of(context)!.connectionError)
                      : AppLocalizations.of(context)!.connectionError,
                      style: const TextStyle(color: Colors.red)),
                TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.email)),
                const SizedBox(height: 16),
                TextField(
                    controller: passwordController,
                    autofillHints: const [AutofillHints.password],
                    onEditingComplete: () => TextInput.finishAutofillContext(),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.password,
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    obscureText: _obscurePassword),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: action.loading ? null : login,
                    child: action.loading
                        ? const CircularProgressIndicator()
                        : Text(AppLocalizations.of(context)!.logIn)),
                TextButton(
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => RegisterPage(
                                initialEmail: emailController.text.trim(),
                                initialPassword: passwordController.text,
                              ))),
                  child: Text(AppLocalizations.of(context)!.signUp),
                ),
                TextButton(
                  onPressed: action.loading
                      ? null
                      : () => ref.read(authViewModelProvider.notifier)
                          .resetPassword(emailController.text.trim()),
                  child: Text(AppLocalizations.of(context)!.forgotYourPassword),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

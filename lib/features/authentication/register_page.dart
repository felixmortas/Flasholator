import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final String? initialEmail;
  final String? initialPassword;

  const RegisterPage({super.key, this.initialEmail, this.initialPassword});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    if (widget.initialEmail != null) {
      emailController.text = widget.initialEmail!;
    }
    if (widget.initialPassword != null) {
      passwordController.text = widget.initialPassword!;
    }
  }


  Future<void> register() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      setState(() => errorMessage = AppLocalizations.of(context)!.allFieldsRequired);
      return;
    }

    if (password != confirmPassword) {
      setState(() => errorMessage = "Les mots de passe ne correspondent pas.");
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final userManager = ref.read(userManagerProvider);
      await userManager.registerUser(email, password, username);

      setState(() => isLoading = false);

      // Message de succès et retour à la page de connexion
      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.accountCreated),
            content: Text(AppLocalizations.of(context)!.verificationEmailSent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Fermer la boîte de dialogue
                  Navigator.pop(context); // Retour à la page login
                },
                child: const Text("OK"),
              )
            ],
          ),
        );
      }
    } on Exception catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.signUp)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (errorMessage != null)
              Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmPassword),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: register,
                    child: Text(AppLocalizations.of(context)!.signUp),
                  ),
          ],
        ),
      ),
    );
  }
}

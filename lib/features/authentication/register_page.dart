import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/core/providers/user_manager_provider.dart';
import 'package:flasholator/style/grid_background_painter.dart';

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
      setState(() => errorMessage = AppLocalizations.of(context)!.passwordsDoNotMatch);
      return;
    }

    final passwordPattern = RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}');
    if (!passwordPattern.hasMatch(password)) {
      setState(() => errorMessage = AppLocalizations.of(context)!.passwordFormatError);
      return;
    }

    setState(() {
      errorMessage = null;
      isLoading = true;
    });

    try {
      final userManager = ref.read(userManagerProvider);
      await userManager.registerUser(email, password, username);

      TextInput.finishAutofillContext();

      setState(() => isLoading = false);

      if (mounted) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(AppLocalizations.of(context)!.accountCreated),
            content: Text(AppLocalizations.of(context)!.verificationEmailSent),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text(AppLocalizations.of(context)!.ok),
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
      body: GridBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AutofillGroup(
            child: Column(
              children: [
                if (errorMessage != null)
                  Text(errorMessage!, style: const TextStyle(color: Colors.red)),
                TextField(
                  controller: usernameController,
                  autofillHints: const [AutofillHints.username, AutofillHints.newUsername],
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.username),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  autofillHints: const [AutofillHints.email],
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.email),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  autofillHints: const [AutofillHints.newPassword, AutofillHints.password],
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.password),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  autofillHints: const [AutofillHints.newPassword, AutofillHints.password],
                  decoration: InputDecoration(labelText: AppLocalizations.of(context)!.confirmPassword),
                  obscureText: true,
                  onEditingComplete: () => TextInput.finishAutofillContext(),
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.passwordRequirements,
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
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
        ),
      ),
    );
  }
}
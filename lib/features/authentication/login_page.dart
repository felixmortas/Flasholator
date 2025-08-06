import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';

import '../../l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? errorMessage;

  Future<void> login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => errorMessage = e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: () => FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim()),
              child: Text(AppLocalizations.of(context)!.forgotYourPassword),
            ),
          ],
        ),
      ),
    );
  }
}

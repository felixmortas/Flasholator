import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flasholator/l10n/app_localizations.dart';
import 'package:flasholator/features/authentication/auth_session_repository.dart';
import 'package:flasholator/features/authentication/auth_view_model.dart';
import 'package:flasholator/style/grid_background_painter.dart';

class EmailVerificationPendingPage extends ConsumerStatefulWidget {
  const EmailVerificationPendingPage({super.key});

  @override
  ConsumerState<EmailVerificationPendingPage> createState() =>
      _EmailVerificationPendingPageState();
}

class _EmailVerificationPendingPageState
    extends ConsumerState<EmailVerificationPendingPage> {
  bool _sent = false;

  Future<void> resendVerificationEmail() async {
    await ref.read(authViewModelProvider.notifier).resendVerification();
    if (mounted) {
      setState(() => _sent = ref.read(authViewModelProvider).completed);
    }
  }

  Future<void> checkVerificationStatus() async {
    setState(() => _sent = false);
    await ref.read(authViewModelProvider.notifier).checkVerification();
  }

  @override
  Widget build(BuildContext context) {
    final action = ref.watch(authViewModelProvider);
    final session = ref.read(authSessionRepositoryProvider.notifier);
    final message = action.error != null
        ? AppLocalizations.of(context)!.error
        : action.verified == false
            ? AppLocalizations.of(context)!.yourAddressHasNotYetBeenVerified
            : _sent
                ? AppLocalizations.of(context)!.verificationEmailSent
                : null;

    return Scaffold(
      appBar:
          AppBar(title: Text(AppLocalizations.of(context)!.emailVerification)),
      body: GridBackground(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                      AppLocalizations.of(context)!
                          .aVerificationEmailHasBeenSentTo,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(session.userEmail,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  if (message != null)
                    Text(
                      message,
                      style: TextStyle(
                        color: message
                                .contains(AppLocalizations.of(context)!.error)
                            ? Colors.red
                            : Colors.green,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: action.loading ? null : resendVerificationEmail,
                    child: action.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!.resendEmail),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: action.loading ? null : checkVerificationStatus,
                    child: action.loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(AppLocalizations.of(context)!
                            .iHaveConfirmedMyEmail),
                  ),
                  const SizedBox(height: 30),
                  TextButton(
                    onPressed: () => session.signOut(),
                    child: Text(AppLocalizations.of(context)!.logOut),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

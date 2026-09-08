import 'package:flutter/material.dart';
import '../../data/services/enterprise_service.dart';

/// Authentication succeeded, but authorized account context has not loaded.
/// This screen offers no route into protected data until onRetry succeeds.
class EnterpriseAccessRecoveryScreen extends StatefulWidget {
  final Object initialError;
  final Future<void> Function() onRetry;
  final Future<void> Function() onSignOut;
  const EnterpriseAccessRecoveryScreen({
    super.key,
    required this.initialError,
    required this.onRetry,
    required this.onSignOut,
  });

  @override
  State<EnterpriseAccessRecoveryScreen> createState() =>
      _EnterpriseAccessRecoveryScreenState();
}

class _EnterpriseAccessRecoveryScreenState
    extends State<EnterpriseAccessRecoveryScreen> {
  late Object error = widget.initialError;
  bool busy = false;

  String get message {
    if (error is EnterpriseException) {
      final status = (error as EnterpriseException).status;
      if (status == 404) {
        return 'Gym services are not available on this server yet. '
            'Please contact your administrator or retry later.';
      }
      if (status == 401 || status == 403) {
        return 'We could not verify your gym access. '
            'Retry or sign in with another account.';
      }
    }
    return 'Your sign-in succeeded, but we could not load your gym access. '
        'Please retry to continue.';
  }

  Future<void> run(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
    } catch (failure) {
      if (mounted) setState(() => error = failure);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Finish signing in'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 48),
                  const SizedBox(height: 20),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  if (busy) const LinearProgressIndicator(),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: busy ? null : () => run(widget.onRetry),
                    child: const Text('Retry'),
                  ),
                  TextButton(
                    onPressed: busy ? null : () => run(widget.onSignOut),
                    child: const Text('Sign out'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

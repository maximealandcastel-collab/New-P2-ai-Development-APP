import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/themes/enterprise_gym_theme.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';

/// Snapshot the gym colors before logout clears the active session.
Future<void> showLogoutDialog(BuildContext context) async {
  final theme = TenantBrandService.to.activeBrand?.theme ??
      Theme.of(context).extension<EnterpriseGymTheme>() ??
      TenantBrandService.to.theme;
  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: .42),
    builder: (_) => LogoutDialog(
      theme: theme,
      onLogout: () => LoginController.to.logout(),
    ),
  );
}

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key, required this.theme, required this.onLogout});

  final EnterpriseGymTheme theme;
  /// The existing logout controller handles successful navigation.
  final Future<void> Function() onLogout;

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _busy = false;
  String? _error;

  Future<void> _confirm() async {
    if (_busy) return;
    setState(() { _busy = true; _error = null; });
    try {
      await widget.onLogout();
    } catch (_) {
      if (mounted) setState(() {
        _busy = false;
        _error = 'Could not log out. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;
    final shadow = BoxShadow(
      color: theme.primaryBrandColor.withValues(alpha: .15),
      blurRadius: 16, offset: const Offset(0, 5),
    );
    return PopScope(
      canPop: !_busy,
      child: Dialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 32, 22, 12),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                      width: 64, height: 64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: theme.ctaGradient,
                        boxShadow: [shadow],
                      ),
                      child: Icon(Icons.logout_rounded, size: 28,
                          color: theme.textOnGradient),
                    ),
                    const SizedBox(height: 18),
                    const Text('Log out?', textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: AppFontWeight.section,
                            color: EnterpriseGymTheme.signatureBlack)),
                    const SizedBox(height: 7),
                    const Text('You’ll need to sign back in to continue.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, height: 1.4,
                            color: Color(0xFF727581))),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 22),
                    DecoratedBox(
                      key: const ValueKey('logout-gradient'),
                      decoration: BoxDecoration(
                        gradient: theme.ctaGradient,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [shadow],
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: _busy ? null : _confirm,
                          style: TextButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            foregroundColor: theme.textOnGradient,
                            disabledForegroundColor: theme.textOnGradient,
                            backgroundColor: Colors.transparent,
                            shape: const StadiumBorder(),
                          ),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min, children: [
                              if (_busy) ...[
                                SizedBox(width: 18, height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2,
                                    color: theme.textOnGradient)),
                                const SizedBox(width: 10),
                              ],
                              Flexible(child: Text(_busy ? 'Logging out…' : 'Log out',
                                style: const TextStyle(fontSize: 14,
                                  fontWeight: AppFontWeight.label))),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _busy ? null : () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(foregroundColor: const Color(0xFF727581)),
                      child: const Text('Cancel'),
                    ),
                  ]),
                ),
              ),
              Positioned(top: 6, right: 6, child: IconButton(
                tooltip: 'Close',
                onPressed: _busy ? null : () => Navigator.of(context).pop(),
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Color(0xFFF4F4F5),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded, size: 18),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

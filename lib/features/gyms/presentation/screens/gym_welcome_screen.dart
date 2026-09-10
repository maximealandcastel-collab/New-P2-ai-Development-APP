import 'staff_signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'gym_application_screen.dart';

/// Select an onboarding path; account privileges still come from the server.
class GymWelcomeScreen extends StatefulWidget {
  final VoidCallback onMember;
  final bool gymEntry;
  const GymWelcomeScreen({
    super.key,
    required this.onMember,
    this.gymEntry = false,
  });

  @override
  State<GymWelcomeScreen> createState() => _GymWelcomeScreenState();
}

class _GymWelcomeScreenState extends State<GymWelcomeScreen> {
  static const _orange = Color(0xFFFF6833);
  static const _ink = Color(0xFF111827);
  static const _muted = Color(0xFF697386);
  String? _path;

  @override
  void initState() {
    super.initState();
    _path = widget.gymEntry ? 'Gym Partner' : null;
  }

  void _apply() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const GymApplicationScreen()));

  Future<void> _continue() async {
    switch (_path) {
      case 'Member':
        widget.onMember();
        return;
      case 'Gym Partner':
        _apply();
        return;
      case 'Staff / Admin':
        await Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const StaffSignupScreen()));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F5F7),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 574),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            children: [
              Row(
                children: [
                  Image.asset(
                    Assets.images.logo.path,
                    width: 48,
                    height: 48,
                    fit: BoxFit.contain,
                    semanticLabel: 'P2P Fit Tech AI logo',
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'P2P FIT TECH AI',
                          style: TextStyle(
                            fontSize: 12,
                            letterSpacing: 1.2,
                            color: Color(0xFF99A1B1),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Welcome to P2P Fitness',
                          style: TextStyle(
                            fontSize: 18,
                            color: _ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              const Text(
                'Get Started.',
                style: TextStyle(
                  fontSize: 38,
                  height: 1.1,
                  letterSpacing: -1,
                  color: _ink,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Connect your gym to personalize your experience.\nChoose your path below.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: _muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 36),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6833).withValues(alpha: .055),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFCABB),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const ExcludeSemantics(
                      child: Icon(
                        Icons.workspace_premium_outlined,
                        size: 26,
                        color: _orange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Claim Your Gym',
                            style: TextStyle(
                              fontSize: 16,
                              color: _ink,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Bring your gym to P2P. Direct partnership.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.45,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        minimumSize: const Size(0, 44),
                      ),
                      onPressed: _apply,
                      child: const Text(
                        'CLAIM ➜',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              _option(
                'Member',
                "I'm a gym member or individual user",
                Icons.directions_run,
              ),
              const SizedBox(height: 14),
              _option(
                'Staff / Admin',
                'I work at a gym — manager, trainer, staff',
                Icons.badge_outlined,
              ),
              const SizedBox(height: 14),
              _option(
                'Gym Partner',
                'I own or operate a gym facility',
                Icons.business_outlined,
              ),
              const SizedBox(height: 32),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFFE7E8EC),
                  disabledForegroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: _path == null ? null : _continue,
                child: const Text(
                  'Continue ➜',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: TextButton(
                  onPressed: () => Get.toNamed(AppRoute.loginScreen),
                  child: const Text.rich(
                    TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(color: Color(0xFF99A1B1), fontSize: 14),
                      children: [
                        TextSpan(
                          text: 'Sign In',
                          style: TextStyle(
                            color: _orange,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _option(String title, String subtitle, IconData icon) {
    final selected = _path == title;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFFFF3EE) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: selected ? _orange : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => setState(() => _path = title),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Row(
              children: [
                ExcludeSemantics(child: Icon(icon, size: 25, color: _muted)),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: _ink,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: _muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  size: 25,
                  color: selected ? _orange : const Color(0xFFD2D6DF),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

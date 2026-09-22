import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';

class NoGymTransitionScreen extends StatelessWidget {
  final VoidCallback onContinue;
  const NoGymTransitionScreen({super.key, required this.onContinue});

  static const orange = Color(0xFFFF6833);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF697386);
  static const soft = Color(0xFF99A1B1);

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF5F5F7),
    body: SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: muted,
                    padding: EdgeInsets.zero,
                  ),
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text(
                    'Back to gym selection',
                    style: TextStyle(fontWeight: AppFontWeight.section),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7E8EC),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: soft,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Text(
                    '– –',
                    style: TextStyle(color: Color(0xFFCDD2DC), fontSize: 22),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFCDD2DC)),
                  const Text(
                    '– –',
                    style: TextStyle(color: Color(0xFFFFB29A), fontSize: 22),
                  ),
                  const SizedBox(width: 14),
                  Container(
                    width: 68,
                    height: 68,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: orange,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x16000000),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      Assets.images.logo.path,
                      fit: BoxFit.contain,
                      semanticLabel: 'P2P Fit Tech AI logo',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 38),
              const Text(
                'LEAVING GYM ONBOARDING',
                style: TextStyle(
                  color: soft,
                  fontSize: 12,
                  letterSpacing: .8,
                  fontWeight: AppFontWeight.title,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You're heading to\nP2P Fit Tech AI",
                style: TextStyle(
                  color: ink,
                  fontSize: 29,
                  height: 1.2,
                  letterSpacing: -.6,
                  fontWeight: AppFontWeight.title,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "P2P Fit Tech AI has its own onboarding and subscription flow. Complete it there — you can return to connect your gym later.",
                style: TextStyle(color: muted, fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF0F1F3)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x10000000),
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WHAT HAPPENS OVER THERE',
                      style: TextStyle(
                        color: soft,
                        fontSize: 12,
                        letterSpacing: .7,
                        fontWeight: AppFontWeight.title,
                      ),
                    ),
                    const SizedBox(height: 16),
                    for (final (index, text) in const [
                      "You'll go through P2P's full onboarding",
                      'Choose your plan and complete account setup',
                      'Set up your AI trainer profile',
                      "You're in — your P2P account is ready",
                    ].indexed)
                      Padding(
                        padding: EdgeInsets.only(bottom: index == 3 ? 0 : 14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 23,
                              height: 23,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                color: orange,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: AppFontWeight.section,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                text,
                                style: const TextStyle(
                                  color: Color(0xFF4B5563),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: orange.withValues(alpha: .05),
                  border: Border.all(color: const Color(0xFFFFCABB)),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text.rich(
                  TextSpan(
                    text: 'Your info carries over. ',
                    style: TextStyle(
                      color: ink,
                      fontWeight: AppFontWeight.title,
                      fontSize: 14,
                      height: 1.7,
                    ),
                    children: [
                      TextSpan(
                        text:
                            "We'll pass your name and email so you don't retype anything.",
                        style: TextStyle(
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: orange,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onContinue,
                child: const Text(
                  'Go to P2P Fit Tech AI ➜',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 17, fontWeight: AppFontWeight.title),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "You'll continue to P2P Fit Tech AI onboarding",
                textAlign: TextAlign.center,
                style: TextStyle(color: soft, fontSize: 12),
              ),
              const SizedBox(height: 26),
              const Row(
                children: [
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text('or', style: TextStyle(color: soft)),
                  ),
                  Expanded(child: Divider(color: Color(0xFFE5E7EB))),
                ],
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4B5563),
                  minimumSize: const Size.fromHeight(54),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Pick a gym instead',
                  style: TextStyle(fontSize: 16, fontWeight: AppFontWeight.section),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

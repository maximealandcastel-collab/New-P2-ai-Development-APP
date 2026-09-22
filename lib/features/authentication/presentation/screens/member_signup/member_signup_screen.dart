import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/onboarding_gym_suggestions.dart';
import 'no_gym_transition_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/legacy_kmf_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/tenant_image.dart';

class MemberSignupScreen extends StatefulWidget {
  const MemberSignupScreen({super.key});
  @override
  State<MemberSignupScreen> createState() => _MemberSignupScreenState();
}

class _MemberSignupScreenState extends State<MemberSignupScreen> {
  static const ink = Color(0xFF111827),
      muted = Color(0xFF697386),
      orange = Color(0xFFFF6833);
  final first = TextEditingController(),
      last = TextEditingController(),
      email = TextEditingController(),
      search = TextEditingController();
  final scroll = ScrollController();
  final form = GlobalKey<FormState>();
  int step = 0, generation = 0;
  String? gender, error, cursor;
  double height = 68, weight = 165;
  final goals = <String>{};
  bool noGym = false, loading = false;
  EnterpriseGymModel? gym;
  List<EnterpriseGymModel> partners = [];
  static const goalItems = [
    (
      'Weight Loss',
      'Burn fat & boost metabolism',
      Icons.local_fire_department_outlined,
      'Lose Weight',
    ),
    (
      'Build Muscle',
      'Strength & hypertrophy',
      Icons.fitness_center,
      'Build Muscle',
    ),
    (
      'Flexibility',
      'Stretch, recover, flow',
      Icons.self_improvement,
      'Improve Flexibility',
    ),
    (
      'Endurance',
      'Stamina & heart health',
      Icons.directions_run,
      'Improve Endurance',
    ),
    (
      'Stress Relief',
      'Mental wellness & balance',
      Icons.psychology_outlined,
      'Stress Relief & Mental Health',
    ),
    (
      'Athletic Performance',
      'Sport-specific training',
      Icons.bolt_outlined,
      'Enhance Athletic Performance',
    ),
  ];
  static const popular = onboardingGymSuggestions;

  Color get accent => step >= 3 && gym != null ? gym!.brandColor : orange;
  String get heightLabel => '${height.round() ~/ 12}\'${height.round() % 12}"';
  bool get canContinue => switch (step) {
    0 =>
      first.text.trim().isNotEmpty &&
          last.text.trim().isNotEmpty &&
          email.text.trim().isNotEmpty,
    1 => gender != null,
    2 => goals.isNotEmpty,
    3 => noGym || gym != null,
    _ => true,
  };

  @override
  void dispose() {
    generation++;
    for (final controller in [first, last, email, search]) {
      controller.dispose();
    }
    scroll.dispose();
    super.dispose();
  }

  Future<void> loadGyms({bool more = false}) async {
    final version = ++generation;
    setState(() {
      loading = true;
      error = null;
      if (!more) {
        partners = [];
        cursor = null;
      }
    });
    try {
      final page = isSingleMode
          ? const EnterprisePage([legacyKmfConfiguration], null)
          : await EnterpriseService.instance.directory(
              query: search.text.trim(),
              cursor: more ? cursor : null,
            );
      final items = page.items
          .map((item) => TenantConfiguration.fromJson(item).toGym())
          .where(
            (item) =>
                !isSingleMode ||
                '${item.name} ${item.city}'.toLowerCase().contains(
                  search.text.toLowerCase(),
                ),
          )
          .toList();
      if (mounted && version == generation) {
        setState(() {
          partners = more ? [...partners, ...items] : items;
          cursor = page.nextCursor;
        });
      }
    } catch (_) {
      if (mounted && version == generation) {
        setState(() => error = 'Partner gyms couldn’t load. Try again.');
      }
    } finally {
      if (mounted && version == generation) setState(() => loading = false);
    }
  }

  void changeStep(int value) {
    FocusScope.of(context).unfocus();
    setState(() => step = value);
    if (scroll.hasClients) scroll.jumpTo(0);
    if (value == 3) loadGyms();
  }

  void next() {
    if (!canContinue) return;
    if (step == 0 && !form.currentState!.validate()) return;
    if (step == 3 && noGym) {
      openNoGymTransition();
      return;
    }
    if (step < 4) {
      changeStep(step + 1);
      return;
    }
    openAccountSetup();
  }

  Future<void> openNoGymTransition() async {
    final proceed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (transitionContext) => NoGymTransitionScreen(
          onContinue: () => Navigator.of(transitionContext).pop(true),
        ),
      ),
    );
    if (mounted && proceed == true) changeStep(4);
  }

  void openAccountSetup() {
    final draft = <String, dynamic>{
      'firstName': first.text.trim(),
      'lastName': last.text.trim(),
      'email': email.text.trim(),
      'gender': gender,
      'heightInches': height.round(),
      'weightLbs': weight.round(),
      'goals': goals.toList(),
    };
    Get.toNamed(
      AppRoute.paywallScreen,
      arguments: {
        'preSignup': true,
        'nextRoute': AppRoute.signUpScreen,
        'freeRoute': AppRoute.signUpScreen,
        'nextArguments': {
          'paywallPassed': true,
          'role': 'User',
          'memberDraft': draft,
          if (!noGym && gym?.tenantId != null) 'tenantId': gym!.tenantId,
          if (!noGym && gym != null) 'gymName': gym!.name,
        },
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Welcome to\nP2P Fit Tech',
      'Your Physical\nProfile',
      'What Are You\nTraining For?',
      'Are You a\nGym Member?',
    ];
    final labels = [
      'MEMBER SIGN UP',
      'BODY STATS',
      'YOUR GOALS',
      'CONNECT YOUR GYM',
    ];
    final descriptions = [
      'Tell us about yourself to personalize your experience.',
      'Used to personalize your workouts and track progress.',
      'Select all that apply. Your AI trainer will build around these.',
      'Connect your gym to unlock a fully branded experience.',
    ];
    return PopScope(
      canPop: step == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) changeStep(step - 1);
      },
      child: Scaffold(
        backgroundColor: step >= 3 && gym != null
            ? Color.alphaBlend(accent.withValues(alpha: .08), Colors.white)
            : const Color(0xFFF5F5F7),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                children: [
                  Row(
                    children: [
                      if (step > 0)
                        TextButton.icon(
                          onPressed: () => changeStep(step - 1),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Back'),
                          style: TextButton.styleFrom(foregroundColor: muted),
                        )
                      else
                        IconButton(
                          tooltip: 'Back to paths',
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, color: muted),
                        ),
                      const Spacer(),
                      Text(
                        'Step ${step + 1} of 5',
                        style: const TextStyle(
                          color: Color(0xFF99A1B1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (step + 1) / 5,
                      minHeight: 4,
                      color: accent,
                      backgroundColor: const Color(0xFFF0F1F3),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (step < 4) ...[
                    Text(
                      labels[step],
                      style: TextStyle(
                        color: accent,
                        fontWeight: AppFontWeight.title,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      titles[step],
                      style: const TextStyle(
                        color: ink,
                        fontSize: 30,
                        height: 1.2,
                        fontWeight: AppFontWeight.title,
                        letterSpacing: -.8,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      descriptions[step],
                      style: const TextStyle(
                        color: muted,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  if (step == 0)
                    Form(
                      key: form,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: field('FIRST NAME', 'Alex', first),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: field('LAST NAME', 'Johnson', last),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          field(
                            'EMAIL ADDRESS',
                            'alex@email.com',
                            email,
                            isEmail: true,
                          ),
                        ],
                      ),
                    ),
                  if (step == 1) ...[
                    caption('GENDER'),
                    const SizedBox(height: 12),
                    for (final row in [
                      ['Male', 'Female'],
                      ['Non-binary', 'Prefer not to say'],
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            for (
                              var index = 0;
                              index < row.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: gender == row[index]
                                        ? accent
                                        : Colors.white,
                                    foregroundColor: gender == row[index]
                                        ? Colors.white
                                        : muted,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 16,
                                    ),
                                    side: BorderSide(
                                      color: gender == row[index]
                                          ? accent
                                          : const Color(0xFFE5E7EB),
                                      width: 2,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  onPressed: () =>
                                      setState(() => gender = row[index]),
                                  child: Text(
                                    row[index],
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: AppFontWeight.section,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    slider(
                      'Height',
                      heightLabel,
                      height,
                      54,
                      84,
                      '54in',
                      '84in',
                      (value) => setState(() => height = value),
                    ),
                    const SizedBox(height: 16),
                    slider(
                      'Weight',
                      '${weight.round()} lbs',
                      weight,
                      90,
                      400,
                      '90lbs',
                      '400lbs',
                      (value) => setState(() => weight = value),
                    ),
                  ],
                  if (step == 2) ...[
                    for (var i = 0; i < goalItems.length; i += 2)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: goalCard(i)),
                              const SizedBox(width: 12),
                              Expanded(child: goalCard(i + 1)),
                            ],
                          ),
                        ),
                      ),
                  ],
                  if (step == 3) ...gymChoices(),
                  if (step == 4) ...summary(),
                  const SizedBox(height: 32),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE7E8EC),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: canContinue ? next : null,
                    child: Text(
                      step == 4
                          ? (noGym
                                ? 'Go to My Dashboard ➜'
                                : 'Continue to Create Account ➜')
                          : 'Continue ➜',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: AppFontWeight.title,
                      ),
                    ),
                  ),
                  if (step == 0) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => Get.toNamed(AppRoute.loginScreen),
                      child: const Text.rich(
                        TextSpan(
                          text: 'Already have an account? ',
                          style: TextStyle(color: Color(0xFF99A1B1)),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: TextStyle(
                                color: orange,
                                fontWeight: AppFontWeight.section,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget caption(String text) => Text(
    text,
    style: const TextStyle(
      color: muted,
      fontSize: 12,
      fontWeight: AppFontWeight.title,
      letterSpacing: .8,
    ),
  );
  Widget field(
    String label,
    String hint,
    TextEditingController controller, {
    bool isEmail = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      caption(label),
      const SizedBox(height: 10),
      TextFormField(
        controller: controller,
        key: ValueKey(label),
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.name,
        textCapitalization: isEmail
            ? TextCapitalization.none
            : TextCapitalization.words,
        onChanged: (_) => setState(() {}),
        validator: (value) {
          if ((value ?? '').trim().isEmpty) return 'Required';
          if (isEmail &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim())) {
            return 'Enter a valid email';
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide(color: accent),
          ),
        ),
      ),
    ],
  );
  Widget slider(
    String title,
    String label,
    double value,
    double min,
    double max,
    String low,
    String high,
    ValueChanged<double> changed,
  ) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(color: muted, fontWeight: AppFontWeight.section),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: ink,
                fontSize: 21,
                fontWeight: AppFontWeight.title,
              ),
            ),
          ],
        ),
        Slider(
          label: label,
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: accent,
          onChanged: changed,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(low, style: const TextStyle(color: Color(0xFFB9C0CC))),
            Text(high, style: const TextStyle(color: Color(0xFFB9C0CC))),
          ],
        ),
      ],
    ),
  );
  Widget goalCard(int index) {
    final item = goalItems[index];
    final selected = goals.contains(item.$4);
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? const Color(0xFFFFEEE7) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: selected ? accent : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => setState(() {
            if (!goals.add(item.$4)) goals.remove(item.$4);
          }),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(item.$3, size: 26, color: muted),
                const SizedBox(height: 14),
                Text(
                  item.$1,
                  style: const TextStyle(
                    color: ink,
                    fontSize: 16,
                    fontWeight: AppFontWeight.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.$2,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: accent,
                      size: 18,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> gymChoices() {
    final choices = [
      ...partners,
      ...popular
          .where(
            (item) =>
                item.$1.toLowerCase().contains(
                  search.text.trim().toLowerCase(),
                ) &&
                !partners.any(
                  (p) => p.name.toLowerCase() == item.$1.toLowerCase(),
                ),
          )
          .map(
            (item) => EnterpriseGymModel(
              id: item.$1,
              name: item.$1,
              initials: item.$1[0],
              category: 'Gym',
              memberCount: '',
              brandColor: item.$3,
              accentColor: item.$3,
              remoteLogoUrl: item.$2,
            ),
          ),
    ];
    return [
      TextField(
        controller: search,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => loadGyms(),
        decoration: InputDecoration(
          hintText: 'Search gyms (e.g. Equinox, LA Fitness...)',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: 'Search partner gyms',
            onPressed: loadGyms,
            icon: const Icon(Icons.arrow_forward),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 22),
      caption('POPULAR GYMS'),
      const SizedBox(height: 6),
      const Text(
        'Popular suggestions include gyms not yet partnered with P2P.',
        style: TextStyle(fontSize: 11, color: muted),
      ),
      const SizedBox(height: 12),
      if (loading) const LinearProgressIndicator(),
      if (error != null) TextButton(onPressed: loadGyms, child: Text(error!)),
      for (var i = 0; i < choices.length; i += 3)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < 3; j++) ...[
                  if (j > 0) const SizedBox(width: 8),
                  Expanded(
                    child: i + j < choices.length
                        ? gymCard(choices[i + j])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
      if (choices.isEmpty && !loading)
        const Text('No gyms found. Continue with P2P or try another search.'),
      if (cursor != null)
        TextButton(
          onPressed: loading ? null : () => loadGyms(more: true),
          child: const Text('More partner gyms'),
        ),
      const SizedBox(height: 12),
      OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: noGym
              ? accent.withValues(alpha: .08)
              : Colors.transparent,
          foregroundColor: muted,
          padding: const EdgeInsets.all(18),
          side: BorderSide(
            color: noGym ? accent : const Color(0xFFD2D6DF),
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        onPressed: () {
          setState(() {
            noGym = true;
            gym = null;
          });
          openNoGymTransition();
        },
        child: const Text(
          'No gym — Continue with P2P Fit Tech AI',
          textAlign: TextAlign.center,
        ),
      ),
      if (gym != null)
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            gym!.isActivated
                ? 'Membership verification required.'
                : 'Gym not partnered. You can continue with P2P.',
            style: const TextStyle(color: muted),
          ),
        ),
    ];
  }

  Widget gymLogo(EnterpriseGymModel item) => item.logoUrl.isNotEmpty
      ? TenantImage(item.logoUrl, fit: BoxFit.contain)
      : Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: item.brandColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            item.initials,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: AppFontWeight.title,
            ),
          ),
        );
  Widget gymCard(EnterpriseGymModel item) => Semantics(
    selected: gym?.id == item.id,
    button: true,
    child: Material(
      color: gym?.id == item.id ? accent.withValues(alpha: .1) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: gym?.id == item.id ? accent : const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() {
          gym = item;
          noGym = false;
        }),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(width: 54, height: 54, child: gymLogo(item)),
              const SizedBox(height: 8),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: AppFontWeight.section,
                  color: muted,
                ),
              ),
              if (gym?.id == item.id)
                Icon(Icons.check_circle_outline, size: 17, color: accent),
            ],
          ),
        ),
      ),
    ),
  );
  List<Widget> summary() => [
    Center(
      child: Container(
        width: 86,
        height: 86,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(26),
        ),
        child: gym == null
            ? Image.asset(Assets.images.logo.path)
            : gymLogo(gym!),
      ),
    ),
    const SizedBox(height: 26),
    Text(
      gym?.name.toUpperCase() ?? 'P2P FIT TECH AI',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: accent,
        fontWeight: AppFontWeight.title,
        letterSpacing: 1,
      ),
    ),
    const SizedBox(height: 18),
    Text(
      'Welcome,\n${first.text.trim()}!',
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: ink,
        fontSize: 30,
        fontWeight: AppFontWeight.title,
      ),
    ),
    const SizedBox(height: 18),
    Text(
      gym == null
          ? 'Your fitness profile is ready. Create your account to get started.'
          : gym!.isActivated
          ? 'Your gym is selected. Create your account to verify membership and start training.'
          : '${gym!.name} isn’t partnered yet. Create your P2P account to start training.',
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16, color: muted, height: 1.5),
    ),
    const SizedBox(height: 20),
    Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: .25)),
      ),
      child: Column(
        children: [
          for (final row in [
            ('Height', heightLabel),
            ('Weight', '${weight.round()} lbs'),
            (
              'Goals',
              goals
                  .map((g) {
                    final item = goalItems.firstWhere((item) => item.$4 == g);
                    return item.$1;
                  })
                  .join(', '),
            ),
            if (gym != null) ('Gym', gym!.name),
          ])
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(row.$1, style: const TextStyle(color: muted)),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      row.$2,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: ink,
                        fontWeight: AppFontWeight.section,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  ];
}

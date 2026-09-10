import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import '../../data/models/enterprise_gym_model.dart';
import '../../data/models/legacy_kmf_configuration.dart';
import '../../data/models/tenant_configuration.dart';
import '../../data/models/onboarding_gym_suggestions.dart';
import '../../data/services/enterprise_service.dart';
import '../widgets/tenant_image.dart';

class StaffSignupScreen extends StatefulWidget {
  const StaffSignupScreen({super.key});
  @override
  State<StaffSignupScreen> createState() => _StaffSignupScreenState();
}

class _StaffSignupScreenState extends State<StaffSignupScreen> {
  static const ink = Color(0xFF111827),
      muted = Color(0xFF697386),
      soft = Color(0xFF99A1B1),
      orange = Color(0xFFFF6833),
      black = Color(0xFF191919);
  static const roles = [
    (
      'Gym Manager',
      'Full dashboard access',
      Icons.business_outlined,
      'gym_manager',
    ),
    (
      'Head Trainer',
      'Member & class management',
      Icons.fitness_center,
      'head_trainer',
    ),
    ('Front Desk', 'Check-ins & bookings', Icons.person_outline, 'front_desk'),
    (
      'Personal Trainer',
      'Client sessions & programs',
      Icons.bolt_outlined,
      'personal_trainer',
    ),
  ];
  final name = TextEditingController(),
      email = TextEditingController(),
      code = TextEditingController(),
      search = TextEditingController();
  final scroll = ScrollController();
  final form = GlobalKey<FormState>();
  int step = 0, generation = 0;
  String? role, error, directoryError, cursor, receipt;
  bool loading = false, sending = false;
  EnterpriseGymModel? gym;
  List<EnterpriseGymModel> partners = [];
  bool get valid => switch (step) {
    0 => name.text.trim().isNotEmpty && email.text.trim().isNotEmpty,
    1 => role != null,
    _ => gym != null,
  };

  @override
  void dispose() {
    generation++;
    for (final controller in [name, email, code, search]) {
      controller.dispose();
    }
    scroll.dispose();
    super.dispose();
  }

  Future<void> loadGyms({bool more = false}) async {
    final version = ++generation;
    setState(() {
      loading = true;
      directoryError = null;
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
          .toList();
      if (mounted && version == generation)
        setState(() {
          partners = more ? [...partners, ...items] : items;
          cursor = page.nextCursor;
        });
    } catch (_) {
      if (mounted && version == generation)
        setState(
          () => directoryError = 'Partner gyms couldn’t load. Please retry.',
        );
    } finally {
      if (mounted && version == generation) setState(() => loading = false);
    }
  }

  void go(int index) {
    FocusScope.of(context).unfocus();
    setState(() {
      step = index;
      error = null;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
    if (index == 2) loadGyms();
  }

  Future<void> next() async {
    if (!valid || sending) return;
    if (step == 0 && !form.currentState!.validate()) return;
    if (step < 3) {
      go(step + 1);
      return;
    }
    setState(() {
      sending = true;
      error = null;
    });
    try {
      final id = await EnterpriseService.instance.requestStaffAccess({
        'fullName': name.text.trim(),
        'workEmail': email.text.trim(),
        'requestedRole': role,
        'gymName': gym!.name,
        if (gym!.tenantId != null) 'tenantId': gym!.tenantId,
        if (code.text.trim().isNotEmpty) 'accessCode': code.text.trim(),
      });
      if (mounted) {
        code.clear();
        setState(() => receipt = id);
      }
    } catch (_) {
      if (mounted)
        setState(
          () => error =
              'We couldn’t send your request. Check your details or access code and try again.',
        );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Staff\nSign Up', "What's Your\nRole?", 'Select\nYour Gym'];
    final labels = ['STAFF ACCOUNT', 'YOUR ROLE', 'YOUR GYM'];
    final descriptions = [
      'For gym owners, managers & authorized staff members.',
      'Choose your requested dashboard access level. Your gym must approve it.',
      "Connect your staff account to your gym's P2P dashboard.",
    ];
    return PopScope(
      canPop: step == 0 && !sending,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !sending) {
          if (receipt != null) {
            Navigator.pop(context);
          } else {
            go(step - 1);
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
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
                      TextButton.icon(
                        onPressed: sending
                            ? null
                            : () {
                                if (step == 0 || receipt != null) {
                                  Navigator.pop(context);
                                } else {
                                  go(step - 1);
                                }
                              },
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Back'),
                        style: TextButton.styleFrom(foregroundColor: muted),
                      ),
                      const Spacer(),
                      Text(
                        'Step ${step + 1} of 4',
                        style: const TextStyle(
                          color: soft,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (step + 1) / 4,
                      minHeight: 4,
                      color: black,
                      backgroundColor: const Color(0xFFF0F1F3),
                    ),
                  ),
                  const SizedBox(height: 30),
                  if (step < 3) ...[
                    caption(labels[step]),
                    const SizedBox(height: 12),
                    Text(
                      titles[step],
                      style: const TextStyle(
                        fontSize: 34,
                        height: 1.2,
                        color: ink,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -.7,
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
                          field('FULL NAME', 'Jordan Smith', name),
                          const SizedBox(height: 20),
                          field(
                            'WORK EMAIL',
                            'jordan@yourgymdomain.com',
                            email,
                            isEmail: true,
                          ),
                        ],
                      ),
                    ),
                  if (step == 1)
                    ...roles.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: Semantics(
                          selected: role == item.$4,
                          button: true,
                          child: Material(
                            color: role == item.$4
                                ? const Color(0xFFFFF0EA)
                                : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: role == item.$4
                                    ? orange
                                    : const Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => setState(() => role = item.$4),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Row(
                                  children: [
                                    Icon(item.$3, size: 26, color: muted),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.$1,
                                            style: const TextStyle(
                                              color: ink,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            item.$2,
                                            style: const TextStyle(
                                              color: muted,
                                              fontSize: 14,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Icon(
                                      role == item.$4
                                          ? Icons.radio_button_checked
                                          : Icons.radio_button_unchecked,
                                      color: role == item.$4
                                          ? orange
                                          : const Color(0xFFD2D6DF),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (step == 2) ...gymChoices(),
                  if (step == 3) ...[
                    Center(
                      child: Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: ink,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      receipt == null ? 'Access\nPending' : 'Request\nReceived',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 34,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      receipt == null
                          ? (gym!.isActivated
                                ? 'Your ${gym!.name} manager can provide an access code to verify your staff account.'
                                : '${gym!.name} is not yet partnered with P2P. Access requires gym partnership and manager approval.')
                          : 'Your request is pending review. Gym access is available only after your identity and role are verified.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: muted,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (receipt == null) ...[
                      field(
                        'ENTER ACCESS CODE (OPTIONAL)',
                        'STAFF-XXXX',
                        code,
                        optional: true,
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'No code? Continue to submit your request for review by the gym manager.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: soft,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ] else
                      Text(
                        'Reference: $receipt',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: muted),
                      ),
                  ],
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(height: 32),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFE7E8EC),
                      disabledForegroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: receipt != null
                        ? () => Get.toNamed(AppRoute.loginScreen)
                        : valid && !sending
                        ? next
                        : null,
                    child: sending
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            receipt != null
                                ? 'Sign In ➜'
                                : step == 3
                                ? 'Request Access ➜'
                                : 'Continue ➜',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
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
      color: soft,
      fontWeight: FontWeight.w800,
      fontSize: 12,
      letterSpacing: .7,
    ),
  );
  Widget field(
    String label,
    String hint,
    TextEditingController controller, {
    bool isEmail = false,
    bool optional = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      caption(label),
      const SizedBox(height: 12),
      TextFormField(
        key: ValueKey(label),
        controller: controller,
        enabled: !sending,
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
        textCapitalization: isEmail
            ? TextCapitalization.none
            : optional
            ? TextCapitalization.characters
            : TextCapitalization.words,
        autocorrect: !optional && !isEmail,
        enableSuggestions: !optional,
        onChanged: (_) => setState(() {}),
        textAlign: optional ? TextAlign.center : TextAlign.start,
        validator: (value) {
          if (optional) return null;
          if ((value ?? '').trim().isEmpty) return 'Required';
          if (isEmail &&
              !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value!.trim()))
            return 'Enter a valid work email';
          return null;
        },
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: soft),
          ),
        ),
      ),
    ],
  );

  List<Widget> gymChoices() {
    final suggestions = [
      ...onboardingGymSuggestions,
      ('Orangetheory', '', const Color(0xFFFF7900)),
      ('Pure Barre', '', const Color(0xFF991B1B)),
      ('Jazzercise', '', const Color(0xFFCDBDA7)),
      ('NYSC', '', const Color(0xFFD71920)),
      ('Fitness Factory', '', const Color(0xFF123E3D)),
      ('24 Hour Fitness', '', Colors.black),
      ("Gold's Gym", '', const Color(0xFF171717)),
      ('Anytime Fitness', '', const Color(0xFF752B90)),
    ];
    final gyms =
        [
              ...partners,
              ...suggestions
                  .where(
                    (item) => !partners.any(
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
            ]
            .where(
              (item) => '${item.name} ${item.city}'.toLowerCase().contains(
                search.text.trim().toLowerCase(),
              ),
            )
            .toList();
    return [
      TextField(
        controller: search,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => loadGyms(),
        decoration: InputDecoration(
          hintText: 'Search gyms',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            tooltip: 'Search partner gyms',
            onPressed: loadGyms,
            icon: const Icon(Icons.arrow_forward),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      const SizedBox(height: 12),
      const Text(
        'Popular suggestions include gyms not yet partnered with P2P.',
        style: TextStyle(color: muted, fontSize: 11),
      ),
      const SizedBox(height: 12),
      if (loading) const LinearProgressIndicator(),
      if (directoryError != null)
        TextButton(onPressed: loadGyms, child: Text(directoryError!)),
      for (var i = 0; i < gyms.length; i += 3)
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < 3; j++) ...[
                  if (j > 0) const SizedBox(width: 10),
                  Expanded(
                    child: i + j < gyms.length
                        ? gymCard(gyms[i + j])
                        : const SizedBox(),
                  ),
                ],
              ],
            ),
          ),
        ),
      if (gyms.isEmpty && !loading)
        const Text('No gyms found. Try another search.'),
      if (cursor != null)
        TextButton(
          onPressed: loading ? null : () => loadGyms(more: true),
          child: const Text('More partner gyms'),
        ),
    ];
  }

  Widget gymCard(EnterpriseGymModel item) => Semantics(
    selected: gym?.id == item.id,
    button: true,
    child: Material(
      color: gym?.id == item.id ? const Color(0xFFFFF0EA) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: gym?.id == item.id ? orange : const Color(0xFFE5E7EB),
          width: 2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => setState(() {
          if (gym?.id != item.id) code.clear();
          gym = item;
        }),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              SizedBox(
                width: 54,
                height: 54,
                child: item.logoUrl.isNotEmpty
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
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                item.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: muted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (gym?.id == item.id)
                const Icon(Icons.check_circle_outline, size: 17, color: orange),
            ],
          ),
        ),
      ),
    ),
  );
}

import '../../services/gym_location_service.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import '../../data/services/enterprise_service.dart';
import '../../data/models/tenant_configuration.dart';
import '../../data/models/enterprise_gym_model.dart';
import '../widgets/tenant_image.dart';

class GymApplicationScreen extends StatefulWidget {
  final EnterpriseGymModel? initialGym;
  const GymApplicationScreen({super.key, this.initialGym});
  @override
  State<GymApplicationScreen> createState() => _GymApplicationScreenState();
}

class _GymApplicationScreenState extends State<GymApplicationScreen> {
  static const orange = Color(0xFFFF6833),
      ink = Color(0xFF111827),
      muted = Color(0xFF697386),
      soft = Color(0xFF99A1B1);
  static const types = [
    'Full-Service Gym',
    'Boutique Studio',
    'CrossFit Affiliate',
    'Run / Cycling Club',
    'Martial Arts',
    'Swim / Aquatics',
    'Corporate Wellness',
    'Other',
  ];
  static const palette = [
    0xFFFF6B35,
    0xFFE53E3E,
    0xFF0056AB,
    0xFF1A1A1A,
    0xFF287F7F,
    0xFF752B90,
    0xFF2B6CB0,
    0xFF276749,
    0xFFC05621,
    0xFFB7791F,
    0xFFCC0000,
    0xFF553C9A,
  ];
  final fields = <String, TextEditingController>{
    for (final key in [
      'gymName',
      'website',
      'logoUrl',
      'shortCode',
      'city',
      'state',
      'representativeName',
      'workEmail',
      'phone',
    ])
      key: TextEditingController(),
  };
  final primary = TextEditingController(text: '#FF6B35'),
      secondary = TextEditingController(text: '#1A1A1A');
  final addressSearch = TextEditingController();
  double? searchLat,searchLng;
  final form = GlobalKey<FormState>();
  final scroll = ScrollController();
  Timer? debounce;
  int step = 0, generation = 0;
  double locations = 1, members = 500;
  String? gymType, tier, tenantId, receipt, error, searchError, cursor;
  bool loading = false, sending = false, authorized = false, codeEdited = false;
  bool uploadingLogo = false;
  XFile? selectedLogo;
  List<TenantConfiguration> matches = [];
  String text(String key) => fields[key]!.text.trim();
  Color? parseColor(String value) =>
      RegExp(r'^#[0-9a-fA-F]{6}$').hasMatch(value)
      ? Color(0xFF000000 | int.parse(value.substring(1), radix: 16))
      : null;
  Color get brand => parseColor(primary.text) ?? orange;
  Color get brandText =>
      ThemeData.estimateBrightnessForColor(brand) == Brightness.dark
      ? Colors.white
      : ink;
  bool get valid => !uploadingLogo && switch (step) {
    0 => text('gymName').isNotEmpty && gymType != null,
    1 =>
      RegExp(r'^[A-Za-z0-9]{2,5}$').hasMatch(text('shortCode')) &&
          parseColor(primary.text) != null &&
          parseColor(secondary.text) != null,
    2 => text('city').isNotEmpty && text('state').isNotEmpty,
    3 =>
      tier != null &&
          text('representativeName').isNotEmpty &&
          text('workEmail').isNotEmpty &&
          text('phone').isNotEmpty &&
          authorized,
    _ => true,
  };

  @override
  void initState() {
    super.initState();
    final gym = widget.initialGym;
    if (gym != null) {
      fields['gymName']!.text = gym.name;
      tenantId = gym.tenantId;
      fields['logoUrl']!.text = gym.remoteLogoUrl;
      final shortCode = gym.initials.replaceAll(
        RegExp(r'[^A-Za-z0-9]'),
        '',
      );
      fields['shortCode']!.text = shortCode.substring(
        0,
        shortCode.length.clamp(0, 5),
      );
      fields['city']!.text = gym.city;
      primary.text = '#${gym.brandColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      secondary.text = '#${gym.accentColor.toARGB32().toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';
      gymType = types.contains(gym.category) ? gym.category : 'Other';
      codeEdited = true;
    }
    loadGyms();
  }

  @override
  void dispose() {
    debounce?.cancel();
    generation++;
    for (final controller in [...fields.values, primary, secondary, addressSearch]) {
      controller.dispose();
    }
    scroll.dispose();
    super.dispose();
  }

  void gymNameChanged() {
    tenantId = null;
    if (!codeEdited) {
      final words = text('gymName')
          .toUpperCase()
          .replaceAll(RegExp(r'[^A-Z0-9 ]'), '')
          .split(' ')
          .where((s) => s.isNotEmpty)
          .toList();
      final code = words.length > 1
          ? words.map((w) => w[0]).join()
          : words.join();
      fields['shortCode']!.text = code.isEmpty
          ? ''
          : (code.length == 1 ? '${code}G' : code).substring(
              0,
              (code.length == 1 ? 2 : code.length).clamp(0, 5),
            );
    }
    setState(() {});
  }

  void addressChanged() {
    searchLat=null;searchLng=null;
    debounce?.cancel();
    generation++;
    setState(() {
      matches = [];
      loading = true;
      searchError = null;
    });
    debounce = Timer(const Duration(milliseconds: 500), loadGyms);
  }

  Future<void> pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 88,
    );
    if (picked == null || !mounted) return;
    setState(() {
      selectedLogo = picked;
      uploadingLogo = true;
      error = null;
    });
    try {
      final logoUrl = await EnterpriseService.instance.uploadGymLogo(picked.path);
      if (!mounted) return;
      setState(() => fields['logoUrl']!.text = logoUrl);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        selectedLogo = null;
        error = 'We couldn’t upload that logo. Choose a JPG, PNG, or WebP image and try again.';
      });
    } finally {
      if (mounted) setState(() => uploadingLogo = false);
    }
  }

  Future<void> loadGyms({bool more = false}) async {
    final version = ++generation;
    setState(() {
      loading = true;
      searchError = null;
      if (!more) {
        matches = [];
        cursor = null;
      }
    });
    try {
      final items = await EnterpriseService.instance.searchFacilities(addressSearch.text,latitude:searchLat,longitude:searchLng);
      if (mounted && version == generation)
        setState(() {
          matches = more ? [...matches, ...items] : items;
          cursor = null;
        });
    } catch (_) {
      if (mounted && version == generation)
        setState(
          () => searchError =
              'Search is unavailable. Retry or submit your gym details for review.',
        );
    } finally {
      if (mounted && version == generation) setState(() => loading = false);
    }
  }

  void go(int value) {
    FocusScope.of(context).unfocus();
    setState(() {
      step = value;
      error = null;
    });
    if (scroll.hasClients) scroll.jumpTo(0);
  }

  Future<void> next() async {
    if (!valid || sending) return;
    if (!(form.currentState?.validate() ?? false)) return;
    if (step < 3) {
      go(step + 1);
      return;
    }
    setState(() {
      sending = true;
      error = null;
    });
    try {
      final id = receipt ?? await EnterpriseService.instance.submitGymApplication({
        'schemaVersion': 2,
        for (final entry in fields.entries) entry.key: entry.value.text.trim(),
        'shortCode': text('shortCode').toUpperCase(),
        'primaryColor': primary.text.toUpperCase(),
        'secondaryColor': secondary.text.toUpperCase(),
        'gymType': gymType,
        'locationCount': locations.round(),
        'activeMembers': members.round(),
        'tier': tier,
        'authorizedRepresentative': authorized,
        'reviewConsent': authorized,
        if (tenantId != null) 'tenantId': tenantId,
      });
      receipt = id;
      if (mounted) {
        receipt = id;
        go(4);
      }
    } catch (_) {
      if (mounted)
        setState(
          () => error =
              receipt != null
                  ? 'Your application was submitted. Open My Applications to check its status.'
                  : 'We couldn’t submit your partnership. Your details are still here. Please try again.',
        );
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Claim Your\nGym',
      'Build Your\nWrapper',
      'Your\nOperations',
      'Simple,\nTransparent.',
    ];
    final labels = [
      'GYM PARTNERSHIP',
      'BRAND SETUP',
      'LOCATION & SCALE',
      'PRICING',
    ];
    final descriptions = [
      'Search for your gym to request a claim. If it’s not listed, submit it for a new branded gym experience.',
      'Preview your gym inside P2P. Add your logo, brand colors, and short code.',
      'Help us understand the size and scope of your gym.',
      'No monthly fee. Choose how much of your story we tell.',
    ];
    return PopScope(
      canPop: !sending && (receipt != null || step == 0 || step == 4),
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !sending) go(step - 1);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: form,
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
                                  if (receipt != null || step == 0 || step == 4) {
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
                          'Step ${step + 1} of 5',
                          style: const TextStyle(
                            color: soft,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (step + 1) / 5,
                        minHeight: 4,
                        color: orange,
                        backgroundColor: const Color(0xFFF0F1F3),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (step < 4) ...[
                      caption(labels[step], color: orange),
                      const SizedBox(height: 12),
                      Text(
                        titles[step],
                        style: const TextStyle(
                          color: ink,
                          fontSize: 34,
                          height: 1.2,
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
                      const SizedBox(height: 30),
                    ],
                    if (step == 0) ...[
                      TextField(controller:addressSearch,decoration:const InputDecoration(labelText:'Find gyms by US address or ZIP',hintText:'123 Main St, Austin, TX or 78701'),onChanged:(_)=>addressChanged()),
                      TextButton.icon(icon:const Icon(Icons.my_location),label:const Text('Use my location'),onPressed:loading?null:() async {
                        debounce?.cancel();setState(()=>loading=true);
                        final position=await GymLocationService().getCurrentPosition();
                        if(!mounted)return;
                        if(position==null){setState((){loading=false;searchError='Location unavailable. Enter a US address or ZIP.';});return;}
                        searchLat=position.latitude;searchLng=position.longitude;addressSearch.clear();await loadGyms();
                      }),
                      if(matches.isNotEmpty)const Text('Google Maps'),

                      field(
                        'gymName',
                        'GYM NAME',
                        'Your gym name',
                        onChanged: (_) => gymNameChanged(),
                      ),
                      if (loading) const LinearProgressIndicator(),
                      if (searchError != null)
                        TextButton(
                          onPressed: loadGyms,
                          child: Text(searchError!),
                        ),
                      ...matches.map(
                        (g) => Card(
                          elevation: 0,
                          color: Colors.white,
                          child: ListTile(
                            title: Text(g.name),
                            subtitle: Text(
                              g.locations.isNotEmpty &&
                                      (g.locations.first['address'] as String? ?? '').isNotEmpty
                                  ? "${g.locations.first['address']}\n${(g.locations.first['attributions'] as List? ?? []).join(', ')}\nRequest a claim • ownership verification required"
                                  : 'Request a claim • ownership verification required',
                            ),
                            trailing: Icon(
                              tenantId == g.id
                                  ? Icons.check_circle
                                  : Icons.radio_button_unchecked,
                              color: orange,
                            ),
                            onTap: () {
                              fields['gymName']!.text = g.name;
                              gymNameChanged();
                              setState(() {
                                tenantId = g.id;
                                fields['logoUrl']!.text = g.logoUrl.startsWith('https://') ? g.logoUrl : '';
                                primary.text = hex(g.primary);
                                secondary.text = hex(g.secondary);
                                if (g.locations.isNotEmpty) {
                                  fields['city']!.text = g.locations.first['city'] as String? ?? '';
                                  fields['state']!.text = g.locations.first['state'] as String? ?? '';
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      if (cursor != null)
                        TextButton(
                          onPressed: loading
                              ? null
                              : () => loadGyms(more: true),
                          child: const Text('More gyms'),
                        ),
                      if (text('gymName').isNotEmpty &&
                          tenantId == null &&
                          !loading)
                        Container(
                          margin: const EdgeInsets.only(bottom: 18),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: orange.withValues(alpha: .06),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFFFCABB)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '＋ Add “${text('gymName')}” to P2P',
                                style: const TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Submit your gym for review and a new branded experience.',
                                style: TextStyle(color: muted),
                              ),
                            ],
                          ),
                        ),
                      field(
                        'website',
                        'WEBSITE (OPTIONAL)',
                        'www.yourgym.com',
                        optional: true,
                      ),
                      caption('GYM TYPE'),
                      const SizedBox(height: 12),
                      for (var i = 0; i < types.length; i += 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                for (var j = 0; j < 2; j++) ...[
                                  if (j > 0) const SizedBox(width: 10),
                                  Expanded(
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: gymType == types[i + j]
                                            ? orange
                                            : Colors.white,
                                        foregroundColor: gymType == types[i + j]
                                            ? Colors.white
                                            : muted,
                                        side: BorderSide(
                                          color: gymType == types[i + j]
                                              ? orange
                                              : const Color(0xFFE5E7EB),
                                          width: 2,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 14,
                                        ),
                                      ),
                                      onPressed: () => setState(
                                        () => gymType = types[i + j],
                                      ),
                                      child: Text(
                                        types[i + j],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                    ],
                    if (step == 1) ...[
                      logoPicker(),
                      const SizedBox(height: 18),
                      preview(),
                      const SizedBox(height: 24),
                      field(
                        'shortCode',
                        'GYM SHORT CODE (2–5 CHARACTERS)',
                        'GYM',
                        onChanged: (_) {
                          codeEdited = true;
                          setState(() {});
                        },
                      ),
                      caption('PRIMARY BRAND COLOR'),
                      const SizedBox(height: 12),
                      for (var i = 0; i < palette.length; i += 6)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              for (var j = 0; j < 6; j++) ...[
                                if (j > 0) const SizedBox(width: 8),
                                Expanded(
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Semantics(
                                      selected: brand == Color(palette[i + j]),
                                      button: true,
                                      label:
                                          'Brand color ${hex(Color(palette[i + j]))}',
                                      child: InkWell(
                                        onTap: () => setState(
                                          () => primary.text = hex(
                                            Color(palette[i + j]),
                                          ),
                                        ),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Color(palette[i + j]),
                                            borderRadius: BorderRadius.circular(
                                              15,
                                            ),
                                            border: Border.all(
                                              color:
                                                  brand == Color(palette[i + j])
                                                  ? ink
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      colorField(primary, 'Primary color hex'),
                      const SizedBox(height: 20),
                      caption('ACCENT / SECONDARY COLOR'),
                      const SizedBox(height: 12),
                      colorField(secondary, 'Secondary color hex'),
                    ],
                    if (step == 2) ...[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: field('city', 'CITY', 'Denver')),
                          const SizedBox(width: 12),
                          Expanded(
                            child: field('state', 'STATE / REGION', 'CO'),
                          ),
                        ],
                      ),
                      slider(
                        'Number of Locations',
                        locations,
                        1,
                        50,
                        (value) => setState(() => locations = value),
                      ),
                      const SizedBox(height: 16),
                      slider(
                        'Active Members',
                        members,
                        50,
                        10000,
                        (value) => setState(() => members = value),
                      ),
                    ],
                    if (step == 3) ...[
                      plan(
                        'starter',
                        'Enterprise Starter',
                        'Launch your gym on P2P',
                        'App Store pricing',
                        [
                          'Your logo and gym information in P2P',
                          'Full P2P AI engine included',
                          'Members can find and join your gym',
                          'Gym member experience',
                        ],
                      ),
                      const SizedBox(height: 14),
                      plan(
                        'pro',
                        'Enterprise Pro',
                        'Operate and grow your community',
                        'App Store pricing',
                        [
                          'Custom branded gym experience',
                          'Trainer and member management',
                          'AI trainer matching for your gym',
                          'Community clubs and events',
                          'Analytics and revenue insights',
                        ],
                      ),
                      const SizedBox(height: 26),
                      caption('OWNER / CONTACT INFO'),
                      const SizedBox(height: 16),
                      field('representativeName', 'FULL NAME', 'Full Name'),
                      field('workEmail', 'EMAIL ADDRESS', 'Email Address'),
                      field('phone', 'PHONE NUMBER', 'Phone Number'),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: authorized,
                        onChanged: sending
                            ? null
                            : (value) =>
                                  setState(() => authorized = value ?? false),
                        title: const Text(
                          'I am authorized to represent this gym and consent to partnership and licensing review.',
                          style: TextStyle(color: muted, fontSize: 13),
                        ),
                      ),
                      const Text(
                        'Submit your application first. After ownership verification, subscribe with Apple from My Applications. No payment is taken on submission.',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                    ],
                    if (step == 4) ...[
                      preview(complete: true),
                      const SizedBox(height: 28),
                      caption('PARTNERSHIP SUBMITTED', color: orange),
                      const SizedBox(height: 16),
                      const Text(
                        'You’re on your way!',
                        style: TextStyle(
                          color: ink,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your branded preview for ${text('gymName')} is ready. Your partnership is pending review; we’ll verify ownership and licensing before activation.',
                        style: const TextStyle(
                          color: muted,
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: brand.withValues(alpha: .05),
                          border: Border.all(
                            color: brand.withValues(alpha: .25),
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            for (final row in [
                              ('Gym', text('gymName')),
                              ('Short Code', text('shortCode').toUpperCase()),
                              (
                                'Colors',
                                '${primary.text.toUpperCase()} + ${secondary.text.toUpperCase()}',
                              ),
                              ('Location', '${text('city')}, ${text('state')}'),
                              ('Locations', '${locations.round()}'),
                              ('Members', '${members.round()}'),
                              (
                                'Tier',
                                tier == 'starter'
                                    ? 'Enterprise Starter'
                                    : 'Enterprise Pro',
                              ),
                              (
                                'Added',
                                tenantId == null
                                    ? 'New gym application'
                                    : 'Existing gym claim',
                              ),
                              ('Status', 'Pending review'),
                              ('Reference', receipt ?? ''),
                            ])
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 7,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      row.$1,
                                      style: const TextStyle(color: muted),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: Text(
                                        row.$2,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                          color: ink,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
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
                    const SizedBox(height: 28),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: step == 4 ? brand : orange,
                        foregroundColor: step == 4 ? brandText : Colors.white,
                        disabledBackgroundColor: const Color(0xFFE7E8EC),
                        disabledForegroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(58),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: step == 4
                          ? () => Navigator.pop(context)
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
                              step == 4
                                  ? 'Return to P2P Fit ➜'
                                  : step == 3
                                  ? 'Submit gym application ➜'
                                  : 'Continue ➜',
                              style: const TextStyle(
                                fontSize: 17,
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
      ),
    );
  }

  String hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  Widget caption(String label, {Color color = muted}) => Text(
    label,
    style: TextStyle(
      color: color,
      fontWeight: FontWeight.w800,
      fontSize: 12,
      letterSpacing: .7,
    ),
  );
  Widget field(
    String key,
    String label,
    String hint, {
    bool optional = false,
    ValueChanged<String>? onChanged,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        caption(label),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey(key),
          controller: fields[key],
          enabled: !sending && receipt == null,
          keyboardType: key == 'workEmail'
              ? TextInputType.emailAddress
              : key == 'phone'
              ? TextInputType.phone
              : key == 'website' || key == 'logoUrl'
              ? TextInputType.url
              : TextInputType.text,
          inputFormatters: key == 'shortCode'
              ? [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(5),
                  TextInputFormatter.withFunction((oldValue, newValue) =>
                      newValue.copyWith(text: newValue.text.toUpperCase())),
                ]
              : null,
          textCapitalization: key == 'shortCode'
              ? TextCapitalization.characters
              : TextCapitalization.none,
          onChanged: onChanged ?? (_) => setState(() {}),
          validator: (value) {
            final text = value?.trim() ?? '';
            if (text.isEmpty) return optional ? null : 'Required';
            if (key == 'workEmail' &&
                !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(text))
              return 'Enter a valid email';
            if (key == 'phone' && text.replaceAll(RegExp(r'\D'), '').length < 7)
              return 'Enter a valid phone number';
            if (key == 'logoUrl') {
              final uri = Uri.tryParse(text);
              if (uri == null || uri.scheme != 'https' || uri.host.isEmpty ||
                  uri.host.contains(' ') || uri.userInfo.isNotEmpty) {
                return 'Enter an HTTPS logo URL';
              }
            }
            if (key == 'website') {
              final uri = Uri.tryParse(
                text.contains('://') ? text : 'https://$text',
              );
              if (uri == null ||
                  !['https', 'http'].contains(uri.scheme) ||
                  !uri.host.contains('.') ||
                  uri.host.contains(' ') ||
                  uri.userInfo.isNotEmpty)
                return 'Enter a valid website';
            }
            if (key == 'shortCode' &&
                !RegExp(r'^[A-Za-z0-9]{2,5}$').hasMatch(text))
              return 'Use 2–5 letters or numbers';
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
          ),
        ),
      ],
    ),
  );
  Widget colorField(TextEditingController controller, String label) =>
      TextFormField(
        key: ValueKey(label),
        controller: controller,
        onChanged: (_) => setState(() {}),
        validator: (value) =>
            parseColor(value ?? '') == null ? 'Use #RRGGBB' : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: CircleAvatar(
              backgroundColor: parseColor(controller.text) ?? Colors.grey,
              radius: 12,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
          ),
        ),
      );
  Widget slider(
    String label,
    double value,
    double min,
    double max,
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
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${value.round()}',
              style: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).round(),
          activeColor: orange,
          onChanged: changed,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.round()}', style: const TextStyle(color: soft)),
            Text('${max.round()}', style: const TextStyle(color: soft)),
          ],
        ),
      ],
    ),
  );
  Widget logoPicker() => InkWell(
    onTap: uploadingLogo || sending ? null : pickLogo,
    borderRadius: BorderRadius.circular(20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.withValues(alpha: .25)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 76,
              height: 76,
              color: brand.withValues(alpha: .08),
              child: selectedLogo != null
                  ? Image.file(File(selectedLogo!.path), fit: BoxFit.contain)
                  : text('logoUrl').isNotEmpty
                      ? TenantImage(text('logoUrl'), fit: BoxFit.contain)
                      : Icon(Icons.add_photo_alternate_outlined, color: brand, size: 34),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedLogo == null && text('logoUrl').isEmpty ? 'Add Your Logo' : 'Gym Logo',
                  style: const TextStyle(color: ink, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  uploadingLogo ? 'Uploading…' : 'JPG, PNG, or WebP. Tap to choose or replace.',
                  style: const TextStyle(color: muted, fontSize: 13),
                ),
              ],
            ),
          ),
          if (uploadingLogo)
            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
          else
            const Icon(Icons.chevron_right, color: muted),
        ],
      ),
    ),
  );

  Widget preview({bool complete = false}) => Container(
    key: const ValueKey('brandPreview'),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: brand.withValues(alpha: .2)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        caption(
          complete ? 'BRANDED PREVIEW READY ✓' : 'WRAPPER PREVIEW',
          color: soft,
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            children: [
              Container(
                color: brand,
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: brandText.withValues(alpha: .15),
                      child: ClipOval(
                        child: selectedLogo != null
                            ? Image.file(File(selectedLogo!.path), width: 48, height: 48, fit: BoxFit.contain)
                            : text('logoUrl').isNotEmpty
                                ? TenantImage(text('logoUrl'), width: 48, height: 48, fit: BoxFit.contain)
                                : Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        text('shortCode').toUpperCase(),
                                        maxLines: 1,
                                        style: TextStyle(color: brandText, fontSize: 11, fontWeight: FontWeight.w800),
                                      ),
                                    ),
                                  ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        text('gymName').isEmpty ? 'Your Gym' : text('gymName'),
                        style: TextStyle(
                          color: brandText,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(Icons.notifications_none, color: brandText),
                  ],
                ),
              ),
              Container(
                color: const Color(0xFFF8F9FA),
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    Container(
                      height: 10,
                      decoration: BoxDecoration(
                        color: brand.withValues(alpha: .2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 150,
                        height: 8,
                        color:
                            parseColor(
                              secondary.text,
                            )?.withValues(alpha: .15) ??
                            Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: brand,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Find My Workout ➜',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: brandText,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['Home', 'Gyms', 'Community', 'Trainer']
                      .map(
                        (label) => Column(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 13,
                              color: label == 'Home'
                                  ? brand
                                  : const Color(0xFFD2D6DF),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: const TextStyle(color: soft, fontSize: 8),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget plan(
    String id,
    String title,
    String badge,
    String price,
    List<String> features,
  ) {
    final color = id == 'pro' ? orange : muted;
    return Semantics(
      selected: tier == id,
      button: true,
      child: Material(
        color: tier == id ? color.withValues(alpha: .07) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: tier == id ? color : const Color(0xFFE5E7EB),
            width: 2,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: sending || receipt != null ? null : () => setState(() => tier = id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: ink,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Icon(
                      tier == id
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: tier == id ? color : const Color(0xFFD2D6DF),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  price,
                  style: TextStyle(
                    color: color,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          size: 16,
                          color: color,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            feature,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

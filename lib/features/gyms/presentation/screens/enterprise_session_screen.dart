import 'dart:async';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/bottom_nav_bar.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'tenant_management_screen.dart';
import '../widgets/enterprise_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/video_playback_manager.dart';
import 'package:pler_to_pler_app/services/stream_chat_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/core/themes/app_theme_data.dart';
import '../../data/models/enterprise_gym_model.dart';
import '../../data/models/tenant_configuration.dart';
import '../../data/services/enterprise_service.dart';
import '../widgets/tenant_image.dart';
import 'enterprise_module_screen.dart';

/// Owns a nested navigator: revocation or switching disposes every protected
/// route, including open editors. No old route remains above this boundary.
class EnterpriseSessionScreen extends StatefulWidget {
  final WidgetBuilder? flagshipBuilder;
  const EnterpriseSessionScreen({super.key, this.flagshipBuilder});
  @override
  State<EnterpriseSessionScreen> createState() => _EnterpriseSessionState();
}

class _EnterpriseSessionState extends State<EnterpriseSessionScreen>
    with WidgetsBindingObserver {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(const Duration(minutes: 1), (_) => refresh());
  }

  void refresh() {
    EnterpriseService.instance.refreshAccess().catchError((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => ValueListenableBuilder<EnterpriseContext?>(
    valueListenable: EnterpriseService.instance.active,
    builder: (context, session, _) {
      if (session == null)
        return Scaffold(
          appBar: AppBar(title: const Text('Gym session')),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Gym access: ${EnterpriseService.instance.bootstrapData.value['entitlement']?['state'] ?? 'unavailable'}. Select a gym, renew with your gym owner, or retry.',
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      await EnterpriseService.instance.restore();
                    } catch (e) {
                      if (context.mounted)
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text('$e')));
                    }
                  },
                  child: const Text('Retry session'),
                ),
                TextButton(
                  onPressed: () => LoginController.to.logout(),
                  child: const Text('Sign out'),
                ),
              ],
            ),
          ),
        );
      return Theme(
        data: enterpriseTheme(context, session.tenant),
        child: Navigator(
          key: ValueKey(session),
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (pageContext) => Scaffold(
              appBar: AppBar(
                title: Text(session.tenant.name),
                actions: [
                  if (session.isAdmin)
                    IconButton(
                      tooltip: 'Manage gym',
                      icon: const Icon(Icons.settings),
                      onPressed: () => Navigator.of(pageContext).push(
                        MaterialPageRoute(
                          builder: (_) => const TenantManagementScreen(),
                        ),
                      ),
                    ),
                ],
              ),
              body:
                  widget.flagshipBuilder?.call(pageContext) ??
                  const BottomNavBarMain(),
            ),
          ),
        ),
      );
    },
  );
}

class EnterpriseMembershipScreen extends StatefulWidget {
  const EnterpriseMembershipScreen({super.key});

  @override
  State<EnterpriseMembershipScreen> createState() =>
      _EnterpriseMembershipScreenState();
}

class _EnterpriseMembershipScreenState
    extends State<EnterpriseMembershipScreen> {
  late Future<EnterprisePage> _memberships;
  String? _switchingTenantId;

  @override
  void initState() {
    super.initState();
    _memberships = EnterpriseService.instance.memberships();
  }

  void _retry() {
    setState(() => _memberships = EnterpriseService.instance.memberships());
  }

  Future<void> _select(String tenantId) async {
    if (_switchingTenantId != null) return;
    setState(() => _switchingTenantId = tenantId);
    try {
      await enterEnterprise(tenantId);
    } catch (error) {
      if (!mounted) return;
      setState(() => _switchingTenantId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open this gym. $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Select a gym')),
    body: FutureBuilder<EnterprisePage>(
      future: _memberships,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Your gyms could not be loaded.'),
                const SizedBox(height: 12),
                FilledButton(onPressed: _retry, child: const Text('Retry')),
              ],
            ),
          );
        }
        final items = snapshot.data?.items ?? const [];
        if (items.isEmpty) {
          return const Center(child: Text('No active gym memberships found.'));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final membership = items[index];
            final rawTenant = membership['tenant'];
            if (rawTenant is! Map) return const SizedBox.shrink();
            final tenant = TenantConfiguration.fromJson(
              Map<String, dynamic>.from(rawTenant),
            );
            final roles = (membership['roles'] as List? ?? const [])
                .map((role) => '$role')
                .join(' · ');
            final busy = _switchingTenantId == tenant.id;
            return Card(
              child: ListTile(
                leading: TenantImage(tenant.logoUrl, width: 44, height: 44),
                title: Text(tenant.name),
                subtitle: roles.isEmpty ? null : Text(roles),
                trailing: busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: _switchingTenantId == null
                    ? () => _select(tenant.id)
                    : null,
              ),
            );
          },
        );
      },
    ),
  );
}

Future<void> enterEnterprise(String? id) async {
  if (Get.isRegistered<VideoPlaybackManager>())
    Get.find<VideoPlaybackManager>().stopAll();
  // The platform chat connection must not carry rooms into a gym session.
  try {
    await StreamChatService.instance.disconnect();
  } catch (_) {}
  await EnterpriseService.instance.switchTenant(id);
  if (Get.isRegistered<BottomNavBarController>())
    await Get.delete<BottomNavBarController>(force: true);
  Get.lazyPut(() => BottomNavBarController(), fenix: true);
  PaintingBinding.instance.imageCache.clear();
  PaintingBinding.instance.imageCache.clearLiveImages();
  if (id == null) {
    Get.changeTheme(AppThemeData.themeData);
    Get.offAllNamed(
      AppRoute.bottonNavBar,
      parameters: {'tenantSession': 'default'},
    );
  } else {
    Get.offAll(() => const EnterpriseSessionScreen());
  }
}

class EnterpriseJoinScreen extends StatefulWidget {
  final EnterpriseGymModel gym;
  const EnterpriseJoinScreen({super.key, required this.gym});
  @override
  State<EnterpriseJoinScreen> createState() => _EnterpriseJoinScreenState();
}

class _EnterpriseJoinScreenState extends State<EnterpriseJoinScreen> {
  bool busy = false, requested = false;
  String? error;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.gym.name)),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        TenantImage(widget.gym.logoUrl, height: 100, fit: BoxFit.contain),
        Text(widget.gym.tagline),
        Text(widget.gym.address),
        const SizedBox(height: 24),
        const Text(
          'Request membership to connect this gym to your P2P account. A gym administrator reviews requests.',
        ),
        if (error != null) Text(error!),
        FilledButton(
          onPressed: busy || requested
              ? null
              : () async {
                  setState(() {
                    busy = true;
                    error = null;
                  });
                  try {
                    await EnterpriseService.instance.request(
                      '/enterprise/tenants/${Uri.encodeComponent(widget.gym.tenantId!)}/join-requests',
                      method: 'POST',
                      body: {},
                    );
                    if (mounted) setState(() => requested = true);
                  } catch (e) {
                    if (mounted) setState(() => error = '$e');
                  } finally {
                    if (mounted) setState(() => busy = false);
                  }
                },
          child: Text(requested ? 'Request submitted' : 'Request to join'),
        ),
      ],
    ),
  );
}

class EnterpriseMemberHome extends StatelessWidget {
  const EnterpriseMemberHome({super.key});
  @override
  Widget build(BuildContext context) {
    final tenant = EnterpriseService.instance.active.value!.tenant;
    final modules = [
      const EnterpriseModule('Facility Information', 'facility'),
      const EnterpriseModule('Trainers', 'trainers'),
      const EnterpriseModule(
        'Classes',
        'classes',
        actions: [
          EnterpriseAction('Enroll', 'enroll'),
          EnterpriseAction('Cancel enrollment', 'cancel-enrollment'),
        ],
      ),
      const EnterpriseModule('Membership plans', 'plans'),
      const EnterpriseModule('My subscriptions', 'subscriptions'),
      const EnterpriseModule('Content', 'content'),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(tenant.name),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            icon: const Icon(Icons.logout),
            onPressed: () => LoginController.to.logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TenantImage(tenant.logoUrl, height: 80, fit: BoxFit.contain),
          const SizedBox(height: 16),
          Text(tenant.slogan, style: Theme.of(context).textTheme.headlineSmall),
          if (tenant.photos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: TenantImage(tenant.photos.first, height: 190),
              ),
            ),
          for (final module in modules)
            Card(
              child: ListTile(
                title: Text(module.title),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        EnterpriseModuleScreen(module: module, admin: false),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

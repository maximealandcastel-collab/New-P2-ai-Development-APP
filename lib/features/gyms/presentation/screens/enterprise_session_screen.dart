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
import 'enterprise_gym_admin_dashboard_screen.dart';
import 'enterprise_module_screen.dart';

/// Owns a nested navigator: revocation or switching disposes every protected
/// route, including open editors. No old route remains above this boundary.
class EnterpriseSessionScreen extends StatelessWidget {
  const EnterpriseSessionScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      ValueListenableBuilder<EnterpriseContext?>(
        valueListenable: EnterpriseService.instance.active,
        builder: (context, session, _) {
          if (session == null)
            return Scaffold(
              appBar: AppBar(title: const Text('Gym session')),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Select a gym or restore your session to continue.',
                    ),
                    FilledButton(
                      onPressed: () =>
                          Get.offAll(() => const EnterpriseMembershipScreen()),
                      child: const Text('My gyms'),
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
                builder: (_) => session.isAdmin
                    ? const EnterpriseGymAdminDashboardScreen()
                    : const EnterpriseMemberHome(),
              ),
            ),
          );
        },
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

class EnterpriseMembershipScreen extends StatefulWidget {
  const EnterpriseMembershipScreen({super.key});
  @override
  State<EnterpriseMembershipScreen> createState() =>
      _EnterpriseMembershipScreenState();
}

class _EnterpriseMembershipScreenState
    extends State<EnterpriseMembershipScreen> {
  final items = <Map<String, dynamic>>[];
  String? cursor, error;
  bool loading = false, busy = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load({bool reset = false}) async {
    if (loading) return;
    setState(() {
      loading = true;
      error = null;
      if (reset) {
        items.clear();
        cursor = null;
      }
    });
    try {
      final page = await EnterpriseService.instance.memberships(cursor: cursor);
      if (mounted)
        setState(() {
          items.addAll(page.items);
          cursor = page.nextCursor;
        });
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> choose(Map<String, dynamic> item) async {
    if (busy) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (item['status'] == 'invited') {
        await EnterpriseService.instance.request(
          '/enterprise/me/invitations/${Uri.encodeComponent(item['id'] as String)}/accept',
          method: 'POST',
          body: {},
        );
        await load(reset: true);
      } else {
        await enterEnterprise(item['tenantId'] as String);
      }
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('My gyms & invitations'),
      actions: [
        IconButton(
          onPressed: loading ? null : () => load(reset: true),
          icon: const Icon(Icons.refresh),
        ),
      ],
    ),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (loading || busy) const LinearProgressIndicator(),
        if (error != null) Text(error!),
        if (!loading && error == null && items.isEmpty)
          const Text('No memberships yet. Browse gyms to request access.'),
        ...items.map(
          (item) => Card(
            child: ListTile(
              title: Text('${item['tenantName']}'),
              subtitle: Text('${item['status']}'),
              trailing: ['active', 'invited'].contains(item['status'])
                  ? TextButton(
                      onPressed: busy ? null : () => choose(item),
                      child: Text(
                        item['status'] == 'invited'
                            ? 'Accept invitation'
                            : 'Open',
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (cursor != null)
          TextButton(
            onPressed: loading ? null : load,
            child: const Text('Load more'),
          ),
        TextButton(
          onPressed: busy
              ? null
              : () async {
                  setState(() => busy = true);
                  try {
                    await enterEnterprise(null);
                  } catch (e) {
                    if (mounted)
                      setState(() {
                        error = '$e';
                        busy = false;
                      });
                  }
                },
          child: const Text('Use personal P2P experience'),
        ),
        TextButton(
          onPressed: () => LoginController.to.logout(),
          child: const Text('Sign out'),
        ),
      ],
    ),
  );
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
        TextButton(
          onPressed: () => Get.to(() => const EnterpriseMembershipScreen()),
          child: const Text('Already connected? Open my gyms'),
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
            tooltip: 'Switch gym',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => Get.to(() => const EnterpriseMembershipScreen()),
          ),
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
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Get.to(() => const EnterpriseMembershipScreen()),
            child: const Text('My gyms & personal P2P fitness'),
          ),
        ],
      ),
    );
  }
}

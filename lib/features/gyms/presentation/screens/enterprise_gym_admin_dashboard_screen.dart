import '../widgets/enterprise_theme.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import '../../data/models/legacy_kmf_configuration.dart';
import '../../data/models/enterprise_dashboard_data.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import '../../data/services/enterprise_service.dart';
import 'enterprise_module_screen.dart';
import 'enterprise_session_screen.dart';
import '../widgets/tenant_image.dart';

const _kmfGreen = Color(0xFF22C55E);
const _kmfBlack = Color(0xFF090A09);

bool _isKmfGym(EnterpriseGymModel gym) => gym.id == 'kmf_fitness_club';
Color _dashboardBackground(EnterpriseGymModel gym) =>
    _isKmfGym(gym) ? Colors.white : gym.brandColor;
Color _dashboardText(EnterpriseGymModel gym) =>
    _isKmfGym(gym) ? _kmfBlack : gym.textColor;
Color _dashboardAccent(EnterpriseGymModel gym) =>
    _isKmfGym(gym) ? _kmfGreen : gym.accentColor;

/// Shared dashboard for every authorized enterprise administrator.
class EnterpriseGymAdminDashboardScreen extends StatefulWidget {
  final bool legacyKmf;
  final String? tenantId;
  const EnterpriseGymAdminDashboardScreen({
    super.key,
    this.legacyKmf = false,
    this.tenantId,
  });

  @override
  State<EnterpriseGymAdminDashboardScreen> createState() =>
      _EnterpriseGymAdminDashboardScreenState();
}

class _EnterpriseGymAdminDashboardScreenState
    extends State<EnterpriseGymAdminDashboardScreen> {
  EnterpriseGymModel get _gym {
    final active = EnterpriseService.instance.active.value?.tenant;
    if (!isSingleMode && active != null) return active.toGym();
    final tenantId = widget.tenantId ??
        (widget.legacyKmf ? 'kmf-fitness' : null);
    if (tenantId != null) {
      for (final gym in EnterpriseGymModel.activatedPartners) {
        if (gym.tenantId == tenantId) return gym;
      }
    }
    if (widget.legacyKmf) return legacyKmfTenant.toGym();
    throw StateError('No branding configuration for tenant: $tenantId');
  }

  late Future<EnterpriseDashboardData> _dashboard;
  EnterpriseDashboardData? _latestDashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = _loadDashboard();
  }

  Future<EnterpriseDashboardData> _loadDashboard() async {
    final tenantId = _gym.tenantId;
    final data = (isSingleMode || widget.tenantId != null) && tenantId != null
        ? await EnterpriseService.instance.request(
            '/gym-admin/${Uri.encodeComponent(tenantId)}/dashboard',
          )
        : await EnterpriseService.instance.scoped('dashboard', admin: true);
    final dashboard = EnterpriseDashboardData.fromJson(
      data,
      // Older deployed gym-admin responses may not include this newer metric.
      // When present, the model still validates that it is a nonnegative int.
      requireMembers: false,
    );
    _latestDashboard = dashboard;
    return dashboard;
  }

  Future<void> _refresh() async {
    final next = _loadDashboard();
    setState(() => _dashboard = next);
    await next;
  }

  void _openModule(String resource) {
    final dashboard = _latestDashboard;
    if (resource == 'analytics' && dashboard != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => _EnterpriseAnalyticsOverviewScreen(
            gym: _gym,
            dashboard: dashboard,
          ),
        ),
      );
      return;
    }
    final module = enterpriseModules.firstWhere(
      (candidate) => candidate.resource == resource,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EnterpriseModuleScreen(module: module),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isKmfGym(_gym)) {
      final base = Theme.of(context);
      return Theme(
        data: base.copyWith(
          scaffoldBackgroundColor: Colors.white,
          colorScheme: base.colorScheme.copyWith(
            primary: _kmfGreen,
            secondary: Colors.white,
            onSecondary: _kmfBlack,
            surface: Colors.white,
            onSurface: _kmfBlack,
          ),
        ),
        child: Builder(builder: _buildDashboard),
      );
    }
    return widget.legacyKmf
        ? Theme(
            data: enterpriseTheme(context, legacyKmfTenant),
            child: Builder(builder: _buildDashboard),
          )
        : _buildDashboard(context);
  }

  Widget _buildDashboard(BuildContext context) {
    return Scaffold(
      backgroundColor: _dashboardBackground(_gym),
      body: FutureBuilder<EnterpriseDashboardData>(
        future: _dashboard,
        builder: (context, snapshot) {
          return RefreshIndicator(
            color: _dashboardAccent(_gym),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _EnterpriseHeader(
                  legacyKmf: widget.legacyKmf,
                  gym: _gym,
                  administratorName: snapshot.hasData
                      ? snapshot.requireData.administratorName
                      : '',
                  onRefresh: () => _refresh(),
                  onLogout: () => LoginController.to.logout(),
                ),
                if (snapshot.connectionState != ConnectionState.done)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _dashboardAccent(_gym)),
                    ),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _DashboardMessage(
                      accentColor: _gym.accentColor,
                      message:
                          'We couldn’t load the dashboard right now. Please try again.',
                      onRetry: () => _refresh(),
                    ),
                  )
                else
                  _DashboardBody(
                    legacyKmf: widget.legacyKmf,
                    gym: _gym,
                    dashboard: snapshot.requireData,
                    onOpenModule: _openModule,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EnterpriseHeader extends StatelessWidget {
  final bool legacyKmf;
  final EnterpriseGymModel gym;
  final String administratorName;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const _EnterpriseHeader({
    required this.legacyKmf,
    required this.gym,
    required this.administratorName,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final welcomeName = administratorName.trim().isEmpty
        ? '${gym.name} Team'
        : administratorName.trim();
    return SliverAppBar(
      expandedHeight:
          340 + (MediaQuery.textScalerOf(context).scale(25) - 25) * 4,
      pinned: true,
      backgroundColor: _dashboardBackground(gym),
      foregroundColor: _dashboardText(gym),
      title: Text(gym.name, style: TextStyle(fontWeight: FontWeight.w700)),
      actions: [
        if (!legacyKmf)
          IconButton(
            tooltip: 'Switch gym',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () => Get.to(() => const EnterpriseMembershipScreen()),
          ),
        IconButton(
          tooltip: 'Refresh',
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh_rounded),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: onLogout,
          icon: const Icon(Icons.logout_rounded),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            TenantImage(gym.imageAssetPath, fit: BoxFit.cover),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0xAA000000),
                    _dashboardBackground(gym),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 72, 20, 22),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.onSecondary,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _dashboardAccent(gym), width: 2),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x66000000),
                            blurRadius: 18,
                            offset: Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: TenantImage(
                          gym.logoAssetPath.isNotEmpty
                              ? gym.logoAssetPath
                              : gym.logoUrl,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome back, $welcomeName',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _dashboardText(gym),
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gym.tagline,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: _dashboardAccent(gym),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: .4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final bool legacyKmf;
  final EnterpriseGymModel gym;
  final EnterpriseDashboardData dashboard;
  final ValueChanged<String> onOpenModule;

  const _DashboardBody({
    required this.legacyKmf,
    required this.gym,
    required this.dashboard,
    required this.onOpenModule,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _LocationCard(gym: gym),
          const SizedBox(height: 22),
          Text(
            '${gym.name} operations',
            style: TextStyle(
              color: _dashboardText(gym),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 12) / 2;
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _MetricCard(
                    width: width,
                    label: 'Signups',
                    count: dashboard.signups,
                    icon: Icons.person_add_alt_1_rounded,
                    accentColor: _dashboardAccent(gym),
                    onTap: () => onOpenModule('analytics'),
                  ),
                  if (dashboard.members != null)
                    _MetricCard(
                      width: width,
                      label: 'Members',
                      count: dashboard.members!,
                      icon: Icons.groups_rounded,
                      accentColor: _dashboardAccent(gym),
                    onTap: () => onOpenModule('analytics'),
                      ),
                  _MetricCard(
                    width: width,
                    label: 'Active plans',
                    count: dashboard.activeSubscriptions,
                    icon: Icons.card_membership_rounded,
                    accentColor: _dashboardAccent(gym),
                    onTap: () => onOpenModule('analytics'),
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Trainers',
                    count: dashboard.trainers,
                    icon: Icons.fitness_center_rounded,
                    accentColor: _dashboardAccent(gym),
                    onTap: () => onOpenModule('analytics'),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey('enterprise-analytics-button'),
                onPressed: () => onOpenModule('analytics'),
                style: FilledButton.styleFrom(
                  backgroundColor: gym.accentColor,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                icon: const Icon(Icons.analytics_rounded),
                label: const Text('Open Analytics'),
              ),
            ),
          const SizedBox(height: 14),
          if (!legacyKmf && !isSingleMode)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: enterpriseModules.map(
                    (module) => ActionChip(
                      label: Text(module.title),
                      onPressed: () => onOpenModule(module.resource),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 26),
          _GymGallery(gym: gym),
          const SizedBox(height: 28),
          _ActivitySection(
            title: 'Recent signups',
            emptyMessage: 'New members will appear here.',
            items: dashboard.recentSignups,
            accentColor: _dashboardAccent(gym),
          ),
          _ActivitySection(
            title: 'Active subscriptions',
            emptyMessage: 'No active subscriptions yet.',
            items: dashboard.activeSubscriptionItems,
            accentColor: _dashboardAccent(gym),
          ),
          _ActivitySection(
            title: 'Trainers',
            emptyMessage: 'Trainers will appear here once assigned.',
            items: dashboard.recentTrainers,
            accentColor: _dashboardAccent(gym),
          ),
          _ActivitySection(
            title: 'Recent activity',
            emptyMessage: 'Gym activity will appear here as your gym grows.',
            items: dashboard.recentActivity,
            accentColor: _dashboardAccent(gym),
          ),
        ]),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _LocationCard({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _dashboardAccent(gym).withOpacity(.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _dashboardAccent(gym).withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_rounded, color: _dashboardAccent(gym)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: TextStyle(
                    color: _dashboardText(gym),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  gym.address,
                  style: TextStyle(
                    color: _dashboardText(gym).withOpacity(.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: _dashboardAccent(gym),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Text(
              'LIVE',
              style: TextStyle(
                color: Colors.black,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EnterpriseAnalyticsOverviewScreen extends StatelessWidget {
  final EnterpriseGymModel gym;
  final EnterpriseDashboardData dashboard;

  const _EnterpriseAnalyticsOverviewScreen({
    required this.gym,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dashboardBackground(gym),
      appBar: AppBar(
        backgroundColor: _dashboardBackground(gym),
        foregroundColor: _dashboardText(gym),
        title: const Text('Analytics'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 36),
          children: [
            Text(
              gym.name,
              style: TextStyle(
                color: _dashboardText(gym),
                fontSize: 25,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Live membership overview',
              style: TextStyle(
                color: _dashboardText(gym).withValues(alpha: .7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final width = (constraints.maxWidth - 12) / 2;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard(
                      width: width,
                      label: 'Signups',
                      count: dashboard.signups,
                      icon: Icons.person_add_alt_1_rounded,
                      accentColor: _dashboardAccent(gym),
                    ),
                    if (dashboard.members != null)
                      _MetricCard(
                        width: width,
                        label: 'Members',
                        count: dashboard.members!,
                        icon: Icons.groups_rounded,
                        accentColor: _dashboardAccent(gym),
                      ),
                    _MetricCard(
                      width: width,
                      label: 'Active plans',
                      count: dashboard.activeSubscriptions,
                      icon: Icons.card_membership_rounded,
                      accentColor: _dashboardAccent(gym),
                    ),
                    _MetricCard(
                      width: width,
                      label: 'Trainers',
                      count: dashboard.trainers,
                      icon: Icons.fitness_center_rounded,
                      accentColor: _dashboardAccent(gym),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 26),
            _ActivitySection(
              title: 'Recent signups',
              emptyMessage: 'New members will appear here.',
              items: dashboard.recentSignups,
              accentColor: _dashboardAccent(gym),
            ),
            _ActivitySection(
              title: 'Active subscriptions',
              emptyMessage: 'No active subscriptions yet.',
              items: dashboard.activeSubscriptionItems,
              accentColor: _dashboardAccent(gym),
            ),
            _ActivitySection(
              title: 'Trainers',
              emptyMessage: 'No trainers yet.',
              items: dashboard.recentTrainers,
              accentColor: _dashboardAccent(gym),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final double width;
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.width,
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Material(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentColor.withOpacity(.3)),
            ),
            child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: accentColor),
              const SizedBox(height: 15),
              Text(
                '$count',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSecondary,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withValues(alpha: .7),
                  fontSize: 12,
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
}

class _GymGallery extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _GymGallery({required this.gym});

  @override
  Widget build(BuildContext context) {
    if (gym.galleryAssetPaths.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your facility',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 128,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: gym.galleryAssetPaths.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) => ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: TenantImage(
                gym.galleryAssetPaths[index],
                width: 194,
                height: 128,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final String emptyMessage;
  final List<dynamic> items;
  final Color accentColor;

  const _ActivitySection({
    required this.title,
    required this.emptyMessage,
    required this.items,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSecondary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                emptyMessage,
                style: TextStyle(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSecondary.withValues(alpha: .54),
                  fontSize: 13,
                ),
              ),
            )
          else
            ...items.take(8).map((item) {
              final data = item is Map
                  ? Map<String, dynamic>.from(item)
                  : <String, dynamic>{'detail': item};
              final firstName = data['firstName']?.toString() ?? '';
              final lastName = data['lastName']?.toString() ?? '';
              final personName = '$firstName $lastName'.trim();
              final itemTitle = personName.isNotEmpty
                  ? personName
                  : data['name'] ??
                        data['title'] ??
                        data['email'] ??
                        data['type'] ??
                        'Gym activity';
              final detail =
                  data['email'] ??
                  data['specialty'] ??
                  data['createdAt'] ??
                  data['date'] ??
                  data['status'] ??
                  data['detail'] ??
                  '';
              return Card(
                color: Theme.of(context).colorScheme.secondary,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: accentColor.withOpacity(.12),
                    child: Icon(Icons.bolt_rounded, color: accentColor),
                  ),
                  title: Text(
                    '$itemTitle',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: detail.toString().isEmpty
                      ? null
                      : Text(
                          '$detail',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSecondary.withValues(alpha: .6),
                          ),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  final Color accentColor;
  final String message;
  final VoidCallback onRetry;

  const _DashboardMessage({
    required this.accentColor,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline_rounded, color: accentColor, size: 42),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(
                context,
              ).colorScheme.onSecondary.withValues(alpha: .7),
            ),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: accentColor,
              side: BorderSide(color: accentColor),
            ),
            child: const Text('Try again'),
          ),
        ],
      ),
    ),
  );
}

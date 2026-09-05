import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

/// Dedicated tenant-isolated experience for KMF Fitness administrators.
///
/// This screen never enters BottomNavBarMain, AdminModeService, or any global
/// Founder Console route. All operational data comes from the KMF-protected API.
class KmfGymAdminDashboardScreen extends StatefulWidget {
  const KmfGymAdminDashboardScreen({super.key});

  @override
  State<KmfGymAdminDashboardScreen> createState() =>
      _KmfGymAdminDashboardScreenState();
}

class _KmfGymAdminDashboardScreenState
    extends State<KmfGymAdminDashboardScreen> {
  static final EnterpriseGymModel _gym = EnterpriseGymModel.partners.firstWhere(
    (gym) => gym.id == 'kmf_fitness_club',
  );

  late Future<_KmfDashboardData> _dashboard;

  @override
  void initState() {
    super.initState();
    _dashboard = _loadDashboard();
  }

  Future<_KmfDashboardData> _loadDashboard() async {
    final token = CacheService().get<String>('accessToken');
    if (token == null || token.isEmpty) {
      throw StateError('Your session has expired. Please sign in again.');
    }

    final response = await http.get(
      Uri.parse('${ApiUrls.baseUrl}/gym-admin/kmf-fitness/dashboard'),
      headers: {'Authorization': 'Bearer $token'},
    );

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } catch (_) {
      throw StateError('KMF services are temporarily unavailable.');
    }

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded is! Map) {
      final message =
          decoded is Map ? decoded['message']?.toString() : response.reasonPhrase;
      throw StateError(message ?? 'Unable to load the KMF dashboard.');
    }

    final body = decoded['data'];
    if (body is! Map) {
      throw StateError('Invalid KMF dashboard response.');
    }
    return _KmfDashboardData.fromJson(Map<String, dynamic>.from(body));
  }

  Future<void> _refresh() async {
    final next = _loadDashboard();
    setState(() => _dashboard = next);
    await next;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _gym.brandColor,
      body: FutureBuilder<_KmfDashboardData>(
        future: _dashboard,
        builder: (context, snapshot) {
          return RefreshIndicator(
            color: _gym.accentColor,
            backgroundColor: const Color(0xFF171917),
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                _KmfHeader(
                  gym: _gym,
                  administratorName:
                      snapshot.hasData ? snapshot.requireData.administratorName : '',
                  onRefresh: () => _refresh(),
                  onLogout: () => LoginController.to.logout(),
                ),
                if (snapshot.connectionState != ConnectionState.done)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: CircularProgressIndicator(color: _gym.accentColor),
                    ),
                  )
                else if (snapshot.hasError)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _DashboardMessage(
                      accentColor: _gym.accentColor,
                      message: snapshot.error
                          .toString()
                          .replaceFirst('Bad state: ', ''),
                      onRetry: () => _refresh(),
                    ),
                  )
                else
                  _DashboardBody(gym: _gym, dashboard: snapshot.requireData),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KmfHeader extends StatelessWidget {
  final EnterpriseGymModel gym;
  final String administratorName;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;

  const _KmfHeader({
    required this.gym,
    required this.administratorName,
    required this.onRefresh,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final welcomeName =
        administratorName.trim().isEmpty ? 'KMF Team' : administratorName.trim();
    return SliverAppBar(
      expandedHeight: 286,
      pinned: true,
      backgroundColor: gym.brandColor,
      foregroundColor: gym.textColor,
      title: Text(
        gym.name,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      actions: [
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
            Image.asset(gym.imageAssetPath, fit: BoxFit.cover),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0xAA000000),
                    Color(0xFF0A0A0A),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: gym.accentColor, width: 2),
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
                        child: Image.asset(gym.logoAssetPath, fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Welcome back, $welcomeName',
                      style: TextStyle(
                        color: gym.textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gym.tagline,
                      style: TextStyle(
                        color: gym.accentColor,
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
  final EnterpriseGymModel gym;
  final _KmfDashboardData dashboard;

  const _DashboardBody({required this.gym, required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 36),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          _LocationCard(gym: gym),
          const SizedBox(height: 22),
          Text(
            'KMF operations',
            style: TextStyle(
              color: gym.textColor,
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
                    accentColor: gym.accentColor,
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Members',
                    count: dashboard.signups,
                    icon: Icons.groups_rounded,
                    accentColor: gym.accentColor,
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Active plans',
                    count: dashboard.activeSubscriptions,
                    icon: Icons.card_membership_rounded,
                    accentColor: gym.accentColor,
                  ),
                  _MetricCard(
                    width: width,
                    label: 'Trainers',
                    count: dashboard.trainers,
                    icon: Icons.fitness_center_rounded,
                    accentColor: gym.accentColor,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 26),
          _GymGallery(gym: gym),
          const SizedBox(height: 28),
          _ActivitySection(
            title: 'Recent KMF signups',
            emptyMessage: 'New KMF members will appear here.',
            items: dashboard.recentSignups,
            accentColor: gym.accentColor,
          ),
          _ActivitySection(
            title: 'Active KMF subscriptions',
            emptyMessage: 'No active KMF subscriptions yet.',
            items: dashboard.activeSubscriptionItems,
            accentColor: gym.accentColor,
          ),
          _ActivitySection(
            title: 'KMF trainers',
            emptyMessage: 'KMF trainers will appear here once assigned.',
            items: dashboard.recentTrainers,
            accentColor: gym.accentColor,
          ),
          _ActivitySection(
            title: 'Recent KMF activity',
            emptyMessage: 'KMF activity will appear here as your gym grows.',
            items: dashboard.recentActivity,
            accentColor: gym.accentColor,
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
        color: const Color(0xFF171917),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: gym.accentColor.withOpacity(.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: gym.accentColor.withOpacity(.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.location_on_rounded, color: gym.accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  gym.name,
                  style: TextStyle(
                    color: gym.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  gym.address,
                  style: TextStyle(
                    color: gym.textColor.withOpacity(.65),
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
              color: gym.accentColor,
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

class _MetricCard extends StatelessWidget {
  final double width;
  final String label;
  final int count;
  final IconData icon;
  final Color accentColor;

  const _MetricCard({
    required this.width,
    required this.label,
    required this.count,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFF171917),
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
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
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
        const Text(
          'Your facility',
          style: TextStyle(
            color: Colors.white,
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
              child: Image.asset(
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
            style: const TextStyle(
              color: Colors.white,
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
                color: const Color(0xFF171917),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                emptyMessage,
                style: const TextStyle(color: Colors.white54, fontSize: 13),
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
                      'KMF activity';
              final detail = data['email'] ??
                  data['specialty'] ??
                  data['createdAt'] ??
                  data['date'] ??
                  data['status'] ??
                  data['detail'] ??
                  '';
              return Card(
                color: const Color(0xFF171917),
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
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: detail.toString().isEmpty
                      ? null
                      : Text(
                          '$detail',
                          style: const TextStyle(color: Colors.white60),
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
                style: const TextStyle(color: Colors.white70),
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

class _KmfDashboardData {
  final String administratorName;
  final int signups;
  final int activeSubscriptions;
  final int trainers;
  final List<dynamic> recentSignups;
  final List<dynamic> activeSubscriptionItems;
  final List<dynamic> recentTrainers;
  final List<dynamic> recentActivity;

  const _KmfDashboardData({
    required this.administratorName,
    required this.signups,
    required this.activeSubscriptions,
    required this.trainers,
    required this.recentSignups,
    required this.activeSubscriptionItems,
    required this.recentTrainers,
    required this.recentActivity,
  });

  factory _KmfDashboardData.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] is Map
        ? Map<String, dynamic>.from(json['counts'] as Map)
        : const <String, dynamic>{};
    final administrator = json['administrator'] is Map
        ? Map<String, dynamic>.from(json['administrator'] as Map)
        : const <String, dynamic>{};
    int count(String key) => (counts[key] as num?)?.toInt() ?? 0;
    List<dynamic> list(String key) =>
        json[key] is List ? List<dynamic>.from(json[key] as List) : const [];
    final administratorName =
        '${administrator['firstName'] ?? ''} ${administrator['lastName'] ?? ''}'
            .trim();

    return _KmfDashboardData(
      administratorName: administratorName,
      signups: count('signups'),
      activeSubscriptions: count('activeSubscriptions'),
      trainers: count('trainers'),
      recentSignups: list('recentSignups'),
      activeSubscriptionItems: list('activeSubscriptions'),
      recentTrainers: list('recentTrainers'),
      recentActivity: list('recentActivity'),
    );
  }
}
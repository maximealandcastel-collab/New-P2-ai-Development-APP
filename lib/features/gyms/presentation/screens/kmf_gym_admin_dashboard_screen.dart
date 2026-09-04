import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';

/// Tenant-isolated operational dashboard for KMF Fitness administrators.
///
/// This screen intentionally does not use BottomNavBarMain or AdminModeService:
/// the global admin console and its Admin/User toggle are not valid for a gym
/// tenant administrator.
class KmfGymAdminDashboardScreen extends StatefulWidget {
  const KmfGymAdminDashboardScreen({super.key});

  @override
  State<KmfGymAdminDashboardScreen> createState() =>
      _KmfGymAdminDashboardScreenState();
}

class _KmfGymAdminDashboardScreenState
    extends State<KmfGymAdminDashboardScreen> {
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
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        decoded is! Map) {
      final message =
          decoded is Map ? decoded['message']?.toString() : response.reasonPhrase;
      throw StateError(message ?? 'Unable to load the KMF dashboard.');
    }
    final body = decoded['data'];
    if (body is! Map) throw StateError('Invalid KMF dashboard response.');
    return _KmfDashboardData.fromJson(Map<String, dynamic>.from(body));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff090a09),
      appBar: AppBar(
        backgroundColor: const Color(0xff090a09),
        foregroundColor: Colors.white,
        title: const Text('KMF Fitness Admin'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => setState(() => _dashboard = _loadDashboard()),
            icon: const Icon(Icons.refresh_rounded),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => LoginController.to.logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<_KmfDashboardData>(
        future: _dashboard,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xff39ff14)),
            );
          }
          if (snapshot.hasError) {
            return _DashboardMessage(
              message: snapshot.error.toString().replaceFirst('Bad state: ', ''),
              onRetry: () => setState(() => _dashboard = _loadDashboard()),
            );
          }
          final dashboard = snapshot.requireData;
          return RefreshIndicator(
            color: const Color(0xff187900),
            onRefresh: () async => setState(() => _dashboard = _loadDashboard()),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  'Keep Moving Forward',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xff39ff14),
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'KMF Fitness operations overview',
                  style: TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _MetricCard('Signups', dashboard.signups, Icons.person_add_alt_1),
                    // The API has no separate member count. KMF members are
                    // therefore the tenant's signups, rather than invented data.
                    _MetricCard('Members', dashboard.signups, Icons.groups_rounded),
                    _MetricCard(
                      'Active subscriptions',
                      dashboard.activeSubscriptions,
                      Icons.card_membership_rounded,
                    ),
                    _MetricCard('Trainers', dashboard.trainers, Icons.fitness_center),
                  ],
                ),
                const SizedBox(height: 28),
                _ActivitySection('Recent signups', dashboard.recentSignups),
                _ActivitySection(
                  'Active subscriptions',
                  dashboard.activeSubscriptionItems,
                ),
                _ActivitySection('Recent trainers', dashboard.recentTrainers),
                _ActivitySection('Recent KMF activity', dashboard.recentActivity),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KmfDashboardData {
  final int signups;
  final int activeSubscriptions;
  final int trainers;
  final List<dynamic> recentSignups;
  final List<dynamic> activeSubscriptionItems;
  final List<dynamic> recentTrainers;
  final List<dynamic> recentActivity;

  const _KmfDashboardData({
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
    int count(String key) => (counts[key] as num?)?.toInt() ?? 0;
    List<dynamic> list(String key) =>
        json[key] is List ? List<dynamic>.from(json[key] as List) : const [];
    return _KmfDashboardData(
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

class _MetricCard extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;
  const _MetricCard(this.label, this.count, this.icon);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: (MediaQuery.sizeOf(context).width - 52) / 2,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xff171917),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xff39ff14).withOpacity(.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: const Color(0xff39ff14)),
            const SizedBox(height: 15),
            Text('$count',
                style: const TextStyle(
                    color: Colors.white, fontSize: 25, fontWeight: FontWeight.w700)),
            const SizedBox(height: 3),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ]),
        ),
      ),
    );
  }
}

class _ActivitySection extends StatelessWidget {
  final String title;
  final List<dynamic> items;
  const _ActivitySection(this.title, this.items);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Text('No KMF records yet.', style: TextStyle(color: Colors.white54))
        else
          ...items.take(8).map((item) {
            final data = item is Map ? item : <String, dynamic>{'detail': item};
            final title = data['name'] ??
                data['title'] ??
                data['email'] ??
                data['type'] ??
                'KMF activity';
            final detail = data['createdAt'] ??
                data['date'] ??
                data['status'] ??
                data['detail'] ??
                '';
            return Card(
              color: const Color(0xff171917),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.bolt_rounded, color: Color(0xff39ff14)),
                title: Text('$title', style: const TextStyle(color: Colors.white)),
                subtitle: detail.toString().isEmpty
                    ? null
                    : Text('$detail', style: const TextStyle(color: Colors.white60)),
              ),
            );
          }),
      ]),
    );
  }
}

class _DashboardMessage extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _DashboardMessage({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 40),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 14),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ]),
        ),
      );
}
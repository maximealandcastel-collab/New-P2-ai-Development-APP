import 'gym_apple_subscription_screen.dart';
import 'package:flutter/material.dart';
import '../../data/services/enterprise_service.dart';

class TenantManagementScreen extends StatefulWidget {
  const TenantManagementScreen({super.key});
  @override
  State<TenantManagementScreen> createState() => _TenantManagementState();
}

class _TenantManagementState extends State<TenantManagementScreen> {
  final fields = {
    for (final key in [
      'gymName',
      'logoUrl',
      'primaryColor',
      'secondaryColor',
      'accentColor',
      'userId',
      'equipment',
    ])
      key: TextEditingController(),
  };
  String? error;
  bool busy = true;
  String role = 'member';
  List<dynamic> members = [];
  String get path =>
      '/enterprise/tenants/${Uri.encodeComponent(EnterpriseService.instance.active.value!.tenant.id)}';
  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    for (final field in fields.values) {
      field.dispose();
    }
    super.dispose();
  }

  Future<void> run(Future<void> Function() action) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => error = '$e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> load() => run(() async {
    final brand = await EnterpriseService.instance.request('$path/branding');
    final list = await EnterpriseService.instance.request('$path/memberships');
    if (!mounted) return;
    for (final key in [
      'gymName',
      'logoUrl',
      'primaryColor',
      'secondaryColor',
      'accentColor',
    ]) {
      fields[key]!.text = brand[key] as String? ?? '';
    }
    members = list['items'] as List? ?? [];
    final facility = EnterpriseService.instance.bootstrapData.value['facility'];
    fields['equipment']!.text = (facility?['equipment'] as List? ?? []).join(
      ', ',
    );
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Manage gym')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        if (busy) const LinearProgressIndicator(),
        if (error != null) Text(error!),
        for (final key in [
          'gymName',
          'logoUrl',
          'primaryColor',
          'secondaryColor',
          'accentColor',
        ])
          TextField(
            controller: fields[key],
            decoration: InputDecoration(labelText: key),
          ),
        FilledButton(
          onPressed: busy
              ? null
              : () => run(() async {
                  await EnterpriseService.instance.request(
                    '$path/branding',
                    method: 'PUT',
                    body: {
                      for (final key in [
                        'gymName',
                        'logoUrl',
                        'primaryColor',
                        'secondaryColor',
                        'accentColor',
                      ])
                        key: fields[key]!.text,
                    },
                  );
                  await EnterpriseService.instance.restore();
                }),
          child: const Text('Save branding'),
        ),
        TextField(
          controller: fields['equipment'],
          decoration: const InputDecoration(
            labelText: 'Equipment (comma separated)',
          ),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () => run(() async {
                  final id = EnterpriseService
                      .instance
                      .bootstrapData
                      .value['facility']?['facilityId'];
                  if (id == null) throw Exception('Facility unavailable');
                  await EnterpriseService.instance.request(
                    '/enterprise/facilities/${Uri.encodeComponent(id)}/inventory',
                    method: 'PUT',
                    body: {
                      'equipment': fields['equipment']!.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList(),
                    },
                  );
                  await EnterpriseService.instance.restore();
                }),
          child: const Text('Save equipment'),
        ),
        TextField(
          controller: fields['userId'],
          decoration: const InputDecoration(labelText: 'Verified P2P user ID'),
        ),
        DropdownButton<String>(
          value: role,
          items: [
            for (final r in ['member', 'trainer', 'staff', 'admin'])
              DropdownMenuItem(value: r, child: Text(r)),
          ],
          onChanged: busy ? null : (v) => setState(() => role = v!),
        ),
        FilledButton(
          onPressed: busy
              ? null
              : () => run(() async {
                  await EnterpriseService.instance.request(
                    '$path/memberships/${Uri.encodeComponent(fields['userId']!.text.trim())}',
                    method: 'PUT',
                    body: {'role': role, 'status': 'active'},
                  );
                  members =
                      (await EnterpriseService.instance.request(
                            '$path/memberships',
                          ))['items']
                          as List;
                }),
          child: const Text('Add or update membership'),
        ),
        for (final m in members)
          ListTile(
            title: Text('${m['userId']}'),
            subtitle: Text('${m['role']} · ${m['status']}'),
            trailing: m['role'] == 'owner'
                ? null
                : TextButton(
                    onPressed: busy
                        ? null
                        : () => run(() async {
                            await EnterpriseService.instance.request(
                              '$path/memberships/${m['userId']}',
                              method: 'PUT',
                              body: {'role': m['role'], 'status': 'revoked'},
                            );
                            members =
                                (await EnterpriseService.instance.request(
                                      '$path/memberships',
                                    ))['items']
                                    as List;
                          }),
                    child: const Text('Revoke'),
                  ),
          ),
      ],
    ),
  );
}

class GymApplicationStatus extends StatefulWidget {
  const GymApplicationStatus({super.key});
  @override
  State<GymApplicationStatus> createState() => _GymApplicationStatusState();
}

class _GymApplicationStatusState extends State<GymApplicationStatus> {
  late Future<Map<String, dynamic>> data;
  @override
  void initState() {
    super.initState();
    data = EnterpriseService.instance.request('/enterprise/me/applications');
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Map<String, dynamic>>(
    future: data,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done)
        return const LinearProgressIndicator();
      if (snapshot.hasError)
        return TextButton(
          onPressed: () => setState(
            () => data = EnterpriseService.instance.request(
              '/enterprise/me/applications',
            ),
          ),
          child: const Text('Application status unavailable. Retry'),
        );
      final items = snapshot.data?['items'] as List? ?? [];
      return Column(
        children: [
          for (final c in items)
            ListTile(
              title: Text('${c['gymName']}'),
              trailing: c['status'] == 'rejected' || c['status'] == 'revoked' ? null : TextButton(
                onPressed: c['ownershipVerifiedAt'] == null ? null : () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder:(_)=>GymAppleSubscriptionScreen(applicationId:'${c['_id']}')));
                  if(mounted)setState(()=>data=EnterpriseService.instance.request('/enterprise/me/applications'));
                }, child: Text(c['ownershipVerifiedAt'] == null ? 'Ownership review pending' : 'Apple subscription'),
              ),
              subtitle: Text(
                '${c['status']} · ownership ${c['ownershipVerifiedAt'] == null ? 'review required' : 'verified'} · payment ${c['paymentStatus'] ?? 'required'} · provisioning ${c['provisioningState'] ?? 'pending'}${c['reason'] == null ? '' : '\n${c['reason']}'}${c['provisioningFailure'] == null ? '' : '\n${c['provisioningFailure']}'}',
              ),
            ),
        ],
      );
    },
  );
}

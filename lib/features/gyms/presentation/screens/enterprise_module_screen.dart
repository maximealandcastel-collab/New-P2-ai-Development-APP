import 'package:url_launcher/url_launcher.dart';
import '../widgets/tenant_image.dart';
import 'package:flutter/material.dart';
import '../../data/services/enterprise_service.dart';
import '../../data/models/tenant_configuration.dart';

class EnterpriseField {
  final String key, label;
  final bool required;
  final String type;
  const EnterpriseField(
    this.key,
    this.label, {
    this.required = true,
    this.type = 'text',
  });
}

class EnterpriseAction {
  final String label, path;
  final List<EnterpriseField> fields;
  const EnterpriseAction(this.label, this.path, [this.fields = const []]);
}

class EnterpriseModule {
  final String title, resource;
  final List<EnterpriseField> fields;
  final List<EnterpriseAction> actions;
  final String? createLabel;
  const EnterpriseModule(
    this.title,
    this.resource, {
    this.fields = const [],
    this.actions = const [],
    this.createLabel,
  });
}

// One centrally approved module registry. Tenants cannot override workflows.
const enterpriseModules = <EnterpriseModule>[
  EnterpriseModule(
    'Signups',
    'signups',
    actions: [
      EnterpriseAction('Approve', 'approve'),
      EnterpriseAction('Decline', 'decline'),
    ],
  ),
  EnterpriseModule(
    'Members',
    'members',
    createLabel: 'Invite member',
    fields: [EnterpriseField('email', 'Email', type: 'email')],
    actions: [
      EnterpriseAction('Suspend', 'suspend'),
      EnterpriseAction('Reactivate', 'reactivate'),
      EnterpriseAction('Remove', 'remove'),
    ],
  ),
  EnterpriseModule(
    'Membership plans',
    'plans',
    createLabel: 'Create plan',
    fields: [
      EnterpriseField('name', 'Plan name'),
      EnterpriseField('description', 'Description', required: false),
      EnterpriseField('durationDays', 'Duration in days', type: 'integer'),
    ],
    actions: [EnterpriseAction('Archive', 'archive')],
  ),
  EnterpriseModule(
    'Subscriptions',
    'subscriptions',
    createLabel: 'Assign plan',
    fields: [
      EnterpriseField('membershipId', 'Member', type: 'members'),
      EnterpriseField('planId', 'Plan', type: 'plans'),
      EnterpriseField('startsAt', 'Start date', type: 'date'),
      EnterpriseField('endsAt', 'Expiry date', type: 'date'),
    ],
    actions: [EnterpriseAction('Cancel', 'cancel')],
  ),
  EnterpriseModule(
    'Trainer Management',
    'trainers',
    createLabel: 'Assign trainer',
    fields: [
      EnterpriseField('membershipId', 'Member', type: 'members'),
      EnterpriseField('bio', 'Trainer biography', required: false),
    ],
    actions: [EnterpriseAction('Remove assignment', 'remove')],
  ),
  EnterpriseModule(
    'Facility Information',
    'facility',
    createLabel: 'Edit facility',
    fields: [
      EnterpriseField('name', 'Gym name'),
      EnterpriseField('slogan', 'Slogan', required: false),
      EnterpriseField('logoUrl', 'Logo URL', type: 'url'),
      EnterpriseField('primaryColor', 'Primary color', type: 'color'),
      EnterpriseField('secondaryColor', 'Secondary color', type: 'color'),
      EnterpriseField('accentColor', 'Accent color', type: 'color'),
      EnterpriseField('timezone', 'Timezone'),
      EnterpriseField('email', 'Contact email', required: false, type: 'email'),
      EnterpriseField('phone', 'Contact phone', required: false),
      EnterpriseField('website', 'Website', required: false, type: 'url'),
      EnterpriseField(
        'photos',
        'Facility photo URLs (one per line)',
        required: false,
        type: 'urls',
      ),
    ],
  ),
  EnterpriseModule(
    'Locations',
    'locations',
    createLabel: 'Add location',
    fields: [
      EnterpriseField('name', 'Location name'),
      EnterpriseField('address', 'Street address'),
      EnterpriseField('city', 'City'),
      EnterpriseField('zipCode', 'Postal code'),
    ],
    actions: [EnterpriseAction('Archive', 'archive')],
  ),
  EnterpriseModule(
    'Classes',
    'classes',
    createLabel: 'Schedule class',
    fields: [
      EnterpriseField('name', 'Class name'),
      EnterpriseField('trainerId', 'Trainer', type: 'trainers'),
      EnterpriseField('locationId', 'Location', type: 'locations'),
      EnterpriseField('startsAt', 'Start time', type: 'datetime'),
      EnterpriseField('capacity', 'Capacity', type: 'integer'),
    ],
    actions: [EnterpriseAction('Cancel class', 'cancel')],
  ),
  EnterpriseModule(
    'Content',
    'content',
    createLabel: 'Publish content',
    fields: [
      EnterpriseField('title', 'Title'),
      EnterpriseField('description', 'Content', required: false),
      EnterpriseField('mediaUrl', 'Media URL', required: false, type: 'url'),
    ],
    actions: [EnterpriseAction('Archive', 'archive')],
  ),
  EnterpriseModule('Activity', 'activity'),
  EnterpriseModule('Analytics', 'analytics'),
];

class EnterpriseModuleScreen extends StatefulWidget {
  final EnterpriseModule module;
  final bool admin;
  const EnterpriseModuleScreen({
    super.key,
    required this.module,
    this.admin = true,
  });
  @override
  State<EnterpriseModuleScreen> createState() => _EnterpriseModuleScreenState();
}

class _EnterpriseModuleScreenState extends State<EnterpriseModuleScreen> {
  final service = EnterpriseService.instance;
  final items = <Map<String, dynamic>>[];
  String? cursor, error;
  bool loading = false, busy = false;
  DateTimeRange? range;
  int generation = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool more = false}) async {
    if (loading && more) return;
    final current = ++generation;
    setState(() {
      loading = true;
      error = null;
      if (!more) {
        items.clear();
        cursor = null;
      }
    });
    try {
      final query = Uri(
        queryParameters: {
          'limit': '30',
          if (more && cursor != null) 'cursor': cursor!,
          if (range != null)
            'from': range!.start.toIso8601String().substring(0, 10),
          if (range != null)
            'to': range!.end.toIso8601String().substring(0, 10),
        },
      ).query;
      final data = await service.scoped(
        '${widget.module.resource}?$query',
        admin: widget.admin,
      );
      final page = EnterprisePage.fromJson(data);
      if (!mounted || current != generation) return;
      setState(() {
        items.addAll(page.items);
        cursor = page.nextCursor;
      });
    } catch (e) {
      if (mounted && current == generation)
        setState(() => error = e.toString());
    } finally {
      if (mounted && current == generation) setState(() => loading = false);
    }
  }

  Future<void> _action({
    Map<String, dynamic>? item,
    EnterpriseAction? action,
  }) async {
    if (busy) return;
    final fields = action?.fields ?? widget.module.fields;
    final label = action?.label ?? widget.module.createLabel!;
    Map<String, dynamic>? body;
    if (fields.isNotEmpty) {
      body = await Navigator.of(context).push<Map<String, dynamic>>(
        MaterialPageRoute(
          builder: (_) => EnterpriseEditor(
            title: label,
            fields: fields,
            initial: widget.module.resource == 'facility' && items.isNotEmpty
                ? items.first
                : const {},
          ),
        ),
      );
    } else {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (c) => AlertDialog(
          title: Text(label),
          content: Text(
            '$label for ${item?['name'] ?? item?['title'] ?? 'this record'}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Keep unchanged'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, true),
              child: Text(label),
            ),
          ],
        ),
      );
      if (confirmed == true) body = {};
    }
    if (body == null || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final resource = widget.module.resource;
      final path = action == null
          ? resource
          : '$resource/${Uri.encodeComponent(item!['id'] as String)}/${action.path}';
      await service.scoped(
        path,
        admin: widget.admin,
        method: resource == 'facility' ? 'PATCH' : 'POST',
        body: body,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Changes saved.')));
      await _load();
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.module.title),
      actions: [
        if (widget.module.resource == 'analytics')
          IconButton(
            icon: const Icon(Icons.date_range),
            tooltip: 'Date range',
            onPressed: () async {
              final selected = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
                initialDateRange: range,
              );
              if (selected != null && mounted) {
                setState(() => range = selected);
                _load();
              }
            },
          ),
        IconButton(
          onPressed: loading ? null : () => _load(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    ),
    body: RefreshIndicator(
      onRefresh: () => _load(),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (widget.module.resource == 'analytics')
            Text(
              'Reporting timezone: ${service.active.value?.tenant.timezone ?? ''}',
            ),
          if (widget.module.createLabel != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: FilledButton.icon(
                onPressed: busy ? null : () => _action(),
                icon: const Icon(Icons.add),
                label: Text(widget.module.createLabel!),
              ),
            ),
          if (loading || busy) const LinearProgressIndicator(),
          if (error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(error!),
                    TextButton(
                      onPressed: () => _load(),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          if (!loading && error == null && items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Text('No records yet.'),
            ),
          ...items.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${item['name'] ?? item['title'] ?? item['email'] ?? 'Record'}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    for (final key in [
                      'description',
                      'summary',
                      'bio',
                      'status',
                      'email',
                      'address',
                      'slogan',
                      'phone',
                      'website',
                      'startsAt',
                      'endsAt',
                      'value',
                    ])
                      if (item[key] != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text('${item[key]}'),
                        ),
                    if (widget.module.resource == 'content' &&
                        item['mediaUrl'] is String)
                      TextButton.icon(
                        icon: const Icon(Icons.play_circle_outline),
                        label: const Text('Open media'),
                        onPressed: () async {
                          final uri = Uri.tryParse(item['mediaUrl'] as String);
                          try {
                            if (uri == null ||
                                uri.scheme != 'https' ||
                                !await launchUrl(
                                  uri,
                                  mode: LaunchMode.externalApplication,
                                ))
                              throw const EnterpriseException(
                                'This media is unavailable.',
                              );
                          } catch (_) {
                            if (context.mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Unable to open media.'),
                                ),
                              );
                          }
                        },
                      ),
                    if (item['photos'] is List)
                      ...List<String>.from(item['photos'] as List).map(
                        (url) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: TenantImage(url, height: 180),
                        ),
                      ),
                    Wrap(
                      spacing: 8,
                      children: widget.module.actions
                          .where(
                            (action) => (item['allowedActions'] as List? ?? [])
                                .contains(action.path),
                          )
                          .map(
                            (action) => TextButton(
                              onPressed: busy
                                  ? null
                                  : () => _action(item: item, action: action),
                              child: Text(action.label),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (cursor != null)
            TextButton(
              onPressed: loading ? null : () => _load(more: true),
              child: const Text('Load more'),
            ),
        ],
      ),
    ),
  );
}

class EnterpriseEditor extends StatefulWidget {
  final String title;
  final List<EnterpriseField> fields;
  final Map<String, dynamic> initial;
  const EnterpriseEditor({
    super.key,
    required this.title,
    required this.fields,
    this.initial = const {},
  });
  @override
  State<EnterpriseEditor> createState() => _EnterpriseEditorState();
}

class _EnterpriseEditorState extends State<EnterpriseEditor> {
  final form = GlobalKey<FormState>();
  final selectedIds = <String, String>{};
  late final controls = {
    for (final f in widget.fields)
      f.key: TextEditingController(
        text: widget.initial[f.key] is List
            ? (widget.initial[f.key] as List).join('\n')
            : widget.initial[f.key]?.toString() ?? '',
      ),
  };
  @override
  void dispose() {
    for (final c in controls.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick(EnterpriseField field) async {
    if (field.type == 'date' || field.type == 'datetime') {
      final date = await showDatePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        initialDate: DateTime.now(),
      );
      if (date == null || !mounted) return;
      var value = date;
      if (field.type == 'datetime') {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time == null) return;
        value = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
      }
      controls[field.key]!.text = value.toUtc().toIso8601String();
      return;
    }
    final selection = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) =>
            EnterpriseRecordPicker(resource: field.type, title: field.label),
      ),
    );
    if (selection != null && mounted)
      setState(() {
        selectedIds[field.key] = selection['id'] as String;
        controls[field.key]!.text =
            '${selection['name'] ?? selection['title'] ?? selection['email'] ?? 'Selected record'}';
      });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.title)),
    body: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ...widget.fields.map((field) {
            final picker = [
              'members',
              'plans',
              'trainers',
              'locations',
              'date',
              'datetime',
            ].contains(field.type);
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: TextFormField(
                controller: controls[field.key],
                readOnly: picker,
                onTap: picker ? () => _pick(field) : null,
                decoration: InputDecoration(
                  labelText: field.label,
                  border: const OutlineInputBorder(),
                  suffixIcon: picker ? const Icon(Icons.arrow_drop_down) : null,
                ),
                maxLines: field.type == 'urls' ? 4 : 1,
                keyboardType: field.type == 'integer'
                    ? TextInputType.number
                    : TextInputType.text,
                validator: (raw) {
                  final v = raw?.trim() ?? '';
                  if (v.isEmpty) return field.required ? 'Required' : null;
                  if (field.type == 'integer' && (int.tryParse(v) ?? 0) <= 0)
                    return 'Enter a positive whole number';
                  if (field.type == 'email' &&
                      !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v))
                    return 'Enter a valid email';
                  if (field.type == 'color' &&
                      !RegExp(r'^#[0-9A-Fa-f]{6}$').hasMatch(v))
                    return 'Use #RRGGBB';
                  if ((field.type == 'url' || field.type == 'urls') &&
                      v
                          .split('\n')
                          .any(
                            (u) =>
                                Uri.tryParse(u.trim())?.scheme != 'https' ||
                                (Uri.tryParse(u.trim())?.host.isEmpty ?? true),
                          ))
                    return 'Use HTTPS URLs';
                  return null;
                },
              ),
            );
          }),
          if (widget.fields.any(
            (f) => f.type == 'datetime' || f.type == 'date',
          ))
            const Text(
              'Choose dates and times in your device timezone. Reports use the gym timezone.',
            ),
          FilledButton(
            onPressed: () {
              if (!form.currentState!.validate()) return;
              final values = <String, dynamic>{
                for (final f in widget.fields)
                  f.key: selectedIds.containsKey(f.key)
                      ? selectedIds[f.key]
                      : f.type == 'integer'
                      ? int.parse(controls[f.key]!.text.trim())
                      : f.type == 'urls'
                      ? controls[f.key]!.text
                            .split('\n')
                            .map((s) => s.trim())
                            .where((s) => s.isNotEmpty)
                            .toList()
                      : controls[f.key]!.text.trim(),
              };
              if (values.containsKey('endsAt') &&
                  !DateTime.parse(
                    values['endsAt'] as String,
                  ).isAfter(DateTime.parse(values['startsAt'] as String))) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Expiry must follow the start date.'),
                  ),
                );
                return;
              }
              Navigator.pop(context, values);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );
}

class EnterpriseRecordPicker extends StatefulWidget {
  final String resource, title;
  const EnterpriseRecordPicker({
    super.key,
    required this.resource,
    required this.title,
  });
  @override
  State<EnterpriseRecordPicker> createState() => _EnterpriseRecordPickerState();
}

class _EnterpriseRecordPickerState extends State<EnterpriseRecordPicker> {
  final items = <Map<String, dynamic>>[];
  String? cursor, error;
  bool loading = false;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final page = EnterprisePage.fromJson(
        await EnterpriseService.instance.scoped(
          '${widget.resource}?limit=30${cursor == null ? '' : '&cursor=${Uri.encodeQueryComponent(cursor!)}'}',
          admin: true,
        ),
      );
      if (mounted)
        setState(() {
          items.addAll(page.items);
          cursor = page.nextCursor;
        });
    } catch (e) {
      if (mounted) setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('Select ${widget.title}')),
    body: ListView(
      children: [
        if (loading) const LinearProgressIndicator(),
        if (error != null)
          ListTile(
            title: Text(error!),
            trailing: TextButton(onPressed: load, child: const Text('Retry')),
          ),
        ...items.map(
          (item) => ListTile(
            title: Text('${item['name'] ?? item['title'] ?? item['email']}'),
            onTap: () => Navigator.pop(context, item),
          ),
        ),
        if (!loading && items.isEmpty && error == null)
          const ListTile(
            title: Text('No records available. Create one first.'),
          ),
        if (cursor != null)
          TextButton(
            onPressed: loading ? null : load,
            child: const Text('Load more'),
          ),
      ],
    ),
  );
}

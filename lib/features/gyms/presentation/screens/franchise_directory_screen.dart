import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/enterprise_gym_model.dart';
import '../../data/models/tenant_configuration.dart';
import '../../data/services/enterprise_service.dart';
import '../widgets/gym_brand_logo.dart';

/// Public brand → city/market → branch discovery. A branch is never inferred
/// from the franchise name: only directory/API records are selectable.
class FranchiseDirectoryScreen extends StatefulWidget {
  const FranchiseDirectoryScreen({
    super.key,
    this.initialGyms = const [],
    this.ownerMode = false,
    this.onSelect,
  });

  final List<EnterpriseGymModel> initialGyms;
  final bool ownerMode;
  final void Function(EnterpriseGymModel, List<EnterpriseGymModel>)? onSelect;

  @override
  State<FranchiseDirectoryScreen> createState() =>
      _FranchiseDirectoryScreenState();
}

class _FranchiseDirectoryScreenState extends State<FranchiseDirectoryScreen> {
  final _search = TextEditingController();
  final _gyms = <String, EnterpriseGymModel>{};
  Timer? _debounce;
  int _request = 0;
  String _query = '';
  String? _brandKey, _market;
  String? _cursor;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    for (final gym in widget.initialGyms) _gyms[gym.id] = gym;
    _load();
  }

  @override
  void dispose() {
    _request++;
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load({bool more = false}) async {
    if (more && (_cursor == null || _loading)) return;
    final request = ++_request;
    setState(() => _loading = true);
    try {
      final page = await EnterpriseService.instance.directory(
        cursor: more ? _cursor : null, query: _query);
      if (!mounted || request != _request) return;
      setState(() {
        _cursor = page.nextCursor;
        for (final item in page.items) {
          try {
            for (final gym in TenantConfiguration.fromJson(item).toGyms()) {
              _gyms[gym.id] = gym;
            }
          } catch (_) {
            // An incomplete tenant must not hide the other real branches.
          }
        }
      });
      // The place-search endpoint supplies prospective facilities by city/ZIP.
      if (!more && _query.trim().length >= 3) {
        final matches = await EnterpriseService.instance.searchFacilities(_query);
        if (!mounted || request != _request) return;
        setState(() {
          for (final item in matches) {
            for (final gym in item.toGyms(isActivated: false)) {
              _gyms.putIfAbsent(gym.id, () => gym);
            }
          }
        });
      }
    } catch (_) {
      // Bundled and already loaded records remain browsable offline.
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  String _marketFor(EnterpriseGymModel gym) => [gym.city, gym.state]
      .where((part) => part.trim().isNotEmpty)
      .join(', ')
      .trim();

  Map<String, List<EnterpriseGymModel>> get _brands {
    final result = <String, List<EnterpriseGymModel>>{};
    for (final gym in _gyms.values) {
      result.putIfAbsent(gym.franchiseKey, () => []).add(gym);
    }
    return result;
  }

  void _select(EnterpriseGymModel gym) {
    if (widget.ownerMode) {
      Navigator.of(context).pop(gym);
    } else {
      widget.onSelect?.call(gym, _brands[gym.franchiseKey] ?? [gym]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brands = _brands;
    final query = _query.trim().toLowerCase();
    final selected = brands[_brandKey] ?? const <EnterpriseGymModel>[];
    final markets = <String, List<EnterpriseGymModel>>{};
    for (final gym in selected) {
      markets.putIfAbsent(_marketFor(gym).isEmpty ? 'Other locations' : _marketFor(gym), () => []).add(gym);
    }
    final sortedMarkets = markets.entries.toList()
      ..sort((a, b) {
        final count = b.value.length.compareTo(a.value.length);
        return count != 0 ? count : a.key.compareTo(b.key);
      });
    final brandEntries = brands.entries.where((entry) {
      if (query.isEmpty) return true;
      return entry.value.any((gym) =>
          gym.displayFranchiseName.toLowerCase().contains(query) ||
          gym.name.toLowerCase().contains(query) ||
          gym.city.toLowerCase().contains(query) ||
          gym.state.toLowerCase().contains(query) ||
          gym.zipCode.toLowerCase().contains(query) ||
          gym.address.toLowerCase().contains(query));
    }).toList()..sort((a, b) => a.value.first.displayFranchiseName.compareTo(b.value.first.displayFranchiseName));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      appBar: AppBar(
        title: Text(_brandKey == null
            ? (widget.ownerMode ? 'Select franchise' : 'Find a franchise')
            : selected.first.displayFranchiseName,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (_brandKey != null) {
              setState(() { _brandKey = null; _market = null; });
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
          children: [
            Text(_brandKey == null ? 'Choose a gym brand' : 'Choose a city or town',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600,
                    color: const Color(0xFF171820))),
            SizedBox(height: 5.h),
            Text(_brandKey == null
                    ? 'Find the exact facility before ${widget.ownerMode ? 'requesting a claim' : 'joining'}.'
                    : '${selected.length} available ${selected.length == 1 ? 'location' : 'locations'} · ${markets.length} cities and towns',
                style: TextStyle(fontSize: 11.sp, color: const Color(0xFF747680))),
            SizedBox(height: 16.h),
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search brand, city, town or ZIP',
                prefixIcon: const Icon(Icons.search_rounded),
                filled: true, fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFFE6E7EA))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: Color(0xFFE6E7EA))),
              ),
              onChanged: (value) {
                setState(() { _query = value; _market = null; });
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 450), () => _load());
              },
            ),
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            SizedBox(height: 16.h),
            if (_brandKey == null) ...[
              for (final entry in brandEntries)
                _DirectoryRow(
                  gym: entry.value.first,
                  title: entry.value.first.displayFranchiseName,
                  subtitle: '${entry.value.length} available ${entry.value.length == 1 ? 'location' : 'locations'}',
                  onTap: () => setState(() { _brandKey = entry.key; _market = null; _search.clear(); _query = ''; }),
                ),
              if (_cursor != null)
                TextButton(onPressed: _loading ? null : () => _load(more: true),
                    child: const Text('Load more franchises')),
              if (brandEntries.isEmpty && !_loading)
                const Text('No matching brands in the available directory.'),
            ] else ...[
              Text('Cities & towns', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 8.h),
              for (final entry in sortedMarkets)
                if (query.isEmpty || entry.key.toLowerCase().contains(query) ||
                    entry.value.any((gym) => gym.address.toLowerCase().contains(query) || gym.zipCode.contains(query)))
                  _MarketRow(
                    label: entry.key,
                    count: entry.value.length,
                    selected: _market == entry.key,
                    color: selected.first.entryColor,
                    onTap: () => setState(() => _market = _market == entry.key ? null : entry.key),
                  ),
              if (_market != null) ...[
                SizedBox(height: 14.h),
                Text('Branches in $_market', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                SizedBox(height: 8.h),
                for (final gym in markets[_market] ?? const <EnterpriseGymModel>[])
                  _DirectoryRow(
                    gym: gym,
                    title: gym.name,
                    subtitle: [gym.address, gym.isActivated ? 'P2P partner' : 'Partnership not yet established']
                        .where((value) => value.isNotEmpty).join(' · '),
                    onTap: () => _select(gym),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _MarketRow extends StatelessWidget {
  const _MarketRow({required this.label, required this.count, required this.selected,
    required this.color, required this.onTap});
  final String label;
  final int count;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r),
          side: BorderSide(color: selected ? color : const Color(0xFFE6E7EA))),
        child: ListTile(
          onTap: onTap,
          leading: Icon(Icons.location_on_outlined, color: selected ? color : const Color(0xFF777983)),
          title: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          subtitle: Text('$count ${count == 1 ? 'location' : 'locations'}', style: TextStyle(fontSize: 10.sp)),
          trailing: Icon(selected ? Icons.keyboard_arrow_up_rounded : Icons.chevron_right_rounded),
        ),
      );
}

class _DirectoryRow extends StatelessWidget {
  const _DirectoryRow({required this.gym, required this.title, required this.subtitle,
    required this.onTap});
  final EnterpriseGymModel gym;
  final String title, subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13.r),
          side: const BorderSide(color: Color(0xFFE6E7EA))),
        child: ListTile(
          onTap: onTap,
          leading: GymBrandLogo(gym: gym, size: 42.r, borderRadius: 10.r),
          title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.sp, color: const Color(0xFF747680))),
          trailing: const Icon(Icons.chevron_right_rounded, size: 19),
        ),
      );
}

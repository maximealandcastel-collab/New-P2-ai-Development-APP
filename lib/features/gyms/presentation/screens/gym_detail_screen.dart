import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

class GymDetailScreen extends StatefulWidget {
  const GymDetailScreen({
    super.key,
    required this.gym,
    this.locations = const [],
    required this.onOpenMaps,
    required this.onClaim,
    required this.onEnter,
  });

  final EnterpriseGymModel gym;
  final List<EnterpriseGymModel> locations;
  final ValueChanged<EnterpriseGymModel> onOpenMaps;
  final ValueChanged<EnterpriseGymModel> onClaim;
  final ValueChanged<EnterpriseGymModel> onEnter;

  @override
  State<GymDetailScreen> createState() => _GymDetailScreenState();
}

class _GymDetailScreenState extends State<GymDetailScreen> {
  late EnterpriseGymModel _selectedGym;
  late List<EnterpriseGymModel> _locations;

  EnterpriseGymModel get gym => _selectedGym;

  @override
  void initState() {
    super.initState();
    _selectedGym = widget.gym;
    final candidates = <EnterpriseGymModel>[widget.gym, ...widget.locations];
    final seen = <String>{};
    _locations = candidates
        .where((item) => seen.add(item.id))
        .toList(growable: false);
  }

  bool get _hasLocation => gym.address.isNotEmpty || gym.city.isNotEmpty;
  bool get _hasHero => gym.stockPhotoAssetPath.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final active = gym.isActivated;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
              ),
              title: Text(
                gym.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171820),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasHero)
                    GymStockImage(
                      gym: gym,
                      height: 205.h,
                      width: double.infinity,
                      showLogo: false,
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GymBrandLogo(
                              gym: gym,
                              size: 58.r,
                              borderRadius: 14.r,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    gym.name,
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF171820),
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    gym.category,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: const Color(0xFF747680),
                                    ),
                                  ),
                                  SizedBox(height: 7.h),
                                  _MetadataRow(gym: gym),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (_locations.isNotEmpty) ...[
                          SizedBox(height: 18.h),
                          _LocationSelector(
                            gym: gym,
                            locations: _locations,
                            onSelected: (selected) =>
                                setState(() => _selectedGym = selected),
                          ),
                        ],
                        if (_hasLocation) ...[
                          SizedBox(height: 10.h),
                          _InfoCard(
                            icon: Icons.location_on_outlined,
                            title: gym.address.isNotEmpty
                                ? gym.address
                                : gym.city,
                            actionLabel: 'Directions',
                            onTap: () => widget.onOpenMaps(gym),
                          ),
                        ],
                        if (gym.tagline.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('About'),
                          SizedBox(height: 7.h),
                          Text(
                            gym.tagline,
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.45,
                              color: const Color(0xFF646670),
                            ),
                          ),
                        ],
                        if (gym.filterTags.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('Amenities & training'),
                          SizedBox(height: 9.h),
                          Wrap(
                            spacing: 7.w,
                            runSpacing: 7.h,
                            children: gym.filterTags
                                .map(
                                  (tag) => Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 6.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20.r),
                                      border: Border.all(
                                        color: const Color(0xFFE6E7EA),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: const Color(0xFF5F616B),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (gym.displayGalleryAssetPaths.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('Photos'),
                          SizedBox(height: 10.h),
                          SizedBox(
                            height: 108.h,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: gym.displayGalleryAssetPaths.length,
                              separatorBuilder: (_, __) => SizedBox(width: 8.w),
                              itemBuilder: (_, index) => ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: GymStockImage(
                                  gym: gym,
                                  source: gym.displayGalleryAssetPaths[index],
                                  width: 152.w,
                                  height: 108.h,
                                  showLogo: false,
                                ),
                              ),
                            ),
                          ),
                        ],
                        SizedBox(height: 22.h),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(13.r),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(0xFFEAF8EF)
                                : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(13.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                active
                                    ? Icons.verified_outlined
                                    : Icons.lock_outline_rounded,
                                size: 16.sp,
                                color: active
                                    ? const Color(0xFF287A46)
                                    : const Color(0xFF777983),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  active ? 'Active P2P partner' : gym.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.35,
                                    color: active
                                        ? const Color(0xFF287A46)
                                        : const Color(0xFF696B75),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 14.h),
                        SizedBox(
                          width: double.infinity,
                          height: 46.h,
                          child: FilledButton(
                            onPressed: () => active
                                ? widget.onEnter(gym)
                                : widget.onClaim(gym),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  active ? gym.entryColor : Colors.white,
                              foregroundColor: active
                                  ? gym.entryTextColor
                                  : gym.brandColor,
                              elevation: 0,
                              side: active
                                  ? BorderSide.none
                                  : BorderSide(
                                      color: gym.brandColor.withOpacity(.28),
                                      width: 1.2,
                                    ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!active) ...[
                                  Icon(
                                    Icons.verified_outlined,
                                    size: 16.sp,
                                    color: gym.accentColor,
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                                Flexible(
                                  child: Text(
                                    active
                                        ? 'Enter ${gym.name}'
                                        : 'Claim this gym',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                if (!active) ...[
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16.sp,
                                    color: gym.accentColor,
                                  ),
                                ],
                              ],
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
        ),
      ),
    );
  }
}

class _LocationSelector extends StatelessWidget {
  const _LocationSelector({
    required this.gym,
    required this.locations,
    required this.onSelected,
  });

  final EnterpriseGymModel gym;
  final List<EnterpriseGymModel> locations;
  final ValueChanged<EnterpriseGymModel> onSelected;

  String _label(EnterpriseGymModel item) {
    if (item.address.isNotEmpty) return item.address;
    if (item.city.isNotEmpty) return item.city;
    return item.name;
  }

  Future<void> _openLocations(BuildContext context) async {
    if (locations.length <= 1) return;
    final selected = await showModalBottomSheet<EnterpriseGymModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FranchiseLocationsSheet(
        franchiseName: gym.displayFranchiseName,
        selectedGym: gym,
        locations: locations,
      ),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) => Semantics(
        button: locations.length > 1,
        label: locations.length > 1
            ? 'Choose ${gym.displayFranchiseName} franchise location'
            : 'Only one franchise location is available',
        child: InkWell(
          onTap: locations.length > 1 ? () => _openLocations(context) : null,
          borderRadius: BorderRadius.circular(13.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: const Color(0xFFE6E7EA)),
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: gym.entryColor.withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 17.sp,
                    color: gym.entryColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        locations.length > 1
                            ? 'Choose city, town or location'
                            : 'Location',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: const Color(0xFF898B94),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        _label(gym),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF292B33),
                        ),
                      ),
                    ],
                  ),
                ),
                if (locations.length > 1)
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.sp,
                    color: const Color(0xFF777983),
                  ),
              ],
            ),
          ),
        ),
      );
}

class _FranchiseLocationsSheet extends StatefulWidget {
  const _FranchiseLocationsSheet({
    required this.franchiseName,
    required this.selectedGym,
    required this.locations,
  });

  final String franchiseName;
  final EnterpriseGymModel selectedGym;
  final List<EnterpriseGymModel> locations;

  @override
  State<_FranchiseLocationsSheet> createState() =>
      _FranchiseLocationsSheetState();
}

class _FranchiseLocationsSheetState
    extends State<_FranchiseLocationsSheet> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _city;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _cityFor(EnterpriseGymModel item) =>
      item.city.trim().isEmpty ? 'Other locations' : item.city.trim();

  String _label(EnterpriseGymModel item) {
    if (item.address.isNotEmpty) return item.address;
    if (item.zipCode.isNotEmpty) return '${_cityFor(item)} ${item.zipCode}';
    return _cityFor(item);
  }

  List<MapEntry<String, List<EnterpriseGymModel>>> get _cityGroups {
    final grouped = <String, List<EnterpriseGymModel>>{};
    for (final location in widget.locations) {
      grouped.putIfAbsent(_cityFor(location), () => []).add(location);
    }
    final groups = grouped.entries.toList();
    // Cities with the most available branches are surfaced first. This uses
    // real directory coverage rather than invented popularity values.
    groups.sort((a, b) {
      final count = b.value.length.compareTo(a.value.length);
      return count != 0 ? count : a.key.compareTo(b.key);
    });
    return groups;
  }

  List<MapEntry<String, List<EnterpriseGymModel>>> get _visibleGroups {
    final query = _query.trim().toLowerCase();
    return _cityGroups
        .where((entry) => _city == null || entry.key == _city)
        .map((entry) {
          final locations = entry.value.where((item) {
            if (query.isEmpty) return true;
            return item.name.toLowerCase().contains(query) ||
                item.city.toLowerCase().contains(query) ||
                item.zipCode.toLowerCase().contains(query) ||
                item.address.toLowerCase().contains(query);
          }).toList(growable: false);
          return MapEntry(entry.key, locations);
        })
        .where((entry) => entry.value.isNotEmpty)
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final groups = _cityGroups;
    final visible = _visibleGroups;
    return FractionallySizedBox(
      heightFactor: .86,
      child: Material(
        color: const Color(0xFFF8F8F9),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(height: 10.h),
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9DBE1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 10.h),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.franchiseName} locations',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF171820),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            '${groups.length} cities and towns · ${widget.locations.length} locations',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: const Color(0xFF747680),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search city, town, ZIP or address',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE6E7EA)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14.r),
                      borderSide: const BorderSide(color: Color(0xFFE6E7EA)),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Top cities & towns',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF5F616B),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 7.h),
              SizedBox(
                height: 36.h,
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CityChip(
                      label: 'All',
                      selected: _city == null,
                      selectedColor: widget.selectedGym.entryColor,
                      onTap: () => setState(() => _city = null),
                    ),
                    ...groups.take(8).map(
                      (entry) => _CityChip(
                        label: '${entry.key} ${entry.value.length}',
                        selected: _city == entry.key,
                        selectedColor: widget.selectedGym.entryColor,
                        onTap: () => setState(() => _city = entry.key),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Expanded(
                child: visible.isEmpty
                    ? const Center(child: Text('No locations found.'))
                    : ListView.builder(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                        itemCount: visible.length,
                        itemBuilder: (context, groupIndex) {
                          final group = visible[groupIndex];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(top: 13.h, bottom: 7.h),
                                child: Text(
                                  group.key,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF292B33),
                                  ),
                                ),
                              ),
                              ...group.value.map(
                                (item) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: _LocationRow(
                                    gym: item,
                                    selected: item.id == widget.selectedGym.id,
                                    label: _label(item),
                                    onTap: () => Navigator.pop(context, item),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CityChip extends StatelessWidget {
  const _CityChip({
    required this.label,
    required this.selected,
    required this.selectedColor,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(right: 7.w),
        child: ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) => onTap(),
          showCheckmark: false,
          backgroundColor: Colors.white,
          selectedColor: selectedColor,
          side: const BorderSide(color: Color(0xFFE6E7EA)),
          labelStyle: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : const Color(0xFF5F616B),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
      );
}

class _LocationRow extends StatelessWidget {
  const _LocationRow({
    required this.gym,
    required this.selected,
    required this.label,
    required this.onTap,
  });
  final EnterpriseGymModel gym;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: selected
                    ? gym.entryColor.withOpacity(.55)
                    : const Color(0xFFE8E9ED),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.location_on_outlined,
                  size: 18.sp,
                  color: selected
                      ? gym.entryColor
                      : const Color(0xFF777983),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF171820),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.sp,
                          height: 1.35,
                          color: const Color(0xFF747680),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 19.sp,
                  color: const Color(0xFF92949D),
                ),
              ],
            ),
          ),
        ),
      );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF171820),
        ),
      );
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.gym});
  final EnterpriseGymModel gym;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    if (gym.rating > 0) {
      items.addAll([
        Icon(Icons.star_rounded, size: 13.sp, color: const Color(0xFFFFB000)),
        SizedBox(width: 2.w),
        Text(gym.rating.toStringAsFixed(1)),
      ]);
    }
    if (gym.memberCount.isNotEmpty) {
      if (items.isNotEmpty) items.add(const Text('  ·  '));
      items.add(Flexible(
        child: Text(gym.memberCount,
            maxLines: 1, overflow: TextOverflow.ellipsis),
      ));
    }
    if (gym.distanceMi != null) {
      if (items.isNotEmpty) items.add(const Text('  ·  '));
      items.add(Text(gym.distanceLabel));
    }
    return DefaultTextStyle(
      style: TextStyle(fontSize: 10.sp, color: const Color(0xFF747680)),
      child: Row(children: items),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEDEEF1)),
            borderRadius: BorderRadius.circular(13.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18.sp, color: primary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: const Color(0xFF5F616B),
                  ),
                ),
              ),
              Text(
                actionLabel,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w600,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

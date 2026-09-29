import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/tenant_configuration.dart';
import 'package:pler_to_pler_app/features/gyms/data/services/enterprise_service.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_mesh.dart';

/// Opens the shared member-facing franchise location picker.
///
/// Keeping this entry point public lets the detail and join-confirmation
/// screens use the same city -> branch workflow and the same real directory
/// records.
Future<EnterpriseGymModel?> showFranchiseLocationPicker(
  BuildContext context, {
  required EnterpriseGymModel selectedGym,
  required List<EnterpriseGymModel> locations,
}) =>
    showModalBottomSheet<EnterpriseGymModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FranchiseLocationsSheet(
        franchiseName: selectedGym.displayFranchiseName,
        selectedGym: selectedGym,
        locations: locations,
      ),
    );

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
  // KMF's approved reference uses a light, logo-first header. Other gyms,
  // including YMCA, keep the branded photo header when a photo is available.
  bool get _sunnyKmf => gym.id == 'kmf_fitness_club' ||
      gym.tenantId == 'kmf-fitness';
  bool get _hasHero => gym.stockPhotoAssetPath.isNotEmpty && !_sunnyKmf;

  void _openGallery() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(sheetContext).height * .72,
          child: Column(children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 8.w, 12.h),
              child: Row(children: [
                Expanded(child: Text('${gym.name} photos',
                  style: TextStyle(fontSize: 17.sp,
                    fontWeight: FontWeight.w600))),
                IconButton(onPressed: () => Navigator.pop(sheetContext),
                  icon: const Icon(Icons.close_rounded)),
              ]),
            ),
            Expanded(child: GridView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h, childAspectRatio: 1.15),
              itemCount: gym.displayGalleryAssetPaths.length,
              itemBuilder: (_, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: GymStockImage(gym: gym,
                  source: gym.displayGalleryAssetPaths[index],
                  width: double.infinity, height: double.infinity,
                  showLogo: false),
              ),
            )),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final active = gym.isActivated;

    return Scaffold(
      backgroundColor: _sunnyKmf ? const Color(0xFFFCFCFB) :
          const Color(0xFFF8F8F9),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: !_hasHero,
              expandedHeight: _hasHero ? 235.h : null,
              elevation: 0,
              backgroundColor: _hasHero ? gym.brandColor : Colors.white,
              surfaceTintColor: Colors.transparent,
              leading: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: _hasHero ? Colors.white : const Color(0xFF171820)),
              ),
              title: _hasHero ? null : Text(
                gym.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF171820),
                ),
              ),
              flexibleSpace: _hasHero
                  ? FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          GymStockImage(gym: gym, height: 235.h,
                              width: double.infinity, showLogo: false),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(.04),
                                  Colors.black.withOpacity(.15),
                                  Color.lerp(const Color(0xFF191A20),
                                      gym.brandColor, .22)!.withOpacity(.92),
                                ],
                                stops: const [0, .4, 1],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20.w, right: 20.w, bottom: 18.h,
                            child: Row(children: [
                              GymBrandLogo(gym: gym, size: 64.r,
                                  borderRadius: 17.r),
                              SizedBox(width: 12.w),
                              Expanded(child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(gym.name, maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.white,
                                      fontSize: 21.sp,
                                      fontWeight: FontWeight.w600)),
                                  SizedBox(height: 3.h),
                                  Text(gym.category, style: TextStyle(
                                    color: Colors.white.withOpacity(.85),
                                    fontSize: 11.5.sp)),
                                  SizedBox(height: 5.h),
                                  DefaultTextStyle(
                                    style: TextStyle(fontSize: 10.sp,
                                      color: Colors.white.withOpacity(.82)),
                                    child: _MetadataRow(gym: gym,
                                      color: Colors.white.withOpacity(.82)),
                                  ),
                                ],
                              )),
                            ]),
                          ),
                        ],
                      ),
                    )
                  : null,
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 30.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!_hasHero) Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                boxShadow: _sunnyKmf ? [
                                  GymBrandMesh.sunnyShadow(gym.brandColor),
                                ] : null,
                              ),
                              child: GymBrandLogo(
                                gym: gym,
                                size: 58.r,
                                borderRadius: 14.r,
                              ),
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
                            sunny: _sunnyKmf,
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
                            accentColor: gym.brandColor,
                            signatureAccent: _sunnyKmf,
                            onTap: () => widget.onOpenMaps(gym),
                          ),
                        ],
                        if (gym.tagline.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          _SectionTitle('About', accent: gym.brandColor),
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
                          _SectionTitle('Amenities & training', accent: gym.brandColor),
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
                                        color: gym.brandColor.withOpacity(.30),
                                      ),
                                      boxShadow: [_sunnyKmf
                                          ? GymBrandMesh.sunnyShadow(gym.brandColor)
                                          : GymBrandMesh.shadow(gym.brandColor)],
                                    ),
                                    child: Row(mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(tag.toLowerCase().contains('box')
                                            ? Icons.sports_mma_rounded
                                            : Icons.fitness_center_rounded,
                                          size: 12.sp,
                                          color: GymBrandMesh.darkBrand(gym.brandColor)),
                                        SizedBox(width: 5.w),
                                        Text(tag, style: TextStyle(
                                          fontSize: 10.sp,
                                          color: const Color(0xFF292B33),
                                        )),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        if (gym.displayGalleryAssetPaths.isNotEmpty) ...[
                          SizedBox(height: 22.h),
                          Row(children: [
                            Expanded(child: _SectionTitle('Photos',
                              accent: gym.brandColor)),
                            TextButton(
                              onPressed: _openGallery,
                              child: Text('See all photos', style: TextStyle(
                                color: Color.lerp(Colors.black,
                                  gym.brandColor, .75))),
                            ),
                          ]),
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
                            color: Color.lerp(Colors.white, gym.brandColor,
                                _sunnyKmf ? .12 : .075),
                            borderRadius: BorderRadius.circular(13.r),
                            boxShadow: [
                              _sunnyKmf
                                  ? GymBrandMesh.sunnyShadow(gym.brandColor)
                                  : GymBrandMesh.franchiseShadow(
                                      gym.brandColor, gym.accentColor),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                active
                                    ? Icons.verified_outlined
                                    : Icons.lock_outline_rounded,
                                size: 16.sp,
                                color: GymBrandMesh.darkBrand(gym.brandColor),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  active ? 'Active P2P partner' : gym.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    height: 1.35,
                                    color: GymBrandMesh.darkBrand(gym.brandColor),
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
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: active
                                  ? _sunnyKmf
                                      ? GymBrandMesh.sunnyAction(gym.brandColor)
                                      : GymBrandMesh.detailAction(gym.brandColor)
                                  : null,
                              borderRadius: BorderRadius.circular(24.r),
                              border: _sunnyKmf && active ? Border.all(
                                color: gym.brandColor.withOpacity(.45)) : null,
                              boxShadow: [_sunnyKmf
                                  ? GymBrandMesh.sunnyShadow(gym.brandColor)
                                  : GymBrandMesh.franchiseShadow(
                                      gym.brandColor, gym.accentColor)],
                            ),
                            child: FilledButton(
                            onPressed: () => active
                                ? widget.onEnter(gym)
                                : widget.onClaim(gym),
                            style: FilledButton.styleFrom(
                              backgroundColor:
                                  active ? Colors.transparent : Colors.white,
                              foregroundColor: active
                                  ? Colors.white
                                  : GymBrandMesh.darkBrand(gym.brandColor),
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
                              shadowColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!active) ...[
                                  Icon(
                                    Icons.verified_outlined,
                                    size: 16.sp,
                                    color: GymBrandMesh.darkBrand(gym.brandColor),
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
                                if (active) ...[
                                  SizedBox(width: 8.w),
                                  Icon(Icons.arrow_forward_rounded,
                                    size: 16.sp, color: Colors.white),
                                ],
                                if (!active) ...[
                                  SizedBox(width: 8.w),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16.sp,
                                    color: GymBrandMesh.darkBrand(gym.brandColor),
                                  ),
                                ],
                              ],
                            ),
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
    this.sunny = false,
  });

  final EnterpriseGymModel gym;
  final List<EnterpriseGymModel> locations;
  final ValueChanged<EnterpriseGymModel> onSelected;
  final bool sunny;

  String _label(EnterpriseGymModel item) {
    if (item.address.isNotEmpty) return item.address;
    if (item.city.isNotEmpty) {
      return [item.city, item.state]
          .where((part) => part.isNotEmpty)
          .join(', ');
    }
    return item.name;
  }

  Future<void> _openLocations(BuildContext context) async {
    final selected = await showFranchiseLocationPicker(
      context,
      selectedGym: gym,
      locations: locations,
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final canBrowse = gym.isFranchiseBrand || locations.length > 1;
    return Semantics(
        button: canBrowse,
        label: canBrowse
            ? 'Choose ${gym.displayFranchiseName} franchise location'
            : 'Only one franchise location is available',
        child: InkWell(
          onTap: canBrowse ? () => _openLocations(context) : null,
          borderRadius: BorderRadius.circular(13.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: gym.brandColor.withOpacity(
                  sunny ? .23 : .12)),
              boxShadow: [sunny
                  ? GymBrandMesh.sunnyShadow(gym.brandColor)
                  : GymBrandMesh.franchiseShadow(
                      gym.brandColor, gym.accentColor)],
            ),
            child: Row(
              children: [
                Container(
                  width: 32.r,
                  height: 32.r,
                  decoration: BoxDecoration(
                    color: sunny ? gym.brandColor.withOpacity(.10)
                        : gym.entryColor.withOpacity(.09),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 17.sp,
                    color: sunny ? GymBrandMesh.darkBrand(gym.brandColor)
                        : gym.entryColor,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        canBrowse
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
                if (canBrowse)
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
  final _discovered = <String, EnterpriseGymModel>{};
  final _marketResultIds = <String>{};
  String _query = '';
  String? _city;
  bool _loadingDirectory = true;
  bool _loadingMarket = false;
  int _searchVersion = 0;

  // These are market search shortcuts, not fabricated branch records. A
  // branch is selectable only when the directory or place search returns it.
  static const _popularMarkets = <String>[
    'New York, NY',
    'Los Angeles, CA',
    'Miami, FL',
    'Chicago, IL',
    'Houston, TX',
    'Atlanta, GA',
    'Dallas, TX',
    'Phoenix, AZ',
    'Philadelphia, PA',
  ];

  @override
  void initState() {
    super.initState();
    for (final location in [widget.selectedGym, ...widget.locations]) {
      _discovered[location.id] = location;
    }
    _loadDirectory();
  }

  @override
  void dispose() {
    _searchVersion++;
    _searchController.dispose();
    super.dispose();
  }

  String _normalized(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');

  bool _belongsToFranchise(EnterpriseGymModel item) {
    final brand = _normalized(widget.franchiseName);
    return _normalized(item.franchiseKey) ==
            _normalized(widget.selectedGym.franchiseKey) ||
        _normalized(item.displayFranchiseName) == brand ||
        (brand.isNotEmpty && _normalized(item.name).startsWith(brand));
  }

  void _addRecords(Iterable<EnterpriseGymModel> records) {
    if (!mounted) return;
    setState(() {
      for (final item in records.where(_belongsToFranchise)) {
        if (!(_discovered[item.id]?.isActivated ?? false) || item.isActivated) {
          _discovered[item.id] = item;
        }
      }
    });
  }

  Future<void> _loadDirectory() async {
    try {
      String? cursor;
      final seenCursors = <String>{};
      do {
        final page = await EnterpriseService.instance.directory(
          cursor: cursor,
          query: widget.franchiseName,
        );
        final records = <EnterpriseGymModel>[];
        for (final raw in page.items) {
          try {
            records.addAll(TenantConfiguration.fromJson(raw).toGyms());
          } catch (_) {
            // An incomplete tenant cannot hide the other franchise branches.
          }
        }
        _addRecords(records);
        cursor = page.nextCursor;
      } while (mounted && cursor != null && seenCursors.add(cursor));
    } catch (_) {
      // Keep bundled and previously loaded branches available offline.
    } finally {
      if (mounted) setState(() => _loadingDirectory = false);
    }
  }

  Future<void> _searchFacilities(String market) async {
    final request = ++_searchVersion;
    setState(() => _loadingMarket = true);
    try {
      final results = await EnterpriseService.instance.searchFacilities(
        '${widget.franchiseName} $market',
      );
      if (!mounted || request != _searchVersion) return;
      final matching = results
          .expand((item) => item.toGyms(isActivated: false))
          .where(_belongsToFranchise)
          .toList(growable: false);
      _addRecords(matching);
      setState(() {
        _marketResultIds
          ..clear()
          ..addAll(matching.map((item) => item.id));
      });
    } catch (_) {
      // Keep the current market visible with an honest empty state.
    } finally {
      if (mounted && request == _searchVersion) {
        setState(() => _loadingMarket = false);
      }
    }
  }

  void _selectMarket(String market) {
    _searchController.clear();
    setState(() {
      _query = '';
      _city = market;
      _marketResultIds.clear();
    });
    _searchFacilities(market);
  }

  String _cityFor(EnterpriseGymModel item) {
    final market = [item.city, item.state]
        .where((part) => part.trim().isNotEmpty).join(', ');
    return market.isEmpty ? 'Other locations' : market;
  }

  String _label(EnterpriseGymModel item) {
    if (item.address.isNotEmpty) return item.address;
    if (item.zipCode.isNotEmpty) return '${_cityFor(item)} ${item.zipCode}';
    return _cityFor(item);
  }

  List<MapEntry<String, List<EnterpriseGymModel>>> get _cityGroups {
    final grouped = <String, List<EnterpriseGymModel>>{};
    for (final location in _discovered.values) {
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
        .where((entry) => _city == null || entry.key == _city ||
            entry.value.any((item) {
              final chosenCity = _city!.split(',').first.trim().toLowerCase();
              final chosenState = _city!.contains(',')
                  ? _city!.split(',').last.trim().toLowerCase()
                  : '';
              return _marketResultIds.contains(item.id) ||
                  item.city.toLowerCase() == chosenCity &&
                  (chosenState.isEmpty || item.state.isEmpty ||
                      item.state.toLowerCase() == chosenState);
            }))
        .map((entry) {
          final locations = entry.value.where((item) {
            if (query.isEmpty) return true;
            return item.name.toLowerCase().contains(query) ||
                item.city.toLowerCase().contains(query) ||
                item.state.toLowerCase().contains(query) ||
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
                            '${groups.length} cities and towns · ${_discovered.length} available locations',
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
                  onChanged: (value) {
                    setState(() {
                      _query = value;
                      _city = null;
                    });
                  },
                  onSubmitted: (value) {
                    if (value.trim().length >= 3) _searchFacilities(value.trim());
                  },
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
                      selectedTextColor: widget.selectedGym.entryTextColor,
                      onTap: () => setState(() => _city = null),
                    ),
                    if (widget.selectedGym.isFranchiseBrand)
                      ..._popularMarkets.map(
                        (market) => _CityChip(
                          label: market,
                          selected: _city == market,
                          selectedColor: widget.selectedGym.entryColor,
                          selectedTextColor: widget.selectedGym.entryTextColor,
                          onTap: () => _selectMarket(market),
                        ),
                      ),
                    ...groups.where((entry) =>
                        !_popularMarkets.contains(entry.key)).map(
                      (entry) => _CityChip(
                        label: '${entry.key} ${entry.value.length}',
                        selected: _city == entry.key,
                        selectedColor: widget.selectedGym.entryColor,
                        selectedTextColor: widget.selectedGym.entryTextColor,
                        onTap: () => setState(() => _city = entry.key),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              if (_loadingDirectory || _loadingMarket)
                const LinearProgressIndicator(minHeight: 2),
              Expanded(
                child: visible.isEmpty
                    ? Center(child: Padding(
                        padding: EdgeInsets.all(20.w),
                        child: Text(
                          _loadingDirectory || _loadingMarket
                              ? 'Finding ${widget.franchiseName} locations…'
                              : 'No listed ${widget.franchiseName} branch in this area yet. Search another city or ZIP.',
                          textAlign: TextAlign.center,
                        ),
                      ))
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
    required this.selectedTextColor,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final Color selectedColor;
  final Color selectedTextColor;
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
            color: selected ? selectedTextColor : const Color(0xFF5F616B),
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
  const _SectionTitle(this.text, {this.accent});
  final String text;
  final Color? accent;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171820),
          )),
          if (accent != null) ...[
            SizedBox(height: 4.h),
            Container(width: 18.w, height: 2.h,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(2.r))),
          ],
        ],
      );
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.gym, this.color = const Color(0xFF747680)});
  final EnterpriseGymModel gym;
  final Color color;

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
      style: TextStyle(fontSize: 10.sp, color: color),
      child: Row(children: items),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.actionLabel,
    required this.accentColor,
    required this.onTap,
    this.signatureAccent = false,
  });

  final IconData icon;
  final String title;
  final String actionLabel;
  final Color accentColor;
  final VoidCallback onTap;
  final bool signatureAccent;

  @override
  Widget build(BuildContext context) {
    final primary = signatureAccent
        ? const Color(0xFFE96C16)
        : Color.lerp(Colors.black, accentColor, .75)!;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            border: Border.all(color: accentColor.withOpacity(.13)),
            borderRadius: BorderRadius.circular(13.r),
            boxShadow: [signatureAccent
                ? GymBrandMesh.sunnyShadow(accentColor)
                : GymBrandMesh.shadow(accentColor)],
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

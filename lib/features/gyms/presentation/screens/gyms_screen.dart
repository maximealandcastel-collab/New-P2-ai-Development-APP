import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'dart:async';
import '../../data/services/enterprise_service.dart';
import 'gym_application_screen.dart';
import 'gym_detail_screen.dart';
import 'gym_login_preview_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/featured_gym_card.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_list_tile.dart';
import 'package:pler_to_pler_app/features/gyms/services/gym_location_service.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class GymsScreen extends StatefulWidget {
  const GymsScreen({
    super.key,
    this.onboardingMode = false,
    this.initialQuery = '',
  });

  final bool onboardingMode;
  final String initialQuery;

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {

  static const _filters = [
    'All Types',
    'Gym',
    'HIIT',
    'Yoga',
    'Pilates',
    'Boxing',
  ];
  static const _moreFilters = ['Cycling', 'Strength'];
  static const _favoriteGymCacheKey = 'favorite_gym_ids';

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _locationService = GymLocationService();

  String _activeFilter = 'All Types';
  String _searchQuery = '';
  bool _locationLoading = false;
  double? _searchLat,_searchLng;
  List<EnterpriseGymModel> _sortedGyms = [];
  Timer? _searchDebounce;
  int _requestVersion = 0;
  String? _cursor, _directoryError;
  bool _directoryLoading = false;
  Set<String> _favoriteGymIds = <String>{};
  Future<void> _loadDirectory({bool refresh = false}) async {
    if (_directoryLoading && !refresh) return;
    final version = ++_requestVersion;
    setState(() {
      _directoryLoading = true;
      _directoryError = null;
      if (refresh) {
        _cursor = null;
        _sortedGyms = [];
      }
    });
    try {
      late final List<EnterpriseGymModel> gyms;
      String? nextCursor;
      if (isSingleMode) {
        gyms = EnterpriseGymModel.partners;
      } else {
        final items = await EnterpriseService.instance.searchFacilities(
          _searchQuery,
          latitude: _searchLat,
          longitude: _searchLng,
          kind: _activeFilter == 'All Types' ? null : _activeFilter,
        );
        gyms=items.map((item)=>item.toGym()).toList();
        nextCursor=null;
      }
      if (mounted && version == _requestVersion)
        setState(() {
          _sortedGyms.addAll(gyms);
          _cursor = nextCursor;
        });
    } catch (e) {
      if (mounted && version == _requestVersion)
        setState(() => _directoryError = e.toString());
    } finally {
      if (mounted && version == _requestVersion)
        setState(() => _directoryLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery.trim();
    _searchController.text = _searchQuery;
    _favoriteGymIds = (CacheService().get<List>(_favoriteGymCacheKey) ?? const [])
        .map((id) => id.toString())
        .toSet();
    _loadDirectory();
    _detectLocationSilently();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _detectLocationSilently() async {
    final position = await _locationService.getCurrentPosition();
    if(position==null||!mounted||_searchQuery.isNotEmpty)return;
    _searchLat=position.latitude;_searchLng=position.longitude;
    await _loadDirectory(refresh:true);
  }

  Future<void> _onNearMeTapped() async {
    if(_locationLoading)return;
    setState(() => _locationLoading = true);
    final position = await _locationService.getCurrentPosition();
    if (position != null) {
      if (!mounted) return;
      setState(() {
        _sortedGyms = _locationService.sortByDistance(
          List.from(_sortedGyms),
          position,
        );
      });
    }

    if (mounted) {
      setState(() => _locationLoading = false);
    }

    if(!mounted)return;
    if(position==null){ToastMessageHelper.showError('Location unavailable. Enter a US address or ZIP.');return;}
    _searchLat=position.latitude;_searchLng=position.longitude;
    _searchQuery='';_searchController.clear();
    await _loadDirectory(refresh:true);
  }

  Future<void> _openNearGymMap({
    String? addressQuery,
    Position? position,
  }) async {
    // Build a smart query: use the requested address, selected filter, or
    // the customer's coordinates for a precise nearby-gyms search.
    String query;
    if (addressQuery != null && addressQuery.isNotEmpty) {
      query = 'gyms near $addressQuery, United States';
    } else if (_activeFilter != 'All Types') {
      query = '$_activeFilter gym near me';
    } else if (position != null) {
      query = 'gyms near ${position.latitude},${position.longitude}';
    } else {
      query = 'gyms near me';
    }

    final webUrl = Uri.https(
      'www.google.com',
      '/maps/search/',
      <String, String>{'api': '1', 'query': query},
    );
    final encodedQuery = Uri.encodeQueryComponent(query);
    final appUrl = Platform.isIOS
        ? Uri.parse('comgooglemaps://?q=$encodedQuery')
        : Uri.parse('geo:0,0?q=$encodedQuery');

    try {
      // Try the installed Maps app first. Do not gate this behind
      // canLaunchUrl: platform URL visibility rules can return false even
      // when launchUrl can successfully hand off the URL.
      if (await launchUrl(appUrl, mode: LaunchMode.externalApplication)) {
        return;
      }

      if (await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      try {
        if (await launchUrl(webUrl, mode: LaunchMode.externalApplication)) {
          return;
        }
      } catch (_) {
        // Surface a clear message instead of silently doing nothing.
      }
      ToastMessageHelper.showError('Could not open Google Maps.');
    }
  }

  void _openGymDetail(EnterpriseGymModel gym) {
    Get.to(
      () => GymDetailScreen(
        gym: gym,
        onOpenMaps: () => _openNearGymMap(
          addressQuery: gym.address.isNotEmpty
              ? gym.address
              : '${gym.name} ${gym.city}',
        ),
        onClaim: () => Get.to(() => GymApplicationScreen(initialGym: gym)),
        onEnter: () => GymLoginPreviewScreen.open(context, gym: gym),
      ),
    );
  }

  Future<void> _toggleFavorite(EnterpriseGymModel gym) async {
    setState(() {
      if (!_favoriteGymIds.add(gym.id)) {
        _favoriteGymIds.remove(gym.id);
      }
    });
    try {
      await CacheService().put(
        _favoriteGymCacheKey,
        _favoriteGymIds.toList(growable: false),
      );
    } catch (_) {
      // The selection remains usable for this session if local storage is
      // temporarily unavailable.
    }
  }

  void _goHome() {
    if (Get.isRegistered<BottomNavBarController>()) {
      final controller = BottomNavBarController.to;
      final homeIndex = controller.indexOfTab(NavItemId.home);
      if (homeIndex >= 0) controller.onChange(homeIndex);
      return;
    }
    Get.back();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Choose a gym type',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12.h),
              ...[..._filters, ..._moreFilters].map(
                (filter) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  trailing: _activeFilter == filter
                      ? Icon(Icons.check_rounded, color: Theme.of(context).colorScheme.primary)
                      : null,
                  onTap: () {
                    setState(() => _activeFilter = filter);
                    _loadDirectory(refresh: true);
                    Navigator.pop(sheetContext);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<EnterpriseGymModel> get _displayedGyms {
    final displayed = _sortedGyms.where((g) {
      final query = _searchQuery.toLowerCase();
      final matchSearch = !isSingleMode ||
          query.isEmpty ||
          g.name.toLowerCase().contains(query) ||
          g.category.toLowerCase().contains(query) ||
          g.city.toLowerCase().contains(query) ||
          g.zipCode.toLowerCase().contains(query) ||
          g.address.toLowerCase().contains(query) ||
          g.filterTags.any((tag) => tag.toLowerCase().contains(query));
      final matchFilter = !isSingleMode ||
          _activeFilter == 'All Types' ||
          (_activeFilter == 'Gym' && g.category.isNotEmpty) ||
          g.filterTags.contains(_activeFilter);
      return matchSearch && matchFilter;
    });
    return EnterpriseGymModel.sortForDirectory(displayed);
  }

  List<EnterpriseGymModel> get _featuredGyms {
    final all = _displayedGyms;
    // The first three licensed experiences stay fixed, followed by prospects.
    return all.take(8).toList();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _displayedGyms;
    final total = _sortedGyms.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F9),
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: () => _loadDirectory(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.onboardingMode) _buildDirectoryBrandHeader(),
                    _NavPills(
                      onHomeTap: _goHome,
                      onGymsTap: () => _scrollController.animateTo(
                        0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    if (_directoryLoading)
                      LinearProgressIndicator(
                        minHeight: 1.5.h,
                        color: Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.transparent,
                      ),
                    if (_directoryError != null) _buildDirectoryError(),
                    _buildHeader(),
                    _buildSearchBar(),
                    _buildFilterRow(),
                    _buildFeaturedSection(),
                    _buildAllGymsHeader(displayed.length, total),
                  ],
                ),
              ),
              displayed.isEmpty
                  ? SliverToBoxAdapter(child: _buildEmptyState())
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openGymDetail(displayed[i]),
                            child: GymListTile(gym: displayed[i]),
                          ),
                        ),
                        childCount: displayed.length,
                      ),
                    ),
              if (_cursor != null)
                SliverToBoxAdapter(
                  child: Center(
                    child: TextButton(
                      onPressed: _directoryLoading ? null : _loadDirectory,
                      child: const Text('Load more gyms'),
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: SizedBox(height: widget.onboardingMode ? 32.h : 18.h),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectoryBrandHeader() {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 10.h),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                Assets.images.logo.path,
                width: 48.w,
                height: 48.w,
                fit: BoxFit.contain,
              ),
              SizedBox(width: 9.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      style: TextStyle(
                        fontSize: 21.sp,
                        height: 1,
                        fontWeight: AppFontWeight.section,
                        color: const Color(0xFF080A12),
                      ),
                      children: [
                        const TextSpan(text: 'P2P '),
                        TextSpan(text: 'FIT', style: TextStyle(color: primary)),
                      ],
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'T E C H    A I',
                    style: TextStyle(
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                      color: const Color(0xFF252731),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.location_on_rounded, color: primary, size: 18.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  _searchLat != null ? 'Nearby' : 'United States',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F616C),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'F I T N E S S   ·   P E O P L E   ·   P R O G R E S S',
              style: TextStyle(
                fontSize: 6.8.sp,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.9,
                color: const Color(0xFF898B96),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectoryError() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      child: Material(
        color: const Color(0xFFFFF5F2),
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () => _loadDirectory(refresh: true),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
            child: Row(
              children: [
                Icon(
                  Icons.refresh_rounded,
                  size: 17.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Gym results could not load. Tap to retry.',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: const Color(0xFF6F5560),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 13.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find a gym',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF14151C),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Discover gyms near you and join your fitness community.',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    height: 1.35,
                    color: const Color(0xFF777984),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          GestureDetector(
            onTap: _onNearMeTapped,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border.all(color: const Color(0xFFEDEEF1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _locationLoading
                      ? SizedBox(
                          width: 14.r,
                          height: 14.r,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.location_on_rounded,
                          color: Theme.of(context).colorScheme.primary,
                          size: 15.sp,
                        ),
                  SizedBox(width: 5.w),
                  Text(
                    'Near Me',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Search bar ────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: const Color(0xFFE7E8EB)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.025),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  setState(() { _requestVersion++; _searchQuery = v.trim(); _searchLat=null;_searchLng=null; });
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () => _loadDirectory(refresh: true),
                  );
                },
                onSubmitted: (v) {
                  if (v.trim().length>=3) { _searchDebounce?.cancel(); _loadDirectory(refresh:true); }
                },
                style: TextStyle(fontSize: 11.5.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'Search gyms, city, state or ZIP code…',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 10.8.sp),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.black38,
                    size: 17.sp,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _loadDirectory(refresh: true);
                          },
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.black38,
                            size: 16.sp,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // ── View on Map button ───────────────────────────────────────────
          GestureDetector(
            onTap: () => _openNearGymMap(addressQuery: _searchQuery),
            child: Container(
              height: 44.h,
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(13.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.18),
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.map_outlined, color: Colors.white, size: 16.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter row ────────────────────────────────────────────────────────────

  Widget _buildFilterRow() {
    return SizedBox(
      height: 48.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        itemCount: _filters.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          if (i == _filters.length) {
            final active = _moreFilters.contains(_activeFilter);
            return GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active
                      ? Theme.of(context).colorScheme.primary
                      : Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: active
                          ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                          : Colors.black.withOpacity(0.025),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      'More',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                        color: active ? Colors.white : Colors.black54,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 14.sp,
                      color: active ? Colors.white : Colors.black54,
                    ),
                  ],
                ),
              ),
            );
          }
          final label = _filters[i];
          final active = _activeFilter == label;
          return GestureDetector(
            onTap: () {
              setState(() => _activeFilter = label);
              _loadDirectory(refresh: true);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: active ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: active
                        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
                        : Colors.black.withOpacity(0.025),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? Colors.white : Colors.black54,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Featured section ──────────────────────────────────────────────────────

  Widget _buildFeaturedSection() {
    final featured = _featuredGyms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 9.h),
          child: Row(
            children: [
              Text(
                'Featured gyms near you',
                style: TextStyle(
                  fontSize: 15.5.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _activeFilter = 'All Types';
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  _scrollController.animateTo(
                    500.h,
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                },
                child: Text(
                  'See all',
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 218.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            itemCount: featured.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, i) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openGymDetail(featured[i]),
              child: FeaturedGymCard(
                gym: featured[i],
                isFavorite: _favoriteGymIds.contains(featured[i].id),
                onFavoriteToggle: () => _toggleFavorite(featured[i]),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── All Gyms header ───────────────────────────────────────────────────────

  Widget _buildAllGymsHeader(int shown, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 9.h),
      child: Row(
        children: [
          Text(
            'All gyms',
            style: TextStyle(
              fontSize: 15.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$shown of $total',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const Spacer(),
          Icon(Icons.swap_vert_rounded,
              size: 15.sp, color: const Color(0xFF777984)),
          SizedBox(width: 3.w),
          Text(
            'Directory',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF777984),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.all(40.r),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 48.sp, color: Colors.black26),
          SizedBox(height: 12.h),
          Text(
            'No gyms found',
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.black38,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Try a different search or filter',
            style: TextStyle(fontSize: 13.sp, color: Colors.black26),
          ),
        ],
      ),
    );
  }
}

// ── Top navigation pills ────────────────────────────────────────────────────

class _NavPills extends StatelessWidget {

  final VoidCallback onHomeTap;
  final VoidCallback onGymsTap;

  const _NavPills({required this.onHomeTap, required this.onGymsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _pill(context, 'Home', Icons.home_outlined, false, onHomeTap),
          SizedBox(width: 8.w),
          _pill(
            context,
            'Find trainer',
            Icons.person_search_outlined,
            false,
            () => Get.toNamed(AppRoute.findTrainerScreen),
          ),
          SizedBox(width: 8.w),
          _pill(context, 'Gyms', Icons.fitness_center_rounded, true, onGymsTap),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? Theme.of(context).colorScheme.primary : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: active
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.16)
                    : Colors.black.withOpacity(0.06),
                blurRadius: active ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14.sp,
                color: active ? Colors.white : Colors.black54,
              ),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w400,
                  color: active ? Colors.white : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:pler_to_pler_app/core/constants/enterprise_flags.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/legacy_kmf_configuration.dart';
import 'dart:async';
import '../widgets/tenant_image.dart';
import '../../data/services/enterprise_service.dart';
import '../../data/models/tenant_configuration.dart';
import 'enterprise_session_screen.dart';
import 'gym_application_screen.dart';
import 'gym_login_preview_screen.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/featured_gym_card.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_list_tile.dart';
import 'package:pler_to_pler_app/features/gyms/services/gym_location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GymsScreen extends StatefulWidget {
  const GymsScreen({super.key});

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {

  static const _filters = [
    'All Types',
    'HIIT',
    'Yoga',
    'Pilates',
    'Boxing',
    'Cycling',
    'Strength',
  ];

  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _locationService = GymLocationService();

  String _activeFilter = 'All Types';
  String _searchQuery = '';
  bool _locationLoading = false;
  List<EnterpriseGymModel> _sortedGyms = [];
  Timer? _searchDebounce;
  int _requestVersion = 0;
  String? _cursor, _directoryError;
  bool _directoryLoading = false;
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
        final page = await EnterpriseService.instance.directory(
          cursor: _cursor,
          query: _searchQuery,
          tag: _activeFilter == 'All Types' ? null : _activeFilter,
        );
        gyms = page.items
            .map((e) => TenantConfiguration.fromJson(e).toGym())
            .toList();
        nextCursor = page.nextCursor;
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
    if (position != null && mounted) {
      setState(() {
        _sortedGyms = _locationService.sortByDistance(
          List.from(_sortedGyms),
          position,
        );
      });
    }
  }

  Future<void> _onNearMeTapped() async {
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

    // Near Me should always take the customer to a real nearby-gyms search.
    await _openNearGymMap(position: position);
  }

  Future<void> _openNearGymMap({
    String? addressQuery,
    Position? position,
  }) async {
    // Build a smart query: use the requested address, selected filter, or
    // the customer's coordinates for a precise nearby-gyms search.
    String query;
    if (addressQuery != null && addressQuery.isNotEmpty) {
      query = 'gyms near $addressQuery';
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

  // ── Show gym detail sheet (with status label for non-activated gyms) ────────
  void _showGymSheet(EnterpriseGymModel gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GymDetailSheet(
        gym: gym,
        onOpenMaps: () {
          Navigator.pop(context);
          _openNearGymMap(
            addressQuery: gym.address.isNotEmpty
                ? gym.address
                : '${gym.name} ${gym.city}',
          );
        },
        onClaim: () {
          Navigator.pop(context);
          Get.to(() => GymApplicationScreen(initialGym: gym));
        },
        onEnter: () {
          Navigator.pop(context);
          GymLoginPreviewScreen.open(context, gym: gym);
        },
      ),
    );
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
              ..._filters.map(
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
    final originalOrder = <String, int>{
      for (var index = 0; index < _sortedGyms.length; index++)
        _sortedGyms[index].id: index,
    };
    final displayed = _sortedGyms.where((g) {
      final q = _searchQuery.toLowerCase();
      final matchSearch =
          q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.category.toLowerCase().contains(q) ||
          g.city.toLowerCase().contains(q) ||
          g.zipCode.contains(q) ||
          g.address.toLowerCase().contains(q);
      final matchFilter =
          _activeFilter == 'All Types' || g.filterTags.contains(_activeFilter);
      return matchSearch && matchFilter;
    }).toList();
    const priority = <String, int>{
      'ymca_yonkers': 0,
      'kmf_fitness_club': 1,
      'p2p_fit_factor': 2,
    };
    displayed.sort((a, b) {
      final aPriority = priority[a.id];
      final bPriority = priority[b.id];
      if (aPriority != null || bPriority != null) {
        return (aPriority ?? 999).compareTo(bPriority ?? 999);
      }
      return (originalOrder[a.id] ?? 9999).compareTo(
        originalOrder[b.id] ?? 9999,
      );
    });
    return displayed;
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  if (!isSingleMode)
                    TextButton.icon(
                      onPressed: () =>
                          Get.to(() => const EnterpriseMembershipScreen()),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('My gyms & invitations'),
                    ),
                  if (_directoryLoading) const LinearProgressIndicator(),
                  if (_directoryError != null) Text(_directoryError!),
                  TextButton(
                    onPressed: _directoryLoading
                        ? null
                        : () => _loadDirectory(refresh: true),
                    child: const Text('Refresh gyms'),
                  ),
                  if (_cursor != null)
                    TextButton(
                      onPressed: _directoryLoading
                          ? null
                          : () => _loadDirectory(),
                      child: const Text('Load more gyms'),
                    ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top nav pills ──────────────────────────────────────
                  _NavPills(
                    onGymsTap: () => _scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                    ),
                  ),
                  // ── Header: Find a Gym + Near Me ──────────────────────
                  _buildHeader(),
                  // ── Search bar ────────────────────────────────────────
                  _buildSearchBar(),
                  // ── Filter row ────────────────────────────────────────
                  _buildFilterRow(),
                  // ── Featured Gyms Near You ─────────────────────────────
                  _buildFeaturedSection(),
                  // ── All Gyms header ───────────────────────────────────
                  _buildAllGymsHeader(displayed.length, total),
                ],
              ),
            ),

            // ── All Gyms list ────────────────────────────────────────────
            displayed.isEmpty
                ? SliverToBoxAdapter(child: _buildEmptyState())
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: GestureDetector(
                          onTap: () => _showGymSheet(displayed[i]),
                          child: GymListTile(gym: displayed[i]),
                        ),
                      ),
                      childCount: displayed.length,
                    ),
                  ),

            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Find a gym',
            style: TextStyle(
              fontSize: 23.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
              letterSpacing: -0.2,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _onNearMeTapped,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
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
                          size: 16.sp,
                        ),
                  SizedBox(width: 5.w),
                  Text(
                    'Near Me',
                    style: TextStyle(
                      fontSize: 13.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) {
                  setState(() => _searchQuery = v.trim());
                  _searchDebounce?.cancel();
                  _searchDebounce = Timer(
                    const Duration(milliseconds: 300),
                    () => _loadDirectory(refresh: true),
                  );
                },
                onSubmitted: (v) {
                  if (v.trim().isNotEmpty)
                    _openNearGymMap(addressQuery: v.trim());
                },
                style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'City, zip, or gym name…',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 13.sp),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: Colors.black38,
                    size: 18.sp,
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
                  contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 10.w),
          // ── View on Map button ───────────────────────────────────────────
          GestureDetector(
            onTap: () => _openNearGymMap(addressQuery: _searchQuery),
            child: Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                    blurRadius: 8,
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
                      fontSize: 12.sp,
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
      height: 50.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        itemCount: _filters.length + 1,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          if (i == _filters.length) {
            return GestureDetector(
              onTap: _showFilterSheet,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.tune_rounded,
                  size: 16.sp,
                  color: Colors.black54,
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
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? Theme.of(context).colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Text(
                'Featured gyms near you',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
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
                    fontSize: 12.sp,
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 340.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: featured.length,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (_, i) => FeaturedGymCard(gym: featured[i]),
          ),
        ),
      ],
    );
  }

  // ── All Gyms header ───────────────────────────────────────────────────────

  Widget _buildAllGymsHeader(int shown, int total) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 10.h),
      child: Row(
        children: [
          Text(
            'All gyms',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$shown / $total gyms',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.black45,
                fontWeight: FontWeight.w400,
              ),
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

// ── Gym detail bottom sheet ─────────────────────────────────────────────────
class _GymDetailSheet extends StatelessWidget {
  final EnterpriseGymModel gym;
  final VoidCallback onOpenMaps;
  final VoidCallback onClaim;
  final VoidCallback onEnter;

  const _GymDetailSheet({
    required this.gym,
    required this.onOpenMaps,
    required this.onClaim,
    required this.onEnter,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = !gym.isActivated;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 18.h),

          // Gym brand row
          Row(
            children: [
              GymBrandLogo(gym: gym, size: 44.r, borderRadius: 10.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      gym.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      gym.category,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    if (gym.address.isNotEmpty)
                      Text(
                        gym.address,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                          height: 1.25,
                        ),
                      ),
                    if (gym.tagline.isNotEmpty)
                      Text(
                        gym.tagline,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: gym.accentColor,
                        ),
                      ),
                  ],
                ),
              ),
              if (gym.address.isEmpty && gym.city.isNotEmpty)
                Text(
                  gym.city,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
            ],
          ),

          SizedBox(height: 16.h),

          if (gym.galleryAssetPaths.isNotEmpty) ...[
            Text(
              'Facility photos',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              height: 112.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: gym.galleryAssetPaths.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: TenantImage(
                    gym.galleryAssetPaths[index],
                    width: 156.w,
                    height: 112.h,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Status / partnership label
          if (isLocked) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      gym.statusLabel,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).colorScheme.primary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Locked prospects can apply; activated gyms enter branded auth.
          GestureDetector(
            onTap: isLocked ? onClaim : onEnter,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              decoration: BoxDecoration(
                color: isLocked ? Colors.black87 : gym.brandColor,
                borderRadius: BorderRadius.circular(14.r),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isLocked ? Icons.lock_outline_rounded : Icons.lock_open_rounded,
                    color: Colors.white,
                    size: 17.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    isLocked ? 'Claim your gym' : 'Enter ${gym.name}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (gym.address.isNotEmpty || gym.city.isNotEmpty) ...[
            SizedBox(height: 10.h),
            TextButton.icon(
              onPressed: onOpenMaps,
              icon: const Icon(Icons.map_outlined),
              label: const Text('View on Google Maps'),
              style: TextButton.styleFrom(
                foregroundColor: gym.brandColor,
                minimumSize: const Size.fromHeight(44),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Top navigation pills ────────────────────────────────────────────────────

class _NavPills extends StatelessWidget {

  final VoidCallback onGymsTap;

  const _NavPills({required this.onGymsTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _pill(context, 'Home', Icons.home_outlined, false, () => Get.back()),
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
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
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

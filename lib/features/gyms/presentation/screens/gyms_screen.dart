import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/featured_gym_card.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_list_tile.dart';
import 'package:pler_to_pler_app/features/gyms/services/gym_location_service.dart';
import 'package:url_launcher/url_launcher.dart';

class GymsScreen extends StatefulWidget {
  const GymsScreen({super.key});

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {
  static const _kOrange = Color(0xFFFD7B00);
  static const _filters = [
    'All Types',
    'HIIT',
    'Yoga',
    'Pilates',
    'Cycling',
    'Strength',
  ];

  final _searchController = TextEditingController();
  final _locationService = GymLocationService();

  String _activeFilter = 'All Types';
  String _searchQuery = '';
  bool _locationLoading = false;
  List<EnterpriseGymModel> _sortedGyms = List.from(EnterpriseGymModel.activatedPartners);

  @override
  void initState() {
    super.initState();
    _detectLocationSilently();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Location ─────────────────────────────────────────────────────────────

  Future<void> _detectLocationSilently() async {
    final position = await _locationService.getCurrentPosition();
    if (position != null && mounted) {
      setState(() {
        _sortedGyms = _locationService.sortByDistance(
          List.from(EnterpriseGymModel.activatedPartners),
          position,
        );
      });
    }
  }

  Future<void> _onNearMeTapped() async {
    setState(() => _locationLoading = true);
    final position = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (position != null) {
      setState(() {
        _sortedGyms = _locationService.sortByDistance(
          List.from(EnterpriseGymModel.activatedPartners),
          position,
        );
        _locationLoading = false;
      });
    } else {
      setState(() => _locationLoading = false);
      // Fallback: open Google Maps
      _openNearGymMap();
    }
  }

  Future<void> _openNearGymMap() async {
    const query = 'gyms+near+me';
    final webUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    final appUrl = Uri.parse('comgooglemaps://?q=$query');
    try {
      if (Platform.isIOS && await canLaunchUrl(appUrl)) {
        await launchUrl(appUrl, mode: LaunchMode.externalApplication);
        return;
      }
      if (await canLaunchUrl(webUrl)) {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      ToastMessageHelper.show('Could not open maps.');
    }
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  List<EnterpriseGymModel> get _displayedGyms {
    return _sortedGyms.where((g) {
      final q = _searchQuery.toLowerCase();
      final matchSearch = q.isEmpty ||
          g.name.toLowerCase().contains(q) ||
          g.category.toLowerCase().contains(q) ||
          g.city.toLowerCase().contains(q) ||
          g.zipCode.contains(q);
      final matchFilter = _activeFilter == 'All Types' ||
          g.filterTags.contains(_activeFilter);
      return matchSearch && matchFilter;
    }).toList();
  }

  List<EnterpriseGymModel> get _featuredGyms {
    final all = _displayedGyms;
    // Own gyms first, then top 6
    final own = all.where((g) => g.isOwnGym).toList();
    final rest = all.where((g) => !g.isOwnGym).take(5).toList();
    return [...own, ...rest];
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final displayed = _displayedGyms;
    final total = EnterpriseGymModel.activatedPartners.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top nav pills ──────────────────────────────────────
                  _NavPills(),
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
                        child: GymListTile(gym: displayed[i]),
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
            'Find a Gym',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _onNearMeTapped,
            child: Container(
              padding:
                  EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
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
                            color: _kOrange,
                          ),
                        )
                      : Icon(Icons.location_on_rounded,
                          color: _kOrange, size: 16.sp),
                  SizedBox(width: 5.w),
                  Text(
                    'Near Me',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
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
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v.trim()),
          style: TextStyle(fontSize: 14.sp, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'Search gym, type, location…',
            hintStyle: TextStyle(color: Colors.black38, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search_rounded,
                color: Colors.black38, size: 20.sp),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: Icon(Icons.close_rounded,
                        color: Colors.black38, size: 18.sp),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
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
              onTap: () {},
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 6),
                  ],
                ),
                child: Icon(Icons.tune_rounded,
                    size: 16.sp, color: Colors.black54),
              ),
            );
          }
          final label = _filters[i];
          final active = _activeFilter == label;
          return GestureDetector(
            onTap: () => setState(() => _activeFilter = label),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? _kOrange : Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 6),
                ],
              ),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
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
          padding:
              EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            children: [
              Text(
                'Featured Gyms Near You',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                'See All >',
                style: TextStyle(
                    fontSize: 13.sp,
                    color: _kOrange,
                    fontWeight: FontWeight.w600),
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
            'All Gyms',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3F5),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              '$shown / $total gyms',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600),
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
          Icon(Icons.search_off_rounded,
              size: 48.sp, color: Colors.black26),
          SizedBox(height: 12.h),
          Text('No gyms found',
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black38,
                  fontWeight: FontWeight.w600)),
          SizedBox(height: 6.h),
          Text('Try a different search or filter',
              style:
                  TextStyle(fontSize: 13.sp, color: Colors.black26)),
        ],
      ),
    );
  }
}

// ── Top navigation pills ────────────────────────────────────────────────────

class _NavPills extends StatelessWidget {
  static const _kOrange = Color(0xFFFD7B00);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          _pill('Home', Icons.home_outlined, false,
              () => Get.back()),
          SizedBox(width: 8.w),
          _pill('Find Trainer', Icons.person_search_outlined, false,
              () {}),
          SizedBox(width: 8.w),
          _pill('Gyms', Icons.fitness_center_rounded, true, () {}),
        ],
      ),
    );
  }

  Widget _pill(
      String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: active ? _kOrange : Colors.white,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: active
                    ? _kOrange.withOpacity(0.3)
                    : Colors.black.withOpacity(0.06),
                blurRadius: active ? 10 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 14.sp,
                  color: active ? Colors.white : Colors.black54),
              SizedBox(width: 5.w),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
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

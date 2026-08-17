import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class GymsScreen extends StatelessWidget {
  const GymsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Layer 1: dark montage grid (building/gym tiles) ────────────
          _MontageBg(),

          // ── Layer 2: white frosted overlay ────────────────────────────
          Container(color: Colors.white.withValues(alpha: 0.91)),

          // ── Layer 3: Coming-Soon content ───────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Top "mock" header bar
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Row(
                    children: [
                      Text('Gyms',
                          style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.black)),
                      const Spacer(),
                      Icon(Icons.tune_rounded, color: Colors.black54, size: 22.sp),
                    ],
                  ),
                ),

                // Mock search bar (greyed out — not interactive)
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 20.w),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Row(children: [
                    Icon(Icons.search, color: Colors.grey, size: 20.sp),
                    SizedBox(width: 10.w),
                    Text('Search gyms near you…',
                        style: TextStyle(color: Colors.grey[400], fontSize: 14.sp)),
                  ]),
                ),
                SizedBox(height: 20.h),

                // Mock 2-card row (wireframe style)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(child: _MockGymCard(name: 'Iron House Gym', distance: '0.4 mi')),
                      SizedBox(width: 12.w),
                      Expanded(child: _MockGymCard(name: 'Peak Performance', distance: '0.9 mi')),
                    ],
                  ),
                ),
                SizedBox(height: 12.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Expanded(child: _MockGymCard(name: 'FitZone Studio', distance: '1.2 mi')),
                      SizedBox(width: 12.w),
                      Expanded(child: _MockGymCard(name: 'Elite Athletic', distance: '1.8 mi')),
                    ],
                  ),
                ),

                const Spacer(),

                // ── COMING SOON badge + icon ─────────────────────────────
                Container(
                  width: 100.r,
                  height: 100.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25), width: 2),
                  ),
                  child: Icon(Icons.location_city_rounded,
                      color: AppColors.primary, size: 48.sp),
                ),
                SizedBox(height: 20.h),

                // COMING SOON pill
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                  child: Text(
                    'COMING SOON',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        letterSpacing: 2.5),
                  ),
                ),
                SizedBox(height: 16.h),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 44.w),
                  child: Text(
                    'Find, book, and track gym sessions near you — AI-matched facilities built around your training plan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                        height: 1.65),
                  ),
                ),
                SizedBox(height: 28.h),

                // Notify Me button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 40.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    child: Text(
                      'Notify Me When Live',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15.sp),
                    ),
                  ),
                ),

                const Spacer(),
                SizedBox(height: 90.h), // clear bottom nav
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Montage background grid ─────────────────────────────────────────────────

class _MontageBg extends StatelessWidget {
  const _MontageBg();

  static const _tiles = [
    _Tile('Iron House', 0xFF1A1A2E, 0xFF16213E),
    _Tile('Peak Perf.', 0xFF1C2340, 0xFF0F172A),
    _Tile('FitZone',    0xFF1E2A3A, 0xFF172032),
    _Tile('Elite Athl.',0xFF1A2030, 0xFF0E1825),
    _Tile('PowerLift',  0xFF1F2535, 0xFF14202E),
    _Tile('FlexGym',    0xFF1B2238, 0xFF101C2C),
    _Tile('CoreFit',    0xFF1D2840, 0xFF13202E),
    _Tile('UrbanAthlet',0xFF202840, 0xFF141F32),
    _Tile('StrongerU',  0xFF1A2236, 0xFF111C2A),
    _Tile('NexGen Gym', 0xFF1C2540, 0xFF0D1828),
    _Tile('ProTraining',0xFF1E2A3C, 0xFF131F30),
    _Tile('MaxForce',   0xFF1F273D, 0xFF12202F),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, childAspectRatio: 1.1),
      itemCount: _tiles.length,
      itemBuilder: (_, i) => _TileWidget(tile: _tiles[i], index: i),
    );
  }
}

class _Tile {
  final String name;
  final int c1, c2;
  const _Tile(this.name, this.c1, this.c2);
}

class _TileWidget extends StatelessWidget {
  final _Tile tile;
  final int index;
  const _TileWidget({required this.tile, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(tile.c1), Color(tile.c2)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_on_rounded, color: const Color(0xFFFD7B00).withValues(alpha: 0.7), size: 28),
          const SizedBox(height: 6),
          Text(tile.name,
              style: const TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text('${(index * 0.4 + 0.2).toStringAsFixed(1)} mi',
              style: const TextStyle(color: Colors.white38, fontSize: 9)),
        ],
      ),
    );
  }
}

// ─── Mock gym card (wireframe / frosted) ─────────────────────────────────────

class _MockGymCard extends StatelessWidget {
  final String name, distance;
  const _MockGymCard({required this.name, required this.distance});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE5E5E5)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          height: 72.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEAEAEA),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(Icons.fitness_center_rounded,
                color: Colors.grey[400], size: 28.sp),
          ),
        ),
        SizedBox(height: 8.h),
        Text(name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: Colors.grey[400])),
        Text(distance,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey[400])),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_card.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

// ─── Filter model ─────────────────────────────────────────────────────────
class _Filter {
  final String id, emoji, label;
  const _Filter({required this.id, required this.emoji, required this.label});
}

// ─── Gender filters ───────────────────────────────────────────────────────
const _genderFilters = [
  _Filter(id: 'all',    emoji: '👥', label: 'All'),
  _Filter(id: 'male',   emoji: '♂',  label: 'Male'),
  _Filter(id: 'female', emoji: '♀',  label: 'Female'),
];

// ─── Specialty filters — IDs match production DB values exactly ───────────
const _specialtyFilters = [
  _Filter(id: 'all',               emoji: '🎯', label: 'All'),
  _Filter(id: 'weight_loss',       emoji: '🔥', label: 'Weight loss'),
  _Filter(id: 'muscle_gain',       emoji: '💪', label: 'Build muscle'),
  _Filter(id: 'maintain_physique', emoji: '🧘', label: 'Maintenance'),
  _Filter(id: 'boxing',            emoji: '🥊', label: 'Boxing'),
  _Filter(id: 'nutrition',         emoji: '🍎', label: 'Nutrition'),
];

const _kOrange = Color(0xFFFF6B1A);

// ─── Screen ───────────────────────────────────────────────────────────────
class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscribeController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            // ── App bar ──────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF5F5F5),
              elevation: 0,
              pinned: true,
              centerTitle: true,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Icon(Icons.chevron_left, size: 22.sp, color: Colors.black87),
                ),
              ),
              title: Text(
                'Find trainer',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // ── Search bar ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 8.h),
                child: GestureDetector(
                  onTap: () => _openSearch(context, controller),
                  child: Container(
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(children: [
                      SizedBox(width: 16.w),
                      Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                      SizedBox(width: 10.w),
                      Text('Search trainer by name or needs',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp)),
                    ]),
                  ),
                ),
              ),
            ),

            // ── Filter by goal + disclosure ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 0),
                child: Row(
                  children: [
                    Text(
                      'Filter by goal',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    GestureDetector(
                      onTap: () => showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          backgroundColor: const Color(0xFF1C1C1E),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r)),
                          title: Text('Filters & Find My Match',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp)),
                          content: Text(
                            'Tap a specialty chip to browse trainers by training style. '
                            'Tap a gender chip to filter by women or men.\n\n'
                            'When a filter is active we skip our featured trainers '
                            'so you always see fresh, authentic coaches from our full network.\n\n'
                            '🎯 Find My Match instantly picks your ideal trainer '
                            'based on your goals and fitness level — no scrolling needed.',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13.sp,
                                height: 1.5),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Got it',
                                  style: TextStyle(
                                      color: const Color(0xFFFF6B00),
                                      fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          size: 15.sp, color: Colors.black38),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52.h,
                child: Obx(() {
                  final activeSpec = controller.selectedSpecialty.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
                    itemCount: _specialtyFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      final f = _specialtyFilters[i];
                      final active = activeSpec == f.id;
                      return _FilterChip(filter: f, active: active, onTap: () {
                        final gen = controller.selectedGender.value;
                        controller.filterBy(specialty: f.id, gender: gen);
                      });
                    },
                  );
                }),
              ),
            ),

            // ── Filter by gender ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 0, 0),
                child: Text(
                  'Filter by gender',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 52.h,
                child: Obx(() {
                  final activeGen = controller.selectedGender.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(16.w, 6.h, 16.w, 6.h),
                    itemCount: _genderFilters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (_, i) {
                      final f = _genderFilters[i];
                      final active = activeGen == f.id;
                      return _FilterChip(filter: f, active: active, onTap: () {
                        final spec = controller.selectedSpecialty.value;
                        controller.filterBy(specialty: spec, gender: f.id);
                      });
                    },
                  );
                }),
              ),
            ),

            // ── Find My Match pill + 1,000+ badge ─────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
                child: Row(
                  children: [
                    // 🎯 Find My Match — auto-picks the ideal trainer
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoute.trainerMatchScreen),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 9.h),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                                color: const Color(0xFFFF6B00).withOpacity(0.32),
                                blurRadius: 10,
                                offset: const Offset(0, 3))
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🎯', style: TextStyle(fontSize: 15.sp)),
                            SizedBox(width: 6.w),
                            Text('Find My Match',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.sp,
                                    letterSpacing: -0.2)),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // 1,000+ badge (compact)
                    RichText(
                      text: TextSpan(
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.black45),
                        children: [
                          TextSpan(
                            text: '1,000+ ',
                            style: TextStyle(
                                color: _kOrange,
                                fontWeight: FontWeight.w800,
                                fontSize: 12.sp),
                          ),
                          const TextSpan(text: '150 ♀ · 150 ♂'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 4.h)),
          ],

          // ── Trainer grid ─────────────────────────────────────────────
          body: Obx(() {
            switch (controller.loadingState) {
              case LoadingState.loading:
              case LoadingState.initial:
                return CustomScrollView(slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 3 / 5.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => const FindTrainerShimmer(),
                        childCount: 6,
                      ),
                    ),
                  ),
                ]);

              case LoadingState.offline:
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey.shade300),
                      SizedBox(height: 12.h),
                      Text('Could not load trainers',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: controller.refresh,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: _kOrange,
                            shape: const StadiumBorder()),
                        child: Text('Try again',
                            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                      ),
                    ],
                  ),
                );

              default:
                return CustomScrollView(slivers: [
                  // ── ⭐ Featured Coaches ───────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                      child: Row(
                        children: [
                          Text('⭐', style: TextStyle(fontSize: 17.sp)),
                          SizedBox(width: 6.w),
                          Text(
                            'Featured Coaches',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.3,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: _kOrange,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'TOP PICKS',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Obx(() {
                      final pinned = controller.pinnedTrainers;
                      if (pinned.isEmpty) return SizedBox(height: 8.h);
                      return SizedBox(
                        height: 270.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                          itemCount: pinned.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (_, i) => SizedBox(
                            width: 168.w,
                            child: FindTrainerCard(trainer: pinned[i]),
                          ),
                        ),
                      );
                    }),
                  ),

                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                  // ── Women section ────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          Text('👩‍💪', style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 8.w),
                          Text('Women Trainers',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const Spacer(),
                          Text('${controller.femaleTrainers.length}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: _kOrange,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 3 / 5.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) =>
                            FindTrainerCard(trainer: controller.femaleTrainers[index]),
                        childCount: controller.femaleTrainers.length,
                      ),
                    ),
                  ),
                  // ── Men section ──────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
                      child: Row(
                        children: [
                          Text('💪', style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 8.w),
                          Text('Men Trainers',
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                          const Spacer(),
                          Text('${controller.maleTrainers.length}',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  color: _kOrange,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 3 / 5.2,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, index) =>
                            FindTrainerCard(trainer: controller.maleTrainers[index]),
                        childCount: controller.maleTrainers.length,
                      ),
                    ),
                  ),
                  SizedBox(height: 130.h).asSliver,
                ]);
            }
          }),
        ),
      ),
    );
  }

  void _openSearch(BuildContext context, SubscribeController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map((trainer) => SearchModel(
                    model: trainer,
                    title: trainer.userId?.fullName,
                    image: trainer.userId?.profilePicture,
                    subtitle: trainer.subscriptionPrice?.premium.toString(),
                  ))
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          Get.toNamed(AppRoute.trainerProfileScreen,
              arguments: result.model.sId as String);
        },
      ),
    );
  }
}

// ─── Reusable filter chip ─────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final _Filter filter;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip(
      {required this.filter, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: active ? _kOrange.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: active ? _kOrange : const Color(0xFFD8D8D8),
            width: active ? 2.0 : 1.0,
          ),
          boxShadow: active
              ? []
              : [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1))
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filter.emoji, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? _kOrange : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


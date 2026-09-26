import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
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
  final String id, label;
  final IconData icon;
  const _Filter({required this.id, required this.icon, required this.label});
}

// ─── Gender filters ───────────────────────────────────────────────────────
const _genderFilters = [
  _Filter(id: 'all', icon: Icons.people_outline_rounded, label: 'All'),
  _Filter(id: 'male', icon: Icons.male_rounded, label: 'Male'),
  _Filter(id: 'female', icon: Icons.female_rounded, label: 'Female'),
];

// ─── Specialty filters — IDs match production DB values exactly ───────────
const _specialtyFilters = [
  _Filter(id: 'all', icon: Icons.adjust_rounded, label: 'All'),
  _Filter(id: 'weight_loss', icon: Icons.local_fire_department_outlined, label: 'Weight loss'),
  _Filter(id: 'muscle_gain', icon: Icons.fitness_center_rounded, label: 'Build muscle'),
  _Filter(id: 'maintain_physique', icon: Icons.self_improvement_outlined, label: 'Maintenance'),
  _Filter(id: 'boxing', icon: Icons.sports_mma_outlined, label: 'Boxing'),
  _Filter(id: 'nutrition', icon: Icons.restaurant_outlined, label: 'Nutrition'),
];



// ─── Screen ───────────────────────────────────────────────────────────────
class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SubscribeController>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            // ── App bar ──────────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              pinned: true,
              toolbarHeight: 44.h,
              leading: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  margin: EdgeInsets.all(7.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE8E9ED)),
                  ),
                  child: Icon(Icons.arrow_back_ios_new_rounded, size: 15.sp,
                      color: const Color(0xFF292B33)),
                ),
              ),
              title: const SizedBox.shrink(),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 13.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your trainer',
                      style: TextStyle(
                        fontSize: 23.sp,
                        height: 1.05,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF171820),
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'Discover coaches that match your goals.',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF747680),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Search bar ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 11.h),
                child: GestureDetector(
                  onTap: () => _openSearch(context, controller),
                  child: Container(
                    height: 43.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: const Color(0xFFE6E7EA)),
                    ),
                    child: Row(children: [
                      SizedBox(width: 13.w),
                      Icon(Icons.search_rounded, color: const Color(0xFF92949D), size: 18.sp),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Search trainer by name or needs',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: const Color(0xFF92949D), fontSize: 11.sp),
                        ),
                      ),
                      SizedBox(width: 13.w),
                    ]),
                  ),
                ),
              ),
            ),

            // ── Filter by goal + disclosure ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 2.h, 20.w, 0),
                child: Row(
                  children: [
                    Text(
                      'Filter by goal',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5F616B),
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
                                  fontWeight: AppFontWeight.label,
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
                                      color: BrandColors.of(context).primary,
                                      fontWeight: AppFontWeight.label)),
                            ),
                          ],
                        ),
                      ),
                      child: Icon(Icons.info_outline_rounded,
                          size: 14.sp, color: const Color(0xFF92949D)),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 43.h,
                child: Obx(() {
                  final activeSpec = controller.selectedSpecialty.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 5.h),
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
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 0, 0),
                child: Text(
                  'Filter by gender',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5F616B),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 43.h,
                child: Obx(() {
                  final activeGen = controller.selectedGender.value;
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(20.w, 5.h, 20.w, 5.h),
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
                padding: EdgeInsets.fromLTRB(20.w, 13.h, 20.w, 7.h),
                child: Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Semantics(
                        button: true,
                        label: 'Find My Match',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Get.toNamed(AppRoute.trainerMatchScreen),
                            borderRadius: BorderRadius.circular(22.r),
                            child: Ink(
                              height: 42.h,
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    BrandColors.of(context).primary,
                                    BrandColors.of(context).light,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(22.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: BrandColors.of(context)
                                        .primary
                                        .withOpacity(0.12),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.adjust_rounded,
                                      color: Colors.white, size: 17.sp),
                                  SizedBox(width: 7.w),
                                  Expanded(
                                    child: Text(
                                      'Find My Match',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11.5.sp,
                                        letterSpacing: -0.1,
                                      ),
                                    ),
                                  ),
                                  Icon(Icons.arrow_forward_rounded,
                                      color: Colors.white, size: 16.sp),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 11.w),
                    const Expanded(
                      flex: 4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _CoachStat(value: '1,000+', label: 'Coaches'),
                          _CoachStat(value: '150', label: 'Women'),
                          _CoachStat(value: '150', label: 'Men'),
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
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: .62,
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
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            shape: const StadiumBorder()),
                        child: Text('Try again',
                            style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                      ),
                    ],
                  ),
                );


              default:
                return Obx(() {
                  final gender    = controller.selectedGender.value;
                  final specialty = controller.selectedSpecialty.value;
                  final females   = controller.femaleTrainers;
                  final males     = controller.maleTrainers;
                  final pinned    = controller.pinnedTrainers;
                  final noFilter   = gender == 'all' && specialty == 'all';
                  final showFemale = gender != 'male';
                  final showMale   = gender != 'female';
                  const gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, crossAxisSpacing: 10,
                    mainAxisSpacing: 10, childAspectRatio: .62,
                  );
                  return CustomScrollView(slivers: [
                    if (noFilter && pinned.isNotEmpty) SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 7.h),
                        child: Row(children: [
                          Icon(Icons.star_rounded, size: 16.sp,
                              color: const Color(0xFFFFB000)),
                          SizedBox(width: 6.w),
                          Text('Featured Coaches', style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600,
                            color: Colors.black87, letterSpacing: -0.3)),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withOpacity(.08),
                              borderRadius: BorderRadius.circular(10.r)),
                            child: Text('TOP PICKS', style: TextStyle(
                              fontSize: 8.sp, fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                              letterSpacing: 0.4)),
                          ),
                          const Spacer(),
                          Icon(Icons.chevron_right_rounded, size: 17.sp,
                              color: const Color(0xFF92949D)),
                        ]),
                      ),
                    ),
                    if (noFilter && pinned.isNotEmpty) SliverToBoxAdapter(
                      child: SizedBox(height: 254.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          itemCount: pinned.length,
                          separatorBuilder: (_, __) => SizedBox(width: 10.w),
                          itemBuilder: (_, i) => SizedBox(
                            width: 158.w,
                            child: FindTrainerCard(trainer: pinned[i])),
                        ),
                      ),
                    ),
                    if (noFilter && pinned.isNotEmpty)
                      SliverToBoxAdapter(child: SizedBox(height: 14.h)),
                    if (showFemale) ...[
                      SliverToBoxAdapter(child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                        child: Row(children: [
                          Icon(Icons.female_rounded, size: 16.sp,
                              color: const Color(0xFF747680)),
                          SizedBox(width: 7.w),
                          Text('Women Trainers', style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                          const Spacer(),
                          Text('${females.length}', style: TextStyle(
                            fontSize: 10.5.sp, color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                          SizedBox(width: 3.w),
                          Icon(Icons.chevron_right_rounded, size: 16.sp,
                              color: const Color(0xFF92949D)),
                        ]),
                      )),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        sliver: SliverGrid(gridDelegate: gridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => FindTrainerCard(trainer: females[i]),
                            childCount: females.length)),
                      ),
                    ],
                    if (showMale) ...[
                      SliverToBoxAdapter(child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, showFemale ? 21.h : 12.h, 20.w, 8.h),
                        child: Row(children: [
                          Icon(Icons.male_rounded, size: 16.sp,
                              color: const Color(0xFF747680)),
                          SizedBox(width: 7.w),
                          Text('Men Trainers', style: TextStyle(
                            fontSize: 13.5.sp, fontWeight: FontWeight.w600,
                            color: Colors.black87)),
                          const Spacer(),
                          Text('${males.length}', style: TextStyle(
                            fontSize: 10.5.sp, color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600)),
                          SizedBox(width: 3.w),
                          Icon(Icons.chevron_right_rounded, size: 16.sp,
                              color: const Color(0xFF92949D)),
                        ]),
                      )),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        sliver: SliverGrid(gridDelegate: gridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => FindTrainerCard(trainer: males[i]),
                            childCount: males.length)),
                      ),
                    ],
                    SliverToBoxAdapter(child: SizedBox(height: 130.h)),
                  ]);
                });
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
    final primary = Theme.of(context).colorScheme.primary;
    return Semantics(
      button: true,
      selected: active,
      label: '${filter.label} filter',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: active ? primary.withOpacity(0.075) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: active ? primary.withOpacity(.72) : const Color(0xFFE1E2E6),
            width: 1,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(30.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(filter.icon, size: 14.sp,
                      color: active ? primary : const Color(0xFF5F616B)),
                  SizedBox(width: 6.w),
                  Text(
                    filter.label,
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                      color: active ? primary : const Color(0xFF363842),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CoachStat extends StatelessWidget {
  const _CoachStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 1.h),
          Text(label,
              style: TextStyle(fontSize: 7.5.sp,
                  color: const Color(0xFF898B94))),
        ],
      );
}

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
                  fontWeight: AppFontWeight.section,
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
                      Expanded(
                        child: Text(
                          'Search trainer by name or needs',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                        ),
                      ),
                      SizedBox(width: 16.w),
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
                        fontWeight: AppFontWeight.label,
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
                    fontWeight: AppFontWeight.label,
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
                child: Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    // 🎯 Find My Match — auto-picks the ideal trainer
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoute.trainerMatchScreen),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 14.w, vertical: 9.h),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [BrandColors.of(context).primary, BrandColors.of(context).light],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight),
                          borderRadius: BorderRadius.circular(22.r),
                          boxShadow: [
                            BoxShadow(
                                color: BrandColors.of(context).primary.withOpacity(0.32),
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
                                    fontWeight: AppFontWeight.label,
                                    fontSize: 13.sp,
                                    letterSpacing: -0.2)),
                          ],
                        ),
                      ),
                    ),
                    // 1,000+ badge (compact)
                    RichText(
                      text: TextSpan(
                        style:
                            TextStyle(fontSize: 11.sp, color: Colors.black45),
                        children: [
                          TextSpan(
                            text: '1,000+ ',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: AppFontWeight.stat,
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
                    mainAxisSpacing: 10, childAspectRatio: 3 / 5.2,
                  );
                  return CustomScrollView(slivers: [
                    if (noFilter && pinned.isNotEmpty) SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
                        child: Row(children: [
                          Text('⭐', style: TextStyle(fontSize: 17.sp)),
                          SizedBox(width: 6.w),
                          // Was Colors.white on this screen's #F5F5F5
                          // background — effectively invisible, and nothing
                          // dark sits behind it. Pre-existing (white at HEAD
                          // too), but worth fixing here: the lighter weight
                          // this pass applies makes an unreadable header even
                          // fainter. Matches the black54 the screen's other
                          // labels already use, one step darker for a heading.
                          Text('Featured Coaches', style: TextStyle(
                            fontSize: 16.sp, fontWeight: AppFontWeight.section,
                            color: Colors.black87, letterSpacing: -0.3)),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(10.r)),
                            child: Text('TOP PICKS', style: TextStyle(
                              fontSize: 9.sp, fontWeight: AppFontWeight.stat,
                              color: Colors.white, letterSpacing: 0.5)),
                          ),
                        ]),
                      ),
                    ),
                    if (noFilter && pinned.isNotEmpty) SliverToBoxAdapter(
                      child: SizedBox(height: 270.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                          itemCount: pinned.length,
                          separatorBuilder: (_, __) => SizedBox(width: 12.w),
                          itemBuilder: (_, i) => SizedBox(
                            width: 168.w,
                            child: FindTrainerCard(trainer: pinned[i])),
                        ),
                      ),
                    ),
                    if (noFilter && pinned.isNotEmpty)
                      SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                    if (showFemale) ...[
                      SliverToBoxAdapter(child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
                        child: Row(children: [
                          Text('👩‍💪', style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 8.w),
                          // Same white-on-light problem as Featured Coaches.
                          Text('Women Trainers', style: TextStyle(
                            fontSize: 15.sp, fontWeight: AppFontWeight.section,
                            color: Colors.black87)),
                          const Spacer(),
                          Text('${females.length}', style: TextStyle(
                            fontSize: 13.sp, color: Theme.of(context).colorScheme.primary,
                            fontWeight: AppFontWeight.label)),
                        ]),
                      )),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                        sliver: SliverGrid(gridDelegate: gridDelegate,
                          delegate: SliverChildBuilderDelegate(
                            (_, i) => FindTrainerCard(trainer: females[i]),
                            childCount: females.length)),
                      ),
                    ],
                    if (showMale) ...[
                      SliverToBoxAdapter(child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, showFemale ? 24.h : 12.h, 16.w, 8.h),
                        child: Row(children: [
                          Text('💪', style: TextStyle(fontSize: 18.sp)),
                          SizedBox(width: 8.w),
                          // Third instance of the same white-on-light header.
                          Text('Men Trainers', style: TextStyle(
                            fontSize: 15.sp, fontWeight: AppFontWeight.section,
                            color: Colors.black87)),
                          const Spacer(),
                          Text('${males.length}', style: TextStyle(
                            fontSize: 13.sp, color: Theme.of(context).colorScheme.primary,
                            fontWeight: AppFontWeight.label)),
                        ]),
                      )),
                      SliverPadding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary.withOpacity(0.08) : Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: active ? Theme.of(context).colorScheme.primary : const Color(0xFFD8D8D8),
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
                fontWeight: active ? AppFontWeight.label : AppFontWeight.emphasis,
                color: active ? Theme.of(context).colorScheme.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

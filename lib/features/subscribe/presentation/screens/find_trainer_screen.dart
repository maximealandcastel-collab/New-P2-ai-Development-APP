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

// ─── Filter definitions ───────────────────────────────────────────────────
const _genderFilters = [
  _Filter(id: 'all',    emoji: '👥', label: 'All'),
  _Filter(id: 'male',   emoji: '♂',  label: 'Male'),
  _Filter(id: 'female', emoji: '♀',  label: 'Female'),
];

const _specialtyFilters = [
  _Filter(id: 'all',               emoji: '⚡', label: 'All Goals'),
  _Filter(id: 'weight_loss',       emoji: '🔥', label: 'Weight Loss'),
  _Filter(id: 'muscle_gain',       emoji: '💪', label: 'Muscle'),
  _Filter(id: 'boxing',            emoji: '🥊', label: 'Combat'),
  _Filter(id: 'maintain_physique', emoji: '🧘', label: 'Abs'),
  _Filter(id: 'nutrition',         emoji: '🏃', label: 'Cardio'),
];

class _Filter {
  final String id, emoji, label;
  const _Filter({required this.id, required this.emoji, required this.label});
}

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
                  decoration: BoxDecoration(
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
                padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
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

            // ── Gender filter row ─────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44.h,
                child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _genderFilters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final f = _genderFilters[i];
                    final active = controller.selectedGender.value == f.id;
                    return GestureDetector(
                      onTap: () => controller.filterBy(
                        specialty: controller.selectedSpecialty.value,
                        gender: f.id,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFFFF6B1A) : Colors.white,
                          borderRadius: BorderRadius.circular(22.r),
                          border: active
                              ? null
                              : Border.all(color: const Color(0xFFD0D0D0), width: 1.5),
                          boxShadow: active
                              ? [BoxShadow(
                                  color: const Color(0xFFFF6B1A).withOpacity(0.35),
                                  blurRadius: 8,
                                )]
                              : null,
                        ),
                        child: Text(
                          '${f.emoji} ${f.label}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 10.h)),

            // ── Specialty filter row ──────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 44.h,
                child: Obx(() => ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _specialtyFilters.length,
                  separatorBuilder: (_, __) => SizedBox(width: 8.w),
                  itemBuilder: (_, i) {
                    final f = _specialtyFilters[i];
                    final active = controller.selectedSpecialty.value == f.id;
                    return GestureDetector(
                      onTap: () => controller.filterBy(
                        specialty: f.id,
                        gender: controller.selectedGender.value,
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: active ? const Color(0xFF1A1A2E) : Colors.white,
                          borderRadius: BorderRadius.circular(22.r),
                          border: active
                              ? null
                              : Border.all(color: const Color(0xFFD0D0D0), width: 1.5),
                          boxShadow: active
                              ? [BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 8,
                                )]
                              : null,
                        ),
                        child: Text(
                          '${f.emoji} ${f.label}',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: active ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    );
                  },
                )),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 14.h)),
          ],

          // ── Trainer grid body ─────────────────────────────────────────
          body: Obx(() {
            switch (controller.loadingState) {
              case LoadingState.loading:
              case LoadingState.initial:
                return CustomScrollView(slivers: [
                  SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
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
              case LoadingState.error:
                return CustomScrollView(slivers: [
                  SliverFillRemaining(
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey.shade300),
                        SizedBox(height: 12.h),
                        Text('Could not load trainers', style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: controller.refresh,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6B1A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                          child: Text('Try again', style: TextStyle(color: Colors.white, fontSize: 13.sp)),
                        ),
                      ]),
                    ),
                  ),
                ]);
              default:
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
                        (_, index) => FindTrainerCard(trainer: controller.trainers[index]),
                        childCount: controller.trainers.length,
                      ),
                    ),
                  ),
                  PaginationLoaderSliver(controller: controller),
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
          Get.toNamed(AppRoute.trainerProfileScreen, arguments: result.model.sId as String);
        },
      ),
    );
  }
}

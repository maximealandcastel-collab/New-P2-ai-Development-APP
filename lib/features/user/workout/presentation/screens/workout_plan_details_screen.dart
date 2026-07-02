import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/user/workout/data/models/workout_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';


class WorkoutPlanDetailsScreen extends StatelessWidget {
  const WorkoutPlanDetailsScreen({super.key});

  WorkoutModel get _workout => Get.arguments as WorkoutModel;

  WorkoutAiPlanModel? get _plan => _workout.aiPlan;

  bool get _hasVideo {
    final video = _plan?.suggestedVideo?.trim() ?? '';
    return video.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final plan = _plan;

    return SliverScaffold(
      appBar: const CustomSliverAppBar(
        title: 'View full workout plan',
        pinned: true,
      ),
      bodyList: [
        if (plan == null)
          const EmptyDataWidget(message: 'Workout plan not available.')
              .asFillRemainingSliver()
        else ...[
          _buildHeader(plan).asSliverWithPadding(horizontal: 16.w, vertical: 12.h),
          if (plan.warmUp?.isNotEmpty ?? false)
            _buildTimedStepSection(
              title: 'Warm up',
              steps: plan.warmUp!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.mainWork?.isNotEmpty ?? false)
            _buildExerciseSection(
              title: 'Main Work',
              exercises: plan.mainWork!,
              tagLabel: 'Main exercise',
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.accessories?.isNotEmpty ?? false)
            _buildExerciseSection(
              title: 'Accessories',
              exercises: plan.accessories!,
              tagLabel: 'Accessory',
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.finisher?.isNotEmpty ?? false)
            _buildFinisherSection(
              title: 'Finisher',
              exercises: plan.finisher!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.coolDown?.isNotEmpty ?? false)
            _buildTimedStepSection(
              title: 'Cool Down',
              steps: plan.coolDown!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if ((plan.nutritionTip ?? '').isNotEmpty)
            _buildInfoCard(
              title: 'Nutrition Tip',
              body: plan.nutritionTip!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.thisWeekFocus?.isNotEmpty ?? false)
            _buildChipSection(
              title: 'This Week Focus',
              values: plan.thisWeekFocus!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          if (plan.estimatedDurationMinutes != null)
            _buildDurationNote(plan).asSliverWithPadding(horizontal: 16.w, vertical: 10.h),
          SizedBox(height: 120.h).asSliver,
        ],
      ],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: CustomButton(
            label: _hasVideo ? 'Complete Exercise' : 'Go home',
            onPressed: _hasVideo ? _watchVideo : _goHome,
          ),
        ),
      ),
    );
  }

  // ---------------- Header ----------------

  Widget _buildHeader(WorkoutAiPlanModel plan) {
    final todayLabel = StringFormat.formatLabel(
      DateTime.now().toString().split(' ').first,
    );

    return CustomContainer(
      width: double.infinity,
      paddingAll: 18.r,
        radiusAll: 20.r,
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: todayLabel,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite.withValues(alpha: 0.85),
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: (plan.trainerSpecialty ?? '').isNotEmpty
                ? StringFormat.formatLabel(plan.trainerSpecialty!)
                : 'Workout Plan',
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textWhite,
          ),
          if ((plan.coachNote ?? '').isNotEmpty) ...[
            SizedBox(height: 8.h),
            CustomText(
              text: plan.coachNote!,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.textWhite,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- Warm up / Cool down (timed steps) ----------------

  Widget _buildTimedStepSection({
    required String title,
    required List<WorkoutPlanStepModel> steps,
  }) {
    final sortedSteps = [...steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            left: 4.w,
            bottom: 10.h,
          ),
          CustomContainer(
            paddingAll: 16.r,
            radiusAll: 16.r,
            bordersColor: AppColors.secondary,
            child: Column(
              children: sortedSteps
                  .asMap()
                  .entries
                  .map((entry) => _buildTimedStepRow(
                index: entry.key + 1,
                step: entry.value,
                isLast: entry.key == sortedSteps.length - 1,
              ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimedStepRow({
    required int index,
    required WorkoutPlanStepModel step,
    required bool isLast,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '$index.',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  textAlign: TextAlign.start,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    children: [
                      TextSpan(
                        text: '${step.instruction ?? ''} — ',
                      ),
                      TextSpan(
                        text: step.duration ?? '',
                        style: TextStyle(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),
          if ((step.tip ?? '').isNotEmpty) ...[
            SizedBox(height: 3.h),
            CustomText(
              text: step.tip!,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------- Main work / Accessories (full exercise cards) ----------------

  Widget _buildExerciseSection({
    required String title,
    required List<WorkoutExerciseModel> exercises,
    required String tagLabel,
  }) {
    final sortedExercises = [...exercises]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            left: 4.w,
            bottom: 10.h,
          ),
          ...sortedExercises.map(
                (exercise) => _buildExerciseCard(exercise, tagLabel: tagLabel),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseCard(
      WorkoutExerciseModel exercise, {
        required String tagLabel,
      }) {
    final steps = [...?exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 12.r,
      marginBottom: 12.h,
      bordersColor: AppColors.secondary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomText(
                  textAlign: TextAlign.start,
                  text: exercise.exerciseName ?? '',
                  fontSize: 18.sp,
                  color: Color(0xff6A3400),
                  fontWeight: FontWeight.w700,
                ),
              ),
              CustomButton(onPressed: (){},label: 'Mark Completed',width: 100.w,height: 30.h,fontSize: 10.sp),
            ],
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: 'Muscle group: ${StringFormat.formatLabel(exercise.muscleGroup!)}',
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (exercise.sets != null)
                _metricChip('${exercise.sets} sets'),
              if ((exercise.reps ?? '').isNotEmpty)
                _metricChip('${exercise.reps} reps'),
              if ((exercise.restTime ?? '').isNotEmpty)
                _metricChip('Rest ${exercise.restTime}'),
              if ((exercise.rpe ?? '').isNotEmpty)
                _metricChip('RPE ${exercise.rpe}'),
            ],
          ),
          if (steps.isNotEmpty) ...[
            SizedBox(height: 14.h),
            Divider(height: 1.h, color: AppColors.colorE6E6E6),
            SizedBox(height: 14.h),
            ...steps.asMap().entries.map(
                  (entry) => Padding(
                padding: EdgeInsets.only(
                  bottom: entry.key == steps.length - 1 ? 0 : 10.h,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: '${entry.key + 1}.',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: entry.value.instruction ?? '',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            textAlign: TextAlign.start,
                          ),
                          if ((entry.value.tip ?? '').isNotEmpty) ...[
                            SizedBox(height: 3.h),
                            CustomText(
                              text: 'Tip: ${entry.value.tip!}',
                              fontSize: 11.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                              textAlign: TextAlign.start,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String label) {
    return CustomContainer(
      paddingHorizontal: 10.w,
      paddingVertical: 7.h,
      radiusAll: 10.r,
      color: AppColors.backgroundLight,
      child: CustomText(
        text: label,
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  // ---------------- Finisher (compact cards, no steps) ----------------

  Widget _buildFinisherSection({
    required String title,
    required List<WorkoutExerciseModel> exercises,
  }) {
    final sortedExercises = [...exercises]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: title,
          fontSize: 17.sp,
          fontWeight: FontWeight.w800,
          left: 4.w,
          bottom: 10.h,
        ),
        ...sortedExercises.map(_buildFinisherCard),
      ],
    );
  }

  Widget _buildFinisherCard(WorkoutExerciseModel exercise) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      marginBottom: 10.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: exercise.exerciseName ?? 'Exercise',
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: 'Muscle group: ${StringFormat.formatLabel(exercise.muscleGroup!)}',
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (exercise.sets != null)
                _metricChip('${exercise.sets} sets'),
              if ((exercise.reps ?? '').isNotEmpty)
                _metricChip('${exercise.reps} reps'),
              if ((exercise.restTime ?? '').isNotEmpty)
                _metricChip('Rest ${exercise.restTime}'),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Info card / chips / duration note ----------------

  Widget _buildInfoCard({required String title, required String body}) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: title, fontSize: 16.sp, fontWeight: FontWeight.w700),
          SizedBox(height: 8.h),
          CustomText(
            text: body,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required String title,
    required List<String> values,
  }) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 12.r,
      color: AppColors.textWhite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            left: 4.w,
            bottom: 10.h,
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: values.asMap().entries.map((entry) {
              final isFilled = entry.key.isEven;
              return CustomContainer(
                paddingHorizontal: 14.w,
                paddingVertical: 6.h,
                radiusAll: 99.r,
                color: AppColors.primary.withValues(alpha: 0.1),
                child: CustomText(
                  text: StringFormat.formatLabel(entry.value),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationNote(WorkoutAiPlanModel plan) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Duration in min: ${plan.estimatedDurationMinutes}',
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
          if ((plan.checkInQuestion ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            CustomText(
              text: plan.checkInQuestion!,
              fontSize: 13.sp,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }

  void _goHome() {
    if (Get.isRegistered<BottomNavBarController>()) {
      BottomNavBarController.to.resetIndex();
    }
    Get.offAllNamed(AppRoute.bottonNavBar);
  }

  void _watchVideo() {
    final videoUrl = _plan?.suggestedVideo?.trim();
    if (videoUrl == null || videoUrl.isEmpty) return;

    Get.toNamed(
      AppRoute.workoutVideoScreen,
      arguments: videoUrl,
    );
  }
}
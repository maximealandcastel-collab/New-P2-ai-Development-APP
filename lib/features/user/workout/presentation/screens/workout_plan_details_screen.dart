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
        title: 'Your workout plan',
        pinned: true,
      ),
      bodyList: [
        if (plan == null)
          const EmptyDataWidget(message: 'Workout plan not available.')
              .asFillRemainingSliver()
        else ...[
          _buildHeader(plan).asSliverWithPadding(horizontal: 16.w, vertical: 16.h),
          if ((plan.coachNote ?? '').isNotEmpty)
            _buildInfoCard(
              title: 'Coach note',
              body: plan.coachNote!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.thisWeekFocus?.isNotEmpty ?? false)
            _buildChipSection(
              title: 'This week focus',
              values: plan.thisWeekFocus!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if ((plan.nutritionTip ?? '').isNotEmpty)
            _buildInfoCard(
              title: 'Nutrition tip',
              body: plan.nutritionTip!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.warmUp?.isNotEmpty ?? false)
            _buildStepSection(
              title: 'Warm up',
              steps: plan.warmUp!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.mainWork?.isNotEmpty ?? false)
            _buildExerciseSection(
              title: 'Main work',
              exercises: plan.mainWork!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.accessories?.isNotEmpty ?? false)
            _buildExerciseSection(
              title: 'Accessories',
              exercises: plan.accessories!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.finisher?.isNotEmpty ?? false)
            _buildExerciseSection(
              title: 'Finisher',
              exercises: plan.finisher!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if (plan.coolDown?.isNotEmpty ?? false)
            _buildStepSection(
              title: 'Cool down',
              steps: plan.coolDown!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          if ((plan.checkInQuestion ?? '').isNotEmpty)
            _buildInfoCard(
              title: 'Check-in question',
              body: plan.checkInQuestion!,
            ).asSliverWithPadding(horizontal: 16.w, vertical: 6.h),
          SizedBox(height: 120.h).asSliver,
        ],
      ],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Expanded(
                child: CustomButton(
                  label: 'Go home',
                  onPressed: _goHome,
                  backgroundColor: AppColors.backgroundLight,
                  foregroundColor: AppColors.textPrimary,
                  bordersColor: AppColors.colorE6E6E6,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CustomButton(
                  label: 'Watch video',
                  onPressed: _hasVideo ? _watchVideo : null,
                  isDisabled: !_hasVideo,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(WorkoutAiPlanModel plan) {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if ((plan.trainerPersona ?? '').isNotEmpty)
            CustomText(
              text: plan.trainerPersona!,
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
            ),
          if ((plan.trainerSpecialty ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: StringFormat.formatLabel(plan.trainerSpecialty!),
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ],
          if (plan.estimatedDurationMinutes != null) ...[
            SizedBox(height: 12.h),
            CustomText(
              text: 'Estimated duration: ${plan.estimatedDurationMinutes} min',
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String body}) {
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
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
      paddingAll: 16.r,
      color: AppColors.textWhite,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: values
                .map(
                  (value) => CustomContainer(
                    paddingHorizontal: 12.w,
                    paddingVertical: 8.h,
                    radiusAll: 99.r,
                    color: AppColors.primary.withValues(alpha: 0.12),
                    child: CustomText(
                      text: StringFormat.formatLabel(value),
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepSection({
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
          SizedBox(height: 12.h),
          ...sortedSteps.map(_buildPlanStepItem),
        ],
      ),
    );
  }

  Widget _buildPlanStepItem(WorkoutPlanStepModel step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: step.instruction ?? '',
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
          if ((step.duration ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: step.duration!,
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseSection({
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
          fontSize: 18.sp,
          fontWeight: FontWeight.w700,
          left: 4.w,
          bottom: 10.h,
        ),
        ...sortedExercises.map(_buildExerciseCard),
      ],
    );
  }

  Widget _buildExerciseCard(WorkoutExerciseModel exercise) {
    final steps = [...?exercise.steps]
      ..sort((a, b) => (a.order ?? 0).compareTo(b.order ?? 0));

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
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
          if ((exercise.muscleGroup ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
            CustomText(
              text: StringFormat.formatLabel(exercise.muscleGroup!),
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ],
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (exercise.sets != null)
                _metricChip('Sets', '${exercise.sets}'),
              if ((exercise.reps ?? '').isNotEmpty)
                _metricChip('Reps', exercise.reps!),
              if ((exercise.restTime ?? '').isNotEmpty)
                _metricChip('Rest', exercise.restTime!),
              if ((exercise.rpe ?? '').isNotEmpty)
                _metricChip('RPE', exercise.rpe!),
            ],
          ),
          if (steps.isNotEmpty) ...[
            SizedBox(height: 12.h),
            CustomText(
              text: 'Steps',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
            SizedBox(height: 8.h),
            ...steps.map(_buildExerciseStepItem),
          ],
        ],
      ),
    );
  }

  Widget _metricChip(String label, String value) {
    return CustomContainer(
      paddingHorizontal: 10.w,
      paddingVertical: 8.h,
      radiusAll: 10.r,
      color: AppColors.backgroundLight,
      child: CustomText(
        text: '$label: $value',
        fontSize: 12.sp,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildExerciseStepItem(WorkoutExerciseStepModel step) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: '${step.order ?? ''}. ${step.instruction ?? ''}',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
          if ((step.tip ?? '').isNotEmpty) ...[
            SizedBox(height: 4.h),
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

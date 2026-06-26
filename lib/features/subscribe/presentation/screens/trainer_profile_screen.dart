import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/trainer_profile_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TrainerProfileScreen extends StatefulWidget {
  const TrainerProfileScreen({super.key});

  @override
  State<TrainerProfileScreen> createState() => _TrainerProfileScreenState();
}

class _TrainerProfileScreenState extends State<TrainerProfileScreen> {
  final String? trainerID = Get.arguments as String?;

  final controller = SubscribeController.to;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchDetails(trainerID ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isLoading = controller.detailsLoadingState.isInitial ||
          controller.detailsLoadingState.isLoading;
      final userData = controller.trainerDetails;

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          safeArea: false,
          expandedHeight: 270.h,
          collapsedTitle: isLoading ? '' : userData?.name ?? '',
          foregroundColor: Colors.white,
          flexibleBackground: isLoading
              ? TrainerProfileShimmer.headerShimmer()
              : _buildHeader(userData),
        ),
        slivers: isLoading
            ? (_) => TrainerProfileShimmer.contentSlivers()
            : _buildSlivers,
      );
    });
  }

  Widget _buildHeader(TrainerDetailsModel? userData) {
    return CustomContainer(
      child: Stack(
        children: [
          CustomNetworkImage(
            height: 210.h,
            fit: BoxFit.cover,
            width: double.infinity,
            imageUrl: '',
          ),
          Positioned(
            top: 132.h,
            left: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomContainer(
                  shape: BoxShape.circle,
                  paddingAll: 6.r,
                  bordersColor: AppColors.primary,
                  child: CustomNetworkImage(
                    height: 124.r,
                    width: 124.r,
                    boxShape: BoxShape.circle,
                    imageUrl: '',
                  ),
                ),
                CustomText(
                  textAlign: TextAlign.start,
                  top: 6.h,
                  text: StringFormat.valueOrNa(userData?.name),
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    final userData = controller.trainerDetails;

    return [
      SizedBox(height: 20.h).asSliver,
      CustomButton(
        onPressed: () => _showRequestSheet(context),
        label: 'Request trainer',
      ).asSliverWithPadding(horizontal: 16.w),
      SizedBox(height: 24.h).asSliver,
      _buildBioCardWidget(
        fontSize: 12.sp,
        label: 'Bio',
        value: StringFormat.valueOrNa(userData?.bio),
      ).asSliver,
      _buildBioCardWidget(
        label: 'Specialty',
        value: StringFormat.specialtyOrNa(userData?.specialty),
      ).asSliver,
      _buildBioCardWidget(
        label: 'Certifications',
        value: StringFormat.listOrNa(userData?.certifications),
      ).asSliver,
      _buildBioCardWidget(
        label: 'Trainer style tags',
        value: StringFormat.listOrNa(userData?.trainingStyleTags),
      ).asSliver,
      CustomContainer(
        horizontalMargin: 16.h,
        verticalMargin: 24.h,
        paddingAll: 20.r,
        radiusAll: 20.r,
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              top: 10.h,
              bottom: 4.h,
              text: 'monthly',
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            CustomText(
              bottom: 16.h,
              text: StringFormat.formatPrice(userData?.subscriptionPrice),
              fontSize: 36.sp,
              fontWeight: FontWeight.w800,
            ),
            Assets.icons.trainerSubIcons.svg(),
            SizedBox(height: 16.h),
            ...HelperData.trainerGuidance.map((e) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Row(
                  children: [
                    Icon(Icons.lock_rounded, size: 16.r),
                    SizedBox(width: 6.w),
                    CustomText(
                      text: e,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ).asSliver,
      SizedBox(height: 60.h).asSliver,
    ];
  }

  void _showRequestSheet(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: Colors.white,
      elevation: 2,
      context: context,
      builder: (context) {
        return Obx(
          () => DialogShowHelper.showBottomSheet(
            context,
            title: 'Trainer request',
            content: CustomTextField(
              controller: controller.noteTEController,
              contentPaddingVertical: 10.h,
              labelText: 'Note :',
              hintText: 'Write a short message ',
              maxLines: 5,
              minLines: 5,
            ),
            buttonLabel: 'Request trainer',
            isLoading: controller.requestLoadingState.isLoading,
            onTapConfirm: () =>
                controller.requestTrainer(trainerID ?? ''),
          ),
        );
      },
    );
  }

  Widget _buildBioCardWidget({
    required String label,
    required String value,
    double? fontSize,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: label, color: AppColors.textSecondary, bottom: 6.h),
          CustomText(
            textAlign: TextAlign.start,
            text: value,
            fontSize: fontSize ?? 16.sp,
            fontWeight: FontWeight.w500,
            bottom: 10.h,
          ),
        ],
      ),
    );
  }

}

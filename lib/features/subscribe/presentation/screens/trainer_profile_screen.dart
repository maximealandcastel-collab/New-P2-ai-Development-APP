import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
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
        bodyList: isLoading
            ? TrainerProfileShimmer.contentSlivers()
            : _buildSlivers(context),
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
        onPressed: () => _showBookSheet(context, userData),
        label: 'Book Trainer',
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
      SizedBox(height: 60.h).asSliver,
    ];
  }

  void _showBookSheet(BuildContext context, TrainerDetailsModel? userData) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _BookTrainerSheet(
        trainerName: userData?.name ?? 'Trainer',
        photoUrl: '',
      ),
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

class _BookTrainerSheet extends StatelessWidget {
  final String trainerName;
  final String photoUrl;

  const _BookTrainerSheet({required this.trainerName, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final ctrl = PaywallController.to;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 36.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 20.h),

          // Trainer avatar + name
          photoUrl.isNotEmpty
              ? CircleAvatar(
                  radius: 36.r,
                  backgroundImage: NetworkImage(photoUrl),
                )
              : CircleAvatar(
                  radius: 36.r,
                  backgroundColor: AppColors.primary.withOpacity(0.15),
                  child: Icon(Icons.person, size: 36.sp, color: AppColors.primary),
                ),
          SizedBox(height: 12.h),
          Text(
            trainerName,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            'Personal Trainer',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
          ),
          SizedBox(height: 24.h),

          // Price card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  ctrl.monthlyPriceStr.value,
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                )),
                Text(
                  '/ month',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
                ),
                SizedBox(height: 16.h),
                ...[
                  'AI-guided workout plans',
                  'Direct trainer messaging',
                  'Progress tracking & analytics',
                  'Cancel anytime',
                ].map((b) => Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.primary, size: 16.r),
                      SizedBox(width: 8.w),
                      Text(b,
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Book button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: ctrl.purchaseLoading.value
                  ? null
                  : () {
                      ctrl.selectPlan('monthly');
                      ctrl.upgradeNow();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: ctrl.purchaseLoading.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.h,
                      child: const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Book Trainer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          )),
          SizedBox(height: 8.h),
          Text(
            'Billed monthly · Cancel anytime',
            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestDetailsContent extends StatelessWidget {
  const RequestDetailsContent({super.key, required this.request});

  final TrainerRequestModel request;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12.h),
        _buildHeaderCard(),
        SizedBox(height: 12.h),
        _buildSummaryMetrics(),
        SizedBox(height: 12.h),
        _buildNoteSection(),
        if (request.isAccepted) ...[
          SizedBox(height: 12.h),
          _buildAcceptedSection(),
        ],
        SizedBox(height: 20.h),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomNetworkImage(
                height: 64.r,
                width: 64.r,
                boxShape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.48)),
                imageUrl: request.userId?.profilePicture ?? '',
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: request.clientName,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      textAlign: TextAlign.start,
                    ),
                    if ((request.userId?.email ?? '').isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      CustomText(
                        text: request.userId!.email!,
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                        textAlign: TextAlign.start,
                      ),
                    ],
                    SizedBox(height: 8.h),
                    _buildStatusBadge(),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Divider(color: AppColors.colorE6E6E6, height: 1.h),
          SizedBox(height: 14.h),
          _buildInfoHighlight(
            label: 'Request date',
            value: request.formatDateTime(request.createdAt),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = request.status?.toLowerCase() ?? '';
    final Color backgroundColor;
    final Color textColor;

    switch (status) {
      case 'accepted':
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
      case 'rejected':
        backgroundColor = AppColors.error.withValues(alpha: 0.12);
        textColor = AppColors.error;
      case 'pending':
        backgroundColor = AppColors.info.withValues(alpha: 0.12);
        textColor = AppColors.info;
      default:
        backgroundColor = AppColors.backgroundLight;
        textColor = AppColors.textSecondary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: CustomText(
        text: request.statusLabel,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildInfoHighlight({
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: value,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryMetrics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10.w) / 2;

        return Row(
          children: [
            SizedBox(
              width: itemWidth,
              child: _buildMetricCard(
                label: 'Fitness level',
                value: StringFormat.formatLabel(
                  request.userId?.fitnessLevel ?? 'N/A',
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: itemWidth,
              child: _buildMetricCard(
                label: 'Primary goal',
                value: StringFormat.formatLabel(
                  request.userId?.primaryGoal ?? 'N/A',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
  }) {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 14.w,
      paddingVertical: 14.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 6.h),
          CustomText(
            text: value,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildNoteSection() {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Assets.icons.note.svg(),
              CustomText(
                left: 6.w,
                text: 'Note',
                fontWeight: FontWeight.w700,
                fontSize: 16.sp,
                textAlign: TextAlign.start,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: CustomText(
              text: StringFormat.valueOrNa(request.note),
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcceptedSection() {
    return CustomContainer(
      color: Colors.white,
      radiusAll: 16.r,
      paddingHorizontal: 16.w,
      paddingVertical: 16.h,
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: 'Accepted',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          _buildInfoHighlight(
            label: 'Accepted at',
            value: request.formatDateTime(request.acceptedAt),
          ),
        ],
      ),
    );
  }
}

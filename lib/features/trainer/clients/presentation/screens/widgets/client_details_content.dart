import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientDetailsContent extends StatelessWidget {
  const ClientDetailsContent({super.key, required this.invoice});

  final ClientInvoiceModel invoice;

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
        _buildDescriptionSection(),
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
                imageUrl: invoice.userId?.profilePicture ?? '',
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: invoice.clientName,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp,
                      textAlign: TextAlign.start,
                    ),
                    if ((invoice.userId?.email ?? '').isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      CustomText(
                        text: invoice.userId!.email!,
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
          _buildPeriodHighlight(),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final status = invoice.status?.toLowerCase() ?? '';
    final Color backgroundColor;
    final Color textColor;

    switch (status) {
      case 'paid':
        backgroundColor = AppColors.success.withValues(alpha: 0.12);
        textColor = AppColors.success;
      case 'sent':
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
        text: invoice.statusLabel,
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
        textAlign: TextAlign.start,
      ),
    );
  }

  Widget _buildPeriodHighlight() {
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
            text: 'Subscription period',
            fontSize: 11.sp,
            color: AppColors.textSecondary,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 4.h),
          CustomText(
            text: invoice.subscriptionPeriod,
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
                label: 'Amount',
                value: invoice.formattedAmount,
                valueColor: AppColors.info,
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: itemWidth,
              child: _buildMetricCard(
                label: 'Renewal',
                value: invoice.isRenewal == true ? 'Yes' : 'No',
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
    Color? valueColor,
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
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection() {
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
            text: 'Description',
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            textAlign: TextAlign.start,
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
              text: StringFormat.valueOrNa(invoice.description),
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}

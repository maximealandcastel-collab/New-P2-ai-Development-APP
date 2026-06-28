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
        _buildDetailsSection(
          title: 'Subscription',
          children: [
            _buildDetailRow(label: 'Period', value: invoice.subscriptionPeriod),
            _buildDetailRow(
              label: 'Description',
              value: StringFormat.valueOrNa(invoice.description),
            ),
            _buildDetailRow(
              label: 'Amount',
              value: invoice.formattedAmount,
              valueColor: AppColors.info,
            ),
            _buildDetailRow(
              label: 'Renewal',
              value: invoice.isRenewal == true ? 'Yes' : 'No',
            ),
          ],
        ),
        SizedBox(height: 12.h),
        _buildDetailsSection(
          title: 'Invoice',
          children: [
            _buildDetailRow(label: 'Status', value: invoice.statusLabel),
            _buildDetailRow(
              label: 'Sent at',
              value: invoice.formatDateTime(invoice.sentAt),
            ),
            if (invoice.isPaid)
              _buildDetailRow(
                label: 'Paid at',
                value: invoice.formatDateTime(invoice.paidAt),
              ),
            _buildDetailRow(
              label: 'Expires at',
              value: invoice.formatDateTime(invoice.expiresAt),
            ),
            _buildDetailRow(
              label: 'Created at',
              value: invoice.formatDateTime(invoice.createdAt),
            ),
          ],
        ),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomNetworkImage(
            height: 56.r,
            width: 56.r,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection({
    required String title,
    required List<Widget> children,
  }) {
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
            text: title,
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            textAlign: TextAlign.start,
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomText(
              text: label,
              fontSize: 13.sp,
              color: AppColors.textSecondary,
              textAlign: TextAlign.start,
            ),
          ),
          Expanded(
            flex: 3,
            child: CustomText(
              text: value,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

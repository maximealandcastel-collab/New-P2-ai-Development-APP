import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientCardWidget extends StatelessWidget {
  const ClientCardWidget({
    super.key,
    this.invoice,
    this.name,
    this.subtitle,
    this.profilePicture,
    this.onTap,
    this.onChatTap,
  });

  final ClientInvoiceModel? invoice;
  final String? name;
  final String? subtitle;
  final String? profilePicture;
  final VoidCallback? onTap;
  final VoidCallback? onChatTap;

  @override
  Widget build(BuildContext context) {
    final clientName = name ?? invoice?.clientName ?? '';
    final subscriptionPeriod = subtitle ?? invoice?.subscriptionPeriod ?? '';
    final profilePictureUrl =
        profilePicture ?? invoice?.userId?.profilePicture ?? '';

    return CustomContainer(
      marginTop: 10.h,
      radiusAll: 18.r,
      color: Colors.white,
      bordersColor: const Color(0xFFECECEF),
      borderWidth: 0.8,
      paddingHorizontal: 14.w,
      paddingVertical: 12.h,
      onTap: onTap,
      child: Row(
        children: [
          CustomNetworkImage(
            height: 42.r,
            width: 42.r,
            boxShape: BoxShape.circle,
            backgroundColor: const Color(0xFFF3F3F5),
            imageUrl: profilePictureUrl,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  textAlign: TextAlign.start,
                  fontSize: 15.sp,
                  fontWeight: AppFontWeight.label,
                  text: clientName,
                  maxline: 1,
                  textOverflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                CustomText(
                  textAlign: TextAlign.start,
                  fontSize: 11.sp,
                  fontWeight: AppFontWeight.body,
                  color: AppColors.textSecondary,
                  text: 'Subscription period',
                ),
                SizedBox(height: 2.h),
                CustomText(
                  textAlign: TextAlign.start,
                  fontSize: 11.sp,
                  fontWeight: AppFontWeight.body,
                  color: AppColors.textSecondary,
                  text: subscriptionPeriod,
                  maxline: 2,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onChatTap != null) ...[
            SizedBox(width: 6.w),
            IconButton(
              onPressed: onChatTap,
              tooltip: 'Message $clientName',
              constraints: BoxConstraints(minWidth: 44.r, minHeight: 44.r),
              style: IconButton.styleFrom(
                backgroundColor: const Color(0xFFF8F8FA),
                side: const BorderSide(color: Color(0xFFECECEF)),
              ),
              icon: Assets.icons.message.svg(height: 18.r, width: 18.r),
            ),
          ],
        ],
      ),
    );
  }
}

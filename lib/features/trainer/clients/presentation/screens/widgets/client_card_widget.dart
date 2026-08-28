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
      marginTop: 8.h,
      radiusAll: 12.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      paddingVertical: 6.h,
      onTap: onTap,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CustomNetworkImage(
          height: 40.r,
          width: 40.r,
          boxShape: BoxShape.circle,
          border: Border.all(color: Colors.black.withValues(alpha: 0.48)),
          imageUrl: profilePictureUrl,
        ),
        title: CustomText(
          textAlign: TextAlign.start,
          fontSize: 16.sp,
          fontWeight: AppFontWeight.label,
          text: clientName,
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: 'Subscription period\n$subscriptionPeriod',
        ),
        trailing: onChatTap == null ? null : GestureDetector(
          onTap: onChatTap,
          behavior: HitTestBehavior.opaque,
          child: Assets.icons.message.svg(),
        ),
      ),
    );
  }
}

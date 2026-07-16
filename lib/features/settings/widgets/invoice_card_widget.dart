import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class InvoiceCardWidget extends StatelessWidget {
  const InvoiceCardWidget({
    super.key,
    required this.invoice,
    this.onTap,
  });

  final ClientInvoiceModel invoice;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isReceived = invoice.isReceived;

    return CustomContainer(
      onTap: onTap,
      marginTop: 8.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      child: Column(
        children: [
          ListTile(
            leading: CustomImageAvatar(
              image: invoice.userId?.profilePicture ?? '',
            ),
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                    text: invoice.clientName,
                    maxline: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                ),
                CustomContainer(
                  radiusAll: 99.r,
                  paddingVertical: 3.h,
                  paddingHorizontal: 6.w,
                  color: isReceived ? AppColors.success : AppColors.primary,
                  child: Row(
                    children: [
                      isReceived
                          ? Assets.icons.recieved.svg()
                          : Assets.icons.panding.svg(),
                      CustomText(
                        text: isReceived ? 'Received' : 'Pending',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            subtitle: CustomText(
              fontSize: 12.sp,
              textAlign: TextAlign.start,
              color: AppColors.textSecondary,
              text: invoice.listSubtitle,
              maxline: 2,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: 'Total billed', fontWeight: FontWeight.w600),
              CustomText(
                text: invoice.formattedAmount,
                fontWeight: FontWeight.w700,
                color: AppColors.info,
              ),
            ],
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

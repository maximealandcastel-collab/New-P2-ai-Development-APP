import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TransactionHistoryWidget extends StatelessWidget {
  const TransactionHistoryWidget({
    super.key,
    this.amount   = '$0.00',
    this.label    = 'Transaction',
    this.subtitle = '',
    this.status   = 'pending',
    this.isCredit = true,
  });

  final String amount;
  final String label;
  final String subtitle;
  final String status;   // pending | approved | paid | rejected
  final bool   isCredit;

  Color get _statusColor {
    switch (status) {
      case 'paid':     return AppColors.success;
      case 'approved': return Colors.blue;
      case 'rejected': return AppColors.error;
      default:         return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      child: ListTile(
        leading: CustomContainer(
          bordersColor: Colors.black.withOpacity(0.16),
          color: Colors.black.withOpacity(0.04),
          radiusAll: 16.r,
          width: 40.w,
          height: 40.h,
          child: Icon(
            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
            color: isCredit ? AppColors.success : Colors.orange,
            size: 20.r,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Expanded(
              child: CustomText(
                textAlign: TextAlign.start,
                fontWeight: FontWeight.w600,
                text: label,
                maxline: 1,
                textOverflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                status[0].toUpperCase() + status.substring(1),
                style: TextStyle(color: _statusColor, fontSize: 11.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: subtitle,
        ),
        trailing: CustomText(
          text: amount,
          fontWeight: FontWeight.w600,
          color: isCredit ? AppColors.success : AppColors.textPrimary,
        ),
      ),
    );
  }
}

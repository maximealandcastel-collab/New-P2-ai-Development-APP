import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/settings/data/models/payment_transaction_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class TransationHistoryWidget extends StatelessWidget {
  const TransationHistoryWidget({
    super.key,
    this.transaction,
  });

  final PaymentTransactionModel? transaction;

  @override
  Widget build(BuildContext context) {
    final titleText = transaction?.clientName ?? 'Received money';
    final subtitleText = transaction?.formattedTime ?? '';
    final amountText = transaction?.formattedAmount ?? '';
    final isWithdrawal = transaction?.status?.toLowerCase() == 'withdrawn';

    return CustomContainer(
      marginTop: 8.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingHorizontal: 12.w,
      child: ListTile(
        leading: CustomContainer(
          bordersColor: Colors.black.withValues(alpha: 0.16),
          color: Colors.black.withValues(alpha: 0.04),
          radiusAll: 16.r,
          width: 40.w,
          height: 40.h,
          child: Icon(
            isWithdrawal ? Icons.arrow_upward : Icons.arrow_downward,
            color: AppColors.textPrimary,
            size: 20.r,
          ),
        ),
        contentPadding: EdgeInsets.zero,
        title: CustomText(
          textAlign: TextAlign.start,
          fontWeight: AppFontWeight.label,
          text: titleText,
          maxline: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
        subtitle: CustomText(
          textAlign: TextAlign.start,
          fontSize: 12.sp,
          color: AppColors.textSecondary,
          text: subtitleText,
        ),
        trailing: CustomText(
          text: amountText,
          fontWeight: AppFontWeight.label,
          color: isWithdrawal ? AppColors.textPrimary : AppColors.success,
        ),
      ),
    );
  }
}

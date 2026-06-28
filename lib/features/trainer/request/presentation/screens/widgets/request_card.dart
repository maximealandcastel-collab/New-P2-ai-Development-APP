import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/controllers/requests_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request});

  final TrainerRequestModel request;

  RequestsController get _controller => RequestsController.to;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginBottom: 10.h,
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 16.r,
      onTap: () => _controller.onRequestTap(request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomNetworkImage(
                height: 40.r,
                width: 40.r,
                imageUrl: request.userId?.profilePicture ?? '',
                boxShape: BoxShape.circle,
                border: Border.all(color: Colors.black.withValues(alpha: 0.48)),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      textAlign: TextAlign.start,
                      textOverflow: TextOverflow.ellipsis,
                      maxline: 1,
                      text: request.clientName,
                      fontWeight: FontWeight.w600,
                    ),
                    CustomText(
                      textAlign: TextAlign.start,
                      text: request.statusLabel,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (request.formattedRequestDate.isNotEmpty)
            CustomText(
              top: 10.h,
              textAlign: TextAlign.start,
              text: request.formattedRequestDate,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          if ((request.note ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            CustomContainer(
              radiusAll: 16.r,
              color: Colors.black.withValues(alpha: 0.08),
              paddingAll: 10.r,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Assets.icons.note.svg(),
                      CustomText(
                        left: 6.w,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.start,
                        text: 'Note',
                        fontSize: 12.sp,
                      ),
                    ],
                  ),
                  CustomText(
                    top: 6.h,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withValues(alpha: 0.50),
                    textAlign: TextAlign.start,
                    text: StringFormat.valueOrNa(request.note),
                  ),
                ],
              ),
            ),
          ],
          ..._buildActions(context),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (request.isAccepted) {
      if (request.canSendInvoice) {
        return [
          SizedBox(height: 16.h),
          CustomButton(
            height: 40.h,
            radius: 16.r,
            fontSize: 14.sp,
            onPressed: () => _showSendInvoiceDialog(context),
            label: 'Send Invoice',
          ),
        ];
      }

      if (request.isInvoiceSent) {
        return [
          SizedBox(height: 16.h),
          CustomContainer(
            radiusAll: 12.r,
            color: AppColors.info.withValues(alpha: 0.12),
            paddingHorizontal: 12.w,
            paddingVertical: 10.h,
            width: double.infinity,
            child: Row(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 18.r,
                  color: AppColors.info,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: CustomText(
                    text: request.invoiceStatusLabel,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.info,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
          ),
        ];
      }

      return const [];
    }

    if (request.isPending) {
      return [
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                height: 40.h,
                radius: 16.r,
                fontSize: 14.sp,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                bordersColor: AppColors.primary,
                onPressed: () => _showAcceptDialog(context),
                label: 'Accept',
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: CustomButton(
                height: 40.h,
                radius: 16.r,
                fontSize: 14.sp,
                backgroundColor: Colors.white,
                foregroundColor: AppColors.error,
                bordersColor: AppColors.error,
                onPressed: () => _showRejectDialog(context),
                label: 'Reject',
              ),
            ),
          ],
        ),
      ];
    }

    return const [];
  }

  void _showAcceptDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Accept request?',
      description: 'Are you sure you want to accept ${request.clientName}?',
      rightButtonLabel: 'Yes, Accept',
      titleColor: AppColors.primary,
      rightButtonBgColor: AppColors.primary,
      onConfirm: () => _controller.acceptRequest(request.id ?? ''),
    );
  }

  void _showRejectDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Reject request?',
      description: 'Are you sure you want to reject ${request.clientName}?',
      rightButtonLabel: 'Yes, Reject',
      titleColor: AppColors.error,
      rightButtonBgColor: AppColors.error,
      onConfirm: () => _controller.rejectRequest(request.id ?? ''),
    );
  }

  void _showSendInvoiceDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Send invoice?',
      description: 'Send invoice to ${request.clientName}?',
      rightButtonLabel: 'Send Invoice',
      titleColor: AppColors.textPrimary,
      rightButtonBgColor: AppColors.primary,
      onConfirm: () => _controller.sendInvoice(request),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String rightButtonLabel,
    required Color titleColor,
    required Color rightButtonBgColor,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return Obx(
          () => CustomDialog(
            title: title,
            description: description,
            titleColor: titleColor,
            rightButtonLabel: rightButtonLabel,
            rightButtonBgColor: rightButtonBgColor,
            isLoading: _controller.actionLoadingState.isLoading,
            onTapLeftButton: () => Get.back(),
            onTapRightButton: onConfirm,
          ),
        );
      },
    );
  }
}

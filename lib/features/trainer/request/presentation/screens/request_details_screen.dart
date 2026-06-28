import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/controllers/requests_controller.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_details_content.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_profile_header.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class RequestDetailsScreen extends StatefulWidget {
  const RequestDetailsScreen({super.key, required this.request});

  final TrainerRequestModel request;

  @override
  State<RequestDetailsScreen> createState() => _RequestDetailsScreenState();
}

class _RequestDetailsScreenState extends State<RequestDetailsScreen> {
  late TrainerRequestModel _request;

  RequestsController get _controller => RequestsController.to;

  @override
  void initState() {
    super.initState();
    _request = widget.request;
  }

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        safeArea: false,
        expandedHeight: 270.h,
        collapsedTitle: _request.clientName,
        foregroundColor: Colors.white,
        flexibleBackground: RequestProfileHeader(request: _request),
      ),
      bodyList: [
        RequestDetailsContent(request: _request).asSliverWithPadding(
          horizontal: 16.w,
        ),
        SizedBox(height: 70.h).asSliver,
      ],
      bottomNavigationBar: _buildBottomActions(context),
    );
  }

  Widget? _buildBottomActions(BuildContext context) {
    if (_request.isPending) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              height: 42.h,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              bordersColor: AppColors.primary,
              onPressed: () => _showAcceptDialog(context),
              label: 'Accept',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: CustomButton(
              height: 42.h,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.error,
              bordersColor: AppColors.error,
              onPressed: () => _showRejectDialog(context),
              label: 'Reject',
            ),
          ),
        ],
      );
    }

    if (_request.canSendInvoice) {
      return CustomButton(
        height: 42.h,
        onPressed: () => _showSendInvoiceDialog(context),
        label: 'Send Invoice',
      );
    }

    return null;
  }

  Future<void> _acceptRequest() async {
    final requestId = _request.id;
    if (requestId == null) return;

    await _controller.acceptRequest(requestId);
    if (_controller.actionLoadingState != LoadingState.error) {
      setState(() => _request.status = 'accepted');
    }
  }

  Future<void> _rejectRequest() async {
    final requestId = _request.id;
    if (requestId == null) return;

    await _controller.rejectRequest(requestId);
    if (_controller.actionLoadingState != LoadingState.error) {
      setState(() => _request.status = 'rejected');
    }
  }

  Future<void> _sendInvoice() async {
    await _controller.sendInvoice(_request);
    if (_controller.actionLoadingState != LoadingState.error) {
      Get.back();
    }
  }

  void _showAcceptDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Accept request?',
      description: 'Are you sure you want to accept ${_request.clientName}?',
      rightButtonLabel: 'Yes, Accept',
      titleColor: AppColors.primary,
      rightButtonBgColor: AppColors.primary,
      onConfirm: _acceptRequest,
    );
  }

  void _showRejectDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Reject request?',
      description: 'Are you sure you want to reject ${_request.clientName}?',
      rightButtonLabel: 'Yes, Reject',
      titleColor: AppColors.error,
      rightButtonBgColor: AppColors.error,
      onConfirm: _rejectRequest,
    );
  }

  void _showSendInvoiceDialog(BuildContext context) {
    _showConfirmDialog(
      context,
      title: 'Send invoice?',
      description: 'Send invoice to ${_request.clientName}?',
      rightButtonLabel: 'Send Invoice',
      titleColor: AppColors.textPrimary,
      rightButtonBgColor: AppColors.primary,
      onConfirm: _sendInvoice,
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String description,
    required String rightButtonLabel,
    required Color titleColor,
    required Color rightButtonBgColor,
    required Future<void> Function() onConfirm,
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

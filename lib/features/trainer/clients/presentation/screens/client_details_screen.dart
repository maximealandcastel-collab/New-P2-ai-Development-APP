import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/controllers/client_details_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_details_content.dart';
import 'package:pler_to_pler_app/features/trainer/widgets/trainer_profile_header.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientDetailsScreen extends StatelessWidget {
  const ClientDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ClientDetailsController.to;
    final invoice = controller.invoice;
    final user = invoice.userId;

    return SliverScaffold(
      appBar: CustomSliverAppBar(
        safeArea: false,
        expandedHeight: 270.h,
        collapsedTitle: invoice.clientName,
        foregroundColor: Colors.white,
        flexibleBackground: TrainerProfileHeader(
          name: invoice.clientName,
          coverPhoto: user?.coverPhoto,
          profilePicture: user?.profilePicture,
        ),
      ),
      bodyList: [
        ClientDetailsContent(
          invoice: invoice,
        ).asSliverWithPadding(horizontal: 16.w),
        SizedBox(height: 70.h).asSliver,
      ],
      bottomNavigationBar: Row(
        children: [
          if (invoice.isPaid) ...[
            Expanded(
              child: CustomButton(
                height: 42.h,
                onPressed: controller.onChatTap,
                label: 'Message',
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: CustomButton(
              height: 42.h,
              onPressed: controller.openInvoicePdf,
              label: 'View invoice',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              bordersColor: AppColors.colorE6E6E6,
            ),
          ),
        ],
      ),
    );
  }
}

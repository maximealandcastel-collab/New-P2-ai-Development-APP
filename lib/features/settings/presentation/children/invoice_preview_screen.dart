import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/invoice_preview_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class InvoicePreviewScreen extends StatelessWidget {
  const InvoicePreviewScreen({
    super.key,
    required this.invoice,
  });

  final ClientInvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final controller = InvoicePreviewController.to;

    return SliverScaffold(

      appBar: CustomSliverAppBar(
        title: invoice.clientName,
      ),
      bodyList: [
        Obx(() => _buildBody(context, controller)),
        SizedBox(height: 40.h).asSliver,
      ],
      bottomNavigationBar: Obx(() {
        final isDownloading = controller.downloadState.isLoading;
        final progressPercent = (controller.downloadProgress * 100).round();

        return CustomButton(
          onPressed: isDownloading ? null : controller.downloadPdf,
          label: isDownloading ? 'Downloading $progressPercent%' : 'Download',
        );
      }),

    );
  }

  Widget _buildBody(BuildContext context, InvoicePreviewController controller) {
    switch (controller.loadingState) {
      case LoadingState.initial:
      case LoadingState.loading:
        return SizedBox(
          height: 500.h,
          child: const Center(child: CustomLoader()),
        ).asSliver;
      case LoadingState.offline:
      case LoadingState.error:
        return SizedBox(
          height: 500.h,
          child: EmptyDataWidget(
            message: 'Could not load invoice PDF.',
            onRefresh: controller.loadPdf,
          ),
        ).asSliver;
      case LoadingState.loaded:
        final filePath = controller.localFilePath;
        if (filePath == null || filePath.isEmpty) {
          return SizedBox(
            height: 500.h,
            child: const EmptyDataWidget(
              message: 'Invoice PDF not available.',
            ),
          ).asSliver;
        }

        return SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.75,
          child: PDFView(
            backgroundColor: AppColors.backgroundLight,
            filePath: filePath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            fitPolicy: FitPolicy.WIDTH,
          ),
        ).asSliver;
    }
  }
}

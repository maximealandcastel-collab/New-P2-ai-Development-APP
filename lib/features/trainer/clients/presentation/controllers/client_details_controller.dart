import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailsController extends GetxController {
  ClientDetailsController({required this.invoice});

  final ClientInvoiceModel invoice;

  static ClientDetailsController get to => Get.find();

  void onChatTap() {
    Get.toNamed(
      AppRoute.chatScreen,
      arguments: ChatScreenArgs(displayName: invoice.clientName),
    );
  }

  Future<void> openInvoicePdf() async {
    final url = invoice.pdfUrl;
    if (url == null || url.trim().isEmpty) {
      ToastMessageHelper.show('Invoice PDF not available');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ToastMessageHelper.show('Could not open invoice');
    }
  }
}

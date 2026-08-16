import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/chat_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ClientDetailsController extends GetxController {
  ClientDetailsController({required this.invoice});

  final ClientInvoiceModel invoice;

  static ClientDetailsController get to => Get.find();

  /// Opens the real-time Stream chat with this subscriber.
  ///
  /// [ChatScreen._initChannel] will call the backend to create/fetch the
  /// Stream channel automatically using [otherUserId] when no [channelId]
  /// is present, so we don't need to await a channel-creation step here.
  void onChatTap() {
    Get.toNamed(
      AppRoute.chatScreen,
      arguments: ChatScreenArgs(
        displayName: invoice.clientName,
        subtitle: 'subscriber',
        otherUserId: invoice.userId?.sId,
        otherUserImage: invoice.userId?.profilePicture,
      ),
    );
  }

  Future<void> openInvoicePdf() async {
    final url = invoice.pdfUrl;
    if (url == null || url.trim().isEmpty) {
      ToastMessageHelper.show('Invoice PDF not available');
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null ||
        !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ToastMessageHelper.show('Could not open invoice');
    }
  }
}

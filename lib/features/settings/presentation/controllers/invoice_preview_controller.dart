import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:share_plus/share_plus.dart';

class InvoicePreviewController extends GetxController {
  InvoicePreviewController({required this.invoice});

  final ClientInvoiceModel invoice;

  static InvoicePreviewController get to => Get.find();

  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;
  final Rx<LoadingState> _downloadState = LoadingState.initial.obs;
  final RxnString _localFilePath = RxnString();

  LoadingState get loadingState => _loadingState.value;
  LoadingState get downloadState => _downloadState.value;
  String? get localFilePath => _localFilePath.value;

  @override
  void onInit() {
    super.onInit();
    loadPdf();
  }

  Future<void> loadPdf() async {
    final url = invoice.pdfUrl?.trim();
    if (url == null || url.isEmpty) {
      _loadingState.value = LoadingState.error;
      return;
    }

    if (_loadingState.value.isLoading) return;
    _loadingState.value = LoadingState.loading;

    try {
      final filePath = await _downloadToLocalFile(url);
      _localFilePath.value = filePath;
      _loadingState.value = LoadingState.loaded;
    } catch (e) {
      _loadingState.value = LoadingState.error;
      if (kDebugMode) debugPrint('loadPdf error: $e');
    }
  }

  Future<void> downloadPdf() async {
    if (_downloadState.value.isLoading) return;

    final url = invoice.pdfUrl?.trim();
    if (url == null || url.isEmpty) {
      ToastMessageHelper.show('Invoice PDF not available');
      return;
    }

    _downloadState.value = LoadingState.loading;

    try {
      final filePath = _localFilePath.value ?? await _downloadToLocalFile(url);
      _localFilePath.value = filePath;

      final file = File(filePath);
      if (!file.existsSync()) {
        throw Exception('Downloaded file not found');
      }

      await Share.shareXFiles(
        [XFile(filePath)],
        subject: invoice.description ?? 'Invoice',
        text: invoice.clientName,
      );

      _downloadState.value = LoadingState.loaded;
      ToastMessageHelper.show('Invoice ready to save or share');
    } catch (e) {
      _downloadState.value = LoadingState.error;
      ToastMessageHelper.show('Could not download invoice');
      if (kDebugMode) debugPrint('downloadPdf error: $e');
    }
  }

  Future<String> _downloadToLocalFile(String url) async {
    final directory = await getTemporaryDirectory();
    final fileName = 'invoice_${invoice.id ?? DateTime.now().millisecondsSinceEpoch}.pdf';
    final savePath = '${directory.path}/$fileName';
    final file = File(savePath);

    if (file.existsSync() && await file.length() > 0) {
      return savePath;
    }

    await Dio().download(
      url,
      savePath,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: true,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (!file.existsSync()) {
      throw Exception('Failed to download invoice PDF');
    }

    return savePath;
  }
}

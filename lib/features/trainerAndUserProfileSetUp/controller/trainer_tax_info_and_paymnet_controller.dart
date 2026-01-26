import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/select_payment_mathod_widget.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/upload_tax_doc_widget.dart';

class TrainerTaxInfoAndPaymnetController extends GetxController {
  final currentIndex = 0.obs;
  final List<Widget> pageList = [
    UploadTaxDocWidget(),
    SelectPaymentMathodWidget(),
  ];

  void tapNext() {
    if (currentIndex.value < 1) {
      currentIndex.value++;
      log("Index ${currentIndex.value}");
    } else {
      log("Go to next page");
    }
  }

  void tapBack() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      log("Index ${currentIndex.value}");
    } else {
      log("No page found!");
    }
  }

  final filePath = "".obs;

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.first;

        debugPrint("File name: ${file.name}");
        debugPrint("File path: ${file.path}");
        debugPrint("File size: ${file.size}");

        filePath.value = file.path ?? "";
      } else {
        debugPrint("User cancelled file picking");
      }
    } catch (e) {
      debugPrint("File pick error: $e");
    }
  }
}

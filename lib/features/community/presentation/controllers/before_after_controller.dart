import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:image_picker/image_picker.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

class BeforeAfterController extends GetxController {
  static BeforeAfterController get to => Get.find();

  final _picker = ImagePicker();

  final Rx<File?> beforeFile = Rx<File?>(null);
  final Rx<File?> afterFile  = Rx<File?>(null);
  final caption        = ''.obs;
  final isSubmitting   = false.obs;
  final submitMessage  = Rx<String?>(null);
  final isSuccess      = false.obs;

  Future<void> pickBefore() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) beforeFile.value = File(img.path);
  }

  Future<void> pickAfter() async {
    final img = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null) afterFile.value = File(img.path);
  }

  void clearResult() {
    submitMessage.value = null;
    isSuccess.value = false;
  }

  Future<void> submit() async {
    if (beforeFile.value == null || afterFile.value == null) {
      submitMessage.value = 'Please select both a before and after photo.';
      isSuccess.value = false;
      return;
    }

    isSubmitting.value = true;
    submitMessage.value = null;
    isSuccess.value = false;

    try {
      final token = CacheService().get<String>(AppConstants.accessToken) ?? '';

      final formData = FormData.fromMap({
        'beforeImage': await MultipartFile.fromFile(
          beforeFile.value!.path,
          filename: 'before.jpg',
        ),
        'afterImage': await MultipartFile.fromFile(
          afterFile.value!.path,
          filename: 'after.jpg',
        ),
        if (caption.value.trim().isNotEmpty) 'caption': caption.value.trim(),
      });

      final dio = Dio();
      await dio.post(
        '${ApiConstants.baseUrl}/api/v1/user-posts',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      isSuccess.value = true;
      submitMessage.value =
          'Your progress is live! 🎉 The community can see your transformation.';
      beforeFile.value = null;
      afterFile.value  = null;
      caption.value    = '';
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Upload failed. Please try again.';
      submitMessage.value = msg.toString();
      isSuccess.value = false;
    } catch (_) {
      submitMessage.value = 'Something went wrong. Please try again.';
      isSuccess.value = false;
    } finally {
      isSubmitting.value = false;
    }
  }
}

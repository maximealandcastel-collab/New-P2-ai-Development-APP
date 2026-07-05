import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class ImageCropConfig {
  const ImageCropConfig({
    required this.cropWidth,
    required this.cropHeight,
    this.cropStyle = CropStyle.rectangle,
  });

  final double cropWidth;
  final double cropHeight;
  final CropStyle cropStyle;

  double get aspectRatio => cropWidth / cropHeight;
}

class ImageCropHelper {
  ImageCropHelper._();

  static const ImageCropConfig profilePicture = ImageCropConfig(
    cropWidth: 1,
    cropHeight: 1,
    cropStyle: CropStyle.circle,
  );

  static ImageCropConfig coverPhoto({
    required double width,
    required double height,
  }) {
    return ImageCropConfig(
      cropWidth: width,
      cropHeight: height,
    );
  }

  static Future<File?> cropImage({
    required String imagePath,
    required ImageCropConfig config,
  }) async {
    if (config.cropWidth <= 0 || config.cropHeight <= 0) {
      return null;
    }

    final cropped = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(
        ratioX: config.cropWidth,
        ratioY: config.cropHeight,
      ),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: AppColors.textPrimary,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppColors.primary,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
          hideBottomControls: false,
          cropStyle: config.cropStyle,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
          cropStyle: config.cropStyle,
        ),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }
}

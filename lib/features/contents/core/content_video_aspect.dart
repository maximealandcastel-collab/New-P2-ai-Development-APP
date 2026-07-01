class ContentVideoAspect {
  ContentVideoAspect._();

  static const double defaultAspectRatio = 16 / 9;

  static double aspectRatio({int? width, int? height}) {
    if (width != null && height != null && width > 0 && height > 0) {
      return width / height;
    }
    return defaultAspectRatio;
  }

  static double displayHeight({
    required double availableWidth,
    int? videoWidth,
    int? videoHeight,
  }) {
    return availableWidth / aspectRatio(width: videoWidth, height: videoHeight);
  }
}

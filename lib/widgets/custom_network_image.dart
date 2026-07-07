import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:shimmer/shimmer.dart';

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final File? imageFile;
  final Widget? fallbackAsset;
  final double? height;
  final double? width;
  final Border? border;
  final double? borderRadius;
  final BoxShape boxShape;
  final Color? backgroundColor;
  final Widget? child;
  final ColorFilter? colorFilter;
  final List<BoxShadow>? boxShadow;
  final bool elevation;
  final BoxFit? fit;

  const CustomNetworkImage({
    super.key,
    this.child,
    this.colorFilter,
    this.imageUrl,
    this.imageFile,
    this.fallbackAsset,
    this.backgroundColor,
    this.height,
    this.width,
    this.border,
    this.borderRadius,
    this.boxShape = BoxShape.rectangle,
    this.boxShadow,
    this.elevation = false,
    this.fit,
  });

  @override
  Widget build(BuildContext context) {
    if (imageFile != null) {
      return _buildContainer(
        null,
        fileChild: Image.file(imageFile!, fit: fit ?? BoxFit.cover),
      );
    }

    if ((imageUrl ?? '').trim().isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _resolveImageUrl(imageUrl!),
        imageBuilder: (context, imageProvider) =>
            _buildContainer(imageProvider),
        placeholder: (context, url) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: _buildContainer(null, shimmer: true),
        ),
        errorWidget: (context, url, error) {
          debugPrint('❌ Image load error: $error');
          return _buildFallback();
        },
      );
    }

    return _buildFallback();
  }

  String _resolveImageUrl(String url) {
    final value = url.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${ApiConstants.baseUrl}$value';
  }

  Widget _buildContainer(
      ImageProvider? imageProvider, {
        bool shimmer = false,
        Widget? fileChild,
      }) {
    return Container(
      height: height,
      width: width,
      decoration: _buildDecoration(
        imageProvider: imageProvider,
        shimmer: shimmer,
      ),
      child: fileChild != null
          ? ClipRRect(
        borderRadius: boxShape == BoxShape.circle
            ? BorderRadius.circular(9999)
            : borderRadius != null
            ? BorderRadius.circular(borderRadius!)
            : BorderRadius.zero,
        child: fileChild,
      )
          : child,
    );
  }

  BoxDecoration _buildDecoration({
    ImageProvider? imageProvider,
    bool shimmer = false,
  }) {
    return BoxDecoration(
      color: shimmer
          ? Colors.grey.withValues(alpha: 0.4)
          : (backgroundColor ?? Colors.grey.shade300),
      boxShadow:
      boxShadow ??
          (elevation
              ? [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              spreadRadius: 6,
            ),
          ]
              : null),
      border: border,
      borderRadius: boxShape == BoxShape.circle
          ? null
          : borderRadius != null
          ? BorderRadius.circular(borderRadius!)
          : null,
      shape: boxShape,
      image: imageProvider != null
          ? DecorationImage(
        image: imageProvider,
        fit: fit ?? BoxFit.cover,
        colorFilter: colorFilter,
      )
          : null,
    );
  }

  Widget _buildFallback() {
    return Container(
      height: height,
      width: width,
      decoration: _buildDecoration(imageProvider: null, shimmer: false),
      child:
      fallbackAsset ??
          Icon(
            Icons.person,
            color: Colors.grey.shade500,
            size: _fallbackIconSize(),
          ),
    );
  }

  double _fallbackIconSize() {
    for (final dimension in [height, width]) {
      if (dimension != null && dimension.isFinite && dimension > 0) {
        return dimension.clamp(16, 96);
      }
    }
    return 40;
  }
}

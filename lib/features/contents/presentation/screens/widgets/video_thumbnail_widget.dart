import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/core/content_media_resolver.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoThumbnailWidget extends StatefulWidget {
  const VideoThumbnailWidget({
    super.key,
    required this.videoUrl,
    required this.width,
    required this.height,
    this.borderRadius = 0,
  });

  final String videoUrl;
  final double width;
  final double height;
  final double borderRadius;

  @override
  State<VideoThumbnailWidget> createState() => _VideoThumbnailWidgetState();
}

class _VideoThumbnailWidgetState extends State<VideoThumbnailWidget> {
  Uint8List? _thumbnailBytes;
  bool _isLoading = true;
  String? _resolvedVideoUrl;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  @override
  void didUpdateWidget(VideoThumbnailWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _generateThumbnail();
    }
  }

  Future<void> _generateThumbnail() async {
    final resolvedUrl = ContentMediaResolver.resolveUrl(widget.videoUrl);
    _resolvedVideoUrl = resolvedUrl;

    if (resolvedUrl.isEmpty) {
      if (mounted) {
        setState(() {
          _thumbnailBytes = null;
          _isLoading = false;
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _thumbnailBytes = null;
        _isLoading = true;
      });
    }

    try {
      final bytes = await _createThumbnailBytes(resolvedUrl);
      if (!mounted || _resolvedVideoUrl != resolvedUrl) return;

      setState(() {
        _thumbnailBytes = bytes;
        _isLoading = false;
      });
    } catch (error) {
      if (kDebugMode) {
        debugPrint(
          'VideoThumbnailWidget: failed for "$resolvedUrl" → $error',
        );
      }
      if (mounted && _resolvedVideoUrl == resolvedUrl) {
        setState(() {
          _thumbnailBytes = null;
          _isLoading = false;
        });
      }
    }
  }

  Future<Uint8List?> _createThumbnailBytes(String resolvedUrl) async {
    final maxHeight = (widget.height * 2).toInt().clamp(120, 512);
    final options = (
      imageFormat: ImageFormat.JPEG,
      maxHeight: maxHeight,
      quality: 75,
      timeMs: 1000,
    );

    if (resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://')) {
      final networkBytes = await VideoThumbnail.thumbnailData(
        video: resolvedUrl,
        imageFormat: options.imageFormat,
        maxHeight: options.maxHeight,
        quality: options.quality,
        timeMs: options.timeMs,
      );
      if (networkBytes != null && networkBytes.isNotEmpty) {
        return networkBytes;
      }
    }

    final sourcePath = await _resolveVideoSource(resolvedUrl);
    if (sourcePath == null) return null;

    return VideoThumbnail.thumbnailData(
      video: sourcePath,
      imageFormat: options.imageFormat,
      maxHeight: options.maxHeight,
      quality: options.quality,
      timeMs: options.timeMs,
    );
  }

  Future<String?> _resolveVideoSource(String resolvedUrl) async {
    if (resolvedUrl.startsWith('file://')) {
      return resolvedUrl.replaceFirst('file://', '');
    }

    if (!resolvedUrl.startsWith('http://') &&
        !resolvedUrl.startsWith('https://')) {
      final file = File(resolvedUrl);
      return file.existsSync() ? resolvedUrl : null;
    }

    return _downloadVideoToCache(resolvedUrl);
  }

  Future<String?> _downloadVideoToCache(String url) async {
    try {
      final cacheFile = File(
        '${Directory.systemTemp.path}/video_thumb_${url.hashCode.abs()}.mp4',
      );

      if (await cacheFile.exists() && await cacheFile.length() > 0) {
        return cacheFile.path;
      }

      await Dio().download(url, cacheFile.path);
      if (await cacheFile.exists() && await cacheFile.length() > 0) {
        return cacheFile.path;
      }
    } catch (error) {
      if (kDebugMode) {
        debugPrint('VideoThumbnailWidget: download failed for "$url" → $error');
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: _isLoading
            ? _buildShimmer()
            : _thumbnailBytes != null
                ? Image.memory(
                    _thumbnailBytes!,
                    width: widget.width,
                    height: widget.height,
                    fit: BoxFit.cover,
                  )
                : _buildFallback(),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: widget.width,
        height: widget.height,
        color: Colors.white,
      ),
    );
  }

  Widget _buildFallback() {
    return Container(
      color: AppColors.backgroundLight,
      child: Icon(
        Icons.play_circle_outline,
        color: AppColors.textSecondary,
        size: 28.r,
      ),
    );
  }
}

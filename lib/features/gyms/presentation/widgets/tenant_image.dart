import 'package:flutter/material.dart';

class TenantImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final double? width, height;
  const TenantImage(
    this.source, {
    super.key,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });
  @override
  Widget build(BuildContext context) {
    Widget fallback(BuildContext c, Object e, StackTrace? s) => SizedBox(
      width: width,
      height: height,
      child: const Center(
        child: Icon(Icons.fitness_center, color: Colors.grey),
      ),
    );
    if (source.startsWith('https://'))
      return Image.network(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: fallback,
      );
    if (source.startsWith('assets/'))
      return Image.asset(
        source,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: fallback,
      );
    return fallback(context, '', null);
  }
}

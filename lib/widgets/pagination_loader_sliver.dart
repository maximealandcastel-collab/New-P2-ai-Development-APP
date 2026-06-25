import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/widgets/custom_loader.dart';

class PaginationLoaderSliver extends StatelessWidget {
  const PaginationLoaderSliver({super.key, required this.controller});

  final PaginatedLoaderUi controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.showPaginationLoader) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: const Center(child: CustomLoader()),
        ),
      );
    });
  }
}

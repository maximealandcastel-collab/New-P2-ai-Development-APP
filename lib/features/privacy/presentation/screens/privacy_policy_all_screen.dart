import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/privacy/presentation/controllers/privacy_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PrivacyPolicyAllScreen extends StatefulWidget {
  const PrivacyPolicyAllScreen({super.key});

  @override
  State<PrivacyPolicyAllScreen> createState() => _PrivacyPolicyAllScreenState();
}

class _PrivacyPolicyAllScreenState extends State<PrivacyPolicyAllScreen> {
  late final String title;
  late final String key;
  final controller = PrivacyController.to;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    title = args?['title'] ?? 'Terms and Conditions';
    key = args?['key'] ?? 'terms';
    controller.setActiveKey(key);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: title),
      body: Obx(() {
        switch (controller.loadingState) {
          case LoadingState.initial:
          case LoadingState.loading:
            return const Center(child: CustomLoader());

          case LoadingState.offline:
          case LoadingState.error:
            return EmptyDataWidget(
              message: 'Failed to load data. Please try again.',
              onRefresh: () async => await controller.refresh(),
            );

          case LoadingState.loaded:
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: _PrivacyContent(description: controller.description),
            );
        }
      }),
    );
  }
}

class _PrivacyContent extends StatelessWidget {
  const _PrivacyContent({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    if (description.trim().isEmpty) {
      return const EmptyDataWidget(message: 'No content available.');
    }

    return CustomText(
      text: description,
      textAlign: TextAlign.start,
      fontSize: 14.sp,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      textHeight: 1.6,
    );
  }
}

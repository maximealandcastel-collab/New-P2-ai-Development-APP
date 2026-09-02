import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../custom_assets/assets.gen.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../common/notification/presentation/screen/notification_screen.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleWidget: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: CustomText(
            text: 'Clients',
            fontSize: 17.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: IconButton(
              onPressed: () => Get.to(() => NotificationsScreen()),
              icon: Assets.icons.notification.svg(height: 42.r, width: 42.r),
            ),
          ),
        ],
      ),
      body: const Center(
        child: _EmptyClientsView(),
      ),
    );
  }
}

class _EmptyClientsView extends StatelessWidget {
  const _EmptyClientsView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: CustomContainer(
        width: double.infinity,
        radiusAll: 16.r,
        paddingAll: 24.r,
        color: Colors.transparent,
        bordersColor: Colors.black.withOpacity(0.12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.group_outlined, size: 36.r, color: Colors.black38),
            SizedBox(height: 14.h),
            CustomText(
              text: 'No clients yet',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
            SizedBox(height: 6.h),
            CustomText(
              text: 'Clients will appear here when they connect with you.',
              fontSize: 12.sp,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }
}

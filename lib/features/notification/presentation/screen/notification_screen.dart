import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/notification/data/models/notification_model.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/widgets/notification_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(
        title: 'Notifications',
      ),
      bodyList: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
          sliver: SliverList.separated(
            itemCount: NotificationModel.demoNotifications.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              return NotificationCardWidget(
                notification: NotificationModel.demoNotifications[index],
              );
            },
          ),
        ),
        SizedBox(height: 120.h).asSliver,
      ],
    );
  }
}

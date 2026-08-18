import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data based on image_033a9f.png
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Sam Alex',
        'action': 'commented on',
        'target': '5 days of losing body weight',
        'date': '8/12/25',
        'preview': 'A awesome tips',
        'image': 'https://picsum.photos/200/200?random=10',
      },
      {
        'title': 'Liza Martine',
        'action': 'Messaged you',
        'target': '',
        'date': '8/12/25',
        'preview': 'I am getting pain on my knees, what should i do?',
        'image': null,
      },
      {
        'title': '40',
        'action': 'new view on',
        'target': '5 days of losing body weight',
        'date': '8/12/25',
        'preview': 'I am getting pain on my knees, what should i do?',
        'image': 'https://picsum.photos/200/200?random=11',
      },
      {
        'title': '25',
        'action': 'new like on',
        'target': '5 days of losing body weight',
        'date': '8/12/25',
        'preview': null,
        'image': 'https://picsum.photos/200/200?random=12',
      },
    ];

    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Notifications',
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.settings, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(16.r),
        itemCount: notifications.length,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          return _buildNotificationCard(notifications[index]);
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> data) {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontFamily: 'Poppins', // Or your global font
                    ),
                    children: [
                      TextSpan(
                        text: '${data['title']} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '${data['action']} ',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      if (data['target'].isNotEmpty)
                        TextSpan(
                          text: '${data['target']} ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      TextSpan(
                        text: '• ${data['date']}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (data['preview'] != null) ...[
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      // Vertical line indicator
                      Container(
                        width: 2.w,
                        height: 20.h,
                        color: Colors.black12,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: CustomText(
                          text: data['preview'],
                          fontSize: 13.sp,
                          color: Colors.grey,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
          if (data['image'] != null) ...[
            SizedBox(width: 12.w),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.network(
                data['image'],
                width: 50.w,
                height: 50.w,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
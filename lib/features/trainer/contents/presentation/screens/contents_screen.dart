import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../custom_assets/assets.gen.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_image_avatar.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../common/notification/presentation/screen/notification_screen.dart';
import '../../../../profile/profile_screen.dart';
import 'content_details_screen.dart';

class ContentsScreen extends StatefulWidget {
  const ContentsScreen({super.key});

  @override
  State<ContentsScreen> createState() => _ContentsScreenState();
}

class _ContentsScreenState extends State<ContentsScreen> {
  // Mock data for the content list
  final List<Map<String, dynamic>> contentList = [
    {
      'title': 'Ultimate Cardio Blast: Feel the Burn!',
      'time': 'uploaded 25 min ago',
      'views': '1.5k',
      'likes': '485',
      'comments': '128',
      'image': 'https://picsum.photos/200/120?random=1',
    },
    {
      'title': 'Strength and Stretch: Full-Body Routine!',
      'time': 'uploaded 4 hour ago',
      'views': '1.5k',
      'likes': '485',
      'comments': '128',
      'image': 'https://picsum.photos/200/120?random=2',
    },
    {
      'title': 'Dynamic Dance Workout: Get Moving!',
      'time': 'uploaded 14 hour ago',
      'views': '1.5k',
      'likes': '485',
      'comments': '128',
      'image': 'https://picsum.photos/200/120?random=3',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleWidget: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomImageAvatar(
                image: 'https://picsum.photos/300',
                radius: 20.r,
                showBorder: true,
              ),
              title: Row(
                children: [
                  CustomText(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                    text: 'Hi Maxime!!',
                  ),
                  SizedBox(width: 6.w),
                  _buildOnlineBadge(),
                ],
              ),
              subtitle: CustomText(
                textAlign: TextAlign.start,
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                text: 'Let’s Manage your users',
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(() => NotificationsScreen());
                  },
                  icon: Assets.icons.notification.svg(
                    height: 42.r,
                    width: 42.r,
                  ),
                ),
                Positioned(
                  right: 10.w,
                  top: 12.h,
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: CustomText(
                      text: '5',
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            _buildOverviewSection(),
            SizedBox(height: 16.h),
            _buildAiInsightSection(),
            SizedBox(height: 24.h),
            CustomText(
              text: "All Contents",
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
            SizedBox(height: 12.h),
            _buildContentList(),
            SizedBox(height: 100.h), // Bottom padding for navigation bar
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection() {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: "Overview",
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
              Row(
                children: [
                  _buildIconAction(Icons.calendar_view_day),
                  SizedBox(width: 8.w),
                  _buildIconAction(Icons.calendar_today_outlined),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(
                text: "1.2k",
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 6.h, left: 8.w),
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward, size: 14.sp, color: Colors.orange),
                    CustomText(
                      text: "5.3%",
                      color: Colors.orange,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          CustomText(
            text: "Total views this week",
            color: Colors.grey,
            fontSize: 12.sp,
          ),
          SizedBox(height: 24.h),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final List<Map<String, dynamic>> chartData = [
      {'day': 'Sun', 'value': 0.4},
      {'day': 'Mon', 'value': 0.2},
      {'day': 'Mon', 'value': 0.9, 'selected': true},
      {'day': 'Wed', 'value': 0.5},
      {'day': 'Thu', 'value': 0.3},
      {'day': 'Tue', 'value': 0.6},
      {'day': 'Sun', 'value': 0.7},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: chartData.map((data) {
        return Column(
          children: [
            if (data['selected'] == true)
              CustomContainer(
                paddingHorizontal: 6.w,
                paddingVertical: 2.h,
                radiusAll: 4.r,
                color: Colors.black.withOpacity(0.05),
                child: CustomText(
                  text: "1.2k Views",
                  fontSize: 10.sp,
                  color: Colors.grey,
                ),
              ),
            SizedBox(height: 4.h),
            CustomContainer(
              height: 100.h * data['value'],
              width: 35.w,
              radiusAll: 8.r,
              color: data['selected'] == true
                  ? Colors.orange
                  : Colors.black.withOpacity(0.1),
            ),
            SizedBox(height: 8.h),
            CustomText(text: data['day'], fontSize: 12.sp, color: Colors.grey),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildAiInsightSection() {
    return CustomContainer(
      width: double.infinity,
      paddingAll: 16.r,
      radiusAll: 16.r,
      linearColors: [const Color(0xFFE8F5E9), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: Colors.black),
              CustomText(
                text: ' AI Insight',
                fontWeight: FontWeight.w700,
                fontSize: 15.sp,
              ),
            ],
          ),
          SizedBox(height: 12.h),
          CustomText(
            text:
                "you haven't posted for a while consider updating what's new going on to clients",
            fontSize: 14.sp,
            textAlign: TextAlign.start,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  Widget _buildContentList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: contentList.length,
      separatorBuilder: (context, index) => SizedBox(height: 16.h),
      itemBuilder: (context, index) {
        final item = contentList[index];
        return GestureDetector(
          onTap: () => Get.to(() => ContentDetailsScreen(content: item)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Stack(
                alignment: Alignment.center,

                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12.r),

                    child: Image.network(
                      item['image'],
                      width: 100.w,
                      height: 75.h,
                      fit: BoxFit.cover,
                    ),
                  ),

                  CircleAvatar(
                    radius: 12.r,

                    backgroundColor: Colors.white.withOpacity(0.8),

                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.black,
                      size: 16,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    CustomText(
                      text: item['title'],
                      fontWeight: FontWeight.bold,
                      fontSize: 14.sp,
                      textAlign: TextAlign.start,
                    ),

                    SizedBox(height: 4.h),

                    CustomText(
                      text: item['time'],
                      color: Colors.grey,
                      fontSize: 11.sp,
                    ),

                    SizedBox(height: 8.h),

                    Row(
                      children: [
                        _buildStatItem(Icons.bar_chart, item['views']),

                        SizedBox(width: 12.w),

                        _buildStatItem(
                          Icons.thumb_up_alt_outlined,
                          item['likes'],
                        ),

                        SizedBox(width: 12.w),

                        _buildStatItem(
                          Icons.chat_bubble_outline,
                          item['comments'],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        SizedBox(width: 4.w),
        CustomText(text: value, color: Colors.grey, fontSize: 11.sp),
      ],
    );
  }

  Widget _buildIconAction(IconData icon) {
    return CustomContainer(
      paddingAll: 6.r,
      radiusAll: 8.r,
      color: Colors.black.withOpacity(0.8),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  // --- Reused Helper Methods from ClientsScreen ---
  Widget _buildOnlineBadge() {
    return CustomContainer(
      paddingHorizontal: 8.w,
      radiusAll: 100.r,
      bordersColor: Colors.grey.withOpacity(0.2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: Colors.green, size: 10.r),
          CustomText(text: 'Online', fontSize: 12.sp, left: 4.w),
        ],
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return Padding(
      padding: EdgeInsets.only(right: 16.w),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Icon(Icons.notifications_none_outlined, size: 28),
          Positioned(
            right: 2,
            top: 14,
            child: Container(
              padding: EdgeInsets.all(3.r),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: CustomText(
                text: '5',
                color: Colors.white,
                fontSize: 8.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

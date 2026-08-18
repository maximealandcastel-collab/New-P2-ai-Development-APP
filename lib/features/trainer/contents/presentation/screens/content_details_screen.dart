import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_image_avatar.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';

class ContentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> content;

  const ContentDetailsScreen({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      // No AppBar here as the video takes the top area
      body: Column(
        children: [
          // Video Player Section
          Stack(
            children: [
              Container(
                height: 250.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  image: (content['image'] as String?)?.isNotEmpty == true
                      ? DecorationImage(
                          image: NetworkImage(content['image'] as String),
                          fit: BoxFit.cover,
                          onError: (_, __) {},
                        )
                      : null,
                ),
              ),
              // Back Button overlay
              Positioned(
                top: 40.h,
                left: 16.w,
                child: GestureDetector(
                  onTap: () => Get.back(),
                  child: const CircleAvatar(
                    backgroundColor: Colors.black26,
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              // Video Controls Overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildVideoControls(),
              ),
            ],
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    text: (content['title'] as String?)?.isNotEmpty == true
                        ? content['title'] as String
                        : 'Untitled',
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    textAlign: TextAlign.start,
                  ),
                  SizedBox(height: 4.h),
                  CustomText(
                    text: "${content['views'] ?? 0} views  •  2 days ago",
                    color: Colors.grey,
                    fontSize: 12.sp,
                  ),
                  SizedBox(height: 16.h),

                  // Action Row: Like, Dislike, Share
                  Row(
                    children: [
                      _buildActionButton(Icons.thumb_up_outlined, content['likes']),
                      SizedBox(width: 8.w),
                      _buildActionButton(Icons.thumb_down_outlined, "2"),
                      const Spacer(),
                      _buildActionButton(Icons.share_outlined, "Share", isFilled: true),
                    ],
                  ),

                  SizedBox(height: 24.h),
                  const Divider(color: Colors.black12),
                  SizedBox(height: 8.h),

                  // Comments Section
                  Row(
                    children: [
                      CustomText(text: "Comments", fontWeight: FontWeight.bold, fontSize: 16.sp),
                      SizedBox(width: 8.w),
                      CustomText(text: "40", color: Colors.grey, fontSize: 14.sp),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  _buildCommentInput(),
                  SizedBox(height: 20.h),
                  _buildCommentItem("Jive Johnny", "Nice vibe!", "219", "5 hours ago"),
                  _buildCommentItem("Rockabilly Lou", "Super chill!", "847", "22 hr ago"),
                  _buildCommentItem("Swingin' Sam", "That's awesome!", "532", "3 days ago"),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoControls() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: Colors.black26,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: "00:24", color: Colors.white, fontSize: 10.sp),
              CustomText(text: "06:40", color: Colors.white, fontSize: 10.sp),
            ],
          ),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 6.r),
              activeTrackColor: Colors.orange,
              inactiveTrackColor: Colors.white30,
              thumbColor: Colors.white,
            ),
            child: Slider(value: 0.3, onChanged: (v) {}),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {bool isFilled = false}) {
    return CustomContainer(
      paddingHorizontal: 16.w,
      paddingVertical: 8.h,
      radiusAll: 24.r,
      color: isFilled ? Colors.black.withOpacity(0.05) : Colors.white,
      bordersColor: isFilled ? null : Colors.black12,
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black),
          SizedBox(width: 6.w),
          CustomText(text: label, fontSize: 13.sp, fontWeight: FontWeight.w600),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return CustomContainer(
      width: double.infinity,
      // Increased vertical padding to 18.h to make the box "bigger"
      paddingHorizontal: 12.w,
      paddingVertical: 18.h,
      radiusAll: 12.r,
      color: Colors.black.withOpacity(0.03),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [

          Expanded(
            child: CustomText(
              text: "Add a comment...",
              color: Colors.grey,
              fontSize: 14.sp,
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentItem(String name, String comment, String likes, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageAvatar(image: 'https://picsum.photos/100', radius: 18.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CustomText(text: name, fontWeight: FontWeight.bold, fontSize: 14.sp),
                    SizedBox(width: 8.w),
                    CustomText(text: "• $time", color: Colors.grey, fontSize: 11.sp),
                  ],
                ),
                SizedBox(height: 4.h),
                CustomText(text: comment, fontSize: 14.sp, textAlign: TextAlign.start),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined, size: 14, color: Colors.grey),
                    SizedBox(width: 4.w),
                    CustomText(text: likes, color: Colors.grey, fontSize: 12.sp),
                    SizedBox(width: 16.w),
                    Icon(Icons.thumb_down_outlined, size: 14, color: Colors.grey),
                    SizedBox(width: 16.w),
                    const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                    SizedBox(width: 4.w),
                    CustomText(text: "1 Reply", color: Colors.grey, fontSize: 11.sp),
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.more_vert, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}
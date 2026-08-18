

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

import '../../../assignedPlan/presentation/screen/assigned_plan_screen.dart';
import 'chat_screen.dart';

class ClientDetailsScreen extends StatelessWidget {
  final Map<String, String> client;

  const ClientDetailsScreen({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Client details',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
        child: Column(
          children: [
            // Header: Avatar and Name
            Row(
              children: [
                CustomImageAvatar(
                  image: 'https://picsum.photos/300',
                  radius: 35.r,
                ),
                SizedBox(width: 16.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      text: client['name'] ?? 'Ethan Carter',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    CustomText(
                      text: client['subtitle'] ?? 'Last Session 1 days ago',
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20.h),

            // Action Button: Only Message
            // Action Button: Only Message
            CustomButton(
              onPressed: () {
                // Navigating to Chat Screen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      clientName: client['name'] ?? 'Ethan Carter',
                    ),
                  ),
                );
              },
              label: 'Message',
              prefixIcon: const Icon(Icons.chat_bubble, color: Colors.white),
              backgroundColor: Colors.orange,
              width: double.infinity,
            ),

            SizedBox(height: 24.h),

            // Next Upcoming Session
            _buildNextSession(),
            SizedBox(height: 16.h),

            // AI Insight Section
            _buildAiInsightCard(),
            SizedBox(height: 16.h),

            // Daily To-Do Section
            _buildDailyToDo(),
            SizedBox(height: 16.h),

            // Assigned Exercise Plan
            _buildExercisePlan(),
            SizedBox(height: 16.h),

            // Water Intake
            _buildWaterIntake(),
            SizedBox(height: 16.h),

            // History Section
            _buildHistorySection(),
          ],
        ),
      ),
    );
  }

  // ---------------------- Reused Widgets Below ----------------------

  Widget _buildNextSession() {
    return CustomContainer(
      width: double.infinity,
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(text: "Next upcoming session", fontWeight: FontWeight.w600, fontSize: 16.sp),
          SizedBox(height: 12.h),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: CustomText(text: "Rehab", fontWeight: FontWeight.bold, textAlign: TextAlign.start),
            subtitle: CustomText(text: "Rehab session  •  10:00 AM", color: Colors.grey, fontSize: 12.sp, textAlign: TextAlign.start),
            trailing: CustomContainer(
              paddingAll: 8.r,
              color: Colors.black.withOpacity(0.05),
              radiusAll: 8.r,
              child: const Icon(Icons.calendar_today, size: 18),
            ),
          ),
          SizedBox(height: 12.h),
          CustomButton(
            onPressed: () {},
            label: "View details",
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            bordersColor: Colors.black12,
            height: 44.h,
          )
        ],
      ),
    );
  }

  Widget _buildAiInsightCard() {
    return CustomContainer(
      radiusAll: 16.r,
      paddingAll: 16.r,
      linearColors: [const Color(0xFFE8F5E9), Colors.white],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 18, color: Colors.black),
              CustomText(text: ' AI Insight', fontWeight: FontWeight.w700, fontSize: 15.sp),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 16),
              CustomText(text: ' Pain level increased after last session', fontSize: 13.sp, fontWeight: FontWeight.w600),
            ],
          ),
          SizedBox(height: 8.h),
          CustomContainer(
            paddingAll: 12.r,
            radiusAll: 12.r,
            color: Colors.black.withOpacity(0.05),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(text: "recommendation", fontSize: 10.sp, color: Colors.grey),
                SizedBox(height: 4.h),
                CustomText(
                  text: 'Consider reducing squat weight by 10% and adding 5 minutes of focused hip mobility warm-ups.',
                  fontSize: 13.sp,
                  textAlign: TextAlign.start,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: CustomButton(onPressed: () {}, label: 'Review', height: 40.h, backgroundColor: Colors.black12, foregroundColor: Colors.black)),
              SizedBox(width: 8.w),
              Expanded(child: CustomButton(onPressed: () {}, label: 'Apply suggestion', height: 40.h, backgroundColor: Colors.white, foregroundColor: Colors.black, bordersColor: Colors.black12)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildDailyToDo() {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: "Daily to do (5/24)", fontWeight: FontWeight.w600),
              CustomText(text: "Edit", color: Colors.grey),
            ],
          ),
          SizedBox(height: 16.h),
          _buildTaskProgress("Daily pushup", 0.75, "15/20"),
          SizedBox(height: 12.h),
          _buildTaskProgress("Run 1 km", 0.15, "0.15km/1km"),
          SizedBox(height: 12.h),
          CustomButton(onPressed: () {}, label: "View all", backgroundColor: Colors.white, foregroundColor: Colors.black, bordersColor: Colors.black12, height: 40.h),
        ],
      ),
    );
  }

  Widget _buildTaskProgress(String title, double progress, String trailing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(text: title, fontSize: 14.sp, fontWeight: FontWeight.w500),
            CustomText(text: trailing, fontSize: 12.sp, color: Colors.grey),
          ],
        ),
        SizedBox(height: 6.h),
        LinearProgressIndicator(value: progress, backgroundColor: Colors.black12, color: Colors.orange, minHeight: 6.h),
      ],
    );
  }

  Widget _buildExercisePlan() {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: "Assigned exercise plan (5/24)", fontWeight: FontWeight.w600),
              // Optional: You can also make "Edit" clickable
              GestureDetector(
                onTap: () => Get.to(() => const AssignedPlanScreen()),
                child: CustomText(text: "Edit", color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Wrap the card with GestureDetector for navigation
          GestureDetector(
            onTap: () {
              debugPrint("Navigating to Assigned Plan Details");
              Get.to(() => const AssignedPlanScreen());
            },
            child: CustomContainer(
              color: Colors.black.withOpacity(0.03),
              paddingAll: 8.r,
              radiusAll: 12.r,
              child: ListTile(
                // contentPadding: EdgeInsets.zero, // Add this if you want to remove default ListTile padding
                leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                        'https://picsum.photos/100',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover
                    )
                ),
                title: CustomText(
                    text: "20 upper body exercise",
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    textAlign: TextAlign.start
                ),
                subtitle: CustomText(
                    text: "Trainer: Maxime Castel\n20 minutes • 8 Exercise step",
                    fontSize: 11.sp,
                    textAlign: TextAlign.start
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildWaterIntake() {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "Water intake", fontWeight: FontWeight.w600),
              SizedBox(height: 20.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(width: 80.r, height: 80.r, child: CircularProgressIndicator(value: 0.8, strokeWidth: 8, color: Colors.blue, backgroundColor: Colors.blue.withOpacity(0.1))),
                  CustomText(text: "80%", fontWeight: FontWeight.bold, fontSize: 18.sp),
                ],
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CustomText(text: "1850 ml", fontWeight: FontWeight.bold),
              CustomText(text: "Consumed", fontSize: 12.sp, color: Colors.grey),
              SizedBox(height: 12.h),
              CustomText(text: "2500 ml", fontWeight: FontWeight.bold),
              CustomText(text: "Targeted calories", fontSize: 12.sp, color: Colors.grey),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildHistorySection() {
    return CustomContainer(
      paddingAll: 16.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: "History", fontWeight: FontWeight.w600),
              CustomText(text: "View all", color: Colors.grey),
            ],
          ),
          SizedBox(height: 12.h),
          _buildHistoryItem("Meditation", "Nov 25, 2025 • 10:00 AM", "Completed", Colors.green),
          _buildHistoryItem("Running", "Nov 4, 2025 • 08:30 AM", "Missed", Colors.red),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(String title, String date, String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: CustomText(text: title, fontWeight: FontWeight.bold, textAlign: TextAlign.start),
      subtitle: CustomText(text: date, color: Colors.grey, fontSize: 12.sp, textAlign: TextAlign.start),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status == "Completed" ? Icons.check_circle : Icons.cancel, color: color, size: 14),
            SizedBox(width: 4.w),
            CustomText(text: status, color: color, fontSize: 11.sp, fontWeight: FontWeight.w600),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';


class AssignedPlanScreen extends StatefulWidget {
  const AssignedPlanScreen({super.key});

  @override
  State<AssignedPlanScreen> createState() => _AssignedPlanScreenState();
}

class _AssignedPlanScreenState extends State<AssignedPlanScreen> {
  int selectedTab = 0; // 0: Exercise, 1: Water Intake

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(title: 'Assigned plan',),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // --- PILL TAB SELECTOR ---
            CustomContainer(
              paddingAll: 4.r,
              radiusAll: 30.r,
              color: Colors.white,
              child: Row(
                children: [
                  _buildPillTab("Exercise", 0),
                  _buildPillTab("Water intake", 1),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            selectedTab == 0 ? _buildExerciseContent() : _buildWaterIntakeContent(),
            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab(String label, int index) {
    bool isSelected = selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),
        child: CustomContainer(
          paddingVertical: 12.h,
          radiusAll: 25.r,
          color: isSelected ? Colors.black : Colors.transparent,
          alignment: Alignment.center,
          child: CustomText(
            text: label,
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }


  // --- EXERCISE TAB CONTENT ---
  Widget _buildExerciseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomContainer(
          paddingAll: 16.r,
          radiusAll: 20.r,
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "Weekly Scheduled to do", fontWeight: FontWeight.bold, fontSize: 16.sp),
              SizedBox(height: 16.h),
              _buildExerciseCalendar(), // Matches image_03be07.png
              SizedBox(height: 24.h),
              _buildProgressItem("Daily pushup", 15, 20),
              _buildProgressItem("Run 1 km", 0.15, 1, unit: "km"),
              _buildProgressItem("Sleep for 8 hour", 0.15, 1, unit: "km"),
              SizedBox(height: 12.h),
              _buildViewAllButton(),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        CustomText(text: "Assigned workout plan", fontWeight: FontWeight.bold, fontSize: 16.sp),
        SizedBox(height: 12.h),
        _buildWorkoutCard(),
      ],
    );
  }

  Widget _buildExerciseCalendar() {
    final days = [
      {"day": "Mon", "icon": Icons.person},
      {"day": "Tue", "icon": Icons.directions_run},
      {"day": "Wed", "icon": Icons.filter_vintage}, // Yoga-like icon
      {"day": "Thu", "icon": Icons.person},
      {"day": "Fri", "icon": Icons.weekend},
      {"day": "Sat", "icon": Icons.directions_run},
      {"day": "Sun", "icon": Icons.person},
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((data) {
        bool isSelected = data['day'] == "Wed";
        return Column(
          children: [
            CustomText(text: data['day'] as String, fontSize: 11.sp, color: Colors.grey),
            SizedBox(height: 6.h),
            CustomContainer(
              width: 40.w,
              radiusAll: 10.r,
              color: isSelected ? Colors.orange : Colors.black.withOpacity(0.03),
              paddingAll: 4.r,
              child: Column(
                children: [
                  if (isSelected) SizedBox(height: 4.h),
                  CustomContainer(
                    paddingAll: 6.r,
                    radiusAll: 8.r,
                    color: isSelected ? Colors.black : Colors.transparent,
                    child: Icon(data['icon'] as IconData,
                        size: 18.sp,
                        color: isSelected ? Colors.white : Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }).toList(),
    );
  }



  // --- WATER INTAKE TAB CONTENT ---
// --- WATER INTAKE TAB CONTENT ---
  Widget _buildWaterIntakeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
            text: "Daily meal progress",
            fontWeight: FontWeight.bold,
            fontSize: 16.sp
        ),
        SizedBox(height: 16.h),

        // Date selector row with circular selection
        _buildWaterDateRow(),
        SizedBox(height: 24.h),

        // Water Intake Progress Card
        CustomContainer(
          paddingAll: 20.r,
          radiusAll: 24.r,
          color: Colors.white,
          child: Row(
            children: [
              _buildCircularProgress(80), // 80% as shown in image
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildWaterStat("1850", "ml", "Consumed"),
                  SizedBox(height: 16.h),
                  _buildWaterStat("2500", "ml", "Targeted calories"),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 20.h),

        // Today's Record List
        CustomContainer(
          paddingAll: 20.r,
          radiusAll: 24.r,
          color: Colors.white,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                      text: "Today record",
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp
                  ),
                  CustomText(
                      text: "1850 ml",
                      color: Colors.grey,
                      fontSize: 14.sp
                  ),
                ],
              ),
              const Divider(height: 32, color: Color(0xFFF1F1F1)),
              _buildWaterRecord("250 ml", "2:15 pm"),
              _buildWaterRecord("150 ml", "9:45 am"),
              _buildWaterRecord("200 ml", "3:30 pm"),
              _buildWaterRecord("75 ml", "10:00 am"),
            ],
          ),
        )
      ],
    );
  }

  // --- Date Row with White Ring Selection ---
  Widget _buildWaterDateRow() {
    final days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        int date = 20 + i;
        bool isSelected = date == 22; // Wednesday the 22nd is selected in the image
        return Column(
          children: [
            CustomText(
                text: days[i],
                fontSize: 12.sp,
                color: Colors.grey
            ),
            SizedBox(height: 8.h),
            CustomContainer(
              width: 45.w,
              height: 65.h,
              radiusAll: 14.r,
              color: isSelected ? Colors.orange : Colors.white,
              bordersColor: isSelected ? null : Colors.black.withOpacity(0.05),
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(isSelected ? 6.r : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.white, width: 2)
                      : null,
                ),
                child: CustomText(
                  text: "$date",
                  color: isSelected ? Colors.white : Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  // --- Circular Progress Widget ---
  Widget _buildCircularProgress(int percent) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 110.w,
          height: 110.w,
          child: CircularProgressIndicator(
            value: percent / 100,
            strokeWidth: 12.w,
            strokeCap: StrokeCap.round,
            color: const Color(0xFF4A80F0), // Blue color from image
            backgroundColor: const Color(0xFFE8EFFF),
          ),
        ),
        CustomText(
            text: "$percent%",
            fontSize: 26.sp,
            fontWeight: FontWeight.bold
        ),
      ],
    );
  }

  // --- Stat Widget (Consumed/Targeted) ---
  Widget _buildWaterStat(String val, String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
                text: val,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold
            ),
            CustomText(
                text: " $unit",
                color: Colors.grey,
                fontSize: 14.sp,
                bottom: 2.h
            ),
          ],
        ),
        CustomText(
            text: label,
            fontSize: 12.sp,
            color: Colors.grey
        ),
      ],
    );
  }

  // --- List Item for Today's Record ---
  Widget _buildWaterRecord(String amount, String time) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        children: [
          CustomContainer(
            paddingAll: 10.r,
            radiusAll: 12.r,
            color: const Color(0xFFF8F8F8),
            bordersColor: Colors.black.withOpacity(0.05),
            child: Icon(
                Icons.water_drop_rounded,
                size: 20.sp,
                color: Colors.black
            ),
          ),
          SizedBox(width: 16.w),
          CustomText(
              text: amount,
              fontWeight: FontWeight.w600,
              fontSize: 15.sp
          ),
          const Spacer(),
          CustomText(
              text: time,
              color: Colors.grey,
              fontSize: 13.sp
          ),
        ],
      ),
    );
  }


  Widget _buildWaterCalendar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        int date = 20 + i;
        bool isSelected = date == 22;
        return Column(
          children: [
            CustomText(text: ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][i], fontSize: 11.sp, color: Colors.grey),
            SizedBox(height: 8.h),
            CustomContainer(
              width: 45.w,
              height: 60.h,
              radiusAll: 12.r,
              color: isSelected ? Colors.orange : Colors.white,
              bordersColor: isSelected ? null : Colors.black12,
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(isSelected ? 6.r : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
                ),
                child: CustomText(
                    text: "$date",
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildProgressItem(String title, double current, double total, {String unit = ""}) {
    double progress = current / total;
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(text: title, fontWeight: FontWeight.w600, fontSize: 14.sp),
              CustomText(text: "$current/$total$unit", color: Colors.grey, fontSize: 12.sp),
            ],
          ),
          SizedBox(height: 8.h),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.black12,
            color: Colors.orange,
            minHeight: 6.h,
            borderRadius: BorderRadius.circular(10.r),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard() {
    return CustomContainer(
      paddingAll: 12.r,
      radiusAll: 16.r,
      color: Colors.white,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Image.network('https://picsum.photos/100', width: 60.w, height: 60.w, fit: BoxFit.cover),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(text: "20 upper body exercise", fontWeight: FontWeight.bold),
              CustomText(text: "Trainer: Maxime Castel", color: Colors.grey, fontSize: 11.sp),
              CustomText(text: "20 minutes • 6 Exercise step", color: Colors.grey, fontSize: 11.sp),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildViewAllButton() {
    return CustomContainer(
      width: double.infinity,
      paddingVertical: 10.h,
      radiusAll: 12.r,
      color: Colors.black.withOpacity(0.03),
      alignment: Alignment.center,
      child: CustomText(text: "View all", fontWeight: FontWeight.w600),
    );
  }

}
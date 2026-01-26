import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:p2p_fitness/core/common/widgets/custom_text.dart';
import 'package:p2p_fitness/core/utils/constants/app_colors.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizer.dart';
import 'package:p2p_fitness/core/utils/constants/app_sizes.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/controller/trainer_and_user_set_up_porfile_controller.dart';

class DateOfBrithInputWidget extends StatelessWidget {
  const DateOfBrithInputWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TrainerAndUserSetUpPorfileController>();
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: CustomText(
              text: "What’s your date of birth ?",
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: getHeight(24)),
          SizedBox(
            height: getHeight(300),
            child: Row(
              children: [
                // Month Picker
                Expanded(
                  child: Obx(() {
                    return ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: controller.selectedMonth.value,
                      ),
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        controller.selectedMonth.value = index;
                      },
                      physics: FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: controller.months.length,
                        builder: (context, index) {
                          bool isSelected =
                              index == controller.selectedMonth.value;

                          return Center(
                            child: Text(
                              controller.months[index],
                              style: GoogleFonts.figtree(
                                fontSize: 28.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // Day Picker (Same style as Month)
                Expanded(
                  child: Obx(() {
                    return ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: controller.selectedDay.value,
                      ),
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        controller.selectedDay.value = index;
                      },
                      physics: FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: controller.days.length,
                        builder: (context, index) {
                          bool isSelected =
                              index == controller.selectedDay.value;

                          return Center(
                            child: Text(
                              controller.days[index].toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 28.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),

                // Year Picker (Same style as Month)
                Expanded(
                  child: Obx(() {
                    return ListWheelScrollView.useDelegate(
                      controller: FixedExtentScrollController(
                        initialItem: controller.selectedYear.value,
                      ),
                      itemExtent: 60,
                      onSelectedItemChanged: (index) {
                        controller.selectedYear.value = index;
                      },
                      physics: FixedExtentScrollPhysics(),
                      childDelegate: ListWheelChildBuilderDelegate(
                        childCount: controller.years.length,
                        builder: (context, index) {
                          bool isSelected =
                              index == controller.selectedYear.value;

                          return Center(
                            child: Text(
                              controller.years[index].toString(),
                              style: GoogleFonts.figtree(
                                fontSize: 28.sp,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? AppColors.textPrimary
                                    : AppColors.textSecondary.withValues(
                                        alpha: 0.3,
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

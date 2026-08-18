import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'mini_calendar.dart';

/// Schedule Timeline Section Component
/// Displays week strip or mini calendar for date selection
class ScheduleTimelineSection extends StatelessWidget {
  final List<String> dayLabels;
  final List<int> dayNumbers;
  final List<bool> hasDot;
  final int selectedIndex;
  final bool showCalendar;
  final int selectedCalDay;
  final ValueChanged<int> onDaySelected;
  final VoidCallback onToggleCalendar;
  final ValueChanged<int> onCalDaySelected;

  const ScheduleTimelineSection({
    super.key,
    required this.dayLabels,
    required this.dayNumbers,
    required this.hasDot,
    required this.selectedIndex,
    required this.showCalendar,
    required this.selectedCalDay,
    required this.onDaySelected,
    required this.onToggleCalendar,
    required this.onCalDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule timeline',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  TimelineIconBtn(
                    icon: Icons.view_week_outlined,
                    active: !showCalendar,
                    onTap: onToggleCalendar,
                  ),
                  SizedBox(width: 6.w),
                  TimelineIconBtn(
                    icon: Icons.calendar_month_outlined,
                    active: showCalendar,
                    onTap: onToggleCalendar,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 14.h),

          if (!showCalendar)
            // Week strip
            WeekStrip(
              dayLabels: dayLabels,
              dayNumbers: dayNumbers,
              hasDot: hasDot,
              selectedIndex: selectedIndex,
              onDaySelected: onDaySelected,
            )
          else
            // Mini calendar
            MiniCalendar(
              selectedDay: selectedCalDay,
              onDaySelected: onCalDaySelected,
            ),
        ],
      ),
    );
  }
}

/// Week Strip Component
/// Horizontal scrollable week days selector
class WeekStrip extends StatelessWidget {
  final List<String> dayLabels;
  final List<int> dayNumbers;
  final List<bool> hasDot;
  final int selectedIndex;
  final ValueChanged<int> onDaySelected;

  const WeekStrip({
    super.key,
    required this.dayLabels,
    required this.dayNumbers,
    required this.hasDot,
    required this.selectedIndex,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(dayLabels.length, (i) {
        final isSelected = i == selectedIndex;
        return DaySelectorItem(
          dayLabel: dayLabels[i],
          dayNumber: dayNumbers[i],
          hasDot: hasDot[i],
          isSelected: isSelected,
          onTap: () => onDaySelected(i),
        );
      }),
    );
  }
}

/// Day Selector Item Component
/// Individual day item in the week strip
class DaySelectorItem extends StatelessWidget {
  final String dayLabel;
  final int dayNumber;
  final bool hasDot;
  final bool isSelected;
  final VoidCallback onTap;

  const DaySelectorItem({
    super.key,
    required this.dayLabel,
    required this.dayNumber,
    required this.hasDot,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            dayLabel,
            style: TextStyle(
              fontSize: 11.sp,
              color: isSelected ? Colors.black : Colors.grey.shade400,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
          SizedBox(height: 6.h),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF7A00) : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$dayNumber',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ),
          SizedBox(height: 4.h),
          if (hasDot)
            Container(
              width: 4.w,
              height: 4.h,
              decoration: const BoxDecoration(
                color: Color(0xFFFF7A00),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }
}

/// Timeline Icon Button Component
class TimelineIconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const TimelineIconBtn({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30.w,
        height: 30.h,
        decoration: BoxDecoration(
          color: active ? Colors.black : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.sp,
          color: active ? Colors.white : Colors.black54,
        ),
      ),
    );
  }
}

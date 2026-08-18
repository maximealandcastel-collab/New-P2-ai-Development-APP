import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Mini Calendar Component
/// Displays a compact month calendar view
class MiniCalendar extends StatelessWidget {
  final int selectedDay;
  final ValueChanged<int> onDaySelected;
  final String monthLabel;
  final VoidCallback? onMonthPrevious;
  final VoidCallback? onMonthNext;

  const MiniCalendar({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.monthLabel = 'January 2025',
    this.onMonthPrevious,
    this.onMonthNext,
  });

  static const _weekDays = ['FR', 'SA', 'SU', 'MO', 'TU', 'WE', 'TH'];
  
  // January 2025 grid (starting from Fri Dec 27 to cover full weeks)
  static const _calRows = [
    [29, 30, 31, 1, 2, 3, 4],
    [5, 6, 7, 8, 9, 10, 11],
    [12, 13, 14, 15, 16, 17, 18],
    [19, 20, 21, 22, 23, 24, 25],
    [26, 27, 28, 29, 30, 1, 2],
  ];
  
  static const _prevMonthDays = {29, 30, 31};
  static const _nextMonthDays = {1, 2};

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Month header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: onMonthPrevious,
              child: Icon(Icons.chevron_left, size: 20.sp, color: Colors.black54),
            ),
            Text(
              monthLabel,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            GestureDetector(
              onTap: onMonthNext,
              child: Icon(Icons.chevron_right, size: 20.sp, color: Colors.black54),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Weekday headers
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _weekDays.map((d) => SizedBox(
            width: 32.w,
            child: Text(
              d,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade400,
                fontWeight: FontWeight.w600,
              ),
            ),
          )).toList(),
        ),
        SizedBox(height: 6.h),

        // Day rows
        ..._calRows.map((row) => Padding(
          padding: EdgeInsets.only(bottom: 4.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: row.asMap().entries.map((e) {
              final day = e.value;
              final col = e.key;
              final isOtherMonth = _calRows.indexOf(row) == 0 && _prevMonthDays.contains(day)
                  || _calRows.indexOf(row) == 4 && _nextMonthDays.contains(day);
              final isSelected = day == selectedDay && !isOtherMonth;

              return CalendarDayItem(
                day: day,
                isSelected: isSelected,
                isOtherMonth: isOtherMonth,
                onTap: isOtherMonth ? null : () => onDaySelected(day),
              );
            }).toList(),
          ),
        )),
      ],
    );
  }
}

/// Calendar Day Item Component
class CalendarDayItem extends StatelessWidget {
  final int day;
  final bool isSelected;
  final bool isOtherMonth;
  final VoidCallback? onTap;

  const CalendarDayItem({
    super.key,
    required this.day,
    required this.isSelected,
    required this.isOtherMonth,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF7A00) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          '$day',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected
                ? Colors.white
                : isOtherMonth
                    ? Colors.grey.shade300
                    : Colors.black87,
          ),
        ),
      ),
    );
  }
}

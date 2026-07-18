import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pler_to_pler_app/features/home/widgets/date_card.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';
import 'package:pler_to_pler_app/widgets/custom_text.dart';

class WeekDatePicker extends StatefulWidget {
  const WeekDatePicker({super.key, this.onDateSelected});

  final void Function(DateTime date)? onDateSelected;

  @override
  State<WeekDatePicker> createState() => _WeekDatePickerState();
}

class _WeekDatePickerState extends State<WeekDatePicker> {
  late List<DateTime> weekDates;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    selectedDate = today;
    final monday = today.subtract(Duration(days: today.weekday - 1));
    weekDates = List.generate(7, (index) => monday.add(Duration(days: index)));
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  bool _isSelected(DateTime date) {
    return date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;
  }

  bool _isUpcoming(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final cardDate = DateTime(date.year, date.month, date.day);
    return cardDate.isAfter(today);
  }

  void _onSelect(DateTime date) {
    setState(() => selectedDate = date);
    widget.onDateSelected?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    final workoutController = WorkoutController.to;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          top: 10.h,
          left: 16.r,
          bottom: 8.h,
          text: 'Daily workout progress',
          fontSize: 18.sp,
          fontWeight: FontWeight.w600,
        ),
        CustomContainer(
          height: 84.h,
          paddingVertical: 4.h,
          child: Obx(() {
            // Explicitly access a reactive getter on the RxList to register the dependency with Obx
            workoutController.monthlyProgression.isEmpty;
            final progressionList = workoutController.monthlyProgression;

            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final date = weekDates[index];
                final isDisabled = _isUpcoming(date);
                
                double progress = 0.0;
                if (!isDisabled) {
                  final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                  for (final item in progressionList) {
                    if (item.date == formattedDate) {
                      progress = item.completionPercentage / 100.0;
                      break;
                    }
                  }
                }

                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16.w : 0,
                    right: index == weekDates.length - 1 ? 16.w : 0,
                  ),
                  child: DateCard(
                    date: date,
                    isSelected: _isSelected(date),
                    isToday: _isToday(date),
                    onTap: () => _onSelect(date),
                    progress: progress,
                    isDisabled: isDisabled,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

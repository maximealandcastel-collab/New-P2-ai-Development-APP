import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class DatePage extends StatefulWidget {
  const DatePage({super.key});

  @override
  State<DatePage> createState() => _DatePageState();
}

class _DatePageState extends State<DatePage> {
  DateTime selectedDate = DateTime(1999, 1, 1);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your date of birth ?',
        fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 24.h),

        // Date Picker Container with border
        SizedBox(
          height: 196.h,
          child: CupertinoTheme(
            data: CupertinoThemeData(
              textTheme: CupertinoTextThemeData(
                dateTimePickerTextStyle: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: CupertinoColors.black,
                ),
              ),
            ),
            child: CupertinoDatePicker(
              itemExtent: 42.0,
              onDateTimeChanged: (DateTime newDate) {
                setState(() {
                  selectedDate = newDate;
                });
              },
              initialDateTime: selectedDate,
              mode: CupertinoDatePickerMode.date,
              minimumYear: 1900,
              maximumYear: DateTime.now().year,
              backgroundColor: Color(0xffF0F0F0),
            ),
          ),
        ),


        // Display selected date (optional)
        // Text(
        //   '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
        //   style: TextStyle(
        //     fontSize: 16.sp,
        //     color: CupertinoColors.systemGrey,
        //   ),
        // ),
      ],
    );
  }
}
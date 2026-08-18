import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class GenderPage extends StatefulWidget {
  const GenderPage({super.key});

  @override
  State<GenderPage> createState() => _GenderPageState();
}

class _GenderPageState extends State<GenderPage> {
  String? selectedGender;

  final List<String> genderOptions = [
    'Male',
    'Female',
    'Not prefer to say',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomText(
          text: 'What\'s your gender ?',
        fontSize: 24.sp,
          fontWeight: FontWeight.w600,
        ),
        SizedBox(height: 16.h),
        ...genderOptions.map((gender) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: _buildGenderOption(gender),
        )),
      ],
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = selectedGender == gender;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGender = gender;
        });
      },
      child: CustomContainer(
        paddingHorizontal: 16.w,
        paddingVertical: 16.h,
          color: Colors.white,
          radiusAll: 16.r,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomText(
              text: gender,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
            CustomContainer(
              width: 24.w,
              height: 24.h,
                shape: BoxShape.circle,
                bordersColor: isSelected ? Colors.black : Colors.grey.shade400,
                borderWidth: isSelected ? 2 : 1,
                color: isSelected ? Colors.black : Colors.transparent,
              child: isSelected
                  ? Icon(
                Icons.circle,
                size: 12.sp,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
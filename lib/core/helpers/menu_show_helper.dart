import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

class MenuShowHelper {
  static final List<String> heightOptions = List.generate(100, (index) {
    final feet = (index ~/ 12) + 4;
    final inches = index % 12;

    final totalInches = (feet * 12) + inches;
    final cm = (totalInches * 2.54).round();

    return "$feet'$inches\" ($cm cm)";
  });

  static final List<String> weightOptions = List.generate(66, (index) {
    return "${35 + index} kg";
  });

  static const List<String> fitnessLevelOptions = [
    'Beginner',
    'Intermediate',
    'Advanced',
    'Professional',
    'Athlete',
  ];


  static const List<String> goalOptions = [
    'Lose Weight',
    'Build Muscle',
    'Improve Endurance',
    'Increase Strength',
    'Improve Flexibility',
    'Enhance Athletic Performance',
    'Maintain Physique',
    'Stress Relief & Mental Health',
    'Improve Posture',
    'Rehabilitation & Recovery',
  ];

  static const List<String> _goalBackendOptions = [
    'weight_loss',
    'muscle_gain',
    'improve_endurance',
    'increase_strength',
    'improve_flexibility',
    'enhance_athletic_performance',
    'maintain_physique',
    'stress_relief',
    'improve_posture',
    'rehabilitation_recovery',
  ];

  static const List<String> equipmentDisplayOptions = [
    'Full Gym',
    'Home Gym',
    'Minimal Equipment',
    'Bodyweight Only',
  ];

  static const List<String> _equipmentBackendOptions = [
    'full_gym',
    'home_gym',
    'minimal_equipment',
    'bodyweight_only',
  ];

  static const List<String> motivationStyleDisplayOptions = [
    'Strict',
    'Chill',
    'Balanced',
  ];

  static const List<String> _motivationStyleBackendOptions = [
    'strict',
    'chill',
    'balanced',
  ];

  static String? goalBackendValue(String display) {
    final index = goalOptions.indexOf(display);
    if (index == -1) return null;
    return _goalBackendOptions[index];
  }

  static String? equipmentBackendValue(String display) {
    final index = equipmentDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return _equipmentBackendOptions[index];
  }

  static String? motivationStyleBackendValue(String display) {
    final index = motivationStyleDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return _motivationStyleBackendOptions[index];
  }

  static String fitnessLevelBackendValue(String display) =>
      display.trim().toLowerCase();

  static String genderBackendValue(String display) =>
      display.trim().toLowerCase();

  static String? goalDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = _goalBackendOptions.indexOf(backend);
    if (index != -1) return goalOptions[index];
    return backend;
  }

  static String? equipmentDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = _equipmentBackendOptions.indexOf(backend);
    if (index != -1) return equipmentDisplayOptions[index];
    return backend;
  }

  static String? motivationStyleDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = _motivationStyleBackendOptions.indexOf(backend);
    if (index != -1) return motivationStyleDisplayOptions[index];
    return backend;
  }

  static String fitnessLevelDisplayValue(String? value) {
    if (value == null || value.isEmpty) return '';
    for (final option in fitnessLevelOptions) {
      if (option.toLowerCase() == value.toLowerCase()) return option;
    }
    return value;
  }

  static String genderDisplayValue(String? value) {
    if (value == null || value.isEmpty) return '';
    final normalized = value.trim().toLowerCase();
    if (normalized == 'male') return 'Male';
    if (normalized == 'female') return 'Female';
    return value;
  }

  static String heightDisplayValue(int? cm) {
    if (cm == null) return '';
    for (final option in heightOptions) {
      final match = RegExp(r'\((\d+)\s*cm\)').firstMatch(option);
      if (match != null && int.parse(match.group(1)!) == cm) return option;
    }
    return '$cm cm';
  }

  static String weightDisplayValue(num? kg) {
    if (kg == null) return '';
    final display = kg == kg.roundToDouble() ? '${kg.round()}' : kg.toString();
    final option = '$display kg';
    return weightOptions.contains(option) ? option : option;
  }

  static String roleDisplayValue(String? role) {
    if (role == null || role.isEmpty) return '';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  static const List<String> coachingStyleOptions = ["strict", "chill", "balanced"];
  static const List<String> intensityMeasureOptions = ["RPE", "RIR", "%1RM"];

  static const List<String> specialityDisplayOptions = [
    'Maintain Physique',
    'Muscle Gain',
    'Weight Loss',
    'Nutrition',
    'Boxing',
  ];

  static const List<String> _specialityBackendOptions = [
    'maintain_physique',
    'muscle_gain',
    'weight_loss',
    'nutrition',
    'boxing',
  ];

  static String? specialityBackendValue(String display) {
    final index = specialityDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return _specialityBackendOptions[index];
  }

  static final List<String> genderOptions = ["Male", "Female"];

  static Future<String?> showCustomMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
  }) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset tapPosition = details.globalPosition;

    return showMenu<String>(
      context: context,
      color: Colors.white,
      constraints: BoxConstraints(
        maxHeight: 200.h,
        minWidth: 120.w,
        maxWidth: 180.w,
      ),
      position: RelativeRect.fromRect(
        Rect.fromPoints(tapPosition, tapPosition),
        Offset.zero & overlay.size,
      ),
      items: options.map((String option) {
        return PopupMenuItem<String>(
          height: 38.h,
          value: option,
          padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
          child: SizedBox(
            //height: 28.h,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option,
                style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary,fontFamily: FontFamily.figtree,fontWeight: FontWeight.w500),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class MenuShowHelper {
  MenuShowHelper._();

  static String? goalBackendValue(String display) {
    final index = HelperData.goalOptions.indexOf(display);
    if (index == -1) return null;
    return HelperData.goalBackendOptions[index];
  }

  static String? equipmentBackendValue(String display) {
    final index = HelperData.equipmentDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return HelperData.equipmentBackendOptions[index];
  }

  static String? motivationStyleBackendValue(String display) {
    final index = HelperData.motivationStyleDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return HelperData.motivationStyleBackendOptions[index];
  }

  static String fitnessLevelBackendValue(String display) =>
      display.trim().toLowerCase();

  static String genderBackendValue(String display) =>
      display.trim().toLowerCase();

  static String? goalDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = HelperData.goalBackendOptions.indexOf(backend);
    if (index != -1) return HelperData.goalOptions[index];
    return backend;
  }

  static String? equipmentDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = HelperData.equipmentBackendOptions.indexOf(backend);
    if (index != -1) return HelperData.equipmentDisplayOptions[index];
    return backend;
  }

  static String? motivationStyleDisplayValue(String? backend) {
    if (backend == null || backend.isEmpty) return null;
    final index = HelperData.motivationStyleBackendOptions.indexOf(backend);
    if (index != -1) return HelperData.motivationStyleDisplayOptions[index];
    return backend;
  }

  static String fitnessLevelDisplayValue(String? value) {
    if (value == null || value.isEmpty) return '';
    for (final option in HelperData.fitnessLevelOptions) {
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
    for (final option in HelperData.heightOptions) {
      final match = RegExp(r'\((\d+)\s*cm\)').firstMatch(option);
      if (match != null && int.parse(match.group(1)!) == cm) return option;
    }
    return '$cm cm';
  }

  static String weightDisplayValue(num? kg) {
    if (kg == null) return '';
    final display = kg == kg.roundToDouble() ? '${kg.round()}' : kg.toString();
    final option = '$display kg';
    return HelperData.weightOptions.contains(option) ? option : option;
  }

  static String roleDisplayValue(String? role) {
    if (role == null || role.isEmpty) return '';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  static String? specialityBackendValue(String display) {
    final index = HelperData.specialityDisplayOptions.indexOf(display);
    if (index == -1) return null;
    return HelperData.specialityBackendOptions[index];
  }

  static Future<String?> showCustomMenu({
    required BuildContext context,
    required TapDownDetails details,
    required List<String> options,
  }) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.textPrimary,
                  fontWeight: AppFontWeight.emphasis,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

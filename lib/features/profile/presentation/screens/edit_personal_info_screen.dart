import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/edit_personal_info_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_dropdown_field.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_fixed_account_card.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = EditPersonalInfoController.to;
    final user = ProfileController.to.userData;

    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Edit Personal Info'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileFixedAccountCard(
                email: user?.email ?? '',
                role: MenuShowHelper.roleDisplayValue(user?.role),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      labelText: 'First name',
                      hintText: 'Enter first name',
                      controller: controller.firstNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: CustomTextField(
                      labelText: 'Last name',
                      hintText: 'Enter last name',
                      controller: controller.lastNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              CustomTextField(
                labelText: 'Preferred name',
                hintText: 'Eg : john',
                controller: controller.preferredNameController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your preferred name';
                  }
                  return null;
                },
              ),
              ProfileDropdownField(
                labelText: 'Gender',
                hintText: 'Select gender',
                controller: controller.genderController,
                options: MenuShowHelper.genderOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              _DateOfBirthField(controller: controller),
              SizedBox(height: 16.h),
              Obx(
                () => CustomButton(
                  label: 'Update',
                  onPressed: controller.save,
                  isLoading: controller.saveState.isLoading,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({required this.controller});

  final EditPersonalInfoController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        DateTime tempDate = controller.selectedDateOfBirth;
        showModalBottomSheet(
          backgroundColor: Colors.white,
          elevation: 2,
          context: context,
          builder: (context) {
            return DialogShowHelper.showBottomSheet(
              context,
              title: 'Date of birth',
              content: SizedBox(
                height: 186.h,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    textTheme: CupertinoTextThemeData(
                      dateTimePickerTextStyle: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.black,
                      ),
                    ),
                  ),
                  child: CupertinoDatePicker(
                    itemExtent: 32.0,
                    onDateTimeChanged: (DateTime newDate) {
                      tempDate = newDate;
                    },
                    initialDateTime: controller.selectedDateOfBirth,
                    mode: CupertinoDatePickerMode.date,
                    minimumYear: 1900,
                    maximumYear: DateTime.now().year,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              onTapConfirm: () {
                controller.selectedDateOfBirth = tempDate;
                controller.dateOfBirthController.text =
                    TimeFormatHelper.formatDate(tempDate);
                Get.back(canPop: true);
              },
            );
          },
        );
      },
      child: AbsorbPointer(
        child: CustomTextField(
          suffixIcon: Padding(
            padding: EdgeInsets.all(12.r),
            child: Assets.icons.date.svg(),
          ),
          labelText: 'Date of birth',
          hintText: 'Select date of birth',
          controller: controller.dateOfBirthController,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please select your date of birth';
            }
            return null;
          },
        ),
      ),
    );
  }
}

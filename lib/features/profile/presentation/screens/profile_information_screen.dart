import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/dialog_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/menu_show_helper.dart';
import 'package:pler_to_pler_app/core/helpers/time_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_information_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_dropdown_field.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileInformationScreen extends StatelessWidget {
  const ProfileInformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileInformationController.to;

    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Profile Information'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionHeader(title: 'Personal details'),
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
                prefixIcon: Assets.icons.emailIcon.image(
                  height: 20.r,
                  width: 20.r,
                ),
                labelText: 'Email',
                hintText: 'Enter your email',
                controller: controller.emailController,
                isEmail: true,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
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
              ProfileDropdownField(
                labelText: 'Role',
                hintText: 'Role',
                controller: controller.roleController,
                options: const ['User', 'Trainer'],
                readOnly: true,
              ),
              _DateOfBirthField(controller: controller),

              _SectionHeader(title: 'Fitness profile'),
              ProfileDropdownField(
                labelText: 'Primary goal',
                hintText: 'Select primary goal',
                controller: controller.primaryGoalController,
                options: MenuShowHelper.goalOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your primary goal';
                  }
                  return null;
                },
              ),
              ProfileDropdownField(
                labelText: 'Height',
                hintText: 'Select your height',
                controller: controller.heightController,
                options: MenuShowHelper.heightOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your height';
                  }
                  return null;
                },
              ),
              ProfileDropdownField(
                labelText: 'Weight',
                hintText: 'Select your weight',
                controller: controller.weightController,
                options: MenuShowHelper.weightOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your weight';
                  }
                  return null;
                },
              ),
              ProfileDropdownField(
                labelText: 'Fitness level',
                hintText: 'Select fitness level',
                controller: controller.fitnessLevelController,
                options: MenuShowHelper.fitnessLevelOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your fitness level';
                  }
                  return null;
                },
              ),
              ProfileDropdownField(
                labelText: 'Available equipment',
                hintText: 'Select equipment',
                controller: controller.equipmentController,
                options: MenuShowHelper.equipmentDisplayOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your available equipment';
                  }
                  return null;
                },
              ),
              CustomTextField(
                labelText: 'Training days per week',
                hintText: 'Eg : 4',
                keyboardType: TextInputType.number,
                controller: controller.trainingDaysController,
                inputFormatter: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter training days per week';
                  }
                  final days = int.tryParse(value.trim());
                  if (days == null || days <= 0 || days > 7) {
                    return 'Please enter a valid number (1-7)';
                  }
                  return null;
                },
              ),
              DynamicFieldListWidget(
                title: 'Injuries',
                initialValues: controller.injuries,
                onChanged: controller.setInjuries,
              ),
              ProfileDropdownField(
                labelText: 'Motivation style',
                hintText: 'Select motivation style',
                controller: controller.motivationStyleController,
                options: MenuShowHelper.motivationStyleDisplayOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your motivation style';
                  }
                  return null;
                },
              ),

              _SectionHeader(title: 'Security'),
              CustomContainer(
                onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
                radiusAll: 16.r,
                color: Colors.white,
                paddingHorizontal: 16.w,
                paddingVertical: 14.h,
                marginBottom: 10.h,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Password',
                            fontSize: 12.sp,
                            color: Colors.grey,
                            bottom: 4.h,
                          ),
                          CustomText(
                            text: '••••••••',
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14.sp,
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),
              Obx(
                () => CustomButton(
                  label: 'Save changes',
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CustomText(
      text: title,
      fontWeight: FontWeight.w600,
      fontSize: 18.sp,
      top: 24.h,
      bottom: 8.h,
    );
  }
}

class _DateOfBirthField extends StatelessWidget {
  const _DateOfBirthField({required this.controller});

  final ProfileInformationController controller;

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

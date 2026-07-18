import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EditPersonalInfoScreen extends StatelessWidget {
  const EditPersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;

    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Edit Personal Info'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: controller.personalFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              MenuDropdownField(
                labelText: 'Gender',
                hintText: 'Select gender',
                controller: controller.genderController,
                options: HelperData.genderOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your gender';
                  }
                  return null;
                },
              ),
              DatePickerField(
                controller: controller.dateOfBirthController,
                initialDate: controller.selectedDateOfBirth,
                onDateChanged: (date) => controller.selectedDateOfBirth = date,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your date of birth';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Obx(
                () => CustomButton(
                  label: 'Update',
                  onPressed: () => controller.updateProfile(
                    updates: controller.personalInfoUpdates(),
                    formKey: controller.personalFormKey,
                  ),
                  isLoading: controller.updateLoadingState.isLoading,
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/helpers/helper_data.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/widgets/dynamic_field_list_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EditFitnessInfoScreen extends StatelessWidget {
  const EditFitnessInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ProfileController.to;

    return CustomScaffold(
      appBar: const CustomAppBar(title: 'Edit Fitness Info'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: controller.fitnessFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuDropdownField(
                labelText: 'Primary goal',
                hintText: 'Select primary goal',
                controller: controller.primaryGoalController,
                options: HelperData.goalOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your primary goal';
                  }
                  return null;
                },
              ),
              MenuDropdownField(
                labelText: 'Height',
                hintText: 'Select your height',
                controller: controller.heightController,
                options: HelperData.heightOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your height';
                  }
                  return null;
                },
              ),
              MenuDropdownField(
                labelText: 'Weight',
                hintText: 'Select your weight',
                controller: controller.weightController,
                options: HelperData.weightOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your weight';
                  }
                  return null;
                },
              ),
              MenuDropdownField(
                labelText: 'Fitness level',
                hintText: 'Select fitness level',
                controller: controller.fitnessLevelController,
                options: HelperData.fitnessLevelOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your fitness level';
                  }
                  return null;
                },
              ),
              MenuDropdownField(
                labelText: 'Available equipment',
                hintText: 'Select equipment',
                controller: controller.equipmentController,
                options: HelperData.equipmentDisplayOptions,
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
              MenuDropdownField(
                labelText: 'Motivation style',
                hintText: 'Select motivation style',
                controller: controller.motivationStyleController,
                options: HelperData.motivationStyleDisplayOptions,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select your motivation style';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),
              Obx(
                () => CustomButton(
                  label: 'Update',
                  onPressed: () => controller.updateProfile(
                    updates: controller.fitnessInfoUpdates(),
                    formKey: controller.fitnessFormKey,
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

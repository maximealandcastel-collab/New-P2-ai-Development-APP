import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/trainer/contentPost/presentation/screens/content_post_screen.dart';
import 'package:pler_to_pler_app/features/trainer/createExercisePlan/presentation/screen/create_exercise_plan_screen.dart';
import 'package:pler_to_pler_app/features/user/find_trainer/presentation/find_trainer_screen.dart';

class NavFabModel {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const NavFabModel({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static List<NavFabModel> get trainerFabItems => [
        NavFabModel(
          label: 'Content category',
          icon: Assets.icons.category.path,
          onTap: () => Get.toNamed(AppRoute.contentCategoryScreen),
        ),
        NavFabModel(
          label: 'Post content',
          icon: Assets.icons.post.path,
          onTap: () => Get.toNamed(AppRoute.createContentScreen),
        ),
        NavFabModel(
          label: 'Add exercise block',
          icon: Assets.icons.exercise.path,
          onTap: () => Get.to(() => const CreateExercisePlanScreen()),
        ),
      ];

  static List<NavFabModel> get userFabItems => [
        NavFabModel(
          label: 'Find Trainer',
          icon: Assets.icons.person.path,
          onTap: () => Get.to(() => const FindTrainerScreen()),
        ),
        NavFabModel(
          label: 'Add exercise plan',
          icon: Assets.icons.exercise.path,
          onTap: () => Get.to(() => const CreateExercisePlanScreen()),
        ),
      ];
}

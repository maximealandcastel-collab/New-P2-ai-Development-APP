import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/community/presentation/screens/post_photo_video_screen.dart';

class NavFabModel {
  final String icon;
  final String label;
  final VoidCallback onTap;

  const NavFabModel({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  // ── Trainer FAB — only shown when role=trainer AND not in viewAsUser mode ──
  static List<NavFabModel> get trainerFabItems => [
        NavFabModel(
          label: 'Content category',
          icon: Assets.icons.category.path,
          onTap: () => Get.toNamed(AppRoute.contentCategoryScreen),
        ),
        NavFabModel(
          label: 'Post Photo/Video',
          icon: Assets.icons.post.path,
          onTap: () => Get.toNamed(AppRoute.createContentScreen),
        ),
        NavFabModel(
          label: 'Add exercise block',
          icon: Assets.icons.exercise.path,
          onTap: () => Get.toNamed(AppRoute.exerciseBlockScreen),
        ),
      ];

  // ── User FAB — shown for subscribers, and for owner when in viewAsUser mode ──
  static List<NavFabModel> get userFabItems => [
        NavFabModel(
          label: 'Find My Trainer',
          icon: Assets.icons.person.path,
          onTap: () => Get.toNamed(AppRoute.findTrainerScreen),
        ),
        NavFabModel(
          label: 'Generate Workout',
          icon: Assets.icons.exercise.path,
          onTap: () => Get.toNamed(AppRoute.workoutScreen),
        ),
        NavFabModel(
          label: 'Post Photo/Video',
          icon: Assets.icons.post.path,
          onTap: () => Get.to(() => const PostPhotoVideoScreen()),
        ),
      ];
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/user/workout/presentation/controllers/workout_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class WorkoutTrainingPickPage extends StatefulWidget {
  const WorkoutTrainingPickPage({super.key});
  @override
  State<WorkoutTrainingPickPage> createState() => _WorkoutTrainingPickPageState();
}

class _WorkoutTrainingPickPageState extends State<WorkoutTrainingPickPage> {
  final TextEditingController _searchController = TextEditingController();

  static const _allOptions = [
    {'id': 'boxing_combat', 'title': 'Boxing &\nCombat', 'subtitle': 'Boxing, MMA, Kickboxing, Muay Thai'},
    {'id': 'calisthenics', 'title': 'Calisthenics', 'subtitle': 'Bodyweight, Street Workout'},
    {'id': 'weight_lifting', 'title': 'Weight\nLifting', 'subtitle': 'Strength, Hypertrophy, Powerlifting'},
    {'id': 'wrestling', 'title': 'Wrestling', 'subtitle': 'Technique, Conditioning, Takedowns'},
    {'id': 'hiit', 'title': 'HIIT', 'subtitle': 'High Intensity Interval Training'},
    {'id': 'yoga', 'title': 'Yoga', 'subtitle': 'Mind-Body, Balance, Recovery'},
    {'id': 'pilates', 'title': 'Pilates', 'subtitle': 'Core Strength, Stability'},
    {'id': 'mobility', 'title': 'Mobility', 'subtitle': 'Movement, Flexibility, Injury Prevention'},
    {'id': 'functional_training', 'title': 'Functional\nTraining', 'subtitle': 'Real-World Movement, Athletic Performance'},
    {'id': 'cardio', 'title': 'Cardio', 'subtitle': 'Endurance, Conditioning, Stamina'},
    {'id': 'sports_performance', 'title': 'Sports\nPerformance', 'subtitle': 'Speed, Agility, Explosiveness'},
    {'id': 'rehabilitation', 'title': 'Rehabilitation', 'subtitle': 'Injury Recovery, Physical Therapy'},
  ];

  // The bundled asset file names under assets/images/training_styles/ don't
  // all match the option ids above 1:1 (e.g. 'boxing_combat' -> 'boxing.png').
  static const _assetFileById = {
    'boxing_combat': 'boxing',
  };

  String _assetPathFor(String id) =>
      'assets/images/training_styles/${_assetFileById[id] ?? id}.png';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkoutController>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: 'What type of training\ndo you want to do?',
          fontSize: 24.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
          maxline: 2,
        ),
        SizedBox(height: 8.h),
        CustomText(
          text: 'Choose one or more styles. We\'ll customize your workouts, trainers, and content.',
          fontSize: 14.sp,
          color: AppColors.textSecondary,
          maxline: 3,
        ),
        SizedBox(height: 24.h),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _searchController,
                hintText: 'Search training styles...',
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
                onChanged: (val) => setState(() {}),
              ),
            ),
            SizedBox(width: 12.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE5E7EB)),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CustomText(text: 'All', fontSize: 14.sp, fontWeight: FontWeight.w600),
                  SizedBox(width: 4.w),
                  Icon(Icons.keyboard_arrow_down, size: 20.sp, color: AppColors.textPrimary),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 24.h),
        Builder(builder: (context) {
          final query = _searchController.text.toLowerCase();
          final items = _allOptions.where((opt) => opt['title']!.toLowerCase().contains(query) || opt['subtitle']!.toLowerCase().contains(query)).toList();

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1, // approximate square
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Obx(() {
                final isSelected = controller.selectedTrainingStyles.contains(item['id']);
                return GestureDetector(
                  onTap: () {
                    if (isSelected) {
                      controller.selectedTrainingStyles.remove(item['id']);
                    } else {
                      controller.selectedTrainingStyles.add(item['id']!);
                      controller.trainingPickSkipped.value = false;
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E), // fallback for missing asset
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: isSelected ? 2 : 1,
                      ),
                      image: DecorationImage(
                        image: AssetImage(_assetPathFor(item['id']!)),
                        fit: BoxFit.cover,
                        onError: (_, __) {},
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.35),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.all(12.w),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: item['title']!,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              maxline: 2,
                            ),
                            SizedBox(height: 4.h),
                            CustomText(
                              text: item['subtitle']!,
                              fontSize: 10.sp,
                              color: Colors.white70,
                              maxline: 2,
                            ),
                          ],
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 24.w,
                            height: 24.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
                              border: Border.all(
                                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white30,
                              ),
                            ),
                            child: isSelected
                                ? Icon(Icons.check, color: Colors.white, size: 16.sp)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          );
        }),
      ],
    );
  }
}

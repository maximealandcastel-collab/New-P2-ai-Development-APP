import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/request/data/models/trainer_request_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_fitness_profile_card.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_info_section_card.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_user_profile_rows.dart';

class RequestDetailsContent extends StatelessWidget {
  const RequestDetailsContent({super.key, required this.request});

  final TrainerRequestModel request;

  @override
  Widget build(BuildContext context) {
    final user = request.userId;
    final profileRows = RequestUserProfileRows.profileInformation(user);
    final fitnessLevel = RequestUserProfileRows.fitnessLevel(user);
    final bodyMetrics = RequestUserProfileRows.bodyMetrics(user);
    final trainingChips = RequestUserProfileRows.trainingPreferenceChips(user);
    final injuryChips = RequestUserProfileRows.injuryChips(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20.h),
        if (profileRows.isNotEmpty) ...[
          RequestInfoSectionCard(
            title: 'Profile Information',
            rows: profileRows,
          ),
        ],
        if (fitnessLevel != null ||
            bodyMetrics.isNotEmpty ||
            trainingChips.isNotEmpty ||
            injuryChips.isNotEmpty) ...[
          SizedBox(height: 12.h),
          RequestFitnessProfileCard(
            fitnessLevel: fitnessLevel,
            bodyMetrics: bodyMetrics,
            trainingChips: trainingChips,
            injuryChips: injuryChips,
          ),
        ],
        SizedBox(height: 20.h),
      ],
    );
  }
}

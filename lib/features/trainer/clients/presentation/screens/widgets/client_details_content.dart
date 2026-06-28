import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_fitness_profile_card.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_info_section_card.dart';
import 'package:pler_to_pler_app/features/trainer/request/presentation/screens/widgets/request_user_profile_rows.dart';
import 'package:pler_to_pler_app/features/trainer/widgets/user_profile_fields.dart';

class ClientDetailsContent extends StatelessWidget {
  const ClientDetailsContent({super.key, required this.invoice});

  final ClientInvoiceModel invoice;

  @override
  Widget build(BuildContext context) {
    final profile = UserProfileFields.fromClientUser(invoice.userId);
    final profileRows =
        RequestUserProfileRows.profileInformationFromFields(profile);
    final fitnessLevel =
        RequestUserProfileRows.fitnessLevelFromFields(profile);
    final bodyMetrics = RequestUserProfileRows.bodyMetricsFromFields(profile);
    final trainingChips =
        RequestUserProfileRows.trainingPreferenceChipsFromFields(profile);
    final injuryChips = RequestUserProfileRows.injuryChipsFromFields(profile);

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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/anam/presentation/arguments/anam_call_args.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class UserTrainerScreen extends StatelessWidget {
  const UserTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final user = ProfileController.to.userData;
      final trainer = user?.subscribedTrainer;

      return CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(),
          SizedBox(height: 16.h).asSliver,
          if (trainer != null)
            ClientCardWidget(
              onChatTap: () {
                Get.toNamed(
                  AppRoute.chatScreen,
                  arguments: ChatScreenArgs(
                    displayName: trainer.name ?? 'Trainer',
                    trainerId: trainer.sId,
                    isAnamEnabled: trainer.sId?.isNotEmpty ?? false,
                  ),
                );
              },
              name: StringFormat.valueOrNa(trainer.name),
              subtitle: user?.subscriptionPeriod ?? 'N/A',
            ).asSliverWithPadding(horizontal: 16.h)
          else
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyDataWidget(
                message: 'No subscribed trainer yet.',
              ),
            ),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      );
    });
  }
}

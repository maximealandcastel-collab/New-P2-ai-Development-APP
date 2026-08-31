import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/home/data/models/gym_model.dart';
import 'package:pler_to_pler_app/features/home/widgets/gym_card_widget.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class GymSection extends StatelessWidget {
  const GymSection({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      marginTop: 8.h,
      color: Colors.white,
      radiusAll: 16.r,
      paddingVertical: 14.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: 'Gyms',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: _openNearGymMap,
                  child: CustomText(
                    textAlign: TextAlign.start,
                    text: 'Near Gym',
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10.h),
          CustomContainer(
            height: 134.h,
            paddingVertical: 4.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GymModel.demoGyms.length,
              separatorBuilder: (_, _) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                final gym = GymModel.demoGyms[index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 16.w : 0,
                    right: index == GymModel.demoGyms.length - 1 ? 16.w : 0,
                  ),
                  child: GymCardWidget(
                    gym: gym,
                    onJoinPressed: () => _openGymMap(gym.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNearGymMap() => _openGymMap('gyms near me');

  Future<void> _openGymMap(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final googleMapsWebUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encodedQuery',
    );
    final googleMapsAppUrl = Uri.parse('comgooglemaps://?q=$encodedQuery');

    if (Platform.isIOS) {
      try {
        final opened = await launchUrl(
          googleMapsAppUrl,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return;
      } catch (_) {
        // Google Maps is optional. Fall through to the universal web URL.
      }
    }

    try {
      final opened = await launchUrl(
        googleMapsWebUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) ToastMessageHelper.show('Could not open map application.');
    } catch (e) {
      ToastMessageHelper.show('Could not open maps: $e');
    }
  }
}

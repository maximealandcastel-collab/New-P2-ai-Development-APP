import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/enterprise_gym_model.dart';
import '../widgets/gym_brand_logo.dart';

/// Confirms the exact facility before entering the existing authenticated
/// member flow. This screen never creates a membership by itself.
class GymJoinConfirmationScreen extends StatelessWidget {
  const GymJoinConfirmationScreen({super.key, required this.gym,
    required this.onContinue});

  final EnterpriseGymModel gym;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF8F8F9),
        appBar: AppBar(
          title: Text('Confirm your gym',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                const Spacer(),
                GymBrandLogo(gym: gym, size: 84.r, borderRadius: 20.r),
                SizedBox(height: 18.h),
                Text(gym.name, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600,
                        color: const Color(0xFF171820))),
                if (gym.address.isNotEmpty || gym.city.isNotEmpty) ...[
                  SizedBox(height: 7.h),
                  Text(gym.address.isNotEmpty ? gym.address : [gym.city, gym.state]
                      .where((part) => part.isNotEmpty).join(', '),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF747680))),
                ],
                SizedBox(height: 18.h),
                Text('Continue to sign in or create an account. Your gym access is verified by P2P.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp, height: 1.4,
                        color: const Color(0xFF747680))),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton(
                    onPressed: onContinue,
                    style: FilledButton.styleFrom(
                      backgroundColor: gym.entryColor,
                      foregroundColor: gym.entryTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                    ),
                    child: Text('Continue with ${gym.name}', maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                TextButton(onPressed: () => Navigator.pop(context),
                    child: const Text('Change location')),
              ],
            ),
          ),
        ),
      );
}

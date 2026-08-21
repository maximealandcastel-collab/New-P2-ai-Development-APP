import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';

class GymLoginPreviewScreen extends StatelessWidget {
  final EnterpriseGymModel gym;
  const GymLoginPreviewScreen({super.key, required this.gym});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: gym.brandColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18.sp),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00C853),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 5.w),
                        Text('Live Demo',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Gym logo ────────────────────────────────────────────────
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: gym.accentColor,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                gym.initials,
                style: TextStyle(
                  color: gym.textColor,
                  fontSize: gym.initials.length > 2 ? 20.sp : 26.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              gym.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Powered by P2P FitTech AI',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13.sp,
              ),
            ),

            SizedBox(height: 40.h),

            // ── Login card ──────────────────────────────────────────────
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Member Login',
                      style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87)),
                  SizedBox(height: 4.h),
                  Text('Access your ${gym.name} experience',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.black45)),
                  SizedBox(height: 20.h),

                  // Email field (demo)
                  _DemoField(
                      icon: Icons.email_outlined, hint: 'Email address'),
                  SizedBox(height: 12.h),
                  _DemoField(
                      icon: Icons.lock_outline_rounded,
                      hint: 'Password',
                      obscure: true),

                  SizedBox(height: 20.h),

                  // Sign in button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: gym.brandColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {},
                      child: Text('Sign In to ${gym.name}',
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w700)),
                    ),
                  ),

                  SizedBox(height: 16.h),
                  Center(
                    child: Text(
                      'New member? Join ${gym.name}',
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: gym.brandColor,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ── Footer ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.only(bottom: 24.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24.r,
                        height: 24.r,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text('P2',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.sp,
                                fontWeight: FontWeight.w900)),
                      ),
                      SizedBox(width: 8.w),
                      Text('P2P FitTech AI · IP Licensed',
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 11.sp)),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text('Branded demo for ${gym.name}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 10.sp)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DemoField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final bool obscure;
  const _DemoField(
      {required this.icon, required this.hint, this.obscure = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20.sp),
          SizedBox(width: 12.w),
          Text(hint,
              style: TextStyle(color: Colors.black38, fontSize: 14.sp)),
          const Spacer(),
          if (obscure)
            Icon(Icons.visibility_off_outlined,
                color: Colors.black26, size: 18.sp),
        ],
      ),
    );
  }
}

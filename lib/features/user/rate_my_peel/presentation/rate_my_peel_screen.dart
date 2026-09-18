import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RateMyPeelScreen extends StatelessWidget {
  const RateMyPeelScreen({super.key});


  static const _ink = Color(0xFF171717);
  static const _muted = Color(0xFF666666);
  static const _line = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          tooltip: 'Back',
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp, color: _ink),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _RateMyPeelHeader(),
              SizedBox(height: 22.h),
              Center(
                child: Text(
                  'RATE MY PEEL',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30.sp,
                    height: 1,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: _ink,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: BrandColors.of(context).primary, width: 1.2),
                    borderRadius: BorderRadius.circular(22.r),
                  ),
                  child: Text(
                    'COMING SOON',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                      color: BrandColors.of(context).primary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Rate My Peel is an AI-powered body analysis tool that helps '
                'you understand your estimated body-fat percentage with a '
                'simple photo upload.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: _muted,
                ),
              ),
              SizedBox(height: 30.h),
              Center(
                child: Text(
                  'WHAT IT WILL DO',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                    color: BrandColors.of(context).primary,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              const _FeatureRow(
                icon: Icons.photo_camera_outlined,
                title: 'Snap & Upload Photos',
                description:
                    'Take or upload clear photos of yourself from multiple angles.',
              ),
              const _FeatureRow(
                icon: Icons.psychology_outlined,
                title: 'AI-Powered Analysis',
                description:
                    'Our advanced AI analyzes your physique to estimate your body-fat percentage.',
              ),
              const _FeatureRow(
                icon: Icons.bar_chart_rounded,
                title: 'Track Your Progress',
                description:
                    'Compare results over time and see your progress with visual history.',
              ),
              const _FeatureRow(
                icon: Icons.track_changes_outlined,
                title: 'Smarter Fitness Decisions',
                description:
                    'Use your insights to set goals, optimize training, and improve results.',
                showDivider: false,
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 18.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _line),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: BrandColors.of(context).primary.withOpacity(0.45)),
                      ),
                      child: Icon(
                        Icons.calendar_month_outlined,
                        color: BrandColors.of(context).primary,
                        size: 21.sp,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Better insights. Better results.',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: _ink,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Rate My Peel is coming soon.',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: BrandColors.of(context).primary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Stay tuned — we’re building something legendary.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              height: 1.35,
                              fontWeight: FontWeight.w400,
                              color: _muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Body-fat results are educated estimates for fitness '
                'guidance, not medical measurements or diagnoses.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  height: 1.35,
                  fontWeight: FontWeight.w400,
                  color: _muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RateMyPeelHeader extends StatelessWidget {
  const _RateMyPeelHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 22.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: BrandColors.of(context).primary, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: BrandColors.of(context).primary.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              border: Border.all(color: BrandColors.of(context).primary),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: RichText(
              text: TextSpan(
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: 'split ',
                    style: TextStyle(color: BrandColors.of(context).primary),
                  ),
                  TextSpan(
                    text: 'bod',
                    style: TextStyle(color: RateMyPeelScreen._ink),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: 68.r,
            height: 68.r,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3EE),
              shape: BoxShape.circle,
              border: Border.all(
                color: BrandColors.of(context).primary.withOpacity(0.32),
              ),
            ),
            child: Icon(
              Icons.photo_camera_outlined,
              color: BrandColors.of(context).primary,
              size: 34.sp,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Your physique, understood.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w600,
              color: RateMyPeelScreen._ink,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Simple photos. Smarter fitness insights.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: RateMyPeelScreen._muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.description,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: RateMyPeelScreen._line))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F8F8),
              shape: BoxShape.circle,
              border: Border.all(
                color: BrandColors.of(context).primary.withOpacity(0.22),
              ),
            ),
            child: Icon(
              icon,
              color: BrandColors.of(context).primary,
              size: 23.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: RateMyPeelScreen._ink,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    height: 1.35,
                    fontWeight: FontWeight.w400,
                    color: RateMyPeelScreen._muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

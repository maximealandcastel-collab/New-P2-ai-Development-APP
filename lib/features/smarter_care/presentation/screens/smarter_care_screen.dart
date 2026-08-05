import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';

class SmarterCareScreen extends StatelessWidget {
  const SmarterCareScreen({super.key});

  // All 10 clinical preview images bundled as assets
  static const List<String> _clinicalPreviews = [
    'assets/images/clinical/clinical_01.jpeg',
    'assets/images/clinical/clinical_02.jpeg',
    'assets/images/clinical/clinical_03.jpeg',
    'assets/images/clinical/clinical_04.jpeg',
    'assets/images/clinical/clinical_05.jpeg',
    'assets/images/clinical/clinical_06.jpeg',
    'assets/images/clinical/clinical_07.jpeg',
    'assets/images/clinical/clinical_08.jpeg',
    'assets/images/clinical/clinical_09.jpeg',
    'assets/images/clinical/clinical_10.jpeg',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Orange gradient blob at the top ─────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280.h,
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 0.9,
                  colors: [
                    Color(0xFFFF8C00),
                    Color(0xFFFFA040),
                    Color(0xFFFFDAAA),
                    Colors.white,
                  ],
                  stops: [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // ── Main content ────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 160.h),

                  // ── Headline ─────────────────────────────────────
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 42.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                        letterSpacing: -1.0,
                      ),
                      children: const [
                        TextSpan(text: 'Smarter care'),
                        TextSpan(
                          text: '.',
                          style: TextStyle(color: AppColors.primary),
                        ),
                        TextSpan(text: '\neffortless\nworkflow'),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Subtitle ─────────────────────────────────────
                  Text(
                    'Get AI-guided plans, track progress, and stay\nconnected to experts all in one platform.',
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: 14.sp,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // ── Two choice cards ─────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _ChoiceCard(
                          title: 'Fitness',
                          subtitle: 'Personal workouts,\ntrainer sessions,\nplans & more',
                          onTap: () => Get.offAllNamed(AppRoute.loginScreen),
                        ),
                      ),
                      SizedBox(width: 14.w),
                      Expanded(
                        child: _ChoiceCard(
                          title: 'Clinical',
                          subtitle: 'Patient intake, scanning,\nAI rehab plans, clinician\ntools',
                          isComingSoon: true,
                          onTap: () => _showClinicalPreview(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClinicalPreview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ClinicalPreviewSheet(),
    );
  }
}

// ── Choice card ──────────────────────────────────────────────────────────────
class _ChoiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isComingSoon;

  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isComingSoon = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // P2P logo icon placeholder
            Container(
              width: 52.w,
              height: 52.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Center(
                child: Icon(
                  isComingSoon ? Icons.medical_services_outlined : Icons.fitness_center,
                  color: AppColors.primary,
                  size: 26.sp,
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: 11.sp,
                height: 1.4,
              ),
            ),
            if (isComingSoon) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Clinical preview bottom sheet ────────────────────────────────────────────
class _ClinicalPreviewSheet extends StatefulWidget {
  const _ClinicalPreviewSheet();

  @override
  State<_ClinicalPreviewSheet> createState() => _ClinicalPreviewSheetState();
}

class _ClinicalPreviewSheetState extends State<_ClinicalPreviewSheet> {
  int _currentPage = 0;
  final _controller = PageController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = SmarterCareScreen._clinicalPreviews;
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        children: [
          // ── Handle ──────────────────────────────────────────────
          SizedBox(height: 12.h),
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Header ──────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Clinical Platform Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.grey.shade400, size: 22.sp),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              'The P2P Clinical module is launching soon. Here\'s a sneak peek at what nurses and clinicians will experience.',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12.sp,
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // ── Image carousel ───────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (ctx, i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.asset(
                    images[i],
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.broken_image, color: Colors.grey.shade700, size: 48),
                    ),
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // ── Page dots ────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.symmetric(horizontal: 3.w),
                width: _currentPage == i ? 20.w : 7.w,
                height: 7.h,
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.primary : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(99.r),
                ),
              ),
            ),
          ),

          SizedBox(height: 10.h),

          // ── Nav arrows ───────────────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavBtn(
                  icon: Icons.arrow_back_ios_new,
                  enabled: _currentPage > 0,
                  onTap: () => _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
                Text(
                  '${_currentPage + 1} / ${images.length}',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13.sp),
                ),
                _NavBtn(
                  icon: Icons.arrow_forward_ios,
                  enabled: _currentPage < images.length - 1,
                  onTap: () => _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 28.h),

          // ── Get notified button ──────────────────────────────────
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Got It — Notify Me When Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 40.w,
        height: 40.h,
        decoration: BoxDecoration(
          color: enabled ? Colors.grey.shade800 : Colors.grey.shade900,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Icon(
          icon,
          color: enabled ? Colors.white : Colors.grey.shade700,
          size: 16.sp,
        ),
      ),
    );
  }
}

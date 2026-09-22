import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';

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
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4),
                  radius: 0.9,
                  colors: [
                    BrandColors.of(context).primary,
                    BrandColors.of(context).light,
                    BrandColors.of(context).light,
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
                  // Was w900 — the heaviest weight Flutter has, on the largest
                  // type in the app. This screen is the clearest example of the
                  // "heavier typography, lost the premium feel" the brief
                  // describes. The line breaks here are intentional (they set
                  // the poster-like shape); the ones in the body copy below
                  // were not.
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 34.sp,
                        fontWeight: AppFontWeight.display,
                        height: 1.05,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'Smarter care'),
                        TextSpan(
                          text: '.',
                          style: TextStyle(color: Theme.of(context).colorScheme.primary),
                        ),
                        TextSpan(text: '\neffortless\nworkflow'),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // ── Subtitle ─────────────────────────────────────
                  // The hard \n after "stay" is removed. It assumed a fixed
                  // width: on the client's own reference screenshot the first
                  // line had already wrapped before reaching it, so "stay" was
                  // left stranded alone on a line of its own. Letting it wrap
                  // naturally is correct at every width.
                  Text(
                    'Get AI-guided plans, track progress, and stay connected '
                    'to experts all in one platform.',
                    style: TextStyle(
                      color: const Color(0xFF888888),
                      fontSize: 14.sp,
                      fontWeight: AppFontWeight.body,
                      height: 1.5,
                    ),
                  ),

                  SizedBox(height: 36.h),

                  // ── Two choice cards ─────────────────────────────
                  // The cards size to their own content, and Clinical has more
                  // text plus the Coming Soon chip, so under the Row's default
                  // (center) the shorter Fitness card floated in the middle and
                  // the pair sat visibly misaligned — clear in the reference
                  // screenshot. stretch gives them a shared height.
                  //
                  // IntrinsicHeight is required, not decorative: this Row is a
                  // child of a Column, so its height constraint is unbounded,
                  // and stretch against an unbounded cross axis is a tight
                  // infinite constraint — it throws. IntrinsicHeight resolves
                  // the height to the taller card first. Cheap here: two
                  // shallow, non-scrolling children.
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _ChoiceCard(
                            title: 'Fitness',
                            subtitle: 'Personal workouts, trainer sessions, plans & more',
                            onTap: () => Get.offAllNamed(AppRoute.loginScreen),
                          ),
                        ),
                        SizedBox(width: 14.w),
                        Expanded(
                          child: _ChoiceCard(
                            title: 'Clinical',
                            subtitle: 'Patient intake, scanning, AI rehab plans, clinician tools',
                            isComingSoon: true,
                            onTap: () => _showClinicalPreview(context),
                          ),
                        ),
                      ],
                    ),
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
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // P2P logo
            SizedBox(
              width: 56.w,
              height: 56.w,
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16.sp,
                fontWeight: AppFontWeight.title,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                color: const Color(0xFF888888),
                fontSize: 11.sp,
                fontWeight: AppFontWeight.body,
                height: 1.4,
              ),
            ),
            // Pushes the chip to the bottom of the card. With the Row now
            // stretching both cards to a common height, the Fitness card has
            // spare vertical space; without this the Clinical chip would not
            // line up with anything and the pair would look unbalanced again.
            const Spacer(),
            if (isComingSoon) ...[
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  'Coming Soon',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10.sp,
                    fontWeight: AppFontWeight.label,
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
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 11.sp,
                      fontWeight: AppFontWeight.label,
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  'Clinical Platform Preview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: AppFontWeight.label,
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
                  color: _currentPage == i ? Theme.of(context).colorScheme.primary : Colors.grey.shade700,
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
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Text(
                  'Got It — Notify Me When Live',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: AppFontWeight.label,
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

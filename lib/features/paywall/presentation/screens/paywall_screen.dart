import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/tenant_image.dart';
import 'package:flutter/material.dart';
    import 'package:get/get.dart';
    import 'package:flutter_screenutil/flutter_screenutil.dart';
    import 'package:pler_to_pler_app/core/routes/app_routes.dart';
    import 'package:pler_to_pler_app/core/services/tenant_brand_service.dart';
    import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
    import 'package:pler_to_pler_app/features/paywall/controllers/paywall_controller.dart';
    import 'package:url_launcher/url_launcher.dart';
    import 'package:pler_to_pler_app/services/api_urls.dart';

    class PaywallScreen extends StatelessWidget {
    PaywallScreen({super.key});

    final controller = Get.find<PaywallController>();
    final RxInt selectedTier = 1.obs;

    static const _ink = Color(0xFF171310);
    static const _muted = Color(0xFF756B64);

    @override
    Widget build(BuildContext context) {
      controller.configureDestination(Get.arguments);
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _header(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(context),
                      SizedBox(height: 18.h),
                      _stats(context),
                      SizedBox(height: 22.h),
                      _billingToggle(context),
                      SizedBox(height: 19.h),
                      Obx(() {
                        final annual = controller.selectedPlan.value == 'annual';
                        return Column(
                          children: [
                            _tier(context, 0, 'Self-Guided', 'Build your own rhythm', '\$0 today', 'A flexible starting point with your AI plan and workout library.', Icons.fitness_center_rounded),
                            _tier(context, 1, 'Personal Trainer', 'Your plan, built around you', annual ? '${controller.annualPriceStr.value}/yr' : '${controller.monthlyPriceStr.value}/mo', '1-on-1 coaching, weekly check-ins, and a plan that adapts as you do.', Icons.person_rounded, badge: 'Most chosen', benefits: const ['Live coaching', 'Weekly plan', 'Progress tracking']),
                            _tier(context, 2, 'Elite Coaching', 'The complete transformation', annual ? '\$449.99/yr' : '\$49.99/mo', 'Everything in Personal Trainer plus dedicated nutrition coaching.', Icons.workspace_premium_rounded),
                          ],
                        );
                      }),
                      SizedBox(height: 3.h),
                      _cta(context),
                      SizedBox(height: 22.h),
                      _proofCard(context),
                      SizedBox(height: 18.h),
                      _accessCode(context),
                      SizedBox(height: 16.h),
                      _reassurance(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _header(BuildContext context) {
      final tenant = TenantBrandService.to;
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 4.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              button: true,
              label: 'Close paywall',
              child: GestureDetector(
                onTap: controller.closePaywall,
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFF0E6DF)),
                    boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.1), blurRadius: 12, offset: const Offset(0, 4))],
                  ),
                  child: Icon(Icons.arrow_back_rounded, color: _ink, size: 19.sp),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 28.h,
                  width: 28.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: BrandColors.of(context).primary.withOpacity(.3), width: 2),
                    boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.16), blurRadius: 10)],
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.12,
                      child: TenantImage(tenant.logoAssetPath ?? 'assets/images/app_logo.png'),
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tenant.displayName, style: TextStyle(color: tenant.isWhiteLabeled ? tenant.primaryColor : _ink, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: .5, height: 1)),
                    if (!tenant.isWhiteLabeled)
                      Text('TECH AI', style: TextStyle(color: BrandColors.of(context).dark, fontSize: 8.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2, height: 1.1)),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: controller.isPreSignup ? controller.openTrainerSignup : null,
              child: Text(controller.isPreSignup ? 'Trainer sign up' : 'Admin', style: TextStyle(color: controller.isPreSignup ? BrandColors.of(context).dark : _muted, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    Widget _hero(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, BrandColors.of(context).soft]),
          border: Border.all(color: BrandColors.of(context).border),
          boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.14), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(top: -70.h, right: -55.w, child: _flare(context, 175.w, BrandColors.of(context).primary.withOpacity(.2))),
            Positioned(bottom: -50.h, left: -55.w, child: _flare(context, 135.w, BrandColors.of(context).light.withOpacity(.16))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.84), borderRadius: BorderRadius.circular(20), border: Border.all(color: BrandColors.of(context).primary.withOpacity(.18))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome_rounded, color: BrandColors.of(context).dark, size: 14.sp), SizedBox(width: 5.w), Text('TRAIN SMARTER. GET RESULTS.', style: TextStyle(color: BrandColors.of(context).dark, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.1))]),
                ),
                SizedBox(height: 14.h),
                Text.rich(TextSpan(children: [const TextSpan(text: 'Your coach.\nYour plan.\n'), TextSpan(text: 'Your growth.', style: TextStyle(color: BrandColors.of(context).dark))]), style: TextStyle(color: _ink, fontSize: 29.sp, fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -.65)),
                SizedBox(height: 12.h),
                Text('Get matched with a certified trainer and an AI that adjusts your plan around how you actually perform.', style: TextStyle(color: _muted, fontSize: 13.5.sp, height: 1.4, fontWeight: FontWeight.w500)),
                SizedBox(height: 17.h),
                Row(
                  children: [
                    _avatar(context, Icons.person_rounded, BrandColors.of(context).light),
                    Transform.translate(offset: Offset(-8.w, 0), child: _avatar(context, Icons.face_rounded, BrandColors.of(context).light)),
                    Transform.translate(offset: Offset(-16.w, 0), child: _avatar(context, Icons.sports_rounded, BrandColors.of(context).primary)),
                    SizedBox(width: 1.w),
                    Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: '3 trainers', style: TextStyle(color: BrandColors.of(context).dark, fontWeight: FontWeight.w900)), const TextSpan(text: ' near your goals are\nready to match this week')]), style: TextStyle(color: _ink, fontSize: 12.sp, height: 1.25))),
                    Container(width: 34.w, height: 34.w, decoration: BoxDecoration(color: _ink, shape: BoxShape.circle, boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.22), blurRadius: 10)]), child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17.sp)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _flare(BuildContext context, double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])));

    Widget _avatar(BuildContext context, IconData icon, Color color) {
      return Container(width: 42.w, height: 42.w, decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.16), blurRadius: 8)]), child: Icon(icon, color: Colors.white, size: 22.sp));
    }

    Widget _stats(BuildContext context) {
      return Row(children: [
        Expanded(child: _stat(context, Icons.star_rounded, '4.9', 'average trainer\nrating')),
        SizedBox(width: 8.w),
        Expanded(child: _stat(context, Icons.insights_rounded, '92%', 'hit their 90-day\ngoal')),
        SizedBox(width: 8.w),
        Expanded(child: _stat(context, Icons.bolt_rounded, '<2hr', 'trainer response\ntime')),
      ]);
    }

    Widget _stat(BuildContext context, IconData icon, String value, String label) {
      return Container(
        padding: EdgeInsets.fromLTRB(5.w, 11.h, 5.w, 12.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: BrandColors.of(context).border), boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.07), blurRadius: 14, offset: const Offset(0, 5))]),
        child: Column(children: [Icon(icon, color: BrandColors.of(context).dark, size: 19.sp), SizedBox(height: 5.h), Text(value, style: TextStyle(color: _ink, fontSize: 18.sp, fontWeight: FontWeight.w900, height: 1)), SizedBox(height: 5.h), Text(label, textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 9.5.sp, height: 1.15, fontWeight: FontWeight.w600))]),
      );
    }

    Widget _billingToggle(BuildContext context) {
      return Obx(() {
        final annual = controller.selectedPlan.value == 'annual';
        return Container(
          height: 56.h,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(color: BrandColors.of(context).soft, borderRadius: BorderRadius.circular(30), border: Border.all(color: BrandColors.of(context).border)),
          child: Row(children: [
            Expanded(child: _billingChoice(context, 'Monthly', !annual, () => controller.selectPlan('monthly'))),
            Expanded(child: _billingChoice(context, 'Annual', annual, () => controller.selectPlan('annual'), suffix: 'Save 25%')),
          ]),
        );
      });
    }

    Widget _billingChoice(BuildContext context, String label, bool selected, VoidCallback onTap, {String? suffix}) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: selected ? BrandColors.of(context).primary : Colors.transparent, borderRadius: BorderRadius.circular(24), boxShadow: selected ? [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.22), blurRadius: 10, offset: const Offset(0, 4))] : const []),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 14.sp, fontWeight: FontWeight.w900)), if (suffix != null) ...[SizedBox(width: 5.w), Icon(Icons.local_offer_rounded, color: selected ? Colors.white : BrandColors.of(context).dark, size: 13.sp), SizedBox(width: 3.w), Text(suffix, style: TextStyle(color: selected ? Colors.white : BrandColors.of(context).dark, fontSize: 10.sp, fontWeight: FontWeight.w900))]]),
        ),
      );
    }

    Widget _tier(BuildContext context, int index, String title, String eyebrow, String price, String description, IconData icon, {String? badge, List<String> benefits = const []}) {
      return Obx(() {
        final selected = selectedTier.value == index;
        return GestureDetector(
          onTap: () => selectedTier.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(bottom: 13.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? BrandColors.of(context).primary : BrandColors.of(context).border, width: selected ? 2 : 1), boxShadow: selected ? [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8)), BoxShadow(color: BrandColors.of(context).light.withOpacity(.16), blurRadius: 3)] : [BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Stack(clipBehavior: Clip.none, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _tierIcon(context, icon, selected),
                  SizedBox(width: 11.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(eyebrow.toUpperCase(), style: TextStyle(color: selected ? BrandColors.of(context).dark : _muted, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: .85)), SizedBox(height: 3.h), Text(title, style: TextStyle(color: _ink, fontSize: 17.sp, fontWeight: FontWeight.w900))])),
                  SizedBox(width: 8.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(price, style: TextStyle(color: selected ? BrandColors.of(context).dark : _ink, fontSize: 16.sp, fontWeight: FontWeight.w900)), SizedBox(height: 3.h), Icon(selected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded, color: selected ? BrandColors.of(context).primary : const Color(0xFFB9AAA0), size: selected ? 18.sp : 13.sp)]),
                ]),
                SizedBox(height: 10.h),
                Padding(padding: EdgeInsets.only(left: 51.w), child: Text(description, style: TextStyle(color: _muted, fontSize: 12.5.sp, height: 1.35, fontWeight: FontWeight.w500))),
                if (benefits.isNotEmpty) ...[SizedBox(height: 12.h), Padding(padding: EdgeInsets.only(left: 51.w), child: Wrap(spacing: 6.w, runSpacing: 6.h, children: benefits.map((item) => _benefit(context, item)).toList()))],
              ]),
              if (badge != null) Positioned(top: -27.h, left: 4.w, child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), decoration: BoxDecoration(color: BrandColors.of(context).primary, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: BrandColors.of(context).primary.withOpacity(.25), blurRadius: 8, offset: const Offset(0, 3))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14.sp), SizedBox(width: 4.w), Text(badge.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: .5))]))),
            ]),
          ),
        );
      });
    }

    Widget _tierIcon(BuildContext context, IconData icon, bool selected) => Container(width: 40.w, height: 40.w, decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? BrandColors.of(context).soft : BrandColors.of(context).soft, border: Border.all(color: selected ? BrandColors.of(context).light : BrandColors.of(context).border)), child: Icon(icon, color: selected ? BrandColors.of(context).dark : BrandColors.of(context).primary, size: 21.sp));

    Widget _benefit(BuildContext context, String label) => Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h), decoration: BoxDecoration(color: BrandColors.of(context).soft, borderRadius: BorderRadius.circular(12), border: Border.all(color: BrandColors.of(context).border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_rounded, color: BrandColors.of(context).dark, size: 12.sp), SizedBox(width: 3.w), Text(label, style: TextStyle(color: _ink, fontSize: 10.sp, fontWeight: FontWeight.w800))]));

    Widget _cta(BuildContext context) {
      return Obx(() {
        final tier = selectedTier.value;
        final annual = controller.selectedPlan.value == 'annual';
        final ptPrice = annual
            ? '${controller.annualPriceStr.value}/yr'
            : '${controller.monthlyPriceStr.value}/mo';
        final ecPrice = annual ? '\$449.99/yr' : '\$49.99/mo';
        final String ctaText;
        if (tier == 0) {
          ctaText = 'Start 7-day free trial — \$0 today';
        } else if (tier == 1) {
          ctaText = 'Start with Personal Trainer — $ptPrice';
        } else {
          ctaText = 'Start Elite Coaching — $ecPrice';
        }

        return Column(
          children: [
            if (controller.purchaseError.value.isNotEmpty)
              Container(
                width: double.infinity,
                margin: EdgeInsets.only(bottom: 10.h),
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE8E4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  controller.purchaseError.value,
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            SizedBox(
              width: double.infinity,
              height: 58.h,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [BrandColors.of(context).primary, BrandColors.of(context).dark],
                  ),
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: BrandColors.of(context).primary.withOpacity(.28),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(19),
                    onTap: controller.purchaseLoading.value
                        ? null
                        : () {
                            if (tier == 0) {
                              controller.startFreeTrial();
                            } else if (tier == 1) {
                              controller.upgradeNow();
                            } else {
                              Get.snackbar(
                                'Coming Soon',
                                'Elite Coaching is not yet available.',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                    child: Center(
                      child: controller.purchaseLoading.value && tier == 1
                          ? SizedBox(
                              height: 23.h,
                              width: 23.h,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  ctaText,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 18.sp,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              tier == 0
                  ? '7 days free, then ${controller.monthlyPriceStr.value}/mo · cancel anytime'
                  : 'Billed ${annual ? 'annually' : 'monthly'} · cancel anytime',
              style: TextStyle(
                color: _muted,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 7.h),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  'By continuing, you agree to our ',
                  style: TextStyle(color: _muted, fontSize: 10.5.sp),
                ),
                GestureDetector(
                  onTap: () async {
                    final opened = await launchUrl(
                      Uri.parse(ApiUrls.termsOfService),
                      mode: LaunchMode.externalApplication,
                    );
                    if (!opened) {
                      Get.snackbar(
                        'Unable to open link',
                        'Please try again in a moment.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                  child: Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: BrandColors.of(context).dark,
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      });
    }

    Widget _proofCard(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(17.w, 16.h, 17.w, 15.h),
        decoration: BoxDecoration(color: BrandColors.of(context).soft, borderRadius: BorderRadius.circular(24), border: Border.all(color: BrandColors.of(context).border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_smallAvatar(context, Icons.person_rounded, BrandColors.of(context).primary), Transform.translate(offset: Offset(-8.w, 0), child: _smallAvatar(context, Icons.face_rounded, BrandColors.of(context).primary)), Transform.translate(offset: Offset(-16.w, 0), child: _smallAvatar(context, Icons.sports_rounded, BrandColors.of(context).primary)), SizedBox(width: 1.w), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: '3 trainers', style: TextStyle(color: BrandColors.of(context).dark, fontWeight: FontWeight.w900)), const TextSpan(text: ' near your goals are available to match this week')]), style: TextStyle(color: _ink, fontSize: 12.sp, height: 1.25)))]),
          SizedBox(height: 14.h),
          Text('“Most clients see their first real strength jump inside three weeks — that is when the plan starts fitting them instead of the other way around.”', style: TextStyle(color: _ink, fontSize: 15.sp, height: 1.32, fontWeight: FontWeight.w700)),
          SizedBox(height: 15.h),
          Row(children: [_metric(context, '6 yrs', 'avg.\nexperience'), _divider(context), _metric(context, 'NASM / ACE', 'certified'), _divider(context), _metric(context, '500+', 'clients\ncoached')]),
        ]),
      );
    }

    Widget _smallAvatar(BuildContext context, IconData icon, Color color) => Container(width: 38.w, height: 38.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFF6F0), width: 2)), child: Icon(icon, color: Colors.white, size: 20.sp));
    Widget _metric(BuildContext context, String value, String label) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: BrandColors.of(context).dark, fontSize: 14.sp, fontWeight: FontWeight.w900)), SizedBox(height: 2.h), Text(label, style: TextStyle(color: _muted, fontSize: 10.sp, height: 1.15, fontWeight: FontWeight.w600))]));
    Widget _divider(BuildContext context) => Container(width: 1, height: 31.h, color: BrandColors.of(context).border, margin: EdgeInsets.symmetric(horizontal: 8.w));

    Widget _accessCode(BuildContext context) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(17.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFFF1E3DA)),
          boxShadow: [
            BoxShadow(
              color: BrandColors.of(context).primary.withOpacity(.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: BrandColors.of(context).soft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: BrandColors.of(context).dark,
                    size: 19.sp,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Already have access?',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Enter your access code to unlock your plan.',
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 49.h,
                    child: TextField(
                      controller: controller.accessCodeController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        letterSpacing: .5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter code',
                        hintStyle: TextStyle(
                          color: const Color(0xFFB9AAA0),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFFFFAF7),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E1D8),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: Color(0xFFF0E1D8),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: BrandColors.of(context).primary, width: 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 9.w),
                Obx(
                  () => SizedBox(
                    height: 49.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _ink,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 17.w),
                      ),
                      onPressed: controller.accessCodeLoading.value
                          ? null
                          : controller.redeemAccessCode,
                      child: controller.accessCodeLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Unlock',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
            Obx(
              () => controller.accessCodeError.value.isNotEmpty
                  ? Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        controller.accessCodeError.value,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      );
    }

    Widget _reassurance(BuildContext context) {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_footerItem(context, Icons.lock_outline_rounded, 'Secure payment'), SizedBox(width: 13.w), _footerItem(context, Icons.autorenew_rounded, 'Cancel anytime'), SizedBox(width: 13.w), _footerItem(context, Icons.people_outline_rounded, 'Trusted by members')]);
    }

    Widget _footerItem(BuildContext context, IconData icon, String label) => Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF9C8D84), size: 13.sp), SizedBox(width: 4.w), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF9C8D84), fontSize: 9.5.sp, fontWeight: FontWeight.w700)))]));
    }


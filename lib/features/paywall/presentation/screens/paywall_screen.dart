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
    static const _cream = Color(0xFFFFFBF8);
    static const _orange = Color(0xFFFF7417);
    static const _deepOrange = Color(0xFFE9540A);

    @override
    Widget build(BuildContext context) {
      controller.configureDestination(Get.arguments);
      return Scaffold(
        backgroundColor: _cream,
        body: SafeArea(
          child: Column(
            children: [
              _header(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 28.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _hero(),
                      SizedBox(height: 18.h),
                      _stats(),
                      SizedBox(height: 22.h),
                      _billingToggle(),
                      SizedBox(height: 19.h),
                      Obx(() {
                        final annual = controller.selectedPlan.value == 'annual';
                        return Column(
                          children: [
                            _tier(0, 'Self-Guided', 'Build your own rhythm', '\$0 today', 'A flexible starting point with your AI plan and workout library.', Icons.fitness_center_rounded),
                            _tier(1, 'Personal Trainer', 'Your plan, built around you', annual ? '${controller.annualPriceStr.value}/yr' : '${controller.monthlyPriceStr.value}/mo', '1-on-1 coaching, weekly check-ins, and a plan that adapts as you do.', Icons.person_rounded, badge: 'Most chosen', benefits: const ['Live coaching', 'Weekly plan', 'Progress tracking']),
                            _tier(2, 'Elite Coaching', 'The complete transformation', annual ? '\$449.99/yr' : '\$49.99/mo', 'Everything in Personal Trainer plus dedicated nutrition coaching.', Icons.workspace_premium_rounded),
                          ],
                        );
                      }),
                      SizedBox(height: 3.h),
                      _cta(),
                      SizedBox(height: 22.h),
                      _proofCard(),
                      SizedBox(height: 18.h),
                      _accessCode(),
                      SizedBox(height: 16.h),
                      _reassurance(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget _header() {
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
                    boxShadow: [BoxShadow(color: _orange.withOpacity(.1), blurRadius: 12, offset: const Offset(0, 4))],
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
                    border: Border.all(color: _orange.withOpacity(.3), width: 2),
                    boxShadow: [BoxShadow(color: _orange.withOpacity(.16), blurRadius: 10)],
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.12,
                      child: Image.asset(tenant.logoAssetPath ?? 'assets/images/app_logo.png', fit: BoxFit.cover, filterQuality: FilterQuality.high, errorBuilder: (_, __, ___) => Icon(Icons.fitness_center_rounded, color: tenant.primaryColor, size: 17.sp)),
                    ),
                  ),
                ),
                SizedBox(width: 7.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tenant.displayName, style: TextStyle(color: tenant.isWhiteLabeled ? tenant.primaryColor : _ink, fontSize: 14.sp, fontWeight: FontWeight.w900, letterSpacing: .5, height: 1)),
                    if (!tenant.isWhiteLabeled)
                      Text('TECH AI', style: TextStyle(color: _deepOrange, fontSize: 8.sp, fontWeight: FontWeight.w800, letterSpacing: 1.2, height: 1.1)),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: controller.isPreSignup ? controller.openTrainerSignup : null,
              child: Text(controller.isPreSignup ? 'Trainer sign up' : 'Admin', style: TextStyle(color: controller.isPreSignup ? _deepOrange : _muted, fontSize: 12.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    }

    Widget _hero() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 18.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Colors.white, Color(0xFFFFE8D9)]),
          border: Border.all(color: const Color(0xFFFFC8A8)),
          boxShadow: [BoxShadow(color: _orange.withOpacity(.14), blurRadius: 24, offset: const Offset(0, 10))],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(top: -70.h, right: -55.w, child: _flare(175.w, _orange.withOpacity(.2))),
            Positioned(bottom: -50.h, left: -55.w, child: _flare(135.w, const Color(0xFFFFB36F).withOpacity(.16))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(.84), borderRadius: BorderRadius.circular(20), border: Border.all(color: _orange.withOpacity(.18))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.auto_awesome_rounded, color: _deepOrange, size: 14.sp), SizedBox(width: 5.w), Text('TRAIN SMARTER. GET RESULTS.', style: TextStyle(color: _deepOrange, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: 1.1))]),
                ),
                SizedBox(height: 14.h),
                Text.rich(TextSpan(children: [const TextSpan(text: 'Your coach.\nYour plan.\n'), TextSpan(text: 'Your growth.', style: TextStyle(color: _deepOrange))]), style: TextStyle(color: _ink, fontSize: 29.sp, fontWeight: FontWeight.w900, height: 1.05, letterSpacing: -.65)),
                SizedBox(height: 12.h),
                Text('Get matched with a certified trainer and an AI that adjusts your plan around how you actually perform.', style: TextStyle(color: _muted, fontSize: 13.5.sp, height: 1.4, fontWeight: FontWeight.w500)),
                SizedBox(height: 17.h),
                Row(
                  children: [
                    _avatar(Icons.person_rounded, const Color(0xFFFFB16A)),
                    Transform.translate(offset: Offset(-8.w, 0), child: _avatar(Icons.face_rounded, const Color(0xFFFF8A42))),
                    Transform.translate(offset: Offset(-16.w, 0), child: _avatar(Icons.sports_rounded, const Color(0xFFFF6B2B))),
                    SizedBox(width: 1.w),
                    Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: '3 trainers', style: TextStyle(color: _deepOrange, fontWeight: FontWeight.w900)), const TextSpan(text: ' near your goals are\nready to match this week')]), style: TextStyle(color: _ink, fontSize: 12.sp, height: 1.25))),
                    Container(width: 34.w, height: 34.w, decoration: BoxDecoration(color: _ink, shape: BoxShape.circle, boxShadow: [BoxShadow(color: _orange.withOpacity(.22), blurRadius: 10)]), child: Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 17.sp)),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    Widget _flare(double size, Color color) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withOpacity(0)])));

    Widget _avatar(IconData icon, Color color) {
      return Container(width: 42.w, height: 42.w, decoration: BoxDecoration(shape: BoxShape.circle, color: color, border: Border.all(color: Colors.white, width: 2.5), boxShadow: [BoxShadow(color: _orange.withOpacity(.16), blurRadius: 8)]), child: Icon(icon, color: Colors.white, size: 22.sp));
    }

    Widget _stats() {
      return Row(children: [
        Expanded(child: _stat(Icons.star_rounded, '4.9', 'average trainer\nrating')),
        SizedBox(width: 8.w),
        Expanded(child: _stat(Icons.insights_rounded, '92%', 'hit their 90-day\ngoal')),
        SizedBox(width: 8.w),
        Expanded(child: _stat(Icons.bolt_rounded, '<2hr', 'trainer response\ntime')),
      ]);
    }

    Widget _stat(IconData icon, String value, String label) {
      return Container(
        padding: EdgeInsets.fromLTRB(5.w, 11.h, 5.w, 12.h),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFFFD9C5)), boxShadow: [BoxShadow(color: _orange.withOpacity(.07), blurRadius: 14, offset: const Offset(0, 5))]),
        child: Column(children: [Icon(icon, color: _deepOrange, size: 19.sp), SizedBox(height: 5.h), Text(value, style: TextStyle(color: _ink, fontSize: 18.sp, fontWeight: FontWeight.w900, height: 1)), SizedBox(height: 5.h), Text(label, textAlign: TextAlign.center, style: TextStyle(color: _muted, fontSize: 9.5.sp, height: 1.15, fontWeight: FontWeight.w600))]),
      );
    }

    Widget _billingToggle() {
      return Obx(() {
        final annual = controller.selectedPlan.value == 'annual';
        return Container(
          height: 56.h,
          padding: EdgeInsets.all(5.w),
          decoration: BoxDecoration(color: const Color(0xFFFFEDE3), borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFFFC9AA))),
          child: Row(children: [
            Expanded(child: _billingChoice('Monthly', !annual, () => controller.selectPlan('monthly'))),
            Expanded(child: _billingChoice('Annual', annual, () => controller.selectPlan('annual'), suffix: 'Save 25%')),
          ]),
        );
      });
    }

    Widget _billingChoice(String label, bool selected, VoidCallback onTap, {String? suffix}) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: selected ? _orange : Colors.transparent, borderRadius: BorderRadius.circular(24), boxShadow: selected ? [BoxShadow(color: _orange.withOpacity(.22), blurRadius: 10, offset: const Offset(0, 4))] : const []),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text(label, style: TextStyle(color: selected ? Colors.white : _muted, fontSize: 14.sp, fontWeight: FontWeight.w900)), if (suffix != null) ...[SizedBox(width: 5.w), Icon(Icons.local_offer_rounded, color: selected ? Colors.white : _deepOrange, size: 13.sp), SizedBox(width: 3.w), Text(suffix, style: TextStyle(color: selected ? Colors.white : _deepOrange, fontSize: 10.sp, fontWeight: FontWeight.w900))]]),
        ),
      );
    }

    Widget _tier(int index, String title, String eyebrow, String price, String description, IconData icon, {String? badge, List<String> benefits = const []}) {
      return Obx(() {
        final selected = selectedTier.value == index;
        return GestureDetector(
          onTap: () => selectedTier.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(bottom: 13.h),
            padding: EdgeInsets.all(15.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: selected ? _orange : const Color(0xFFEFE3DB), width: selected ? 2 : 1), boxShadow: selected ? [BoxShadow(color: _orange.withOpacity(.18), blurRadius: 18, offset: const Offset(0, 8)), BoxShadow(color: const Color(0xFFFFC28E).withOpacity(.16), blurRadius: 3)] : [BoxShadow(color: Colors.black.withOpacity(.025), blurRadius: 8, offset: const Offset(0, 3))]),
            child: Stack(clipBehavior: Clip.none, children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _tierIcon(icon, selected),
                  SizedBox(width: 11.w),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(eyebrow.toUpperCase(), style: TextStyle(color: selected ? _deepOrange : _muted, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: .85)), SizedBox(height: 3.h), Text(title, style: TextStyle(color: _ink, fontSize: 17.sp, fontWeight: FontWeight.w900))])),
                  SizedBox(width: 8.w),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [Text(price, style: TextStyle(color: selected ? _deepOrange : _ink, fontSize: 16.sp, fontWeight: FontWeight.w900)), SizedBox(height: 3.h), Icon(selected ? Icons.check_circle_rounded : Icons.arrow_forward_ios_rounded, color: selected ? _orange : const Color(0xFFB9AAA0), size: selected ? 18.sp : 13.sp)]),
                ]),
                SizedBox(height: 10.h),
                Padding(padding: EdgeInsets.only(left: 51.w), child: Text(description, style: TextStyle(color: _muted, fontSize: 12.5.sp, height: 1.35, fontWeight: FontWeight.w500))),
                if (benefits.isNotEmpty) ...[SizedBox(height: 12.h), Padding(padding: EdgeInsets.only(left: 51.w), child: Wrap(spacing: 6.w, runSpacing: 6.h, children: benefits.map(_benefit).toList()))],
              ]),
              if (badge != null) Positioned(top: -27.h, left: 4.w, child: Container(padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h), decoration: BoxDecoration(color: _orange, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: _orange.withOpacity(.25), blurRadius: 8, offset: const Offset(0, 3))]), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 14.sp), SizedBox(width: 4.w), Text(badge.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.w900, letterSpacing: .5))]))),
            ]),
          ),
        );
      });
    }

    Widget _tierIcon(IconData icon, bool selected) => Container(width: 40.w, height: 40.w, decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? const Color(0xFFFFE1CC) : const Color(0xFFFFF1E9), border: Border.all(color: selected ? const Color(0xFFFFB17E) : const Color(0xFFFFDED0))), child: Icon(icon, color: selected ? _deepOrange : _orange, size: 21.sp));

    Widget _benefit(String label) => Container(padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h), decoration: BoxDecoration(color: const Color(0xFFFFF5EF), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFFFE0CE))), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.check_rounded, color: _deepOrange, size: 12.sp), SizedBox(width: 3.w), Text(label, style: TextStyle(color: _ink, fontSize: 10.sp, fontWeight: FontWeight.w800))]));

    Widget _cta() {
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
                  gradient: const LinearGradient(
                    colors: [_orange, _deepOrange],
                  ),
                  borderRadius: BorderRadius.circular(19),
                  boxShadow: [
                    BoxShadow(
                      color: _orange.withOpacity(.28),
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
                      color: _deepOrange,
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

    Widget _proofCard() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(17.w, 16.h, 17.w, 15.h),
        decoration: BoxDecoration(color: const Color(0xFFFFE9DC), borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFFFC9AA))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [_smallAvatar(Icons.person_rounded, const Color(0xFFEF7D42)), Transform.translate(offset: Offset(-8.w, 0), child: _smallAvatar(Icons.face_rounded, const Color(0xFFD9652E))), Transform.translate(offset: Offset(-16.w, 0), child: _smallAvatar(Icons.sports_rounded, const Color(0xFFB94B20))), SizedBox(width: 1.w), Expanded(child: Text.rich(TextSpan(children: [TextSpan(text: '3 trainers', style: TextStyle(color: _deepOrange, fontWeight: FontWeight.w900)), const TextSpan(text: ' near your goals are available to match this week')]), style: TextStyle(color: _ink, fontSize: 12.sp, height: 1.25)))]),
          SizedBox(height: 14.h),
          Text('“Most clients see their first real strength jump inside three weeks — that is when the plan starts fitting them instead of the other way around.”', style: TextStyle(color: _ink, fontSize: 15.sp, height: 1.32, fontWeight: FontWeight.w700)),
          SizedBox(height: 15.h),
          Row(children: [_metric('6 yrs', 'avg.\nexperience'), _divider(), _metric('NASM / ACE', 'certified'), _divider(), _metric('500+', 'clients\ncoached')]),
        ]),
      );
    }

    Widget _smallAvatar(IconData icon, Color color) => Container(width: 38.w, height: 38.w, decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFFFF6F0), width: 2)), child: Icon(icon, color: Colors.white, size: 20.sp));
    Widget _metric(String value, String label) => Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: _deepOrange, fontSize: 14.sp, fontWeight: FontWeight.w900)), SizedBox(height: 2.h), Text(label, style: TextStyle(color: _muted, fontSize: 10.sp, height: 1.15, fontWeight: FontWeight.w600))]));
    Widget _divider() => Container(width: 1, height: 31.h, color: const Color(0xFFFFC6A5), margin: EdgeInsets.symmetric(horizontal: 8.w));

    Widget _accessCode() {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(17.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(23),
          border: Border.all(color: const Color(0xFFF1E3DA)),
          boxShadow: [
            BoxShadow(
              color: _orange.withOpacity(.06),
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
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFE7D7),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.vpn_key_rounded,
                    color: _deepOrange,
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
                          borderSide: BorderSide(color: _orange, width: 1.5),
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

    Widget _reassurance() {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [_footerItem(Icons.lock_outline_rounded, 'Secure payment'), SizedBox(width: 13.w), _footerItem(Icons.autorenew_rounded, 'Cancel anytime'), SizedBox(width: 13.w), _footerItem(Icons.people_outline_rounded, 'Trusted by members')]);
    }

    Widget _footerItem(IconData icon, String label) => Flexible(child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, color: const Color(0xFF9C8D84), size: 13.sp), SizedBox(width: 4.w), Flexible(child: Text(label, overflow: TextOverflow.ellipsis, style: TextStyle(color: const Color(0xFF9C8D84), fontSize: 9.5.sp, fontWeight: FontWeight.w700)))]));
    }
    
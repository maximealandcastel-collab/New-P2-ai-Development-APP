import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';

/// Gym-branded login screen that stays inside the P2P Fit Tech AI design system.
///
/// The gym's logo + color personalize the experience — they do NOT replace P2P.
/// Background stays white. Actions stay P2P orange. Layout stays P2P standard.
class GymLoginPreviewScreen extends StatefulWidget {
  final EnterpriseGymModel gym;
  const GymLoginPreviewScreen({super.key, required this.gym});

  @override
  State<GymLoginPreviewScreen> createState() => _GymLoginPreviewScreenState();
}

class _GymLoginPreviewScreenState extends State<GymLoginPreviewScreen> {
  static const _kOrange = Color(0xFFFD7B00);
  static const _kBg = Color(0xFFF7F8FA);
  bool _isLogin = true;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final gym = widget.gym;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top bar ──────────────────────────────────────────────
              _TopBar(gym: gym),

              SizedBox(height: 8.h),

              // ── Gym identity card ─────────────────────────────────────
              _GymIdentityBanner(gym: gym),

              SizedBox(height: 20.h),

              // ── Login / Signup toggle ─────────────────────────────────
              _buildToggle(),

              SizedBox(height: 20.h),

              // ── Auth form ─────────────────────────────────────────────
              _buildForm(gym),

              SizedBox(height: 24.h),

              // ── Social divider ────────────────────────────────────────
              _buildDivider(),

              SizedBox(height: 16.h),

              // ── Social buttons ────────────────────────────────────────
              _buildSocialButtons(),

              SizedBox(height: 32.h),

              // ── P2P footer ────────────────────────────────────────────
              _P2PFooter(gym: gym),

              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  // ── Toggle: Login / Sign Up ───────────────────────────────────────────────

  Widget _buildToggle() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _togglePill('Login', _isLogin, () => setState(() => _isLogin = true)),
            _togglePill('Sign Up', !_isLogin, () => setState(() => _isLogin = false)),
          ],
        ),
      ),
    );
  }

  Widget _togglePill(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: active ? _kOrange : Colors.transparent,
            borderRadius: BorderRadius.circular(30.r),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: active ? Colors.white : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }

  // ── Auth form ─────────────────────────────────────────────────────────────

  Widget _buildForm(EnterpriseGymModel gym) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isLogin
                  ? 'Welcome back'
                  : 'Join ${gym.name}',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _isLogin
                  ? 'Sign in to your ${gym.name} account'
                  : 'Create your ${gym.name} membership',
              style: TextStyle(fontSize: 13.sp, color: Colors.black45),
            ),

            SizedBox(height: 20.h),

            if (!_isLogin) ...[
              _field(
                icon: Icons.person_outline_rounded,
                hint: 'Full name',
              ),
              SizedBox(height: 12.h),
            ],

            _field(
              icon: Icons.email_outlined,
              hint: 'Email address',
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 12.h),
            _field(
              icon: Icons.lock_outline_rounded,
              hint: 'Password',
              obscure: _obscure,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscure = !_obscure),
                child: Icon(
                  _obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.black38,
                  size: 18.sp,
                ),
              ),
            ),

            if (!_isLogin) ...[
              SizedBox(height: 12.h),
              _field(
                icon: Icons.lock_outline_rounded,
                hint: 'Confirm password',
                obscure: true,
              ),
            ],

            if (_isLogin) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: _kOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],

            SizedBox(height: 20.h),

            // Primary CTA — always P2P orange
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                onPressed: () {},
                child: Text(
                  _isLogin ? 'Login' : 'Create Account',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black38, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(color: Colors.black38, fontSize: 14.sp),
            ),
          ),
          if (suffix != null) suffix,
        ],
      ),
    );
  }

  // ── Divider ───────────────────────────────────────────────────────────────

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              'or continue with',
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black38,
                  fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Divider(color: Colors.black12, thickness: 1)),
        ],
      ),
    );
  }

  // ── Social buttons ────────────────────────────────────────────────────────

  Widget _buildSocialButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: _socialBtn(
              label: 'Apple',
              icon: Icons.apple_rounded,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _socialBtn(
              label: 'Google',
              icon: Icons.g_mobiledata_rounded,
              color: const Color(0xFF4285F4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _socialBtn({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Top bar ───────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _TopBar({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black87, size: 16.sp),
            ),
          ),

          const Spacer(),

          // P2P + Gym co-brand
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFFD7B00),
                  borderRadius: BorderRadius.circular(7.r),
                ),
                alignment: Alignment.center,
                child: Text('P2',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w900)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                child: Text('×',
                    style:
                        TextStyle(color: Colors.black26, fontSize: 12.sp)),
              ),
              // Gym mini logo
              Container(
                width: 28.r,
                height: 28.r,
                decoration: BoxDecoration(
                  color: gym.brandColor,
                  borderRadius: BorderRadius.circular(7.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  gym.initials.length > 2
                      ? gym.initials.substring(0, 2)
                      : gym.initials,
                  style: TextStyle(
                    color: gym.textColor == Colors.white
                        ? Colors.white
                        : gym.accentColor,
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          // Live demo badge
          Container(
            padding:
                EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5.r,
                  height: 5.r,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00C853),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 4.w),
                Text('Live',
                    style: TextStyle(
                        color: const Color(0xFF2E7D32),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gym identity banner ───────────────────────────────────────────────────────

class _GymIdentityBanner extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _GymIdentityBanner({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gym logo chip
            Container(
              width: 54.r,
              height: 54.r,
              decoration: BoxDecoration(
                color: gym.brandColor,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: gym.brandColor.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                gym.initials,
                style: TextStyle(
                  color: gym.textColor == Colors.white
                      ? Colors.white
                      : gym.accentColor,
                  fontSize: gym.initials.length > 2 ? 13.sp : 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),

            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gym.name,
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    gym.category,
                    style:
                        TextStyle(fontSize: 12.sp, color: Colors.black45),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12.sp,
                          color: const Color(0xFFFFAB00)),
                      SizedBox(width: 3.w),
                      Text(
                        '${gym.rating.toStringAsFixed(1)}  ·  ${gym.memberCount}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black45,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // YOUR GYM / PARTNER badge
            gym.isOwnGym
                ? Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFD7B00).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('YOUR\nGYM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFFFD7B00),
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.3)),
                  )
                : Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text('LICENSED\nPARTNER',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF2E7D32),
                            fontSize: 7.sp,
                            fontWeight: FontWeight.w800,
                            height: 1.3)),
                  ),
          ],
        ),
      ),
    );
  }
}

// ── P2P footer ────────────────────────────────────────────────────────────────

class _P2PFooter extends StatelessWidget {
  final EnterpriseGymModel gym;
  const _P2PFooter({required this.gym});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20.r,
              height: 20.r,
              decoration: BoxDecoration(
                color: const Color(0xFFFD7B00),
                borderRadius: BorderRadius.circular(5.r),
              ),
              alignment: Alignment.center,
              child: Text('P2',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 7.sp,
                      fontWeight: FontWeight.w900)),
            ),
            SizedBox(width: 6.w),
            Text(
              'Powered by P2P FitTech AI',
              style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.black45,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '${gym.name} · IP Licensed · Enterprise Partner',
          style: TextStyle(fontSize: 10.sp, color: Colors.black26),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/utils/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_application_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gym_login_preview_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/screens/gyms_screen.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

class GymGatewayScreen extends StatefulWidget {
  const GymGatewayScreen({super.key});

  @override
  State<GymGatewayScreen> createState() => _GymGatewayScreenState();
}

class _GymGatewayScreenState extends State<GymGatewayScreen> {
  String _selectedRole = 'Gym';
  bool _isMember = true;
  String _searchQuery = '';
  EnterpriseGymModel? _selectedGym;
  final TextEditingController _searchController = TextEditingController();
  final LoginController _loginController = LoginController.to;
  bool _obscurePassword = true;

  List<EnterpriseGymModel> get _filteredGyms {
    final gyms = EnterpriseGymModel.partners;
    if (_searchQuery.isEmpty) {
      // partners is intentionally ordered: YMCA, KMF, P2P, then prospects.
      return gyms;
    }
    final query = _searchQuery.toLowerCase();
    return gyms.where((gym) {
      return gym.name.toLowerCase().contains(query) ||
          gym.initials.toLowerCase().contains(query) ||
          gym.city.toLowerCase().contains(query);
    }).toList();
  }

  void _onContinue() {
    if (_selectedRole == 'Gym') {
      _onAdminLogin();
      return;
    }
    if (!_isMember) {
      // Continue with P2P standard auth
      if (Get.isRegistered<LoginController>()) {
        Get.find<LoginController>().setRole(_selectedRole);
      }
      Get.toNamed(AppRoute.p2pLoginScreen);
    } else {
      // Gym Member flow
      if (_selectedGym == null) {
        ToastMessageHelper.showError('Please select a gym first.');
        return;
      }
      if (_selectedGym!.isActivated) {
        GymLoginPreviewScreen.open(context, gym: _selectedGym!);
      } else {
        Get.to(() => GymApplicationScreen(initialGym: _selectedGym));
      }
    }
  }

  void _onAdminLogin() {
    if (_selectedGym == null) {
      ToastMessageHelper.showError('Please select your gym first to access your admin dashboard.');
      return;
    }
    if (_selectedGym!.isActivated) {
      GymLoginPreviewScreen.open(context, gym: _selectedGym!);
    } else {
      Get.to(() => GymApplicationScreen(initialGym: _selectedGym));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 20.h),
              _buildClaimGymCard(),
              SizedBox(height: 20.h),
              _buildRoleToggle(),
              SizedBox(height: 20.h),
              _buildMembershipToggle(),
              SizedBox(height: 16.h),
              _buildCredentialLogin(),
              if (_isMember) ...[
                SizedBox(height: 16.h),
                _buildSearchBar(),
                SizedBox(height: 20.h),
                _buildPopularGyms(),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to P2P Fitness',
          style: TextStyle(
            fontSize: 26.sp,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Connect your gym to personalize your experience.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildClaimGymCard() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFFE0D0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.domain, color: BrandColors.of(context).primary, size: 36.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claim Your Gym',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Bring your gym to P2P. Get your entire ecosystem online with a direct partnership.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => Get.to(() => const GymApplicationScreen()),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: BrandColors.of(context).primary.withOpacity(0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, color: BrandColors.of(context).primary, size: 14.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'CLAIM YOUR GYM →',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: BrandColors.of(context).primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'TARGETED PARTNERSHIP',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleToggle() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(24.r),
      ),
      padding: EdgeInsets.all(4.r),
      child: Row(
        children: ['Trainer', 'User', 'Gym'].map((role) {
          final isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (role != 'Gym') {
                  _loginController.setRole(role);
                  Get.offNamed(AppRoute.loginScreen);
                  return;
                }
                setState(() {
                  _selectedRole = role;
                  _isMember = true;
                });
              },
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Colors.transparent,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  role,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.black54,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMembershipToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you a gym member?',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Find and connect your gym to unlock a personalized experience.',
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black54,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildMemberCard(
                title: "Yes, I'm a member",
                subtitle: "Connect my gym",
                icon: Icons.fitness_center,
                isSelected: _isMember,
                onTap: () => setState(() => _isMember = true),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMemberCard(
                title: "No gym",
                subtitle: "Continue with P2P",
                icon: Icons.home,
                isSelected: !_isMember,
                onTap: () => setState(() => _isMember = false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMemberCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = BrandColors.of(context).primary;
    final bgColor = isSelected ? activeColor.withOpacity(0.08) : Colors.white;
    final borderColor = isSelected ? activeColor : const Color(0xFFEAEAEA);
    final iconColor = isSelected ? activeColor : Colors.black45;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 28.sp),
                Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? activeColor : Colors.black26,
                  size: 20.sp,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loginWithGymCredentials() async {
    final gym = _selectedGym;
    if (_isMember && gym != null && !gym.isActivated) {
      Get.to(() => GymApplicationScreen(initialGym: gym));
      return;
    }
    await _loginController.login(
      requestedTenantId: _isMember ? gym?.tenantId : null,
    );
  }

  Widget _buildCredentialLogin() {
    return Form(
      key: _loginController.loginFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginController.emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            decoration: InputDecoration(
              hintText: 'Username (email)',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFDADADA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFDADADA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: BrandColors.of(context).primary,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Enter your email address';
              if (!GetUtils.isEmail(email)) return 'Enter a valid email address';
              return null;
            },
          ),
          SizedBox(height: 10.h),
          TextFormField(
            controller: _loginController.passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            onFieldSubmitted: (_) => _loginWithGymCredentials(),
            decoration: InputDecoration(
              hintText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: () => setState(
                  () => _obscurePassword = !_obscurePassword,
                ),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFDADADA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: const BorderSide(color: Color(0xFFDADADA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14.r),
                borderSide: BorderSide(
                  color: BrandColors.of(context).primary,
                  width: 1.5,
                ),
              ),
            ),
            validator: (value) => (value?.isEmpty ?? true)
                ? 'Enter your password'
                : null,
          ),
          SizedBox(height: 12.h),
          Obx(() {
            final loading =
                _loginController.loginState == LoadingState.loading;
            return SizedBox(
              height: 50.h,
              child: ElevatedButton(
                onPressed: loading ? null : _loginWithGymCredentials,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BrandColors.of(context).primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      BrandColors.of(context).primary.withOpacity(0.5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Log In',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            );
          }),
          TextButton(
            onPressed: () => Get.toNamed(AppRoute.forgotScreen),
            child: Text(
              'Forgot Username or Password?',
              style: TextStyle(
                color: BrandColors.of(context).primary,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          Center(
            child: GestureDetector(
              onTap: () => Get.toNamed(
                AppRoute.signUpScreen,
                arguments: <String, dynamic>{
                  if (_selectedGym?.isActivated == true &&
                      _selectedGym?.tenantId != null)
                    'tenantId': _selectedGym!.tenantId,
                },
              ),
              child: Text.rich(
                TextSpan(
                  text: "Don't have an account yet? ",
                  style: TextStyle(fontSize: 12.sp, color: Colors.black54),
                  children: [
                    TextSpan(
                      text: 'Create account',
                      style: TextStyle(
                        color: BrandColors.of(context).primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFEAEAEA)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(fontSize: 14.sp),
        decoration: InputDecoration(
          hintText: 'Search gyms (e.g. Equinox, LA Fitness, Crunch...)',
          hintStyle: TextStyle(color: Colors.black38, fontSize: 13.sp),
          prefixIcon: Icon(Icons.search, color: Colors.black54, size: 20.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildPopularGyms() {
    final gyms = _filteredGyms;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular gyms',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const GymsScreen()),
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black54,
                    ),
                  ),
                  Icon(Icons.chevron_right, size: 16.sp, color: Colors.black54),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (gyms.isEmpty)
          Text('No gyms found.', style: TextStyle(color: Colors.black54))
        else
          SizedBox(
            height: 138.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gyms.length,
              separatorBuilder: (_, __) => SizedBox(width: 12.w),
              itemBuilder: (context, index) {
                final gym = gyms[index];
                final isSelected = _selectedGym?.id == gym.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGym = gym),
                  child: Container(
                    width: 108.w,
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? BrandColors.of(context).primary : const Color(0xFFEAEAEA),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: BrandColors.of(context).primary.withOpacity(0.2),
                                blurRadius: 8,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GymBrandLogo(
                            gym: gym,
                            size: 56.r,
                            borderRadius: 8.r,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          gym.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildAdminActions() {
    return Row(
      children: [
        Expanded(
          child: _buildAdminButton(
            icon: Icons.person_add_alt_1_outlined,
            title: 'Admin Sign Up',
            subtitle: 'For gym owners & authorized staff',
            onTap: () => Get.to(
              () => GymApplicationScreen(initialGym: _selectedGym),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildAdminButton(
            icon: Icons.login_outlined,
            title: 'Admin Login',
            subtitle: 'Access your gym dashboard',
            onTap: _onAdminLogin,
          ),
        ),
      ],
    );
  }

  Widget _buildAdminButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFEAEAEA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Colors.black87),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 14.sp, color: Colors.black38),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: ElevatedButton(
        onPressed: _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: BrandColors.of(context).primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Continue',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 8.w),
            Icon(Icons.arrow_forward, size: 18.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLogin() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: const Color(0xFFEAEAEA))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Text(
                'Or continue with',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black45,
                ),
              ),
            ),
            Expanded(child: Divider(color: const Color(0xFFEAEAEA))),
          ],
        ),
        SizedBox(height: 20.h),
        SizedBox(
          width: double.infinity,
          height: 52.h,
          child: OutlinedButton(
            onPressed: () {
              ToastMessageHelper.showError('Google sign-in is not available yet. Please use email and password.');
            },
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFEAEAEA)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(26.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/icons/google_g.svg',
                  width: 20.r,
                  height: 20.r,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Sign in with Google',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: () {
            if (_selectedRole != 'Gym' && Get.isRegistered<LoginController>()) {
              Get.find<LoginController>().setRole(_selectedRole);
            }
            Get.toNamed(AppRoute.signUpScreen);
          },
          child: Text.rich(
            TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black54,
              ),
              children: [
                TextSpan(
                  text: 'Sign up',
                  style: TextStyle(
                    color: BrandColors.of(context).primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

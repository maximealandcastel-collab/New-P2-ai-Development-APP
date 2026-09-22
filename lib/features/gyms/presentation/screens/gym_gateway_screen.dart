import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
// import 'package:pler_to_pler_app/core/utils/helpers/toast_message_helper.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  List<EnterpriseGymModel> get _filteredGyms {
    final gyms = EnterpriseGymModel.partners;
    if (_searchQuery.isEmpty) {
      const priority = <String, int>{
        'ymca_yonkers': 0,
        'kmf_fitness_club': 1,
        'p2p_fit_factor': 2,
      };
      return [...gyms]..sort(
        (a, b) => (priority[a.id] ?? 999).compareTo(priority[b.id] ?? 999),
      );
    }
    final query = _searchQuery.toLowerCase();
    return gyms.where((gym) {
      return gym.name.toLowerCase().contains(query) ||
          gym.initials.toLowerCase().contains(query) ||
          gym.city.toLowerCase().contains(query);
    }).toList();
  }

  // void _onContinue() {
  //   if (_selectedRole == 'Gym') {
  //     _onAdminLogin();
  //     return;
  //   }
  //   if (!_isMember) {
  //     // Continue with P2P standard auth
  //     if (Get.isRegistered<LoginController>()) {
  //       Get.find<LoginController>().setRole(_selectedRole);
  //     }
  //     Get.toNamed(AppRoute.p2pLoginScreen);
  //   } else {
  //     // Gym Member flow
  //     if (_selectedGym == null) {
  //       ToastMessageHelper.showError('Please select a gym first.');
  //       return;
  //     }
  //     if (_selectedGym!.isActivated) {
  //       GymLoginPreviewScreen.open(context, gym: _selectedGym!);
  //     } else {
  //       Get.to(() => GymApplicationScreen(initialGym: _selectedGym));
  //     }
  //   }
  // }

  // void _onAdminLogin() {
  //   if (_selectedGym == null) {
  //     ToastMessageHelper.showError(
  //       'Please select your gym first to access your admin dashboard.',
  //     );
  //     return;
  //   }
  //   if (_selectedGym!.isActivated) {
  //     GymLoginPreviewScreen.open(context, gym: _selectedGym!);
  //   } else {
  //     Get.to(() => GymApplicationScreen(initialGym: _selectedGym));
  //   }
  // }

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
        child: Stack(
          children: [
            const Positioned.fill(child: _EnterpriseBackdrop()),
            Positioned(
              top: 112.h,
              right: -102.w,
              child: IgnorePointer(
                child: Opacity(
                  opacity: .075,
                  child: Image.asset(
                    'assets/images/gym_photos/kmf_fitness_club_floor.jpg',
                    width: 300.w,
                    height: 420.h,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 92.h,
              left: 0,
              right: 0,
              height: 480.h,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white,
                        Colors.white.withValues(alpha: .98),
                        Colors.white.withValues(alpha: .94),
                        Colors.white.withValues(alpha: .68),
                      ],
                      stops: const [0, .50, .78, 1],
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(28.w, 16.h, 28.w, 24.h),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandHeader(),
                  SizedBox(height: 20.h),
                  _buildHeader(),
                  SizedBox(height: 16.h),
                  _buildClaimGymCard(),
                  SizedBox(height: 18.h),
                  _buildRoleToggle(),
                  SizedBox(height: 22.h),
                  _buildMembershipToggle(),
                  SizedBox(height: 18.h),
                  _buildCredentialLogin(),
                  SizedBox(height: 24.h),
                  _buildSearchBar(),
                  SizedBox(height: 18.h),
                  _buildPopularGyms(),
                  SizedBox(height: 14.h),
                  _buildAdminActions(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    final primary = BrandColors.of(context).primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Image.asset(
              Assets.images.logo.path,
              width: 54.w,
              height: 54.w,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 23.sp,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF080A12),
                    ),
                    children: [
                      const TextSpan(text: 'P2P '),
                      TextSpan(text: 'FIT', style: TextStyle(color: primary)),
                    ],
                  ),
                ),
                SizedBox(height: 7.h),
                Text(
                  'T E C H    A I',
                  style: TextStyle(
                    fontSize: 8.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3.5,
                    color: const Color(0xFF181A22),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'A\nS T R O N G E R\nY O U\nT O G E T H E R',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 6.5.sp,
                    height: 1.42,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.25,
                    color: const Color(0xFF343640),
                  ),
                ),
                SizedBox(height: 5.h),
                Container(width: 28.w, height: 2.h, color: primary),
              ],
            ),
          ],
        ),
        SizedBox(height: 9.h),
        Text(
          'F I T N E S S   ·   P E O P L E   ·   P R O G R E S S',
          style: TextStyle(
            fontSize: 7.2.sp,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.15,
            color: const Color(0xFF898B96),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to P2P Fitness',
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF090B14),
            letterSpacing: -.8,
            height: 1.08,
          ),
        ),
        SizedBox(height: 7.h),
        Text(
          'Connect your gym to personalize your experience.',
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.3,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF71717D),
          ),
        ),
      ],
    );
  }

  Widget _buildClaimGymCard() {
    final primary = BrandColors.of(context).primary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => Get.to(() => const GymApplicationScreen()),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF7).withValues(alpha: .94),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFFFE2D2)),
          ),
          child: Row(
            children: [
              Container(
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: .10),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.domain_outlined, color: primary, size: 20.sp),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Claim Your Gym',
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF171820),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      'Bring your gym to P2P with a direct partnership.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        height: 1.3,
                        color: const Color(0xFF737580),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Claim gym',
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w600,
                          color: primary,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(Icons.arrow_forward_rounded, size: 14.sp, color: primary),
                    ],
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    'TARGETED PARTNERSHIP',
                    style: TextStyle(
                      fontSize: 6.5.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: .7,
                      color: const Color(0xFF777984),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleToggle() {
    final primary = BrandColors.of(context).primary;
    const icons = <String, IconData>{
      'Trainer': Icons.fitness_center_rounded,
      'User': Icons.person_rounded,
      'Gym': Icons.apartment_rounded,
    };
    const roles = ['Trainer', 'User', 'Gym'];
    return SizedBox(
      height: 64.h,
      child: Row(
        children: List.generate(5, (index) {
          if (index.isOdd) {
            return Container(
              width: 1,
              height: 30.h,
              color: const Color(0xFFE3E4E8),
            );
          }
          final role = roles[index ~/ 2];
          final isSelected = _selectedRole == role;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icons[role],
                    size: 20.sp,
                    color: isSelected ? primary : const Color(0xFF686A75),
                  ),
                  SizedBox(height: 5.h),
                  Text(
                    role,
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? primary : const Color(0xFF686A75),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 1.5.h,
                    margin: EdgeInsets.symmetric(horizontal: 14.w),
                    color: isSelected ? primary : Colors.transparent,
                  ),
                ],
              ),
            ),
          );
        }),
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
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF171820),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Find and connect your gym to unlock a personalized experience.',
          style: TextStyle(
            fontSize: 11.5.sp,
            height: 1.3,
            color: const Color(0xFF777985),
          ),
        ),
        SizedBox(height: 12.h),
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
            SizedBox(width: 10.w),
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
    final bgColor = isSelected
        ? activeColor.withValues(alpha: .055)
        : Colors.white.withValues(alpha: .88);
    final borderColor = isSelected ? activeColor : const Color(0xFFEAEAEA);
    final iconColor = isSelected ? activeColor : Colors.black45;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 82.h),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: iconColor, size: 20.sp),
                Icon(
                  isSelected
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: isSelected ? activeColor : Colors.black26,
                  size: 17.sp,
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF20212A),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5.sp,
                color: const Color(0xFF777985),
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
      formKey: _formKey,
    );
  }

  Widget _buildCredentialLogin() {
    final primary = BrandColors.of(context).primary;
    InputDecoration fieldDecoration({
      required String hint,
      required IconData icon,
      Widget? suffix,
    }) {
      OutlineInputBorder border(Color color) => OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide(color: color),
          );
      return InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.w400,
          color: const Color(0xFFB5B6BE),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: .90),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        prefixIcon: Icon(icon, size: 19.sp, color: const Color(0xFF696B76)),
        prefixIconConstraints: BoxConstraints(minWidth: 48.w),
        suffixIcon: suffix,
        border: border(const Color(0xFFE4E5E9)),
        enabledBorder: border(const Color(0xFFE4E5E9)),
        focusedBorder: border(primary.withValues(alpha: .72)),
        errorBorder: border(const Color(0xFFE95454)),
        focusedErrorBorder: border(const Color(0xFFE95454)),
        errorStyle: TextStyle(fontSize: 10.sp, height: 1.1),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _loginController.emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username, AutofillHints.email],
            autovalidateMode: AutovalidateMode.onUserInteraction,
            cursorColor: primary,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF22242D),
            ),
            decoration: fieldDecoration(
              hint: 'Username (email)',
              icon: Icons.person_outline_rounded,
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Enter your email address';
              if (!GetUtils.isEmail(email)) return 'Enter a valid email address';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          TextFormField(
            controller: _loginController.passwordController,
            obscureText: _obscurePassword,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            onFieldSubmitted: (_) => _loginWithGymCredentials(),
            cursorColor: primary,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF22242D),
            ),
            decoration: fieldDecoration(
              hint: 'Password',
              icon: Icons.lock_outline_rounded,
              suffix: IconButton(
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                splashRadius: 18.r,
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19.sp,
                  color: const Color(0xFF696B76),
                ),
              ),
            ),
            validator: (value) =>
                (value?.isEmpty ?? true) ? 'Enter your password' : null,
          ),
          SizedBox(height: 14.h),
          Row(
            children: [
              Obx(
                () => GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _loginController.toggleSaveLogin,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 20.w,
                    height: 20.w,
                    decoration: BoxDecoration(
                      color: _loginController.saveLogin.value
                          ? primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(
                        color: _loginController.saveLogin.value
                            ? primary
                            : const Color(0xFFD7D9DE),
                      ),
                    ),
                    child: _loginController.saveLogin.value
                        ? Icon(Icons.check_rounded, color: Colors.white, size: 14.sp)
                        : null,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: _loginController.toggleSaveLogin,
                child: Text(
                  'Remember me',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF74747F),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoute.forgotScreen),
                child: Text(
                  'Forgot password?',
                  style: TextStyle(
                    color: primary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Obx(() {
            final loading = _loginController.loginState == LoadingState.loading;
            return Center(
              child: GestureDetector(
                onTap: loading ? null : _loginWithGymCredentials,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: loading ? .72 : 1,
                  child: Container(
                    width: 168.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9A2F),
                          Color(0xFFFF6A16),
                          Color(0xFFFF4C12),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999.r),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: .24),
                          blurRadius: 16,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: Center(
                      child: loading
                          ? SizedBox(
                              width: 19.w,
                              height: 19.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Colors.white,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Log in',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 9.w),
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
            );
          }),
          SizedBox(height: 18.h),
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
                  text: 'New to P2P Fit? ',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF8A8B94),
                  ),
                  children: [
                    TextSpan(
                      text: 'Create account',
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFDADCE1))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'O R   C O N T I N U E   W I T H',
                  style: TextStyle(
                    fontSize: 7.2.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.55,
                    color: const Color(0xFF777985),
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFDADCE1))),
            ],
          ),
          SizedBox(height: 17.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _EnterpriseSocialButton(
                icon: Icon(Icons.apple, color: Colors.black, size: 25.sp),
                onTap: () => _socialUnavailable('Apple'),
              ),
              SizedBox(width: 18.w),
              _EnterpriseSocialButton(
                icon: SvgPicture.asset(
                  'assets/icons/google_g.svg',
                  width: 23.r,
                  height: 23.r,
                ),
                onTap: () => _socialUnavailable('Google'),
              ),
              SizedBox(width: 18.w),
              _EnterpriseSocialButton(
                icon: Icon(
                  Icons.facebook_rounded,
                  color: const Color(0xFF0866FF),
                  size: 24.sp,
                ),
                onTap: () => _socialUnavailable('Meta'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _socialUnavailable(String provider) {
    Get.snackbar(
      '$provider sign-in',
      '$provider sign-in is not available yet. Please use email and password.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 44.h,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .90),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFE4E5E9)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF22242D)),
        decoration: InputDecoration(
          hintText: 'Search gyms (e.g. Equinox, LA Fitness, YMCA...)',
          hintStyle: TextStyle(color: const Color(0xFFB5B6BE), fontSize: 11.5.sp),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF696B76),
            size: 18.sp,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
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
              'Targeted partnerships',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF20212A),
              ),
            ),
            GestureDetector(
              onTap: () => Get.to(() => const GymsScreen()),
              child: Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF777985),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 15.sp,
                    color: const Color(0xFF777985),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        if (gyms.isEmpty)
          Text('No gyms found.', style: TextStyle(color: Colors.black54))
        else
          SizedBox(
            height: 112.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gyms.length,
              separatorBuilder: (_, __) => SizedBox(width: 10.w),
              itemBuilder: (context, index) {
                final gym = gyms[index];
                final isSelected = _selectedGym?.id == gym.id;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedGym = gym);
                    if (gym.isActivated) {
                      GymLoginPreviewScreen.open(context, gym: gym);
                    } else {
                      Get.to(() => GymApplicationScreen(initialGym: gym));
                    }
                  },
                  child: Container(
                    width: 98.w,
                    padding: EdgeInsets.all(7.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11.r),
                      border: Border.all(
                        color: isSelected
                            ? BrandColors.of(context).primary
                            : const Color(0xFFEAEAEA),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: BrandColors.of(
                                  context,
                                ).primary.withValues(alpha: .12),
                                blurRadius: 6,
                              ),
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GymBrandLogo(
                            gym: gym,
                            size: 44.r,
                            borderRadius: 8.r,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          gym.name,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.5.sp,
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
            icon: Icons.shield_outlined,
            title: 'Admin Demo Login',
            subtitle: 'Use approved demo credentials',
            onTap: _loginWithGymCredentials,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildAdminButton(
            icon: Icons.login_outlined,
            title: 'Gym Admin Login',
            subtitle: 'Use your facility credentials',
            onTap: _loginWithGymCredentials,
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
        padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11.r),
          border: Border.all(color: const Color(0xFFE7E8EC)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .018),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: const Color(0xFF454750)),
            SizedBox(width: 7.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF20212A),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 8.5.sp,
                      color: const Color(0xFF777985),
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

  // Widget _buildContinueButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     height: 52.h,
  //     child: ElevatedButton(
  //       onPressed: _onContinue,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: BrandColors.of(context).primary,
  //         foregroundColor: Colors.white,
  //         elevation: 0,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(26.r),
  //         ),
  //       ),
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.center,
  //         children: [
  //           Text(
  //             'Continue',
  //             style: TextStyle(
  //               fontSize: 16.sp,
  //               fontWeight: FontWeight.w600,
  //             ),
  //           ),
  //           SizedBox(width: 8.w),
  //           Icon(Icons.arrow_forward, size: 18.sp),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildSocialLogin() {
  //   return Column(
  //     children: [
  //       Row(
  //         children: [
  //           Expanded(child: Divider(color: const Color(0xFFEAEAEA))),
  //           Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 12.w),
  //             child: Text(
  //               'Or continue with',
  //               style: TextStyle(
  //                 fontSize: 12.sp,
  //                 color: Colors.black45,
  //               ),
  //             ),
  //           ),
  //           Expanded(child: Divider(color: const Color(0xFFEAEAEA))),
  //         ],
  //       ),
  //       SizedBox(height: 20.h),
  //       SizedBox(
  //         width: double.infinity,
  //         height: 52.h,
  //         child: OutlinedButton(
  //           onPressed: () {
  //             ToastMessageHelper.showError('Google sign-in is not available yet. Please use email and password.');
  //           },
  //           style: OutlinedButton.styleFrom(
  //             backgroundColor: Colors.white,
  //             side: const BorderSide(color: Color(0xFFEAEAEA)),
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(26.r),
  //             ),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: [
  //               SvgPicture.asset(
  //                 'assets/icons/google_g.svg',
  //                 width: 20.r,
  //                 height: 20.r,
  //               ),
  //               SizedBox(width: 12.w),
  //               Text(
  //                 'Sign in with Google',
  //                 style: TextStyle(
  //                   fontSize: 15.sp,
  //                   fontWeight: FontWeight.w600,
  //                   color: Colors.black87,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 24.h),
  //       GestureDetector(
  //         onTap: () {
  //           if (_selectedRole != 'Gym' && Get.isRegistered<LoginController>()) {
  //             Get.find<LoginController>().setRole(_selectedRole);
  //           }
  //           Get.toNamed(AppRoute.signUpScreen);
  //         },
  //         child: Text.rich(
  //           TextSpan(
  //             text: "Don't have an account? ",
  //             style: TextStyle(
  //               fontSize: 14.sp,
  //               color: Colors.black54,
  //             ),
  //             children: [
  //               TextSpan(
  //                 text: 'Sign up',
  //                 style: TextStyle(
  //                   color: BrandColors.of(context).primary,
  //                   fontWeight: FontWeight.w600,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }
}

class _EnterpriseBackdrop extends StatelessWidget {
  const _EnterpriseBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFFFFFF),
            Color(0xFFFFFCFA),
            Color(0xFFFFF8F3),
          ],
          stops: [0, .46, .78, 1],
        ),
      ),
    );
  }
}

class _EnterpriseSocialButton extends StatelessWidget {
  const _EnterpriseSocialButton({
    required this.icon,
    required this.onTap,
  });

  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          width: 46.w,
          height: 46.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .96),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFF0F0F2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .045),
                blurRadius: 9,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

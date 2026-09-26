import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/extensions/app_extension.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/core/services/admin_mode_service.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/user_profile_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/widgets/profile_flexible_background.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/trainer_profile_shimmer.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // When admin is in User-mode toggle, show subscriber profile
    if (Get.isRegistered<AdminModeService>() &&
        AdminModeService.to.isAdmin &&
        AdminModeService.to.viewAsUser) {
      return const UserProfileScreen();
    }
    final controller = ProfileController.to;

    return Obx(() {
      final isLoading = controller.loadingState.isLoading;
      final trainer   = controller.trainerData;

      return SliverScaffold(
        appBar: CustomSliverAppBar(
          safeArea: false,
          expandedHeight: 270.h,
          collapsedTitle: isLoading
              ? ''
              : trainer?.name ?? controller.userData?.fullName ?? '',
          foregroundColor: Colors.white,
          flexibleBackground: isLoading
              ? TrainerProfileShimmer.headerShimmer()
              : const ProfileFlexibleBackground(),
        ),
        bodyList: isLoading
            ? TrainerProfileShimmer.contentSlivers()
            : _buildSlivers(context, trainer, controller),
      );
    });
  }

  List<Widget> _buildSlivers(
    BuildContext context,
    TrainerDetailsModel? trainer,
    ProfileController controller,
  ) {
    const accessCode = 'MAXP210';

    return [
      SizedBox(height: 14.h).asSliver,

      // ── Access Code Card ───────────────────────────────────────────────
      _AccessCodeCard(code: accessCode).asSliverWithPadding(horizontal: 18.w),
      SizedBox(height: 22.h).asSliver,

      // ── Business & Clients ─────────────────────────────────────────────
      _SectionHeader(title: 'Business & Clients').asSliver,
      SizedBox(height: 9.h).asSliver,
      _MenuSection(items: [
        _MenuItem(
          icon: Icons.attach_money_rounded,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          title: 'Earnings & Payouts',
          subtitle: 'Track your revenue and payouts',
          onTap: () => Get.toNamed(AppRoute.earningsScreen),
        ),
        _MenuItem(
          icon: Icons.people_alt_rounded,
          iconBg: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF7C3AED),
          title: 'Clients',
          subtitle: 'Manage your clients and progress',
          // clientDetailsScreen is a single-client detail route whose binding
          // requires a ClientInvoiceModel argument; opening it with none threw
          // a TypeError. The clients *list* is the Clients tab.
          onTap: () {
            Get.until((route) => route.settings.name == AppRoute.bottonNavBar);
            final nav = BottomNavBarController.to;
            final clients = nav.clientsTabIndex;
            if (clients >= 0) nav.onChange(clients);
          },
        ),
        _MenuItem(
          icon: Icons.calendar_today_rounded,
          iconBg: BrandColors.of(context).soft,
          iconColor: BrandColors.of(context).primary,
          title: 'Sessions & Packages',
          subtitle: 'Manage sessions and packages',
          onTap: () => Get.toNamed(AppRoute.paymentRequestScreen),
        ),
        _MenuItem(
          icon: Icons.play_circle_filled_rounded,
          iconBg: const Color(0xFFF3E8FF),
          iconColor: const Color(0xFF9333EA),
          title: 'Content & Video Library',
          subtitle: 'Upload and manage your content',
          onTap: () => Get.toNamed(AppRoute.createContentScreen),
        ),
        _MenuItem(
          icon: Icons.smart_toy_rounded,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          title: 'AI Coach / AI Video Chat',
          subtitle: 'Configure your AI coaching',
          badge: 'AI Ready',
          onTap: () => Get.toNamed(AppRoute.aiVideoChatConnectScreen),
        ),
        _MenuItem(
          icon: Icons.trending_up_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'Performance Analytics',
          subtitle: 'View your performance insights',
          badge: 'This Month',
          onTap: () => Get.snackbar(
            'Performance Analytics',
            'Performance analytics are not available yet.',
            snackPosition: SnackPosition.BOTTOM,
          ),
        ),
        _MenuItem(
          icon: Icons.receipt_long_rounded,
          iconBg: BrandColors.of(context).soft,
          iconColor: BrandColors.of(context).primary,
          title: 'Invoices & Statements',
          subtitle: 'View and download invoices',
          onTap: () => Get.toNamed(AppRoute.invoicesScreen),
        ),
      ]).asSliverWithPadding(horizontal: 18.w),
      SizedBox(height: 22.h).asSliver,

      // ── Account & Support ──────────────────────────────────────────────
      _SectionHeader(title: 'Account & Support').asSliver,
      SizedBox(height: 9.h).asSliver,
      _MenuSection(items: [
        _MenuItem(
          icon: Icons.person_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'Profile & Trainer Info',
          subtitle: 'Manage your profile, bio and specialties',
          badge: 'Complete',
          onTap: () => Get.toNamed(AppRoute.profileInformationScreen),
        ),
        _MenuItem(
          icon: Icons.settings_rounded,
          iconBg: const Color(0xFFF3F4F6),
          iconColor: const Color(0xFF6B7280),
          title: 'Account & Settings',
          subtitle: 'Manage your account and preferences',
          onTap: () => Get.toNamed(AppRoute.settingsScreen),
        ),
        _MenuItem(
          icon: Icons.headset_mic_rounded,
          iconBg: BrandColors.of(context).soft,
          iconColor: BrandColors.of(context).primary,
          title: 'Admin Support',
          subtitle: 'Get help from the P2P FitTech AI team',
          badge: 'Contact',
          onTap: () => Get.toNamed(AppRoute.adminSupportScreen),
        ),
      ]).asSliverWithPadding(horizontal: 18.w),
      SizedBox(height: 22.h).asSliver,

      // ── Quick Actions ──────────────────────────────────────────────────
      _SectionHeader(title: 'Quick Actions').asSliver,
      SizedBox(height: 9.h).asSliver,
      _MenuSection(items: [
        _MenuItem(
          icon: Icons.edit_rounded,
          iconBg: const Color(0xFFF0FDF4),
          iconColor: const Color(0xFF16A34A),
          title: 'Edit Profile',
          subtitle: 'Update your photo and details',
          onTap: () => Get.toNamed(AppRoute.profileInformationScreen),
        ),
        _MenuItem(
          icon: Icons.lock_rounded,
          iconBg: const Color(0xFFEFF6FF),
          iconColor: const Color(0xFF2563EB),
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => Get.toNamed(AppRoute.changePasswordScreen),
        ),
        _MenuItem(
          icon: Icons.logout_rounded,
          iconBg: const Color(0xFFFFF1F2),
          iconColor: const Color(0xFFE11D48),
          title: 'Logout',
          subtitle: 'Sign out of your account',
          onTap: () => LoginController.to.logout(),
        ),
      ]).asSliverWithPadding(horizontal: 18.w),
      SizedBox(height: 48.h).asSliver,
    ];
  }
}

// ── Access Code Card ───────────────────────────────────────────────────────

class _AccessCodeCard extends StatelessWidget {
  final String code;
  const _AccessCodeCard({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFEDEEF1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('YOUR ACCESS CODE',
                    style: TextStyle(fontSize: 9.sp, fontWeight: AppFontWeight.label,
                        color: BrandColors.of(context).primary, letterSpacing: 0.8)),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Text(code,
                        style: TextStyle(fontSize: 17.sp, fontWeight: AppFontWeight.stat,
                            color: const Color(0xFF20232B), letterSpacing: 1.1)),
                    SizedBox(width: 10.w),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: code));
                        ToastMessageHelper.show('Code copied!');
                      },
                      child: SizedBox(
                        width: 44.w,
                        height: 44.h,
                        child: Icon(Icons.copy_outlined, size: 16.sp,
                            color: BrandColors.of(context).primary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, size: 18.sp, color: const Color(0xFFB7BBC4)),
        ],
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Text(title,
          style: TextStyle(fontSize: 14.sp, fontWeight: AppFontWeight.section,
              color: const Color(0xFF20232B))),
    );
  }
}

// ── Menu Section ───────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: const Color(0xFFEDEEF1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: items.asMap().entries.map((e) {
          final isLast = e.key == items.length - 1;
          return _MenuTile(item: e.value, isLast: isLast);
        }).toList(),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final _MenuItem item;
  final bool isLast;
  const _MenuTile({required this.item, required this.isLast});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Column(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 56.h),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
                child: Row(
                  children: [
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        color: item.iconBg,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(item.icon, color: item.iconColor, size: 18.sp),
                    ),
                    SizedBox(width: 11.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: AppFontWeight.label,
                              color: const Color(0xFF20232B),
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            item.subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: AppFontWeight.body,
                              color: const Color(0xFF777D89),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (item.badge != null) ...[
                      SizedBox(width: 5.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: BrandColors.of(context).soft,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          item.badge!,
                          maxLines: 1,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: AppFontWeight.label,
                            color: BrandColors.of(context).primary,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right_rounded, size: 18.sp,
                        color: const Color(0xFFB7BBC4)),
                  ],
                ),
              ),
            ),
            if (!isLast)
              Divider(height: 1, thickness: 1, indent: 57.w,
                  color: const Color(0xFFF0F1F4)),
          ],
        ),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final Color iconBg, iconColor;
  final String title, subtitle;
  final String? badge;
  final VoidCallback onTap;
  const _MenuItem({
    required this.icon, required this.iconBg, required this.iconColor,
    required this.title, required this.subtitle, this.badge, required this.onTap,
  });
}

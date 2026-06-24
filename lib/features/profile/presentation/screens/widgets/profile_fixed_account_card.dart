import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/helpers/string_format.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileFixedAccountCard extends StatelessWidget {
  const ProfileFixedAccountCard({
    super.key,
    required this.email,
    required this.role,
  });

  final String email;
  final String role;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 20.r,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withValues(alpha: 0.14),
              Colors.white,
              Colors.white,
            ],
          ),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    text: 'Account info',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                  const Spacer(),
                  CustomContainer(
                    paddingHorizontal: 10.w,
                    paddingVertical: 4.h,
                    radiusAll: 20.r,
                    color: Colors.black.withValues(alpha: 0.06),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 12.r,
                          color: AppColors.textSecondary,
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: 'Read only',
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              _AccountInfoTile(
                icon: Assets.icons.emailIcon.image(height: 20.r, width: 20.r),
                label: 'Email',
                value: StringFormat.valueOrNa(email),
              ),
              SizedBox(height: 10.h),
              _AccountInfoTile(
                icon: Icon(
                  Icons.badge_outlined,
                  size: 20.r,
                  color: AppColors.primary,
                ),
                label: 'Role',
                value: StringFormat.valueOrNa(role),
                trailing: _RoleBadge(role: role),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AccountInfoTile extends StatelessWidget {
  const _AccountInfoTile({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final Widget icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      color: Colors.white.withValues(alpha: 0.72),
      radiusAll: 14.r,
      paddingHorizontal: 14.w,
      paddingVertical: 12.h,
      width: double.infinity,
      child: Row(
        children: [
          CustomContainer(
            shape: BoxShape.circle,
            paddingAll: 10.r,
            color: AppColors.primary.withValues(alpha: 0.12),
            child: icon,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                  bottom: 2.h,
                ),
                CustomText(
                  text: value,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  maxline: 2,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final displayRole = role.trim().isEmpty ? 'N/A' : role.toUpperCase();

    return CustomContainer(
      paddingHorizontal: 10.w,
      paddingVertical: 5.h,
      radiusAll: 20.r,
      color: AppColors.primary.withValues(alpha: 0.15),
      child: CustomText(
        text: displayRole,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    );
  }
}

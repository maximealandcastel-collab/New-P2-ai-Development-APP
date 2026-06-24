import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ProfileFixedAccountCard extends StatelessWidget {
  const ProfileFixedAccountCard({
    super.key,
    required this.email,
    this.username,
  });

  final String email;
  final String? username;

  @override
  Widget build(BuildContext context) {
    final hasEmail = email.trim().isNotEmpty;
    final displayUsername = _usernameValue(username);
    final hasUsername = displayUsername != null;

    if (!hasEmail && !hasUsername) {
      return const SizedBox.shrink();
    }

    return CustomContainer(
      radiusAll: 20.r,
      width: double.infinity,
      color: Colors.white,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                color: AppColors.primary,
                child: Row(
                  children: [
                    CustomContainer(
                      shape: BoxShape.circle,
                      paddingAll: 8.r,
                      color: Colors.white.withValues(alpha: 0.12),
                      child: Icon(
                        Icons.verified_user_outlined,
                        size: 18.r,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            text: 'Account credentials',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          CustomText(
                            text: 'These details are linked to your account',
                            fontSize: 11.sp,
                            color: Colors.white.withValues(alpha: 0.7),
                            top: 2.h,
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.lock_rounded,
                      size: 16.r,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
                child: Column(
                  children: [
                    if (hasEmail)
                      _CredentialRow(
                        icon: Assets.icons.emailIcon.image(
                          height: 18.r,
                          width: 18.r,
                        ),
                        label: 'Email address',
                        value: email.trim(),
                      ),
                    if (hasEmail && hasUsername)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Divider(
                          height: 1,
                          color: Colors.black.withValues(alpha: 0.08),
                        ),
                      ),
                    if (hasUsername)
                      _UsernameRow(username: displayUsername),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _usernameValue(String? raw) {
    final trimmed = raw?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed.startsWith('@') ? trimmed.substring(1) : trimmed;
  }
}

class _CredentialRow extends StatelessWidget {
  const _CredentialRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final Widget icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomContainer(
          radiusAll: 12.r,
          paddingAll: 10.r,
          color: AppColors.backgroundLight,
          child: icon,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: label,
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
                bottom: 4.h,
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
      ],
    );
  }
}

class _UsernameRow extends StatelessWidget {
  const _UsernameRow({required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      radiusAll: 10.r,
      paddingHorizontal: 10.w,
      paddingVertical: 8.h,
      color: AppColors.backgroundLight,
      width: double.infinity,
      child: _InlineMetaItem(
        label: '@username',
        value: username,
      ),
    );
  }
}

class _InlineMetaItem extends StatelessWidget {
  const _InlineMetaItem({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: TextStyle(
          fontSize: 11.sp,
          fontFamily: 'Figtree',
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        children: [
          TextSpan(text: '$label : '),
          TextSpan(
            text: value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }
}

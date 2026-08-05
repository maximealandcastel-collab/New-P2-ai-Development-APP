import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  late final AdminDashboardController _c;
  late final String _filter;
  late final String _title;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _c = AdminDashboardController.to;
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _filter = args['filter'] as String? ?? 'all';
    _title  = args['title']  as String? ?? 'Users';
    _c.fetchFilteredUsers(_filter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 18.sp, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title,
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary)),
            Obx(() => Text(
                  '${_c.filteredUsers.length} users',
                  style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                )),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: AppColors.textSecondary, size: 20.sp),
            onPressed: () => _c.fetchFilteredUsers(_filter),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
            child: TextField(
              controller: _search,
              onChanged: (v) => _c.filterSearchQuery.value = v.trim().toLowerCase(),
              decoration: InputDecoration(
                hintText: 'Search by email or name…',
                hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey.shade400),
                filled: true,
                fillColor: AppColors.backgroundLight,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ── List ────────────────────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (_c.filteredUsersLoading && _c.filteredUsers.isEmpty) {
                return Center(
                    child: CircularProgressIndicator(color: AppColors.primary));
              }
              final query = _c.filterSearchQuery.value;
              final list = query.isEmpty
                  ? _c.filteredUsers
                  : _c.filteredUsers
                      .where((u) =>
                          u.email.toLowerCase().contains(query) ||
                          u.fullName.toLowerCase().contains(query))
                      .toList();
              if (list.isEmpty) {
                return Center(
                  child: Text('No users found',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 14.sp)),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
                itemCount: list.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (ctx, i) =>
                    _UserCard(user: list[i], controller: _c),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── User card ────────────────────────────────────────────────────────────────
class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final AdminDashboardController controller;

  const _UserCard({required this.user, required this.controller});

  Color get _roleColor {
    switch (user.role) {
      case 'trainer': return const Color(0xFF4F46E5);
      case 'admin':   return const Color(0xFFDC2626);
      default:        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22.r,
              backgroundColor: _roleColor.withOpacity(0.12),
              child: Text(
                user.email.isNotEmpty ? user.email[0].toUpperCase() : '?',
                style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: _roleColor),
              ),
            ),
            SizedBox(width: 12.w),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.fullName.trim().isNotEmpty)
                    Text(user.fullName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary)),
                  Text(user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 12.sp,
                          color: user.fullName.trim().isNotEmpty
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          fontWeight: user.fullName.trim().isNotEmpty
                              ? FontWeight.w400
                              : FontWeight.w600)),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 4.w,
                    children: [
                      _Badge(label: user.role, color: _roleColor),
                      _Badge(
                        label: user.isVerified ? 'verified' : 'unverified',
                        color: user.isVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFD97706),
                      ),
                      if (user.subscriptionTier != 'free' &&
                          user.subscriptionTier.isNotEmpty)
                        _Badge(
                          label: user.subscriptionTier,
                          color: const Color(0xFF7C3AED),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // Date + chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(_fmt(user.createdAt),
                    style: TextStyle(
                        fontSize: 10.sp, color: AppColors.textSecondary)),
                SizedBox(height: 4.h),
                Icon(Icons.chevron_right_rounded,
                    size: 16.sp, color: Colors.grey.shade300),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(user: user, controller: controller),
    );
  }

  String _fmt(DateTime d) => '${d.month}/${d.day}/${d.year}';
}

// ── User detail bottom sheet ─────────────────────────────────────────────────
class _UserDetailSheet extends StatelessWidget {
  final AdminUserModel user;
  final AdminDashboardController controller;

  const _UserDetailSheet({required this.user, required this.controller});

  Color get _roleColor {
    switch (user.role) {
      case 'trainer': return const Color(0xFF4F46E5);
      case 'admin':   return const Color(0xFFDC2626);
      default:        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 40.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40.w, height: 4.h,
              margin: EdgeInsets.only(bottom: 20.h),
              decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(99.r)),
            ),
          ),

          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 26.r,
                backgroundColor: _roleColor.withOpacity(0.12),
                child: Text(
                  user.email[0].toUpperCase(),
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: _roleColor),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (user.fullName.trim().isNotEmpty)
                      Text(user.fullName,
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary)),
                    Text(user.email,
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),
          _InfoRow(label: 'User ID',        value: user.id),
          _InfoRow(label: 'Role',           value: user.role),
          _InfoRow(label: 'Verified',       value: user.isVerified ? '✅ Yes' : '❌ No'),
          _InfoRow(label: 'Subscription',   value: user.subscriptionTier),
          if (user.subscriptionEndDate != null)
            _InfoRow(label: 'Sub Expires',  value: _fmtFull(user.subscriptionEndDate!)),
          if (user.referredByCode != null && user.referredByCode!.isNotEmpty)
            _InfoRow(label: 'Referred By',  value: user.referredByCode!),
          _InfoRow(label: 'Joined',         value: _fmtFull(user.createdAt)),

          SizedBox(height: 20.h),
          const Divider(),
          SizedBox(height: 16.h),

          // ── Actions ───────────────────────────────────────────────
          Text('Actions',
              style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary)),
          SizedBox(height: 12.h),

          Row(
            children: [
              // Toggle verified
              Expanded(
                child: _ActionBtn(
                  label: user.isVerified ? 'Mark Unverified' : 'Mark Verified',
                  color: user.isVerified
                      ? const Color(0xFFD97706)
                      : const Color(0xFF059669),
                  icon: user.isVerified
                      ? Icons.cancel_outlined
                      : Icons.verified_outlined,
                  onTap: () async {
                    await controller.setVerified(user.id, !user.isVerified);
                    Get.back();
                    Get.snackbar(
                      user.isVerified ? 'Marked Unverified' : 'Marked Verified',
                      user.email,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ),
              SizedBox(width: 10.w),
              // Change role
              Expanded(
                child: _ActionBtn(
                  label: user.role == 'user' ? 'Make Trainer' : 'Make User',
                  color: const Color(0xFF4F46E5),
                  icon: user.role == 'user'
                      ? Icons.fitness_center
                      : Icons.person_outline,
                  onTap: () async {
                    final newRole = user.role == 'user' ? 'trainer' : 'user';
                    await controller.setRole(user.id, newRole);
                    Get.back();
                    Get.snackbar('Role Updated', '${user.email} → $newRole',
                        snackPosition: SnackPosition.BOTTOM);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmtFull(DateTime d) =>
      '${d.month}/${d.day}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.label,
      required this.color,
      required this.icon,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4.r)),
      child: Text(label,
          style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

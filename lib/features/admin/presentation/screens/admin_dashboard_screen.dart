import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AdminDashboardController>()
        ? AdminDashboardController.to
        : Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.loadAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              // ── Header ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 16.h),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.shield_rounded,
                            color: AppColors.primary, size: 22.sp),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin Dashboard',
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary)),
                          Text('P2P FitTech AI',
                              style: TextStyle(
                                  fontSize: 11.sp,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                      const Spacer(),
                      Obx(() => c.metricsLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: AppColors.primary))
                          : IconButton(
                              icon: Icon(Icons.refresh_rounded,
                                  color: AppColors.textSecondary, size: 22.sp),
                              onPressed: c.loadAll,
                            )),
                    ],
                  ),
                ),
              ),

              // ── Metrics body ─────────────────────────────────────────
              Obx(() {
                if (c.metricsLoading && c.metrics == null) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60.h),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    ),
                  );
                }
                final m = c.metrics;
                if (m == null) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Text(
                          c.error.isNotEmpty ? c.error : 'No data available',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Overview grid ─────────────────────────────────
                    _SectionHeader(title: 'Overview'),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.55,
                        children: [
                          _StatCard(
                            label: 'Total Users',
                            value: m.overview.totalUsers.toString(),
                            icon: Icons.people_rounded,
                            color: const Color(0xFF4F46E5),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'all', 'title': 'All Users'}),
                          ),
                          _StatCard(
                            label: 'Today Signups',
                            value: m.overview.todaySignups.toString(),
                            icon: Icons.person_add_rounded,
                            color: const Color(0xFF059669),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'today', 'title': "Today's Signups"}),
                          ),
                          _StatCard(
                            label: 'This Week',
                            value: m.overview.weekSignups.toString(),
                            icon: Icons.trending_up_rounded,
                            color: const Color(0xFF0284C7),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'week', 'title': 'This Week'}),
                          ),
                          _StatCard(
                            label: 'This Month',
                            value: m.overview.monthSignups.toString(),
                            icon: Icons.calendar_month_rounded,
                            color: const Color(0xFF7C3AED),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'month', 'title': 'This Month'}),
                          ),
                          _StatCard(
                            label: 'Verified',
                            value: m.overview.verifiedUsers.toString(),
                            icon: Icons.verified_rounded,
                            color: const Color(0xFF059669),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'verified', 'title': 'Verified Users'}),
                          ),
                          _StatCard(
                            label: 'Unverified',
                            value: m.overview.unverifiedUsers.toString(),
                            icon: Icons.mark_email_unread_rounded,
                            color: const Color(0xFFD97706),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'unverified', 'title': 'Unverified Users'}),
                          ),
                          _StatCard(
                            label: 'Active Subs',
                            value: m.overview.activeSubscriptions.toString(),
                            icon: Icons.star_rounded,
                            color: const Color(0xFFF59E0B),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'active_subs', 'title': 'Active Subscribers'}),
                          ),
                          _StatCard(
                            label: 'Admin Bypass',
                            value: m.overview.adminBypassUsers.toString(),
                            icon: Icons.admin_panel_settings_rounded,
                            color: const Color(0xFFDC2626),
                            onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
                                arguments: {'filter': 'admin_bypass', 'title': 'Admin Bypass Users'}),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // ── Role breakdown ────────────────────────────────
                    if (m.roleBreakdown.isNotEmpty) ...[
                      _SectionHeader(title: 'Users by Role'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _BreakdownCard(
                          items: m.roleBreakdown
                              .map((r) => _BreakdownItem(
                                    label: _capitalize(r.role),
                                    count: r.count,
                                    total: m.overview.totalUsers,
                                    color: _roleColor(r.role),
                                    onTap: r.role == 'admin'
                                        ? null
                                        : () => Get.toNamed(
                                              AppRoute.adminUserListScreen,
                                              arguments: {
                                                'filter': r.role,
                                                'title': '${_capitalize(r.role)}s',
                                              },
                                            ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // ── Subscription breakdown ────────────────────────
                    if (m.subscriptionBreakdown.isNotEmpty) ...[
                      _SectionHeader(title: 'Subscription Tiers'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _BreakdownCard(
                          items: m.subscriptionBreakdown
                              .map((s) => _BreakdownItem(
                                    label: _capitalize(s.tier),
                                    count: s.count,
                                    total: m.overview.totalUsers,
                                    color: _tierColor(s.tier),
                                    onTap: s.count == 0
                                        ? null
                                        : () => Get.toNamed(
                                              AppRoute.adminUserListScreen,
                                              arguments: {
                                                'filter': (s.tier == 'monthly' || s.tier == 'annual')
                                                    ? 'active_subs'
                                                    : 'all',
                                                'title': '${_capitalize(s.tier)} Users',
                                              },
                                            ),
                                  ))
                              .toList(),
                        ),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // ── Daily signups chart ───────────────────────────
                    if (m.dailySignups.isNotEmpty) ...[
                      _SectionHeader(title: 'Daily Signups (Recent)'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: _DailySignupsChart(days: m.dailySignups),
                      ),
                      SizedBox(height: 20.h),
                    ],

                    // ── Recent users ──────────────────────────────────
                    if (m.recentUsers.isNotEmpty) ...[
                      _SectionHeader(title: 'Recent Users'),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ],
                          ),
                          child: Column(
                            children: m.recentUsers
                                .asMap()
                                .entries
                                .map((entry) => _RecentUserRow(
                                      user: entry.value,
                                      isLast:
                                          entry.key == m.recentUsers.length - 1,
                                    ))
                                .toList(),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ]),
                );
              }),

              // ── Withdrawals ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: _SectionHeader(title: 'Trainer Withdrawals'),
              ),

              Obx(() {
                if (c.withdrawalsLoading && c.withdrawals.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    ),
                  );
                }
                if (c.withdrawals.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                      child: Text('No withdrawal requests yet.',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 14.sp)),
                    ),
                  );
                }
                return SliverPadding(
                  padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _WithdrawalCard(
                          withdrawal: c.withdrawals[index], controller: c),
                      childCount: c.withdrawals.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Color _roleColor(String role) {
    switch (role) {
      case 'trainer':
        return const Color(0xFF4F46E5);
      case 'admin':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF059669);
    }
  }

  Color _tierColor(String tier) {
    switch (tier) {
      case 'premium':
        return const Color(0xFFF59E0B);
      case 'pro':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF6B7280);
    }
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ─── Section header ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 10.h),
      child: Text(title,
          style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary)),
    );
  }
}

// ─── Stat card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(6.w),
            decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8.r)),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Text(label,
                  style: TextStyle(
                      fontSize: 11.sp, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    ));
  }
}

// ─── Breakdown card (roles / tiers) ─────────────────────────────────────────

class _BreakdownItem {
  final String label;
  final int count;
  final int total;
  final Color color;
  final VoidCallback? onTap;
  const _BreakdownItem(
      {required this.label,
      required this.count,
      required this.total,
      required this.color,
      this.onTap});
  double get fraction => total == 0 ? 0 : count / total;
}

class _BreakdownCard extends StatelessWidget {
  final List<_BreakdownItem> items;
  const _BreakdownCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: items.map((item) {
          return GestureDetector(
            onTap: item.onTap,
            child: Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.label,
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Text(item.count.toString(),
                        style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w700,
                            color: item.color)),
                  ],
                ),
                SizedBox(height: 6.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: item.fraction,
                    minHeight: 6.h,
                    backgroundColor: Colors.black.withOpacity(0.06),
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
                  ),
                ),
              ],
            ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Daily signups mini-chart (custom bars, no external deps) ───────────────

class _DailySignupsChart extends StatelessWidget {
  final List<DailySignup> days;
  const _DailySignupsChart({required this.days});

  @override
  Widget build(BuildContext context) {
    final maxCount =
        days.fold<int>(1, (m, d) => d.count > m ? d.count : m);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: days.map((d) {
                final frac = maxCount == 0 ? 0.0 : d.count / maxCount;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (d.count > 0)
                          Text(d.count.toString(),
                              style: TextStyle(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        SizedBox(height: 3.h),
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(4.r)),
                          child: Container(
                            height: (frac * 55.h).clamp(4.0, 55.h),
                            color: AppColors.primary
                                .withOpacity(0.2 + frac * 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: days.map((d) {
              final parts = d.date.split('-');
              final label =
                  parts.length >= 3 ? '${parts[1]}/${parts[2]}' : d.date;
              return Expanded(
                child: Text(label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 9.sp, color: AppColors.textSecondary)),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Recent user row ─────────────────────────────────────────────────────────

class _RecentUserRow extends StatelessWidget {
  final RecentUser user;
  final bool isLast;
  const _RecentUserRow({required this.user, required this.isLast});

  Color get _roleColor {
    switch (user.role) {
      case 'trainer':
        return const Color(0xFF4F46E5);
      case 'admin':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF059669);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoute.adminUserListScreen,
        arguments: {
          'filter': user.role == 'trainer' ? 'trainer' : 'all',
          'title': user.role == 'trainer' ? 'Trainers' : 'All Users',
        },
      ),
      child: Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: _roleColor.withOpacity(0.12),
                child: Text(
                  user.email.isNotEmpty
                      ? user.email[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: _roleColor),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary)),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.only(top: 2.h),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                              color: _roleColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4.r)),
                          child: Text(user.role,
                              style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _roleColor)),
                        ),
                        if (!user.isVerified) ...[
                          SizedBox(width: 4.w),
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.symmetric(
                                horizontal: 6.w, vertical: 1.h),
                            decoration: BoxDecoration(
                                color: const Color(0xFFD97706).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r)),
                            child: Text('unverified',
                                style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFD97706))),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(user.createdAt),
                style: TextStyle(
                    fontSize: 10.sp, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              thickness: 0.5,
              indent: 46.w,
              color: Colors.black.withOpacity(0.06)),
      ],
    ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';
}

// ─── Withdrawal card ─────────────────────────────────────────────────────────

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalItem withdrawal;
  final AdminDashboardController controller;
  const _WithdrawalCard({required this.withdrawal, required this.controller});

  Color get _statusColor {
    switch (withdrawal.status) {
      case 'approved':
        return const Color(0xFF059669);
      case 'rejected':
        return const Color(0xFFDC2626);
      case 'paid':
        return const Color(0xFF4F46E5);
      default:
        return const Color(0xFFD97706);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('\$${withdrawal.amountDollars.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary)),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r)),
                child: Text(withdrawal.status.toUpperCase(),
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '${withdrawal.withdrawalMethod.toUpperCase()} • ${withdrawal.paymentEmail}',
            style:
                TextStyle(color: AppColors.textSecondary, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(_formatDate(withdrawal.createdAt),
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 11.sp)),
          if (withdrawal.additionalNote?.isNotEmpty == true) ...[
            SizedBox(height: 6.h),
            Text('"${withdrawal.additionalNote}"',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.sp,
                    fontStyle: FontStyle.italic)),
          ],
          if (withdrawal.requiresApproval) ...[
            SizedBox(height: 14.h),
            Obx(() {
              final loading = controller.actionLoading == withdrawal.id;
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          loading ? null : () => controller.approve(withdrawal.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: loading
                          ? SizedBox(
                              width: 16.w,
                              height: 16.w,
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text('Approve',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp)),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          loading ? null : () => controller.reject(withdrawal.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text('Reject',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13.sp)),
                    ),
                  ),
                ],
              );
            }),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';
}



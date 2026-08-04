import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = AdminDashboardController.to;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: c.loadAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              // ── Header ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
                  child: Row(
                    children: [
                      Icon(Icons.shield_rounded,
                          color: AppColors.primary, size: 26.sp),
                      SizedBox(width: 10.w),
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Obx(() => c.metricsLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary))
                          : IconButton(
                              icon: Icon(Icons.refresh,
                                  color: AppColors.textSecondary, size: 22.sp),
                              onPressed: c.loadAll,
                            )),
                    ],
                  ),
                ),
              ),

              // ── Metrics cards ─────────────────────────────────────
              SliverToBoxAdapter(
                child: Obx(() {
                  if (c.metricsLoading && c.metrics == null) {
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.h),
                      child: Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    );
                  }
                  final m = c.metrics;
                  if (m == null) {
                    return Padding(
                      padding: EdgeInsets.all(20.w),
                      child: Text(c.error.isNotEmpty
                          ? c.error
                          : 'No metrics available'),
                    );
                  }
                  return Padding(
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
                          value: m.totalUsers.toString(),
                          icon: Icons.people_rounded,
                          color: const Color(0xFF4F46E5),
                        ),
                        _StatCard(
                          label: 'Today Signups',
                          value: m.todaySignups.toString(),
                          icon: Icons.person_add_rounded,
                          color: const Color(0xFF059669),
                        ),
                        _StatCard(
                          label: 'Active Subs',
                          value: m.activeSubscriptions.toString(),
                          icon: Icons.star_rounded,
                          color: const Color(0xFFD97706),
                        ),
                        _StatCard(
                          label: 'Admin Bypass',
                          value: m.adminBypassUsers.toString(),
                          icon: Icons.admin_panel_settings_rounded,
                          color: const Color(0xFFDC2626),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              SliverToBoxAdapter(child: SizedBox(height: 24.h)),

              // ── Withdrawals header ────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Text(
                    'Trainer Withdrawals',
                    style: TextStyle(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 10.h)),

              // ── Withdrawal list ───────────────────────────────────
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
                      padding: EdgeInsets.all(20.w),
                      child: Text(
                        'No withdrawal requests yet.',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 14.sp),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding:
                      EdgeInsets.fromLTRB(16.w, 0, 16.w, 120.h),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final w = c.withdrawals[index];
                        return _WithdrawalCard(withdrawal: w, controller: c);
                      },
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
}

// ─── Stat card ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 18.sp),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Withdrawal card ────────────────────────────────────────────────────────

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalItem withdrawal;
  final AdminDashboardController controller;

  const _WithdrawalCard(
      {required this.withdrawal, required this.controller});

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
          // Top row: amount + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${withdrawal.amountDollars.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  withdrawal.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Method + email
          Text(
            '${withdrawal.withdrawalMethod.toUpperCase()} • ${withdrawal.paymentEmail}',
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 12.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            _formatDate(withdrawal.createdAt),
            style: TextStyle(
                color: AppColors.textSecondary, fontSize: 11.sp),
          ),

          if (withdrawal.additionalNote?.isNotEmpty == true) ...[
            SizedBox(height: 6.h),
            Text(
              '"${withdrawal.additionalNote}"',
              style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic),
            ),
          ],

          // Approve / Reject buttons — only for pending ≥ $2k
          if (withdrawal.requiresApproval) ...[
            SizedBox(height: 14.h),
            Obx(() {
              final loading = controller.actionLoading == withdrawal.id;
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: loading
                          ? null
                          : () => controller.approve(withdrawal.id),
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
                      onPressed: loading
                          ? null
                          : () => controller.reject(withdrawal.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFDC2626),
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r)),
                      ),
                      child: Text('Reject',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.sp)),
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

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }
}

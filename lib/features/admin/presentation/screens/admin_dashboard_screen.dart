import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

// ─── App theme (matches AppColors exactly) ────────────────────────────────────
const _bg         = Color(0xFFF0F0F0);   // AppColors.backgroundLight
const _card       = Colors.white;
const _border     = Color(0xFFE5E7EB);
const _orange     = Color(0xFFFD7B00);   // AppColors.primary
const _green      = Color(0xFF22C55E);
const _blue       = Color(0xFF3B82F6);
const _purple     = Color(0xFFA855F7);
const _pink       = Color(0xFFEC4899);
const _yellow     = Color(0xFFEAB308);
const _tPrim      = Color(0xFF000000);   // AppColors.textPrimary
const _tSec       = Color(0xFF7F7F7F);   // AppColors.textSecondary

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AdminDashboardController>()
        ? AdminDashboardController.to
        : Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: _orange,
          backgroundColor: _card,
          onRefresh: c.loadAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
              SliverToBoxAdapter(child: _DashHeader(c: c)),
              Obx(() => SliverToBoxAdapter(child: _KpiGrid(c: c))),
              Obx(() => SliverToBoxAdapter(child: _ActivityFeed(c: c))),
              SliverToBoxAdapter(child: _QuickActions(c: c)),
              Obx(() => SliverToBoxAdapter(child: _RevenueOverview(c: c))),
              Obx(() => SliverToBoxAdapter(child: _TrainerManagement(c: c))),
              Obx(() => SliverToBoxAdapter(child: _Withdrawals(c: c))),
              const SliverToBoxAdapter(child: SizedBox(height: 64)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _DashHeader extends StatelessWidget {
  final AdminDashboardController c;
  const _DashHeader({required this.c});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Row(
        children: [
          Container(
            width: 42.w, height: 42.w,
            decoration: BoxDecoration(
              color: _orange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.shield_rounded, color: _orange, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin Dashboard',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w800, color: _tPrim)),
              Text('P2P FitTech AI · Live',
                  style: TextStyle(fontSize: 11.sp, color: _tSec)),
            ],
          ),
          const Spacer(),
          Obx(() => c.metricsLoading
              ? SizedBox(width: 18.w, height: 18.w,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _orange))
              : GestureDetector(
                  onTap: c.loadAll,
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: _border),
                    ),
                    child: Icon(Icons.refresh_rounded, color: _tSec, size: 18.sp),
                  ))),
        ],
      ),
    );
  }
}

// ─── KPI Grid (2×3) ───────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final AdminDashboardController c;
  const _KpiGrid({required this.c});

  @override
  Widget build(BuildContext context) {
    final m = c.metrics;
    final trainerCount = m?.roleBreakdown
        .where((r) => r.role == 'trainer').fold(0, (s, r) => s + r.count) ?? 0;
    final userCount = m?.roleBreakdown
        .where((r) => r.role == 'user').fold(0, (s, r) => s + r.count) ?? 0;
    final activeSubs = m?.overview.activeSubscriptions ?? 0;
    final todayNew   = m?.overview.todaySignups ?? 0;
    final weekNew    = m?.overview.weekSignups ?? 0;
    final verified   = m?.overview.verifiedUsers ?? 0;

    final cards = [
      _KpiData('👥', 'TOTAL TRAINERS', '$trainerCount', '+$weekNew this week', _blue,   const Color(0xFFEFF6FF)),
      _KpiData('🏃', 'ACTIVE USERS',   '$userCount',   '+$todayNew today',    _green,  const Color(0xFFF0FDF4)),
      _KpiData('💰', 'ACTIVE SUBS',    '$activeSubs',  'Paying members',       _orange, const Color(0xFFFFF7ED)),
      _KpiData('✅', 'VERIFIED',        '$verified',    'Email confirmed',      _purple, const Color(0xFFFAF5FF)),
      _KpiData('📊', 'NEW THIS WEEK',  '$weekNew',     'Signups this week',    _pink,   const Color(0xFFFFF1F5)),
      _KpiData('📱', 'NEW TODAY',      '$todayNew',    'Signups today',        _yellow, const Color(0xFFFFFBEB)),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(children: [
        Row(children: [Expanded(child: _KpiCard(d: cards[0])), SizedBox(width: 10.w), Expanded(child: _KpiCard(d: cards[1]))]),
        SizedBox(height: 10.h),
        Row(children: [Expanded(child: _KpiCard(d: cards[2])), SizedBox(width: 10.w), Expanded(child: _KpiCard(d: cards[3]))]),
        SizedBox(height: 10.h),
        Row(children: [Expanded(child: _KpiCard(d: cards[4])), SizedBox(width: 10.w), Expanded(child: _KpiCard(d: cards[5]))]),
        SizedBox(height: 16.h),
      ]),
    );
  }
}

class _KpiData {
  final String emoji, label, value, sub;
  final Color accent, bg;
  const _KpiData(this.emoji, this.label, this.value, this.sub, this.accent, this.bg);
}

class _KpiCard extends StatelessWidget {
  final _KpiData d;
  const _KpiCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: d.bg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: d.accent.withValues(alpha: 0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(d.emoji, style: TextStyle(fontSize: 20.sp)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: d.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text('LIVE', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w700, color: d.accent)),
          ),
        ]),
        SizedBox(height: 10.h),
        Text(d.value, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: d.accent)),
        SizedBox(height: 2.h),
        Text(d.label, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: _tSec, letterSpacing: 0.5)),
        SizedBox(height: 2.h),
        Text(d.sub, style: TextStyle(fontSize: 10.sp, color: _tSec)),
      ]),
    );
  }
}

// ─── Live Activity Feed ────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  final AdminDashboardController c;
  const _ActivityFeed({required this.c});

  @override
  Widget build(BuildContext context) {
    final users = c.metrics?.recentUsers ?? [];
    final items = users.take(8).toList();

    return _Section(
      title: 'Live Activity Feed',
      icon: Icons.bolt_rounded,
      iconColor: _orange,
      child: Column(
        children: items.map((u) {
          final isTrainer = u.role == 'trainer';
          final isSub = u.subscriptionTier != 'free' && u.subscriptionTier.isNotEmpty;
          final typeLabel = isTrainer ? 'trainer' : isSub ? 'purchase' : 'signup';
          final typeColor = isTrainer ? _blue : isSub ? _green : _purple;
          final mins = DateTime.now().difference(u.createdAt).inMinutes;
          final timeStr = mins < 60 ? '${mins}m ago' : mins < 1440 ? '${mins ~/ 60}h ago' : '${mins ~/ 1440}d ago';
          return _ActivityRow(typeLabel: typeLabel, typeColor: typeColor,
              title: isTrainer ? 'Trainer joined' : isSub ? 'New subscriber' : 'New signup',
              subtitle: u.email, time: timeStr);
        }).toList(),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  final String typeLabel, title, subtitle, time;
  final Color typeColor;
  const _ActivityRow({required this.typeLabel, required this.typeColor,
      required this.title, required this.subtitle, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: typeColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(typeLabel, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: typeColor)),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _tPrim)),
          Text(subtitle, style: TextStyle(fontSize: 11.sp, color: _tSec)),
        ])),
        Text(time, style: TextStyle(fontSize: 11.sp, color: _tSec)),
      ]),
    );
  }
}

// ─── Quick Actions ─────────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  final AdminDashboardController c;
  const _QuickActions({required this.c});

  @override
  Widget build(BuildContext context) {
    final pending = c.withdrawals.where((w) => w.status == 'pending').length;
    final actions = [
      _QaData('Approve Pending Trainers', pending > 0 ? '$pending pending' : null, _blue,
          () => Get.toNamed(AppRoute.adminUserListScreen, arguments: {'filter': 'trainer', 'title': 'Trainers'})),
      _QaData('Review Withdrawal Requests', pending > 0 ? '$pending requests' : null, const Color(0xFFDC2626), () {}),
      _QaData('User Management', null, _purple,
          () => Get.toNamed(AppRoute.adminUserListScreen, arguments: {'filter': 'all', 'title': 'All Users'})),
      _QaData('Send Platform Announcement', null, _green, () {}),
      _QaData('Export Revenue Report', 'This month', _orange, () {}),
    ];

    return _Section(
      title: 'Quick Actions',
      icon: Icons.flash_on_rounded,
      iconColor: _orange,
      child: Column(children: actions.map((a) => _QaButton(data: a)).toList()),
    );
  }
}

class _QaData {
  final String label;
  final String? badge;
  final Color color;
  final VoidCallback onTap;
  const _QaData(this.label, this.badge, this.color, this.onTap);
}

class _QaButton extends StatelessWidget {
  final _QaData data;
  const _QaButton({required this.data});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: data.onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: data.color.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Expanded(child: Text(data.label,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: data.color))),
          if (data.badge != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: data.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r)),
              child: Text(data.badge!, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: data.color)),
            )
          else
            Icon(Icons.arrow_forward_ios_rounded, size: 13.sp, color: data.color),
        ]),
      ),
    );
  }
}

// ─── Revenue Overview ──────────────────────────────────────────────────────────

class _RevenueOverview extends StatelessWidget {
  final AdminDashboardController c;
  const _RevenueOverview({required this.c});

  @override
  Widget build(BuildContext context) {
    final ov = c.metrics?.overview;
    final sb = c.metrics?.subscriptionBreakdown ?? [];
    final monthlyCount = sb.where((s) => s.tier == 'monthly').fold(0, (s, r) => s + r.count);
    final annualCount  = sb.where((s) => s.tier == 'annual').fold(0, (s, r) => s + r.count);
    final daily  = c.metrics?.dailySignups ?? [];
    final last7  = daily.length > 7 ? daily.sublist(daily.length - 7) : daily;
    final maxCnt = last7.isEmpty ? 1 : last7.map((d) => d.count).reduce((a, b) => a > b ? a : b);

    final stats = [
      _StatCard('TOTAL USERS',    '${ov?.totalUsers ?? 0}',        'All time',        _blue),
      _StatCard('ACTIVE SUBS',    '${ov?.activeSubscriptions ?? 0}','Currently active', _green),
      _StatCard('MONTHLY PLANS',  '$monthlyCount',                  'Monthly billing',  _purple),
      _StatCard('ANNUAL PLANS',   '$annualCount',                   'Annual billing',   _orange),
    ];

    return _Section(
      title: 'Platform Overview',
      icon: Icons.trending_up_rounded,
      iconColor: _green,
      child: Column(children: [
        Row(children: [Expanded(child: _MiniStat(s: stats[0])), SizedBox(width: 10.w), Expanded(child: _MiniStat(s: stats[1]))]),
        SizedBox(height: 10.h),
        Row(children: [Expanded(child: _MiniStat(s: stats[2])), SizedBox(width: 10.w), Expanded(child: _MiniStat(s: stats[3]))]),
        SizedBox(height: 20.h),
        Row(children: [
          Icon(Icons.bar_chart_rounded, color: _orange, size: 16.sp),
          SizedBox(width: 6.w),
          Text('Daily Signups · Last 7 days',
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: _tPrim)),
        ]),
        SizedBox(height: 14.h),
        SizedBox(
          height: 100.h,
          child: last7.isEmpty
              ? Center(child: Text('No data yet', style: TextStyle(color: _tSec, fontSize: 12.sp)))
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: last7.map((d) {
                    final ratio = maxCnt == 0 ? 0.0 : d.count / maxCnt;
                    final label = d.date.length >= 10 ? d.date.substring(5, 10).replaceAll('-', '/') : d.date;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                          Text('${d.count}', style: TextStyle(fontSize: 9.sp, color: _tSec, fontWeight: FontWeight.w600)),
                          SizedBox(height: 3.h),
                          Container(
                            height: (80 * ratio).clamp(4.0, 80.0).h,
                            decoration: BoxDecoration(
                              color: _orange,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(label, style: TextStyle(fontSize: 8.sp, color: _tSec), textAlign: TextAlign.center),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ]),
    );
  }
}

class _StatCard {
  final String label, value, sub;
  final Color color;
  const _StatCard(this.label, this.value, this.sub, this.color);
}

class _MiniStat extends StatelessWidget {
  final _StatCard s;
  const _MiniStat({required this.s});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: s.color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: s.color.withValues(alpha: 0.18)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.value, style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: s.color)),
        Text(s.label, style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w600, color: _tSec, letterSpacing: 0.4)),
        Text(s.sub, style: TextStyle(fontSize: 10.sp, color: _tSec)),
      ]),
    );
  }
}

// ─── Trainer Management ────────────────────────────────────────────────────────

class _TrainerManagement extends StatelessWidget {
  final AdminDashboardController c;
  const _TrainerManagement({required this.c});

  @override
  Widget build(BuildContext context) {
    final allUsers = c.metrics?.recentUsers ?? [];
    final trainers = allUsers.where((u) => u.role == 'trainer').toList();
    final active  = trainers.where((u) => u.isVerified).length;
    final pending = trainers.where((u) => !u.isVerified).length;

    return _Section(
      title: 'Trainer Management',
      icon: Icons.people_alt_rounded,
      iconColor: _blue,
      trailing: GestureDetector(
        onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'trainer', 'title': 'Trainers'}),
        child: Text('View All', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: _orange)),
      ),
      child: Column(children: [
        // Filter tabs
        Row(children: [
          _FilterTab(label: 'All',     count: trainers.length, active: true),
          SizedBox(width: 8.w),
          _FilterTab(label: 'Active',  count: active,  active: false),
          SizedBox(width: 8.w),
          _FilterTab(label: 'Pending', count: pending, active: false, badge: true),
        ]),
        SizedBox(height: 14.h),
        // Column headers
        Row(children: ['TRAINER', 'STATUS'].map((h) => Expanded(
          child: Text(h, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: _tSec, letterSpacing: 0.5)),
        )).toList()),
        Divider(color: _border, height: 16.h),
        if (trainers.isEmpty)
          Padding(padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(child: Text('No trainers in recent data', style: TextStyle(color: _tSec, fontSize: 12.sp))))
        else
          ...trainers.take(6).map((u) => _TrainerRow(user: u)),
      ]),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool active, badge;
  const _FilterTab({required this.label, required this.count, required this.active, this.badge = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: active ? _orange : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: active ? _orange : _border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600,
            color: active ? Colors.white : _tSec)),
        if (badge && count > 0) ...[
          SizedBox(width: 5.w),
          Container(width: 18.w, height: 18.w,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Center(child: Text('$count', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w700, color: Colors.white)))),
        ] else if (!active && count > 0) ...[
          SizedBox(width: 5.w),
          Text('$count', style: TextStyle(fontSize: 11.sp, color: _tSec)),
        ],
      ]),
    );
  }
}

class _TrainerRow extends StatelessWidget {
  final RecentUser user;
  const _TrainerRow({required this.user});

  @override
  Widget build(BuildContext context) {
    final joined = '${user.createdAt.month}/${user.createdAt.year}';
    final statusLabel = user.isVerified ? 'Active' : 'Pending';
    final statusColor = user.isVerified ? _green : _yellow;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _border))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user.email.split('@').first,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: _tPrim)),
          Text('Joined $joined', style: TextStyle(fontSize: 10.sp, color: _tSec)),
        ])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(statusLabel, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: statusColor)),
        ),
      ]),
    );
  }
}

// ─── Withdrawals ───────────────────────────────────────────────────────────────

class _Withdrawals extends StatelessWidget {
  final AdminDashboardController c;
  const _Withdrawals({required this.c});

  @override
  Widget build(BuildContext context) {
    final withdrawals = c.withdrawals;
    if (withdrawals.isEmpty && !c.withdrawalsLoading) return const SizedBox.shrink();

    return _Section(
      title: 'Pending Withdrawals',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: _orange,
      child: c.withdrawalsLoading
          ? Padding(padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(child: CircularProgressIndicator(color: _orange, strokeWidth: 2)))
          : Column(children: withdrawals.map((w) => _WithdrawalCard(w: w, c: c)).toList()),
    );
  }
}

class _WithdrawalCard extends StatelessWidget {
  final WithdrawalItem w;
  final AdminDashboardController c;
  const _WithdrawalCard({required this.w, required this.c});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = c.actionLoading == w.id;
      return Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: _border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(w.trainerId,
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: _tPrim)),
              Text('${w.createdAt != null ? _fmt(w.createdAt!) : ''} · ${w.withdrawalMethod}',
                  style: TextStyle(fontSize: 11.sp, color: _tSec)),
            ])),
            Text('\$${w.amountDollars.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: _orange)),
          ]),
          SizedBox(height: 12.h),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: loading ? null : () => c.approve(w.id),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: loading
                    ? SizedBox(width: 16.w, height: 16.w,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('Approve', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: OutlinedButton(
                onPressed: loading ? null : () => c.reject(w.id),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFDC2626),
                  side: const BorderSide(color: Color(0xFFDC2626)),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: Text('Reject', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp)),
              ),
            ),
          ]),
        ]),
      );
    });
  }

  String _fmt(DateTime dt) => '${dt.month}/${dt.day}/${dt.year}';
}

// ─── Shared Section Wrapper ────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? trailing;
  const _Section({required this.title, required this.icon, required this.iconColor, required this.child, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: _border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, color: iconColor, size: 18.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: _tPrim))),
          if (trailing != null) trailing!,
        ]),
        SizedBox(height: 16.h),
        child,
      ]),
    );
  }
}

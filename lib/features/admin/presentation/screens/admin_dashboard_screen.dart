import 'package:pler_to_pler_app/core/themes/brand_colors.dart';
import 'package:pler_to_pler_app/core/helpers/toast_message_helper.dart';
import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/gym_brand_logo.dart';

// ─── App theme (matches AppColors exactly) ────────────────────────────────────

const _card       = Colors.white;
const _border     = Color(0xFFE5E7EB);

const _green      = Color(0xFF22C55E);
const _blue       = Color(0xFF3B82F6);
const _purple     = Color(0xFFA855F7);
const _pink       = Color(0xFFEC4899);
const _yellow     = Color(0xFFEAB308);
const _tPrim      = Color(0xFF000000);   // AppColors.textPrimary
const _tSec       = Color(0xFF7F7F7F);   // AppColors.textSecondary

/// Lets the "Review Withdrawal Requests" quick action scroll down to the
/// withdrawals section, which lives further down this same screen.
final _withdrawalsKey = GlobalKey();

void _scrollToWithdrawals() {
  final ctx = _withdrawalsKey.currentContext;
  // Null when the section is not built: _Withdrawals returns a shrunk box when
  // there is nothing pending, and the sliver may not have been laid out yet.
  if (ctx == null) {
    ToastMessageHelper.show('No withdrawal requests right now.');
    return;
  }
  Scrollable.ensureVisible(
    ctx,
    duration: const Duration(milliseconds: 400),
    curve: Curves.easeInOut,
    alignment: 0.1,
  );
}

void _notBuiltYet(String feature) =>
    ToastMessageHelper.show('$feature is not available yet.');

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<AdminDashboardController>()
        ? AdminDashboardController.to
        : Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          backgroundColor: _card,
          onRefresh: c.loadAll,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            // REACTIVITY NOTE — do not wrap these in Obx here.
            //
            // This list used to read:
            //     Obx(() => SliverToBoxAdapter(child: _KpiGrid(c: c)))
            // which looks reactive but is not. The closure only *constructs*
            // widgets; _KpiGrid.build() — where c.metrics is actually read —
            // runs later, in its own element, outside the window in which GetX
            // records observable reads. GetX therefore saw zero observables and
            // threw ObxError, whose ErrorWidget is a RenderBox. Sitting directly
            // in slivers:, that produced the hard failure
            //     "A RenderViewport expected a child of type RenderSliver but
            //      received a child of type RenderErrorBox"
            // and the whole Admin tab rendered as an error screen.
            //
            // Each section now owns its own Obx around a method that is CALLED
            // inside the closure, so the reads land where GetX can see them.
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 56)),
              SliverToBoxAdapter(child: _DashHeader(c: c)),
              SliverToBoxAdapter(child: _OnboardedGymsPill(c: c)),
              SliverToBoxAdapter(child: _KpiGrid(c: c)),
              SliverToBoxAdapter(child: _ActivityFeed(c: c)),
              SliverToBoxAdapter(child: _QuickActions(c: c)),
              SliverToBoxAdapter(child: _RevenueOverview(c: c)),
              SliverToBoxAdapter(child: _TrainerManagement(c: c)),
              SliverToBoxAdapter(child: _Withdrawals(key: _withdrawalsKey, c: c)),
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
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Icons.shield_rounded, color: Theme.of(context).colorScheme.primary, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          // Expanded, not a bare Column + Spacer: the title is unbounded text
          // between a fixed icon and a fixed refresh button, with nothing in the
          // Row able to yield, so it overflows rather than shrinking. It does so
          // under the widget test's font metrics today, and would do the same on
          // device at a large system text-scale setting or a narrower screen.
          // Expanded also does the Spacer's job of pushing the button to the end.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Admin Dashboard',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20.sp, fontWeight: AppFontWeight.section, color: _tPrim)),
                Text('P2P FitTech AI · Live',
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: _tSec)),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Obx(() => c.metricsLoading
              ? SizedBox(width: 18.w, height: 18.w,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Theme.of(context).colorScheme.primary))
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

// ─── Onboarded gyms ───────────────────────────────────────────────────────────


class _OnboardedGymsPill extends StatelessWidget {
  final AdminDashboardController c;
  const _OnboardedGymsPill({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
    final gyms = EnterpriseGymModel.activatedPartners
        .where((gym) => gym.tenantId != null &&
            c.onboardedGyms.containsKey(gym.tenantId))
        .toList();
    final status = c.onboardedGymsLoading
        ? 'Loading live gym data…'
        : c.onboardedGymsError
            ? 'Live gym data unavailable'
            : '${gyms.length} active partner gyms · Live';
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
      child: Material(color: Colors.transparent, child: InkWell(
        borderRadius: BorderRadius.circular(30.r),
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _OnboardedGymsSheet(c: c),
        ),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30.r), border: Border.all(color: _border), boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))]),
          child: Row(children: [
            Icon(Icons.apartment_rounded, color: Theme.of(context).colorScheme.primary, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gyms Onboarded', style: TextStyle(fontSize: 14.sp, fontWeight: AppFontWeight.section, color: _tPrim)),
              Text(status, style: TextStyle(fontSize: 10.sp, color: c.onboardedGymsError ? Colors.red.shade700 : _tSec)),
            ])),
            if (c.onboardedGymsLoading) SizedBox(width: 16.w, height: 16.w, child: const CircularProgressIndicator(strokeWidth: 2)) else Icon(Icons.keyboard_arrow_up_rounded, color: _tSec, size: 22.sp),
          ]),
        ),
      )),
    );
  });
}

class _OnboardedGymsSheet extends StatelessWidget {
  final AdminDashboardController c;
  const _OnboardedGymsSheet({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() {
    final gyms = EnterpriseGymModel.activatedPartners
        .where((gym) => gym.tenantId != null && c.onboardedGyms.containsKey(gym.tenantId))
        .toList();
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .78),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
      child: SafeArea(top: false, child: Padding(
        padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 24.h),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 42.w, height: 4.h, decoration: BoxDecoration(color: const Color(0xFFD1D5DB), borderRadius: BorderRadius.circular(4.r))),
          SizedBox(height: 16.h),
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Gyms Onboarded', style: TextStyle(fontSize: 22.sp, fontWeight: AppFontWeight.section, color: _tPrim)),
              Text(c.onboardedGymsError ? 'Live gym data unavailable' : 'Updated from the P2P backend', style: TextStyle(fontSize: 13.sp, color: c.onboardedGymsError ? Colors.red.shade700 : _tSec)),
            ])),
            IconButton(onPressed: c.onboardedGymsLoading ? null : c.fetchOnboardedGyms, icon: const Icon(Icons.refresh_rounded)),
            IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
          ]),
          SizedBox(height: 10.h),
          if (c.onboardedGymsLoading) const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())
          else if (c.onboardedGymsError) Padding(padding: EdgeInsets.all(24.w), child: const Text('Live counts could not be loaded. Pull to refresh the dashboard or try again.'))
          else Flexible(child: ListView.separated(
            shrinkWrap: true,
            itemCount: gyms.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, i) => _OnboardedGymCard(gym: gyms[i], stats: c.onboardedGyms[gyms[i].tenantId]!),
          )),
        ]),
      )),
    );
  });
}

class _OnboardedGymCard extends StatelessWidget {
  final EnterpriseGymModel gym;
  final OnboardedGymStats stats;
  const _OnboardedGymCard({required this.gym, required this.stats});

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(18.r),
    onTap: () => Get.toNamed(AppRoute.adminUserListScreen, arguments: {'filter': 'all', 'title': '${gym.name} Members', 'tenantId': gym.tenantId}),
    child: Ink(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r), border: Border.all(color: _border)),
      child: Column(children: [
        Row(children: [
          GymBrandLogo(gym: gym, size: 64.r, borderRadius: 10.r), SizedBox(width: 14.w),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(gym.name, style: TextStyle(fontSize: 17.sp, fontWeight: AppFontWeight.section, color: _tPrim)), Text(gym.address, maxLines: 2, style: TextStyle(fontSize: 12.sp, color: _tSec))])),
          Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h), decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20.r)), child: Text('Live', style: TextStyle(fontSize: 11.sp, fontWeight: AppFontWeight.label, color: const Color(0xFF16A34A)))),
          Icon(Icons.chevron_right_rounded, color: _tSec, size: 22.sp),
        ]),
        SizedBox(height: 16.h),
        Row(children: [
          _GymStat('${stats.members}', 'Members'), _GymStat('${stats.trainers}', 'Trainers'),
          _GymStat(stats.classes?.toString() ?? '—', 'Classes'), _GymStat('${stats.staff}', 'Staff'),
        ]),
      ]),
    ),
  );
}

class _GymStat extends StatelessWidget {
  final String value, label;
  const _GymStat(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: AppFontWeight.stat, color: _tPrim)), Text(label, style: TextStyle(fontSize: 10.sp, color: _tSec))]));
}

// ─── KPI Grid (2×3) ───────────────────────────────────────────────────────────

class _KpiGrid extends StatelessWidget {
  final AdminDashboardController c;
  const _KpiGrid({required this.c});

  // Obx(() => _content(context)): _content() is invoked inside the Obx builder, so the
  // c.metrics read below happens where GetX is recording. Obx(() => SomeWidget())
  // would not — see the note in AdminDashboardScreen.build.
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
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
      _KpiData(
        '👥', 'TOTAL TRAINERS', '$trainerCount', '+$weekNew this week',
        _blue, const Color(0xFFEFF6FF),
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'trainer', 'title': 'Trainers'}),
      ),
      _KpiData(
        '🏃', 'ACTIVE USERS', '$userCount', '+$todayNew today',
        _green, const Color(0xFFF0FDF4),
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'user', 'title': 'Active Users'}),
      ),
      _KpiData(
        '💰', 'ACTIVE SUBS', '$activeSubs', 'Paying members',
        Theme.of(context).colorScheme.primary, BrandColors.of(context).soft,
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'active_subs', 'title': 'Active Subscribers'}),
      ),
      _KpiData(
        '✅', 'VERIFIED', '$verified', 'Email confirmed',
        _purple, const Color(0xFFFAF5FF),
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'verified', 'title': 'Verified Accounts'}),
      ),
      _KpiData(
        '📊', 'NEW THIS WEEK', '$weekNew', 'Signups this week',
        _pink, const Color(0xFFFFF1F5),
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'week', 'title': 'New This Week'}),
      ),
      _KpiData(
        '📱', 'NEW TODAY', '$todayNew', 'Signups today',
        _yellow, const Color(0xFFFFFBEB),
        () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'today', 'title': 'New Today'}),
      ),
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
  final VoidCallback onTap;
  const _KpiData(
    this.emoji,
    this.label,
    this.value,
    this.sub,
    this.accent,
    this.bg,
    this.onTap,
  );
}

class _KpiCard extends StatelessWidget {
  final _KpiData d;
  const _KpiCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: d.onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Ink(
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
                // Stays at w700, unlike the rest of this screen: 9sp uppercase in a
                // tinted pill is micro-type, and the lighter scale stops it reading
                // as a badge. Same exception as the P2P and YOUR GYM badges.
                child: Text('LIVE', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w600, color: d.accent)),
              ),
            ]),
            SizedBox(height: 10.h),
            Text(d.value, style: TextStyle(fontSize: 24.sp, fontWeight: AppFontWeight.stat, color: d.accent)),
            SizedBox(height: 2.h),
            Text(d.label, style: TextStyle(fontSize: 10.sp, fontWeight: AppFontWeight.label, color: _tSec, letterSpacing: 0.5)),
            SizedBox(height: 2.h),
            Text(d.sub, style: TextStyle(fontSize: 10.sp, color: _tSec)),
          ]),
        ),
      ),
    );
  }
}

// ─── Live Activity Feed ────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  final AdminDashboardController c;
  const _ActivityFeed({required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final users = c.metrics?.recentUsers ?? [];
    final items = users.take(8).toList();

    return _Section(
      title: 'Live Activity Feed',
      icon: Icons.bolt_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
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
          child: Text(typeLabel, style: TextStyle(fontSize: 10.sp, fontWeight: AppFontWeight.label, color: typeColor)),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: AppFontWeight.label, color: _tPrim)),
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

  // This section reads c.withdrawals for its pending badge but was not reactive
  // before, so the badge kept whatever count it had at first build.
  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final pending = c.withdrawals.where((w) => w.status == 'pending').length;
    final actions = [
      _QaData('Approve Pending Trainers', pending > 0 ? '$pending pending' : null, _blue,
          () => Get.toNamed(AppRoute.adminUserListScreen, arguments: {'filter': 'trainer', 'title': 'Trainers'})),
      // Was an empty handler. The withdrawals list, with its approve/reject
      // buttons, is already on this screen — it just sits below the fold — so
      // this scrolls to it rather than needing a route of its own.
      _QaData('Review Withdrawal Requests', pending > 0 ? '$pending requests' : null,
          const Color(0xFFDC2626), _scrollToWithdrawals),
      _QaData('User Management', null, _purple,
          () => Get.toNamed(AppRoute.adminUserListScreen, arguments: {'filter': 'all', 'title': 'All Users'})),
      // These two have no backing feature anywhere in the app — no route, no
      // controller, no endpoint. They were empty handlers, so tapping them did
      // nothing at all and gave no feedback, which reads as the app being
      // broken. Saying so is the honest minimum until the feature exists;
      // building announcements or report export is not in this scope.
      _QaData('Send Platform Announcement', null, _green,
          () => _notBuiltYet('Platform announcements')),
      _QaData('Export Revenue Report', 'This month', Theme.of(context).colorScheme.primary,
          () => _notBuiltYet('Revenue export')),
    ];

    return _Section(
      title: 'Quick Actions',
      icon: Icons.flash_on_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
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
              style: TextStyle(fontSize: 14.sp, fontWeight: AppFontWeight.label, color: data.color))),
          if (data.badge != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(color: data.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20.r)),
              child: Text(data.badge!, style: TextStyle(fontSize: 11.sp, fontWeight: AppFontWeight.label, color: data.color)),
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
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
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
      _StatCard('ANNUAL PLANS',   '$annualCount',                   'Annual billing',   Theme.of(context).colorScheme.primary),
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
          Icon(Icons.bar_chart_rounded, color: Theme.of(context).colorScheme.primary, size: 16.sp),
          SizedBox(width: 6.w),
          Expanded(
            child: Text('Daily Signups · Last 7 days',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, fontWeight: AppFontWeight.section, color: _tPrim)),
          ),
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
                          Text('${d.count}', style: TextStyle(fontSize: 9.sp, color: _tSec, fontWeight: AppFontWeight.label)),
                          SizedBox(height: 3.h),
                          Container(
                            height: (80 * ratio).clamp(4.0, 80.0).h,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
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
        Text(s.value, style: TextStyle(fontSize: 22.sp, fontWeight: AppFontWeight.stat, color: s.color)),
        Text(s.label, style: TextStyle(fontSize: 9.5.sp, fontWeight: AppFontWeight.label, color: _tSec, letterSpacing: 0.4)),
        Text(s.sub, style: TextStyle(fontSize: 10.sp, color: _tSec)),
      ]),
    );
  }
}

// ─── Trainer Management ────────────────────────────────────────────────────────

class _TrainerManagement extends StatefulWidget {
  final AdminDashboardController c;
  const _TrainerManagement({required this.c});

  @override
  State<_TrainerManagement> createState() => _TrainerManagementState();
}

class _TrainerManagementState extends State<_TrainerManagement> {
  /// Local, matching the sub-filter chips on admin_user_list_screen.dart.
  ///
  /// These three pills used to be decorative: `active:` was hardcoded
  /// true/false and there was no `onTap` at all, so they rendered counts,
  /// always showed "All" as selected, and tapping them did nothing.
  String _filter = 'all';

  /// One predicate for both the count on a pill and the rows it shows, so the
  /// two cannot drift apart — a tab reading "5" over a list of 3 is precisely
  /// the bug that two independent expressions invite.
  bool _matches(RecentUser u, String f) {
    switch (f) {
      case 'active':    return u.isVerified && u.isSuspended != true;
      case 'pending':   return !u.isVerified;
      case 'suspended': return u.isSuspended == true;
      default:          return true;
    }
  }

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final c = widget.c;
    final allUsers = c.metrics?.recentUsers ?? [];
    final trainers = allUsers.where((u) => u.role == 'trainer').toList();
    final active  = trainers.where((u) => _matches(u, 'active')).length;
    final pending = trainers.where((u) => _matches(u, 'pending')).length;

    // Only offer Suspended once the payload actually carries the field — see
    // RecentUser.isSuspended. A tab reading 0 because we were never told is
    // worse than no tab at all.
    final knowsSuspension = trainers.any((u) => u.isSuspended != null);
    final suspended = trainers.where((u) => _matches(u, 'suspended')).length;

    final visible = trainers.where((u) => _matches(u, _filter)).toList();

    return _Section(
      title: 'Trainer Management',
      icon: Icons.people_alt_rounded,
      iconColor: _blue,
      trailing: GestureDetector(
        onTap: () => Get.toNamed(AppRoute.adminUserListScreen,
            arguments: {'filter': 'trainer', 'title': 'Trainers'}),
        child: Text('View All', style: TextStyle(fontSize: 12.sp, fontWeight: AppFontWeight.label, color: Theme.of(context).colorScheme.primary)),
      ),
      child: Column(children: [
        // Filter tabs. Three natural-width pills plus their counts have no room
        // to shrink, so the strip overflows once the labels or counts grow.
        // Scrolling it keeps the pills at their natural size rather than
        // squeezing the labels, and costs nothing when they already fit.
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: [
            _FilterTab(label: 'All', count: trainers.length,
                active: _filter == 'all',
                onTap: () => setState(() => _filter = 'all')),
            SizedBox(width: 8.w),
            _FilterTab(label: 'Active', count: active,
                active: _filter == 'active',
                onTap: () => setState(() => _filter = 'active')),
            SizedBox(width: 8.w),
            _FilterTab(label: 'Pending', count: pending, badge: true,
                active: _filter == 'pending',
                onTap: () => setState(() => _filter = 'pending')),
            if (knowsSuspension) ...[
              SizedBox(width: 8.w),
              _FilterTab(label: 'Suspended', count: suspended,
                  active: _filter == 'suspended',
                  onTap: () => setState(() => _filter = 'suspended')),
            ],
          ]),
        ),
        SizedBox(height: 14.h),
        // Column headers
        Row(children: ['TRAINER', 'STATUS'].map((h) => Expanded(
          child: Text(h, style: TextStyle(fontSize: 10.sp, fontWeight: AppFontWeight.label, color: _tSec, letterSpacing: 0.5)),
        )).toList()),
        Divider(color: _border, height: 16.h),
        if (visible.isEmpty)
          Padding(padding: EdgeInsets.symmetric(vertical: 20.h),
              child: Center(child: Text(
                  // Distinguish "no data at all" from "nothing matches this
                  // tab", so an empty Pending list does not read as the
                  // section having failed to load.
                  trainers.isEmpty
                      ? 'No trainers in recent data'
                      : 'No $_filter trainers',
                  style: TextStyle(color: _tSec, fontSize: 12.sp))))
        else
          ...visible.take(6).map((u) => _TrainerRow(user: u)),
      ]),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final int count;
  final bool active, badge;
  final VoidCallback? onTap;
  const _FilterTab({required this.label, required this.count, required this.active, this.badge = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: active ? Theme.of(context).colorScheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: active ? Theme.of(context).colorScheme.primary : _border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: AppFontWeight.label,
              color: active ? Colors.white : _tSec)),
          if (badge && count > 0) ...[
            SizedBox(width: 5.w),
            Container(width: 18.w, height: 18.w,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Center(child: Text('$count', style: TextStyle(fontSize: 10.sp, fontWeight: AppFontWeight.label, color: Colors.white)))),
          ] else if (!active && count > 0) ...[
            SizedBox(width: 5.w),
            Text('$count', style: TextStyle(fontSize: 11.sp, color: _tSec)),
          ],
        ]),
      ),
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
              style: TextStyle(fontSize: 13.sp, fontWeight: AppFontWeight.title, color: _tPrim)),
          Text('Joined $joined', style: TextStyle(fontSize: 10.sp, color: _tSec)),
        ])),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(statusLabel, style: TextStyle(fontSize: 11.sp, fontWeight: AppFontWeight.label, color: statusColor)),
        ),
      ]),
    );
  }
}

// ─── Withdrawals ───────────────────────────────────────────────────────────────

class _Withdrawals extends StatelessWidget {
  final AdminDashboardController c;
  const _Withdrawals({super.key, required this.c});

  @override
  Widget build(BuildContext context) => Obx(() => _content(context));

  Widget _content(BuildContext context) {
    final withdrawals = c.withdrawals;
    if (withdrawals.isEmpty && !c.withdrawalsLoading) return const SizedBox.shrink();

    return _Section(
      title: 'Pending Withdrawals',
      icon: Icons.account_balance_wallet_rounded,
      iconColor: Theme.of(context).colorScheme.primary,
      child: c.withdrawalsLoading
          ? Padding(padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary, strokeWidth: 2)))
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
                  style: TextStyle(fontSize: 14.sp, fontWeight: AppFontWeight.label, color: _tPrim)),
              Text('${w.createdAt != null ? _fmt(w.createdAt!) : ''} · ${w.withdrawalMethod}',
                  style: TextStyle(fontSize: 11.sp, color: _tSec)),
            ])),
            Text('\$${w.amountDollars.toStringAsFixed(0)}',
                style: TextStyle(fontSize: 18.sp, fontWeight: AppFontWeight.display, color: Theme.of(context).colorScheme.primary)),
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
                    : Text('Approve', style: TextStyle(fontWeight: AppFontWeight.label, fontSize: 13.sp)),
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
                child: Text('Reject', style: TextStyle(fontWeight: AppFontWeight.label, fontSize: 13.sp)),
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
          Expanded(child: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: AppFontWeight.display, color: _tPrim))),
          if (trailing != null) trailing!,
        ]),
        SizedBox(height: 16.h),
        child,
      ]),
    );
  }
}

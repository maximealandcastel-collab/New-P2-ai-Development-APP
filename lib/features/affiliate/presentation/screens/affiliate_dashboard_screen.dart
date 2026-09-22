import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/affiliate/presentation/controllers/affiliate_dashboard_controller.dart';

class AffiliateDashboardScreen extends StatelessWidget {
  const AffiliateDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Obx(() {
        final c = AffiliateDashboardController.to;
        if (c.loading && c.stats == null) {
          return Center(
            child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
          );
        }
        if (c.error.isNotEmpty && c.stats == null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.error, style: TextStyle(color: Colors.red.shade400, fontSize: 14.sp)),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: c.loadAll,
                  style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }
        final s = c.stats;
        return RefreshIndicator(
          color: Theme.of(context).colorScheme.primary,
          onRefresh: c.loadAll,
          child: CustomScrollView(
            slivers: [
              // ── App bar ──────────────────────────────────────────
              SliverAppBar(
                backgroundColor: const Color(0xFF0A0A0A),
                // Explicit, because this is the app's one near-black app bar.
                // AppBarTheme.foregroundColor is the light-background default
                // (it used to be white, which was invisible on every *other*
                // screen); without this override the back arrow here would be
                // black on black.
                foregroundColor: Colors.white,
                expandedHeight: 120.h,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Partner Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: AppFontWeight.section,
                        ),
                      ),
                      if (s != null)
                        Text(
                          'Code: ${s.promoCode}  ·  ${s.revenueSharePercent}% revenue share',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 10.sp,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    if (s != null) ...[
                      // ── Earnings cards ────────────────────────────────
                      _EarningsCard(stats: s),
                      SizedBox(height: 16.h),

                      // ── Referral stats ────────────────────────────────
                      _SectionHeader(title: 'Referral Stats'),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Expanded(child: _StatBox(label: 'Total Referred', value: '${s.totalReferrals}')),
                          SizedBox(width: 10.w),
                          Expanded(child: _StatBox(label: 'Paid Subscribers', value: '${s.paidReferrals}', accent: true)),
                        ],
                      ),
                      SizedBox(height: 20.h),

                      // ── Withdraw button ───────────────────────────────
                      _WithdrawButton(stats: s),
                      SizedBox(height: 24.h),

                      // ── Recent withdrawals ────────────────────────────
                      if (s.recentWithdrawals.isNotEmpty) ...[
                        _SectionHeader(title: 'Withdrawal History'),
                        SizedBox(height: 10.h),
                        ...s.recentWithdrawals.map((w) => _WithdrawalTile(w: w)),
                        SizedBox(height: 20.h),
                      ],

                      // ── Referral list ─────────────────────────────────
                      _SectionHeader(title: 'Your Referrals (${s.totalReferrals})'),
                      SizedBox(height: 10.h),
                    ],
                    if (c.referralsLoading && c.referrals.isEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary),
                        ),
                      )
                    else if (c.referrals.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 32.h),
                        child: Center(
                          child: Text(
                            'No referrals yet.\nShare your code: ${s?.promoCode ?? ''}',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14.sp, height: 1.6),
                          ),
                        ),
                      )
                    else
                      ...c.referrals.map((r) => _ReferralTile(referral: r)),
                  ]),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ── Earnings summary card ────────────────────────────────────────────────────
class _EarningsCard extends StatelessWidget {
  final AffiliateStats stats;
  const _EarningsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary.withOpacity(0.85), Theme.of(context).colorScheme.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: TextStyle(color: Colors.white70, fontSize: 13.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            '\$${stats.availableDollars.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36.sp,
              fontWeight: AppFontWeight.stat,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _EarningChip(label: 'Total Earned', value: '\$${stats.totalEarnedDollars.toStringAsFixed(2)}'),
              SizedBox(width: 12.w),
              _EarningChip(label: 'Total Paid Out', value: '\$${stats.totalWithdrawnDollars.toStringAsFixed(2)}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningChip extends StatelessWidget {
  final String label;
  final String value;
  const _EarningChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
            SizedBox(height: 2.h),
            Text(value, style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: AppFontWeight.section)),
          ],
        ),
      ),
    );
  }
}

// ── Withdraw button ──────────────────────────────────────────────────────────
class _WithdrawButton extends StatelessWidget {
  final AffiliateStats stats;
  const _WithdrawButton({required this.stats});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        icon: Icon(Icons.account_balance_wallet_outlined, size: 18.sp),
        label: Text(
          'Withdraw Earnings',
          style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label),
        ),
        onPressed: stats.availableToWithdrawCents < 500
            ? null
            : () => _showWithdrawSheet(context, stats),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade800,
          disabledForegroundColor: Colors.grey.shade500,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        ),
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context, AffiliateStats stats) {
    final amountController = TextEditingController();
    final emailController = TextEditingController();
    final methodVal = 'paypal'.obs;
    final loading = false.obs;
    final err = ''.obs;

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 32.h),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),
              Text(
                'Request Withdrawal',
                style: TextStyle(color: Colors.white, fontSize: 18.sp, fontWeight: AppFontWeight.section),
              ),
              SizedBox(height: 4.h),
              Text(
                'Available: \$${stats.availableDollars.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey.shade400, fontSize: 13.sp),
              ),
              SizedBox(height: 20.h),

              // Amount
              _SheetLabel('Amount (\$)'),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(color: Colors.white),
                decoration: _sheetInputDec(context, 'e.g. 50.00'),
              ),
              SizedBox(height: 14.h),

              // Method
              _SheetLabel('Payment Method'),
              Obx(() => DropdownButtonFormField<String>(
                value: methodVal.value,
                dropdownColor: const Color(0xFF2A2A2A),
                style: const TextStyle(color: Colors.white),
                decoration: _sheetInputDec(context, ''),
                items: const [
                  DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
                  DropdownMenuItem(value: 'zelle', child: Text('Zelle')),
                  DropdownMenuItem(value: 'cashapp', child: Text('Cash App')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                ],
                onChanged: (v) => methodVal.value = v ?? 'paypal',
              )),
              SizedBox(height: 14.h),

              // Payment email / handle
              _SheetLabel('PayPal / Zelle / Email'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: _sheetInputDec(context, 'your@email.com'),
              ),
              SizedBox(height: 8.h),

              Obx(() => err.value.isNotEmpty
                  ? Text(err.value, style: TextStyle(color: Colors.red.shade400, fontSize: 12.sp))
                  : const SizedBox.shrink()),
              SizedBox(height: 16.h),

              Obx(() => SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: loading.value ? null : () async {
                    err.value = '';
                    final raw = amountController.text.trim();
                    final dollars = double.tryParse(raw);
                    if (dollars == null || dollars <= 0) {
                      err.value = 'Enter a valid amount';
                      return;
                    }
                    final cents = (dollars * 100).round();
                    if (cents < 500) { err.value = 'Minimum withdrawal is \$5.00'; return; }
                    if (cents > stats.availableToWithdrawCents) {
                      err.value = 'Exceeds available balance'; return;
                    }
                    final email = emailController.text.trim();
                    if (email.isEmpty) { err.value = 'Enter payment email or handle'; return; }

                    loading.value = true;
                    final ok = await AffiliateDashboardController.to.requestWithdraw(
                      amountCents: cents,
                      paymentMethod: methodVal.value,
                      paymentEmail: email,
                    );
                    loading.value = false;
                    if (ok) {
                      Get.back();
                      Get.snackbar('✅ Submitted', 'Withdrawal request sent!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green.shade800,
                          colorText: Colors.white);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: loading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('Submit Request', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: AppFontWeight.section)),
                ),
              )),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  InputDecoration _sheetInputDec(BuildContext context, String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade600),
    filled: true,
    fillColor: const Color(0xFF2A2A2A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
    ),
    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
  );
}

class _SheetLabel extends StatelessWidget {
  final String text;
  const _SheetLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Text(text, style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
  );
}

// ── Referral tile ────────────────────────────────────────────────────────────
class _ReferralTile extends StatelessWidget {
  final AffiliateReferral referral;
  const _ReferralTile({required this.referral});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: referral.isPaid ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: referral.isPaid
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.grey.shade800,
            child: Text(
              referral.displayName.isNotEmpty ? referral.displayName[0].toUpperCase() : '?',
              style: TextStyle(
                color: referral.isPaid ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                fontWeight: AppFontWeight.section,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  referral.displayName,
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: AppFontWeight.label),
                ),
                Text(
                  referral.email,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: referral.isPaid
                      ? Colors.green.shade900.withOpacity(0.6)
                      : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  referral.subscriptionTier,
                  style: TextStyle(
                    color: referral.isPaid ? Colors.green.shade400 : Colors.grey.shade400,
                    fontSize: 10.sp,
                    fontWeight: AppFontWeight.label,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                _formatDate(referral.joinedAt),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 10.sp),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ── Withdrawal history tile ──────────────────────────────────────────────────
class _WithdrawalTile extends StatelessWidget {
  final AffiliateWithdrawal w;
  const _WithdrawalTile({required this.w});

  @override
  Widget build(BuildContext context) {
    final isPaid = w.status == 'paid';
    final isPending = w.status == 'pending';
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(
            isPaid ? Icons.check_circle : isPending ? Icons.hourglass_empty : Icons.cancel,
            color: isPaid ? Colors.green : isPending ? Colors.orange : Colors.red,
            size: 18.sp,
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\$${w.amountDollars.toStringAsFixed(2)} via ${w.paymentMethod}',
                  style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: AppFontWeight.label),
                ),
                Text(
                  w.paymentEmail,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11.sp),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: (isPaid
                  ? Colors.green.shade900
                  : isPending
                      ? Colors.orange.shade900
                      : Colors.red.shade900)
                  .withOpacity(0.5),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              w.status,
              style: TextStyle(
                color: isPaid ? Colors.green.shade300 : isPending ? Colors.orange.shade300 : Colors.red.shade300,
                fontSize: 10.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) => Text(
    title,
    style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: AppFontWeight.section),
  );
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;
  const _StatBox({required this.label, required this.value, this.accent = false});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: accent ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : const Color(0xFF1A1A1A),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: accent ? Theme.of(context).colorScheme.primary.withOpacity(0.4) : Colors.transparent),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade400, fontSize: 11.sp)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(color: Colors.white, fontSize: 22.sp, fontWeight: AppFontWeight.stat)),
      ],
    ),
  );
}

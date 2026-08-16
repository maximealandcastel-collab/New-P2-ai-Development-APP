import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/trainer/balance/data/models/balance_model.dart';
import 'package:pler_to_pler_app/features/trainer/balance/presentation/controllers/balance_controller.dart';

const _kOrange = Color(0xFFFF6B1A);
const _kDark   = Color(0xFF0E0E10);

// ─────────────────────────────────────────────────────────────────────────────
// Balance Dashboard View
// Embedded inside ClientsScreen when the Balance tab is selected.
// ─────────────────────────────────────────────────────────────────────────────
class BalanceDashboardView extends StatelessWidget {
  const BalanceDashboardView({super.key});

  BalanceController get ctrl {
    if (!Get.isRegistered<BalanceController>()) {
      Get.put(BalanceController());
    }
    return BalanceController.to;
  }

  @override
  Widget build(BuildContext context) {
    final controller = ctrl;
    return Obx(() {
      switch (controller.loadingState) {
        case LoadingState.loading:
        case LoadingState.initial:
          return _buildShimmer();
        case LoadingState.error:
        case LoadingState.offline:
          return _buildError(controller);
        case LoadingState.loaded:
          return _buildContent(context, controller);
      }
    });
  }

  // ── Shimmer ────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
      children: [
        _shimmerBox(180.h, radius: 20),
        SizedBox(height: 12.h),
        Row(children: List.generate(3, (_) =>
          Expanded(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: _shimmerBox(72.h, radius: 14),
          )))),
        SizedBox(height: 20.h),
        ...List.generate(4, (_) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _shimmerBox(64.h, radius: 14),
        )),
      ],
    );
  }

  Widget _shimmerBox(double height, {double radius = 12}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }

  // ── Error ──────────────────────────────────────────────────────
  Widget _buildError(BalanceController controller) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text('Could not load balance',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade500)),
          SizedBox(height: 12.h),
          ElevatedButton(
            onPressed: controller.fetchAll,
            style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange, shape: const StadiumBorder()),
            child: Text('Try again',
                style: TextStyle(color: Colors.white, fontSize: 13.sp)),
          ),
        ],
      ),
    );
  }

  // ── Main content ───────────────────────────────────────────────
  Widget _buildContent(BuildContext context, BalanceController controller) {
    final earnings = controller.earnings;
    if (earnings == null) return const SizedBox.shrink();

    return RefreshIndicator(
      color: _kOrange,
      onRefresh: controller.fetchAll,
      child: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 130.h),
        children: [
          _HeroBalanceCard(
            earnings: earnings,
            onWithdraw: () => _showWithdrawSheet(context, controller, earnings),
          ),
          SizedBox(height: 12.h),

          // ── Three stat tiles ───────────────────────────────────
          Row(
            children: [
              _StatTile(
                label: 'Available',
                value: earnings.availableFormatted,
                color: const Color(0xFF22C55E),
              ),
              SizedBox(width: 8.w),
              _StatTile(
                label: 'Pending',
                value: earnings.pendingFormatted,
                color: _kOrange,
              ),
              SizedBox(width: 8.w),
              _StatTile(
                label: 'This Month',
                value: controller.thisMonthFormatted,
                color: _kOrange,
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // ── Banner ─────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: _kOrange,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 18.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'P2P pays trainers directly. No hassle.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),

          // ── How it works steps ─────────────────────────────────
          Row(
            children: [
              _StepTile(step: '1', label: 'Client subscribes\nto your plan'),
              _StepTile(step: '2', label: 'P2P verifies\nfunds securely'),
              _StepTile(step: '3', label: 'You withdraw\ndirectly to bank', active: true),
            ],
          ),
          SizedBox(height: 24.h),

          // ── Subscriber list ────────────────────────────────────
          if (controller.subscribers.isNotEmpty) ...[
            Text(
              'Recent Payments',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),
            ...controller.subscribers.map((s) => _SubscriberRow(subscriber: s)),
          ] else
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 32.h),
                child: Text(
                  'No subscribers yet',
                  style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade400),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Withdraw bottom sheet ──────────────────────────────────────
  void _showWithdrawSheet(
    BuildContext context,
    BalanceController controller,
    TrainerEarningsModel earnings,
  ) {
    final amountCtrl = TextEditingController();
    final emailCtrl  = TextEditingController();
    final noteCtrl   = TextEditingController();
    final method     = 'paypal'.obs;
    final error      = ''.obs;
    const threshold  = 200000; // $2,000 in cents

    Get.bottomSheet(
      isScrollControlled: true,
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40.w, height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99.r),
                  ),
                ),
              ),

              Text('Request Withdrawal',
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800)),

              // >$2k warning (reactive on amount change)
              Obx(() {
                final raw = int.tryParse(amountCtrl.text
                    .replaceAll(',', '').replaceAll('\$', '').trim()) ?? 0;
                if (raw * 100 <= threshold) return const SizedBox.shrink();
                return Container(
                  margin: EdgeInsets.only(top: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: _kOrange.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline, color: _kOrange, size: 16.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Amounts over \$2,000 require admin approval before payout.',
                        style: TextStyle(fontSize: 12.sp, color: Colors.orange.shade800),
                      ),
                    ),
                  ]),
                );
              }),
              SizedBox(height: 16.h),

              // Amount
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  hintText: 'Max: ${earnings.availableFormatted}',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: _kOrange),
                  ),
                ),
                onChanged: (_) => error.value = '',
              ),
              SizedBox(height: 12.h),

              // Method selector
              Obx(() => Row(children: [
                _MethodChip(label: 'PayPal',  icon: Icons.paypal,           selected: method.value == 'paypal',        onTap: () => method.value = 'paypal'),
                SizedBox(width: 8.w),
                _MethodChip(label: 'Bank',    icon: Icons.account_balance,  selected: method.value == 'bank_transfer', onTap: () => method.value = 'bank_transfer'),
                SizedBox(width: 8.w),
                _MethodChip(label: 'Stripe',  icon: Icons.credit_card,      selected: method.value == 'stripe',        onTap: () => method.value = 'stripe'),
              ])),
              SizedBox(height: 12.h),

              // Payout email
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Payout email / account',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: _kOrange),
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // Note
              TextField(
                controller: noteCtrl,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
              ),

              // Error
              Obx(() => error.value.isEmpty
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(error.value,
                          style: TextStyle(color: Colors.red, fontSize: 12.sp)),
                    )),
              SizedBox(height: 16.h),

              // Submit
              Obx(() => SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                  ),
                  onPressed: controller.withdrawState == LoadingState.loading
                      ? null
                      : () async {
                          final raw = int.tryParse(amountCtrl.text
                              .replaceAll(',', '').replaceAll('\$', '').trim());
                          if (raw == null || raw <= 0) {
                            error.value = 'Enter a valid amount.';
                            return;
                          }
                          final cents = raw * 100;
                          if (cents > earnings.availableBalanceCents) {
                            error.value = 'Exceeds available balance (${earnings.availableFormatted}).';
                            return;
                          }
                          if (emailCtrl.text.trim().isEmpty) {
                            error.value = 'Enter a payout email.';
                            return;
                          }
                          final ok = await controller.requestWithdraw(
                            amountCents: cents,
                            method: method.value,
                            email: emailCtrl.text.trim(),
                            note: noteCtrl.text.trim(),
                          );
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              cents > threshold ? 'Pending Approval' : 'Withdrawal Submitted',
                              cents > threshold
                                  ? 'Your withdrawal is pending admin approval.'
                                  : 'Your withdrawal has been submitted.',
                              backgroundColor: _kOrange,
                              colorText: Colors.white,
                            );
                          } else {
                            error.value = 'Withdrawal failed. Please try again.';
                          }
                        },
                  child: controller.withdrawState == LoadingState.loading
                      ? SizedBox(
                          height: 20.h, width: 20.h,
                          child: const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                      : Text('Withdraw →',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800)),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _HeroBalanceCard extends StatelessWidget {
  final TrainerEarningsModel earnings;
  final VoidCallback onWithdraw;
  const _HeroBalanceCard({required this.earnings, required this.onWithdraw});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: _kDark,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(width: 8.w, height: 8.w,
                decoration: const BoxDecoration(color: _kOrange, shape: BoxShape.circle)),
            SizedBox(width: 6.w),
            Text('P2P Direct Pay™ · Available Balance',
                style: TextStyle(color: Colors.white60, fontSize: 11.sp, letterSpacing: 0.3)),
          ]),
          SizedBox(height: 10.h),
          Text(earnings.availableFormatted,
              style: TextStyle(color: Colors.white, fontSize: 42.sp,
                  fontWeight: FontWeight.w900, letterSpacing: -1)),
          if (earnings.pendingWithdrawalCents > 0) ...[
            SizedBox(height: 4.h),
            Text('+ ${earnings.pendingFormatted} pending · awaiting processing',
                style: TextStyle(color: Colors.white38, fontSize: 12.sp)),
          ],
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _kOrange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              onPressed: earnings.availableBalanceCents > 0 ? onWithdraw : null,
              child: Text('Withdraw ${earnings.availableFormatted} →',
                  style: TextStyle(color: Colors.white, fontSize: 15.sp,
                      fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatTile({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(children: [
          Text(value, style: TextStyle(color: color, fontSize: 15.sp, fontWeight: FontWeight.w800)),
          SizedBox(height: 4.h),
          Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 10.sp, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _StepTile extends StatelessWidget {
  final String step;
  final String label;
  final bool active;
  const _StepTile({required this.step, required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(children: [
        Container(
          width: 28.w, height: 28.w,
          decoration: BoxDecoration(
            color: active ? _kOrange : Colors.grey.shade200,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(step, style: TextStyle(
              color: active ? Colors.white : Colors.grey.shade600,
              fontSize: 12.sp, fontWeight: FontWeight.w700)),
        ),
        SizedBox(height: 6.h),
        Text(label, textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade600, height: 1.4)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SubscriberRow extends StatelessWidget {
  final TrainerSubscriberPaymentModel subscriber;
  const _SubscriberRow({required this.subscriber});

  @override
  Widget build(BuildContext context) {
    final initials = (subscriber.subscriberName?.isNotEmpty ?? false)
        ? subscriber.subscriberName!.split(' ').take(2)
            .map((w) => w.isNotEmpty ? w[0] : '').join().toUpperCase()
        : '?';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: _kOrange.withOpacity(0.12),
          backgroundImage: (subscriber.subscriberImage?.isNotEmpty ?? false)
              ? NetworkImage(subscriber.subscriberImage!) : null,
          child: (subscriber.subscriberImage?.isNotEmpty ?? false)
              ? null
              : Text(initials, style: TextStyle(color: _kOrange, fontSize: 12.sp, fontWeight: FontWeight.w700)),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(subscriber.subscriberName ?? 'Subscriber',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.black87)),
            SizedBox(height: 2.h),
            Text(_fmt(subscriber.createdAt),
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(subscriber.amountFormatted,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.black87)),
          SizedBox(height: 2.h),
          Text('Available', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600,
              color: const Color(0xFF22C55E))),
        ]),
      ]),
    );
  }

  String _fmt(DateTime d) {
    const m = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${m[d.month - 1]} ${d.day}';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _MethodChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _MethodChip({required this.label, required this.icon,
      required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? _kOrange.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
              color: selected ? _kOrange : Colors.grey.shade300,
              width: selected ? 1.5 : 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14.sp, color: selected ? _kOrange : Colors.grey.shade600),
          SizedBox(width: 4.w),
          Text(label, style: TextStyle(
              fontSize: 12.sp,
              color: selected ? _kOrange : Colors.grey.shade700,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    );
  }
}

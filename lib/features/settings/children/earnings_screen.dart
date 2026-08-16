import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/features/settings/children/invoices_screen.dart';
import 'package:pler_to_pler_app/features/settings/widgets/transation_history_widget.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({super.key});

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  bool _loading = true;
  String? _error;

  double _available = 0;
  double _pending   = 0;
  double _total     = 0;
  double _withdrawn = 0;

  List<Map<String, dynamic>> _history = [];

  // ── Withdraw dialog state ─────────────────────────────────────────────────
  final _amountCtrl  = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _noteCtrl    = TextEditingController();
  String _method     = 'paypal';
  bool   _submitting = false;
  String _withdrawError = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _emailCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<String> _token() async {
    final p = await SharedPreferences.getInstance();
    return p.getString('accessToken') ?? '';
  }

  Map<String, String> get _headers async => {};

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tok = await _token();
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $tok',
      };

      final base = ApiUrls.baseUrl;
      final results = await Future.wait([
        http.get(Uri.parse('$base/withdrawal/earnings'), headers: headers)
            .timeout(const Duration(seconds: 15)),
        http.get(Uri.parse('$base/withdrawal/my'), headers: headers)
            .timeout(const Duration(seconds: 15)),
      ]);

      final earningsRes  = results[0];
      final historyRes   = results[1];

      if (earningsRes.statusCode == 200) {
        final body = json.decode(earningsRes.body);
        final d    = body['data'] ?? body;
        _available = _cents(d['availableBalanceCents']);
        _pending   = _cents(d['pendingCents'] ?? d['totalWithdrawnCents'] ?? 0);
        _total     = _cents(d['totalEarnedCents']);
        _withdrawn = _cents(d['totalWithdrawnCents']);
      }

      if (historyRes.statusCode == 200) {
        final body = json.decode(historyRes.body);
        final list = body['data'] ?? body['withdrawals'] ?? [];
        _history = List<Map<String, dynamic>>.from(list is List ? list : []);
      }

      setState(() => _loading = false);
    } catch (e) {
      log('[EarningsScreen] load error: $e');
      setState(() { _loading = false; _error = 'Could not load earnings.\nTap to retry.'; });
    }
  }

  double _cents(dynamic v) => (v is num ? v.toDouble() : 0) / 100;

  // ── Withdraw ──────────────────────────────────────────────────────────────
  void _openWithdrawDialog() {
    _amountCtrl.clear();
    _emailCtrl.clear();
    _noteCtrl.clear();
    _method = 'paypal';
    _withdrawError = '';
    _submitting = false;

    Get.dialog(
      StatefulBuilder(builder: (ctx, setS) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: const Text('Request Withdrawal', style: TextStyle(fontWeight: FontWeight.w700)),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (USD)',
                  hintText: 'e.g. 50.00',
                  prefixText: '$ ',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 12.h),
              DropdownButtonFormField<String>(
                value: _method,
                decoration: InputDecoration(
                  labelText: 'Payment Method',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                items: const [
                  DropdownMenuItem(value: 'paypal',        child: Text('PayPal')),
                  DropdownMenuItem(value: 'stripe',        child: Text('Stripe')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer')),
                ],
                onChanged: (v) => setS(() => _method = v ?? 'paypal'),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Payment Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: _noteCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              if (_withdrawError.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Text(_withdrawError, style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: _submitting ? null : () => _submitWithdraw(setS),
              child: _submitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Submit', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  Future<void> _submitWithdraw(StateSetter setS) async {
    final amtStr = _amountCtrl.text.trim();
    final email  = _emailCtrl.text.trim();
    final amt    = double.tryParse(amtStr);

    if (amt == null || amt <= 0) {
      setS(() => _withdrawError = 'Enter a valid amount.');
      return;
    }
    if (amt > _available) {
      setS(() => _withdrawError = 'Amount exceeds your available balance ($${_available.toStringAsFixed(2)}).');
      return;
    }
    if (email.isEmpty || !email.contains('@')) {
      setS(() => _withdrawError = 'Enter a valid email.');
      return;
    }

    setS(() { _submitting = true; _withdrawError = ''; });

    try {
      final tok = await _token();
      final res = await http.post(
        Uri.parse('${ApiUrls.baseUrl}/withdrawal'),
        headers: { 'Content-Type': 'application/json', 'Authorization': 'Bearer $tok' },
        body: json.encode({
          'requestedAmountCents': (amt * 100).round(),
          'withdrawalMethod':     _method,
          'paymentEmail':         email,
          if (_noteCtrl.text.trim().isNotEmpty) 'additionalNote': _noteCtrl.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200 || res.statusCode == 201) {
        Get.back();
        Get.snackbar('Submitted', 'Withdrawal request sent. You will be notified once processed.',
          backgroundColor: AppColors.success, colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
        _load();
      } else {
        final body = json.decode(res.body);
        setS(() {
          _submitting = false;
          _withdrawError = body['message'] ?? 'Request failed. Try again.';
        });
      }
    } catch (e) {
      setS(() { _submitting = false; _withdrawError = 'Network error. Check your connection.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        title: 'Earnings',
        actions: [
          GestureDetector(
            onTap: () => Get.to(() => const InvoicesScreen()),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Icon(Icons.receipt_long_outlined),
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? GestureDetector(
                  onTap: _load,
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.refresh_rounded, size: 40, color: Colors.grey),
                      SizedBox(height: 12.h),
                      Text(_error!, textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                    ]),
                  ),
                )
              : CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Available balance ─────────────────────────
                            Center(
                              child: CustomText(
                                text: 'Available balance',
                                fontWeight: FontWeight.w500,
                                fontSize: 16.sp,
                                color: AppColors.textSecondary,
                                bottom: 8.h,
                                top: 24.h,
                              ),
                            ),
                            Center(
                              child: Text(
                                '$${_available.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 40.sp,
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // ── Stats row ─────────────────────────────────
                            Row(children: [
                              Expanded(child: _statCard('Total Earned', _total, AppColors.success)),
                              SizedBox(width: 10.w),
                              Expanded(child: _statCard('Withdrawn', _withdrawn, Colors.orange)),
                            ]),
                            SizedBox(height: 10.h),

                            // ── Pending card ──────────────────────────────
                            CustomContainer(
                              width: double.infinity,
                              radiusAll: 16.r,
                              color: Colors.white,
                              paddingAll: 18.r,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomText(
                                    text: 'Pending balance',
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  Text(
                                    '$${_pending.toStringAsFixed(2)} USD',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── History header ────────────────────────────
                            CustomText(
                              text: 'Withdrawal History',
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                              bottom: 4.h,
                              top: 24.h,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── History list ──────────────────────────────────────
                    _history.isEmpty
                        ? SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                              child: Center(
                                child: CustomText(
                                  text: 'No withdrawal requests yet.',
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : SliverPadding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) {
                                  final w = _history[i];
                                  final amtCents = w['requestedAmountCents'] ?? 0;
                                  final status   = w['status'] ?? 'pending';
                                  final method   = w['withdrawalMethod'] ?? '';
                                  final created  = w['createdAt'] ?? '';
                                  return TransactionHistoryWidget(
                                    amount:    '$${(amtCents / 100).toStringAsFixed(2)}',
                                    label:     _methodLabel(method),
                                    subtitle:  _formatDate(created),
                                    status:    status,
                                    isCredit:  false,
                                  );
                                },
                                childCount: _history.length,
                              ),
                            ),
                          ),

                    SliverToBoxAdapter(child: SizedBox(height: 30.h)),
                  ],
                ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CustomButton(
            onPressed: _available > 0 ? _openWithdrawDialog : null,
            label: _available > 0 ? 'Withdraw' : 'No balance to withdraw',
            width: double.infinity,
          ),
        ),
      ),
    );
  }

  Widget _statCard(String label, double value, Color color) {
    return CustomContainer(
      width: double.infinity,
      radiusAll: 16.r,
      color: Colors.white,
      paddingAll: 14.r,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        CustomText(text: label, fontSize: 12.sp, color: AppColors.textSecondary),
        SizedBox(height: 4.h),
        Text('$${value.toStringAsFixed(2)}',
            style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 18.sp)),
      ]),
    );
  }

  String _methodLabel(String method) {
    switch (method) {
      case 'paypal':        return 'PayPal';
      case 'stripe':        return 'Stripe';
      case 'bank_transfer': return 'Bank Transfer';
      default:              return method;
    }
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.month}/${dt.day}/${dt.year}';
    } catch (_) { return iso; }
  }
}

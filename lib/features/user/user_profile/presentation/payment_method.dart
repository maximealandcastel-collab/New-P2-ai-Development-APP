import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/user_profile/widgets/shared_appbar.dart';
// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 3 — PAYMENT METHODS
// ═══════════════════════════════════════════════════════════════════════════════

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  int _selectedMethod = 0;
  final TextEditingController _emailCtrl =
  TextEditingController(text: 'maximecastel@gmail.com');

  final List<_PayMethod> _methods = const [
    _PayMethod(name: 'paypal', icon: Icons.paypal, color: Color(0xFF003087)),
    _PayMethod(name: 'Apple Pay', icon: Icons.apple, color: Colors.black),
    _PayMethod(name: 'Google Pay', icon: Icons.g_mobiledata, color: Color(0xFF4285F4)),
    _PayMethod(name: 'Wire transfer', icon: Icons.account_balance, color: Colors.black54),
  ];

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            SharedAppBar(title: 'Payment Methods'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payout method',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                    SizedBox(height: 12.h),

                    // Payment method list
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        children: _methods.asMap().entries.map((e) {
                          final isLast = e.key == _methods.length - 1;
                          return _PaymentMethodTile(
                            method: e.value,
                            isSelected: _selectedMethod == e.key,
                            showDivider: !isLast,
                            onTap: () => setState(() => _selectedMethod = e.key),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // Payoneer section
                    Text('Payoneer detail',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                    SizedBox(height: 12.h),

                    Text('Payment mail',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                    SizedBox(height: 8.h),

                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.mail_outline, size: 18.sp, color: Colors.black54),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextField(
                              controller: _emailCtrl,
                              style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                              decoration: const InputDecoration.collapsed(hintText: 'Payment email'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),

                    // Save button
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('Save',
                            style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PayMethod {
  final String name;
  final IconData icon;
  final Color color;

  const _PayMethod({required this.name, required this.icon, required this.color});
}

class _PaymentMethodTile extends StatelessWidget {
  final _PayMethod method;
  final bool isSelected;
  final bool showDivider;
  final VoidCallback onTap;

  const _PaymentMethodTile({
    required this.method,
    required this.isSelected,
    required this.showDivider,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
            child: Row(
              children: [
                Container(
                  width: 38.w, height: 38.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(method.icon, size: 20.sp, color: method.color),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(method.name,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black)),
                ),
                // Radio button
                Container(
                  width: 22.w, height: 22.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.black : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                    child: Container(
                      width: 10.w, height: 10.h,
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 16.w, endIndent: 16.w, color: Colors.grey.shade100),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/user_profile/data/invoice_models.dart';
import 'package:pler_to_pler_app/features/user/user_profile/widgets/shared_appbar.dart';

import 'invoice_preview.dart';


// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — INVOICES LIST
// ═══════════════════════════════════════════════════════════════════════════════

class UserInvoicesScreen extends StatelessWidget {
  const UserInvoicesScreen({super.key});

  static const _invoices = [
    InvoiceItem(
      title: 'Full recover',
      client: 'Carter Jameson',
      billedAgo: 'Billed 5 days ago',
      amount: 249.99,
      status: InvoiceStatus.paid,
    ),
    InvoiceItem(
      title: 'Regular training',
      client: 'Ethan Hawthorne',
      billedAgo: 'Billed 2 days ago',
      amount: 128.00,
      status: InvoiceStatus.pending,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SharedAppBar(title: 'Invoices'),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                'Available Invoices',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: Colors.black),
              ),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _invoices.length,
                itemBuilder: (_, i) => _InvoiceCard(
                  item: _invoices[i],
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const UsersInvoicePreviewScreen()),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceCard extends StatelessWidget {
  final InvoiceItem item;
  final VoidCallback onTap;

  const _InvoiceCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPaid = item.status == InvoiceStatus.paid;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40.w, height: 40.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Icons.receipt_long_outlined, size: 20.sp, color: Colors.black54),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black)),
                      SizedBox(height: 3.h),
                      Text('${item.client} · ${item.billedAgo}',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                _StatusBadge(isPaid: isPaid),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(color: Colors.grey.shade100, height: 1),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total billed',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
                Text(
                  '\$${item.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1565C0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isPaid;

  const _StatusBadge({required this.isPaid});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isPaid ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isPaid ? const Color(0xFF4CAF50) : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPaid) ...[
            Icon(Icons.check_circle, size: 11.sp, color: const Color(0xFF4CAF50)),
            SizedBox(width: 4.w),
          ],
          Text(
            isPaid ? 'Paid' : 'Pending',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: isPaid ? const Color(0xFF4CAF50) : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}







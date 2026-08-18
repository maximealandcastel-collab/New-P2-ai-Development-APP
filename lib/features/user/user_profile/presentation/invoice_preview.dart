import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/user/user_profile/data/invoice_models.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/payment_method.dart';
import 'package:pler_to_pler_app/features/user/user_profile/widgets/shared_appbar.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 2 — INVOICE PREVIEW
// ═══════════════════════════════════════════════════════════════════════════════

class UsersInvoicePreviewScreen extends StatelessWidget {
  const UsersInvoicePreviewScreen({super.key});

  static const _lineItems = [
    LineItem(
      description: 'Physical therapy session',
      subtitle: 'Total 8 hr × \$26/hr',
      amount: 120,
      isBold: true,
    ),
    LineItem(
      description: 'Paired staff',
      subtitle: 'Supervision 4 hr × \$10/hr',
      amount: 68,
      isBold: true,
    ),
    LineItem(description: 'Subtotal', amount: 184.00),
    LineItem(description: 'Adjustment', amount: 0.00, isNegative: true),
    LineItem(
      description: 'Paired staff',
      amount: 184.00,
      isBold: true,
      isHighlighted: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            SharedAppBar(title: 'Invoice preview'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                child: Column(
                  children: [
                    // Invoice card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Orange top accent
                          Container(
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.all(16.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  children: [
                                    Container(
                                      width: 44.w, height: 44.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(10.r),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: Icon(Icons.fitness_center, size: 22.sp, color: Colors.black54),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text('P2P fitTech',
                                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700)),
                                          Text('Center for wellness',
                                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('INV-2456-524',
                                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
                                        Text('Dec 26, 2025',
                                            style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16.h),

                                // Billing info grid
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8F8F8),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _InfoLabel('Billing to'),
                                            _InfoValue('Ethan Carter'),
                                            SizedBox(height: 10.h),
                                            _InfoLabel('Service Period'),
                                            _InfoValue('Dec 15 - Dec 24'),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            _InfoLabel('Patient ID'),
                                            _InfoValue('150-250-5420'),
                                            SizedBox(height: 10.h),
                                            _InfoLabel('Care type'),
                                            _InfoValue('Rehab'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),

                                // Line items header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Description',
                                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                                    Text('Amount',
                                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
                                  ],
                                ),
                                SizedBox(height: 10.h),
                                Divider(color: Colors.grey.shade100, height: 1),
                                SizedBox(height: 10.h),

                                // Line items
                                ..._lineItems.map((item) => _LineItemRow(item: item)),
                                SizedBox(height: 14.h),

                                // Disclaimer
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE3F2FD),
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(Icons.info_outline, size: 14.sp, color: const Color(0xFF1565C0)),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          'This invoice is a service summary generated by P2P FitTech. This is not a direct insurance claim document. Please contact your facility administrator for official tax documents.',
                                          style: TextStyle(fontSize: 11.sp, color: const Color(0xFF1565C0), height: 1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Scalloped bottom edge
                          _ScallopedEdge(),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Download invoice
                    GestureDetector(
                      onTap: () {},
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Download invoice',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                          SizedBox(width: 8.w),
                          Icon(Icons.download_outlined, size: 18.sp, color: Colors.black87),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),

                    // Pay now
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PaymentMethodsScreen()),
                      ),
                      child: Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00),
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Pay now',
                                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w700)),
                            SizedBox(width: 8.w),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 18.sp),
                          ],
                        ),
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

class _InfoLabel extends StatelessWidget {
  final String text;
  const _InfoLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400),
  );
}

class _InfoValue extends StatelessWidget {
  final String text;
  const _InfoValue(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87),
  );
}

class _LineItemRow extends StatelessWidget {
  final LineItem item;

  const _LineItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: item.isBold ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.black87,
                  ),
                ),
                if (item.subtitle.isNotEmpty)
                  Text(item.subtitle,
                      style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
              ],
            ),
          ),
          Text(
            item.isNegative
                ? '-\$${item.amount.toStringAsFixed(2)}'
                : '\$${item.amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: item.isBold ? FontWeight.w600 : FontWeight.w400,
              color: item.isHighlighted
                  ? const Color(0xFF1565C0)
                  : item.isNegative
                  ? const Color(0xFF4CAF50)
                  : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

// Scalloped / zigzag edge at bottom of invoice
class _ScallopedEdge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 18.h,
      child: CustomPaint(
        size: Size(double.infinity, 18.h),
        painter: _ScallopPainter(),
      ),
    );
  }
}

class _ScallopPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF2F2F2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);

    final scallopWidth = 18.0;
    final scallops = (size.width / scallopWidth).ceil();

    for (int i = 0; i < scallops; i++) {
      final x = i * scallopWidth;
      path.arcToPoint(
        Offset(x + scallopWidth, 0),
        radius: const Radius.circular(9),
        clockwise: false,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
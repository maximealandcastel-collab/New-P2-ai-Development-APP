import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/payment_success_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({super.key, required this.paymentUrl});

  final String paymentUrl;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  final RxBool _isLoading = true.obs;
  bool _handled = false;

  /// Called only once the page has fully loaded, so the server-side
  /// `payment-success` page can complete its verification / activation
  /// before we leave the webview.
  void _handleLoadedUrl(String? url) {
    if (url == null || _handled) return;

    if (url.contains('payment-success')) {
      _handled = true;
      Get.off(() => const PaymentSuccessScreen());
    } else if (url.contains('payment-cancel')) {
      _handled = true;
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      paddingSide: 0,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.paymentUrl)),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                  ),
                  onLoadStart: (controller, url) {
                    _isLoading.value = true;
                  },
                  onLoadStop: (controller, url) {
                    _isLoading.value = false;
                    _handleLoadedUrl(url?.toString());
                  },
                ),
                Obx(
                  () => _isLoading.value
                      ? Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: Icon(Icons.close, size: 24.sp, color: Colors.black),
          ),
          SizedBox(width: 12.w),
          Icon(Icons.lock_outline, size: 18.sp, color: AppColors.textSecondary),
          SizedBox(width: 6.w),
          CustomText(
            text: 'Secure Payment',
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }
}

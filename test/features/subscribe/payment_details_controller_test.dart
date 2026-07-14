import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/payment_details_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PaymentDetailsController controller;

  setUp(() {
    controller = PaymentDetailsController();
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<PaymentDetailsController>();
  });

  group('PaymentDetailsController Tests', () {
    test('initial state has correct default values', () {
      expect(controller.selectedIndex, 0);
      expect(controller.isPurchasing, isFalse);
    });

    test('onChange updates selectedIndex correctly', () {
      controller.onChange(1);
      expect(controller.selectedIndex, 1);
    });
  });
}

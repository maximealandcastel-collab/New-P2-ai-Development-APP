import 'package:get/get.dart';

class BottomNavBarController extends GetxController {

  static BottomNavBarController get to => Get.find();

  RxInt _selectedIndex = 0.obs;

  int get selectedIndex => _selectedIndex.value;

  void onChange(int index) {
    _selectedIndex.value = index;
  }
}

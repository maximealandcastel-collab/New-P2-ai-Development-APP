import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/domain/services/auth_services.dart';

class SubscribeController extends GetxController {
  final AuthService _service;

  static SubscribeController get to => Get.find();

  SubscribeController({required AuthService service}) : _service = service;

  final RxInt _selected = 0.obs;

  final RxInt _selectedIndex = 0.obs;

  int get selected => _selected.value;

  int get selectedIndex => _selectedIndex.value;

  set selected(int val) => _selected.value = val;

  void onChange(int index) {
    _selectedIndex.value = index;
  }
}

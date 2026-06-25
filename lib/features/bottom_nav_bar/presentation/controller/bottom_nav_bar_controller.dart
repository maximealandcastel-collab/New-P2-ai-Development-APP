import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/authentication/presentation/controllers/login_controller.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_item_model.dart';

class BottomNavBarController extends GetxController {
  static BottomNavBarController get to => Get.find();

  final RxInt _selectedIndex = 0.obs;
  int get selectedIndex => _selectedIndex.value;

  List<NavItemModel> get navItems =>
      LoginController.to.isTrainer()
          ? NavItemModel.trainerNavItems
          : NavItemModel.userNavItems;

  List<NavFabModel> get fabItems =>
      LoginController.to.isTrainer()
          ? NavFabModel.trainerFabItems
          : NavFabModel.userFabItems;

  static const int contentsTabIndex = 2;

  void onChange(int index) {
    _selectedIndex.value = index;
  }

  void goToContentsTab() {
    _selectedIndex.value = contentsTabIndex;
  }

  void resetIndex() {
    _selectedIndex.value = 0;
  }
}
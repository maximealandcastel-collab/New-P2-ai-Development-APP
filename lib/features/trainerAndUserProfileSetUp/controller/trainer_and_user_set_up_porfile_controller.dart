import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/about_you_input_widget.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/date_of_brith_input_widget.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/gender_input_widget.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/name_input_widgets.dart';
import 'package:p2p_fitness/features/trainerAndUserProfileSetUp/presentation/widgets/profile_img_input_widget.dart';

class TrainerAndUserSetUpPorfileController extends GetxController {
  final currentIndex = 0.obs;
  final List<Widget> pageList = [
    NameInputWidgets(),
    DateOfBrithInputWidget(),
    GenderInputWidget(),
    ProfileImgInputWidget(),
    AboutYouInputWidget(),
  ];

  void tapNext() {
    if (currentIndex.value < 4) {
      currentIndex.value++;
      log("Index ${currentIndex.value}");
    } else {
      log("Go to next page");
    }
  }

  void tapBack() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
      log("Index ${currentIndex.value}");
    } else {
      log("No page found!");
    }
  }

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final aboutYouController = TextEditingController();


  // for date of birth
  final months = <String>[
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  final days = List.generate(31, (index) => index + 1);

  final years = List.generate(100, (index) => DateTime.now().year - index);

  RxInt selectedMonth = 0.obs;
  RxInt selectedDay = 0.obs;
  RxInt selectedYear = 0.obs;

  // for gender selection
  final selectedGender = "Male".obs;
  void changeGender(value) {
    selectedGender.value = value;
    log(selectedGender.value);
  }

  // for pick img
  final ImagePicker _picker = ImagePicker();

  final selectedImage = "".obs;

  /// Pick image from camera or gallery
  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      selectedImage.value = image.path;
    }
  }
}

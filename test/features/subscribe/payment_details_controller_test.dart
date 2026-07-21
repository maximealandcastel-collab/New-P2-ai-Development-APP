import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/features/profile/data/models/user_model.dart';
import 'package:pler_to_pler_app/features/profile/domain/services/profile_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/iap_verify_result_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/payment_details_controller.dart';

class _FakeSubscribeServices implements SubscribeServices {
  @override
  Future<List<FindTrainerModel>> fetchMorePolls(int offset, int limit) async =>
      [];

  @override
  Future<void> fetchPolls(int currentPage, int limit, {String? search}) async {}

  @override
  List<FindTrainerModel> getCachedTrainers() => [];

  @override
  bool hasCache() => false;

  @override
  Future<TrainerDetailsModel> trainerDetails(String trainerId) {
    throw UnimplementedError();
  }

  @override
  Future<void> trainerRequest({
    required String trainerId,
    required String note,
  }) async {}

  @override
  Future<IapVerifyResultModel> verifyIap({
    required String platform,
    required String productId,
    required String purchaseId,
    required String verificationData,
  }) async {
    return const IapVerifyResultModel(isSubscribed: true);
  }
}

class _FakeProfileService implements ProfileService {
  @override
  Future<void> fetchUserProfile() async {}

  @override
  Future<void> fetchTrainerProfile() async {}

  @override
  UserModel? getCachedUserData() => null;

  @override
  TrainerDetailsModel? getCachedTrainerProfile() => null;

  @override
  bool hasCache() => false;

  @override
  bool hasTrainerCache() => false;

  @override
  Future<String> resolveInitialRoute({
    bool? isProfileCompleted,
    bool? isSubscribed,
  }) async =>
      '/';

  @override
  Future<UserModel> updateUserProfile(Map<String, dynamic> data) async =>
      UserModel();

  @override
  Future<UserModel> uploadCoverPhoto(File file) async => UserModel();

  @override
  Future<UserModel> uploadProfilePicture(File file) async => UserModel();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late PaymentDetailsController controller;

  setUp(() {
    controller = PaymentDetailsController(
      subscribeService: _FakeSubscribeServices(),
      profileService: _FakeProfileService(),
    );
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<PaymentDetailsController>();
  });

  group('PaymentDetailsController Tests', () {
    test('initial state has correct default values', () {
      expect(controller.selectedIndex, 0);
      expect(controller.purchaseLoadingState, LoadingState.initial);
    });

    test('onChange updates selectedIndex correctly', () {
      controller.onChange(1);
      expect(controller.selectedIndex, 1);
    });
  });
}

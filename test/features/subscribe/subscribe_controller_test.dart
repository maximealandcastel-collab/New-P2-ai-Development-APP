import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/controllers/subscribe_controller.dart';
import 'package:pler_to_pler_app/features/subscribe/domain/services/subscribe_services.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/repositories/subscribe_repository.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/trainer_details_model.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/default_checkout_model.dart';

class FakeSubscribeRepository implements SubscribeRepository {
  @override
  bool hasCache() => false;
  
  @override
  List<FindTrainerModel> getCachedTrainers() => [];
  
  @override
  Future<void> getTrainers(int currentPage, int limit, {String? search}) async {}
  
  @override
  Future<List<FindTrainerModel>> fetchMoreTrainer(int offset, int limit) async => [];
  
  @override
  Future<TrainerDetailsModel> trainerDetails(String trainerId) async {
    throw UnimplementedError();
  }
  
  @override
  Future<void> trainerRequest({required String trainerId, required String note}) async {}
  
  @override
  Future<DefaultCheckoutModel> createDefaultCheckout({required String tier, String? promoCode}) async {
    throw UnimplementedError();
  }
}

class FakeSubscribeServices extends SubscribeServices {
  FakeSubscribeServices() : super(repository: FakeSubscribeRepository());

  @override
  List<FindTrainerModel> getCachedTrainers() => [];

  @override
  Future<void> fetchPolls(int currentPage, int limit, {String? search}) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SubscribeController controller;
  late FakeSubscribeServices services;
  late ConnectivityService connectivityService;

  setUp(() {
    services = FakeSubscribeServices();
    connectivityService = ConnectivityService();
    controller = SubscribeController(
      service: services,
      connectivityService: connectivityService,
    );
    Get.put(controller);
  });

  tearDown(() {
    Get.delete<SubscribeController>();
  });

  group('SubscribeController IAP Integration Tests', () {
    test('initial state has correct default values', () {
      expect(controller.selectedIndex, 0);
    });

    test('onChange updates selectedIndex correctly', () {
      controller.onChange(1);
      expect(controller.selectedIndex, 1);
    });
  });
}

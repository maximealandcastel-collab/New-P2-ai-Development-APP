import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/settings/data/models/earnings_model.dart';
import 'package:pler_to_pler_app/features/settings/data/models/payment_transaction_model.dart';
import 'package:pler_to_pler_app/features/settings/domain/services/earnings_service.dart';

class EarningsController extends GetxController with PaginatedLoaderUi {
  EarningsController({
    required EarningsService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final EarningsService _service;
  final ConnectivityService _connectivityService;

  static EarningsController get to => Get.find();

  final Rx<LoadingState> _earningsState = LoadingState.initial.obs;
  final Rx<LoadingState> _paymentsState = LoadingState.initial.obs;

  LoadingState get earningsState => _earningsState.value;
  LoadingState get paymentsState => _paymentsState.value;

  final RxBool isFirstTimePaymentsLoad = true.obs;

  final Rxn<EarningsModel> _earnings = Rxn<EarningsModel>();
  EarningsModel? get earnings => _earnings.value;

  late final PaginatedList<PaymentTransactionModel> paymentsList;
  List<PaymentTransactionModel> get payments => paymentsList.items;
  ScrollController? get scrollController => paymentsList.scrollController;

  @override
  LoadingState get paginationContentState => paymentsState;

  @override
  PaginatedList<dynamic> get paginatedList => paymentsList;

  @override
  void onInit() {
    super.onInit();
    
    paymentsList = PaginatedList<PaymentTransactionModel>(
      limit: 20,
      fetchPage: _fetchPaymentsPage,
    );
    paymentsList.initScroll();

    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) {
        loadEarnings();
        loadPayments();
      }
    });

    loadEarnings();
    loadPayments();
  }

  Future<List<PaymentTransactionModel>> _fetchPaymentsPage(int page, int limit) async {
    if (page == 1) {
      await _service.getPayments(page: page, limit: limit);
      return _service.getCachedPayments();
    }
    return _service.getPayments(page: page, limit: limit);
  }

  Future<void> loadEarnings() async {
    final hasUsableCache = _service.hasEarningsCache();
    final isOnline = _connectivityService.isConnected.value;

    if (hasUsableCache) {
      _earnings.value = _service.getCachedEarnings();
      _earningsState.value = LoadingState.loaded;
    } else {
      _earningsState.value = LoadingState.loading;
    }

    if (!isOnline) {
      if (!hasUsableCache) {
        _earningsState.value = LoadingState.offline;
      }
      return;
    }

    try {
      final data = await _service.getEarnings();
      _earnings.value = data;
      _earningsState.value = LoadingState.loaded;
    } catch (e) {
      if (!hasUsableCache) {
        _earningsState.value = LoadingState.error;
      }
      if (kDebugMode) {
        debugPrint('EarningsController loadEarnings error: $e');
      }
    }
  }

  Future<void> loadPayments({bool showFullLoader = true}) async {
    final hasUsableCache = _service.hasPaymentsCache();
    final isOnline = _connectivityService.isConnected.value;

    if (showFullLoader) {
      if (hasUsableCache) {
        paymentsList.items.value = _service.getCachedPayments();
        _paymentsState.value = LoadingState.loaded;
        isFirstTimePaymentsLoad.value = false;
      } else {
        paymentsList.items.clear();
        _paymentsState.value = LoadingState.loading;
        isFirstTimePaymentsLoad.value = true;
      }
    }

    if (!isOnline) {
      if (!hasUsableCache) {
        _paymentsState.value = LoadingState.offline;
      }
      return;
    }

    try {
      await paymentsList.loadFirst();
      _paymentsState.value = LoadingState.loaded;
      isFirstTimePaymentsLoad.value = false;
    } catch (e) {
      if (!hasUsableCache) {
        _paymentsState.value = LoadingState.error;
      }
      if (kDebugMode) {
        debugPrint('EarningsController loadPayments error: $e');
      }
    }
  }

  @override
  Future<void> refresh() async {
    await Future.wait([
      loadEarnings(),
      paymentsList.refreshWith(() => loadPayments(showFullLoader: false)),
    ]);
  }

  @override
  void onClose() {
    paymentsList.dispose();
    super.onClose();
  }
}

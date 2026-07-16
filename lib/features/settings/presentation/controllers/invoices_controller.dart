import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/features/settings/domain/services/invoices_service.dart';
import 'package:pler_to_pler_app/features/settings/presentation/children/invoice_preview_screen.dart';
import 'package:pler_to_pler_app/features/settings/presentation/controllers/invoice_preview_controller.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';

class InvoicesController extends GetxController with PaginatedLoaderUi {
  InvoicesController({
    required InvoicesService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final InvoicesService _service;
  final ConnectivityService _connectivityService;

  static InvoicesController get to => Get.find();

  final RxInt _selectedTab = 0.obs;
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  int get selectedTab => _selectedTab.value;
  LoadingState get loadingState => _loadingState.value;
  List<ClientInvoiceModel> get invoices => invoicesList.items;

  String? get _status {
    switch (selectedTab) {
      case 1:
        return 'paid';
      case 2:
        return 'sent';
      default:
        return null;
    }
  }

  late final PaginatedList<ClientInvoiceModel> invoicesList;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => invoicesList;

  @override
  void onInit() {
    super.onInit();
    invoicesList = PaginatedList<ClientInvoiceModel>(
      limit: 10,
      fetchPage: _fetchInvoicesPage,
    );
    invoicesList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<ClientInvoiceModel>> _fetchInvoicesPage(int page, int limit) async {
    _service.updateFilters(status: _status);

    if (page == 1) {
      await _service.fetchInvoices(page, limit);
      return _service.getCachedInvoices();
    }
    return _service.fetchMoreInvoices(page, limit);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      _service.updateFilters(status: _status);

      final cached = _service.getCachedInvoices();
      final hasUsableCache = cached.isNotEmpty;
      final isOnline = _connectivityService.isConnected.value;

      if (showFullLoader) {
        if (hasUsableCache) {
          invoicesList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          invoicesList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasUsableCache) _loadingState.value = LoadingState.offline;
        return;
      }

      try {
        await invoicesList.loadFirst();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasUsableCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch invoices error: $e');
      }
    } catch (e) {
      final cached = _service.getCachedInvoices();
      if (cached.isNotEmpty) {
        invoicesList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected invoices error: $e');
    }
  }

  void onTabSelected(int index) {
    if (_selectedTab.value == index) return;
    _selectedTab.value = index;
    _loadData();
  }

  void onInvoiceTap(ClientInvoiceModel invoice) {
    Get.to(
      () => InvoicePreviewScreen(invoice: invoice),
      binding: BindingsBuilder(() {
        Get.put(InvoicePreviewController(invoice: invoice));
      }),
    );
  }

  @override
  Future<void> refresh() =>
      invoicesList.refreshWith(() => _loadData(showFullLoader: false));

  @override
  void onClose() {
    invoicesList.dispose();
    super.onClose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/services/paginated_loader_ui.dart';
import 'package:pler_to_pler_app/core/services/search_service.dart';
import 'package:pler_to_pler_app/features/trainer/clients/data/models/client_invoice_model.dart';
import 'package:pler_to_pler_app/features/trainer/clients/domain/services/client_service.dart';

class ClientsController extends GetxController with PaginatedLoaderUi {
  ClientsController({
    required ClientService service,
    required ConnectivityService connectivityService,
  })  : _service = service,
        _connectivityService = connectivityService;

  final ClientService _service;
  final ConnectivityService _connectivityService;

  static ClientsController get to => Get.find();

  final searchController = TextEditingController();
  final RxInt _selectedTab = 0.obs;
  final Rx<LoadingState> _loadingState = LoadingState.initial.obs;

  int get selectedTab => _selectedTab.value;
  LoadingState get loadingState => _loadingState.value;
  List<ClientInvoiceModel> get clients => clientsList.items;
  ScrollController? get scrollController => clientsList.scrollController;

  String get _status => selectedTab == 0 ? 'paid' : 'sent';

  late final PaginatedList<ClientInvoiceModel> clientsList;
  late final SearchService<ClientInvoiceModel> search;

  @override
  LoadingState get paginationContentState => loadingState;

  @override
  PaginatedList<dynamic> get paginatedList => clientsList;

  @override
  void onInit() {
    super.onInit();
    clientsList = PaginatedList<ClientInvoiceModel>(
      limit: 10,
      fetchPage: _fetchClientsPage,
    );
    search = SearchService(fetcher: _fetchSearch);
    clientsList.initScroll();
    ever(_connectivityService.isConnected, (isConnected) {
      if (isConnected) _loadData();
    });
    _loadData();
  }

  Future<List<ClientInvoiceModel>> _fetchClientsPage(int page, int limit) async {
    _service.updateFilters(
      status: _status,
      search: searchController.text.trim(),
    );

    if (page == 1) {
      await _service.fetchInvoices(page, limit);
      return _service.getCachedInvoices();
    }
    return _service.fetchMoreInvoices(page, limit);
  }

  Future<void> _loadData({bool showFullLoader = true}) async {
    try {
      _service.updateFilters(
        status: _status,
        search: searchController.text.trim(),
      );

      final cached = _service.getCachedInvoices();
      final hasUsableCache = cached.isNotEmpty;
      final isOnline = _connectivityService.isConnected.value;

      if (showFullLoader) {
        if (hasUsableCache) {
          clientsList.items.value = cached;
          _loadingState.value = LoadingState.loaded;
        } else {
          clientsList.items.clear();
          _loadingState.value = LoadingState.loading;
        }
      }

      if (!isOnline) {
        if (!hasUsableCache) _loadingState.value = LoadingState.offline;
        return;
      }

      try {
        await clientsList.loadFirst();
        _loadingState.value = LoadingState.loaded;
      } on AppException catch (e) {
        if (!hasUsableCache) _loadingState.value = LoadingState.error;
        if (kDebugMode) debugPrint('Fetch clients error: $e');
      }
    } catch (e) {
      final cached = _service.getCachedInvoices();
      if (cached.isNotEmpty) {
        clientsList.items.value = cached;
        _loadingState.value = LoadingState.loaded;
      } else {
        _loadingState.value = LoadingState.error;
      }
      if (kDebugMode) debugPrint('Unexpected clients error: $e');
    }
  }

  void onTabSelected(int index) {
    if (_selectedTab.value == index) return;
    _selectedTab.value = index;
    _loadData();
  }

  Future<List<ClientInvoiceModel>> _fetchSearch(String query) async {
    final fromCache = _service
        .getCachedInvoices()
        .where(
          (invoice) =>
              invoice.clientName.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    if (fromCache.isNotEmpty) return fromCache;
    if (!_connectivityService.isConnected.value) return [];

    _service.updateFilters(status: _status, search: query);
    await _service.fetchInvoices(1, 20);
    return _service.getCachedInvoices();
  }

  void applySearchQuery(String query) {
    searchController.text = query;
    _loadData(showFullLoader: false);
  }

  void onClientTap(ClientInvoiceModel invoice) {
    Get.toNamed(AppRoute.clientDetailsScreen, arguments: invoice);
  }

  void onChatTap(ClientInvoiceModel invoice) {
    Get.toNamed(AppRoute.chatScreen);
  }

  @override
  Future<void> refresh() =>
      clientsList.refreshWith(() => _loadData(showFullLoader: false));

  @override
  void onClose() {
    clientsList.dispose();
    searchController.dispose();
    super.onClose();
  }
}

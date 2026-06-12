import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';

class SearchHistoryController extends GetxController {

  final CacheService _cacheService;

  SearchHistoryController({
    required CacheService cacheService,
  }) : _cacheService = cacheService;

  static SearchHistoryController get to => Get.find();

   final int _maxItems = 10;

  final RxList<String> history = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    final saved = _cacheService.get<List>(ApiConstants.searchHistoryKey, defaultValue: []);
    history.assignAll(saved?.cast<String>() ?? []);
  }

  Future<void> addQuery(String query) async {
    final q = query.trim();
    if (q.isEmpty) return;

    history.remove(q);
    history.insert(0, q);
    if (history.length > _maxItems) history.removeRange(_maxItems, history.length);

    await _cacheService.put(ApiConstants.searchHistoryKey, history.toList());
  }

  Future<void> removeQuery(String query) async {
    history.remove(query);
    await _cacheService.put(ApiConstants.searchHistoryKey, history.toList());
  }

  Future<void> clearAll() async {
    history.clear();
    await _cacheService.delete(ApiConstants.searchHistoryKey);
  }
}
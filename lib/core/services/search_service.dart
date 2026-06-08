import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class SearchService<T> {
  SearchService({required this.fetcher});

  final Future<List<T>> Function(String query) fetcher;

  final RxList<T> results = <T>[].obs;
  final RxBool isActive = false.obs;
  final RxBool isLoading = false.obs;

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      clear();
      return;
    }

    isActive.value = true;
    isLoading.value = true;

    try {
      results.value = await fetcher(q);
    } catch (e) {
      results.clear();
      if (kDebugMode) debugPrint('SearchService error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void clear() {
    results.clear();
    isActive.value = false;
  }
}

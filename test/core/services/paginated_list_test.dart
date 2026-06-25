import 'package:flutter_test/flutter_test.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PaginatedList', () {
    late PaginatedList<int> list;
    int fetchCount = 0;

    setUp(() {
      fetchCount = 0;
      list = PaginatedList<int>(
        limit: 10,
        postRefreshSuppressMs: 50,
        fetchPage: (page, limit) async {
          fetchCount++;
          if (page == 1) {
            return List<int>.generate(10, (i) => i);
          }
          return List<int>.generate(5, (i) => i + 10);
        },
      );
      list.initScroll();
    });

    tearDown(() {
      list.dispose();
    });

    test('refresh resets page and clears isLoadingMore', () async {
      await list.loadFirst();
      expect(list.items.length, 10);
      expect(list.isLoadingMore.value, isFalse);

      await list.refreshList();

      expect(list.items.length, 10);
      expect(list.isLoadingMore.value, isFalse);
      expect(list.isRefreshing.value, isFalse);
      expect(list.hasMore.value, isTrue);
    });

    test('refresh does not auto-trigger load more', () async {
      await list.loadFirst();

      await list.refreshList();
      await Future<void>.delayed(const Duration(milliseconds: 100));

      expect(list.isLoadingMore.value, isFalse);
      expect(list.items.length, 10);
      expect(fetchCount, 2);
    });

    test('canLoadMore is false while refreshing', () async {
      list.isRefreshing.value = true;
      list.hasMore.value = true;
      list.isLoadingMore.value = false;

      expect(list.canLoadMore, isFalse);
    });
  });
}

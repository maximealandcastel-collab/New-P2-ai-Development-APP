import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/features/search/controller/search_controller.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/widgets/custom_search_theme.dart';
import 'package:pler_to_pler_app/features/search/widgets/search_item_empty.dart';
import 'package:pler_to_pler_app/features/search/widgets/search_list_item.dart';


class SearchScreen extends SearchDelegate {
  SearchScreen({
    this.hintText = 'Search here . . .',
    this.onResultTap,
    required this.onSearch,
  });

  final String hintText;
  final void Function(SearchModel selectedItem)? onResultTap;
  final Future<List<SearchModel>> Function(String query) onSearch;

  SearchHistoryController get _ctrl => SearchHistoryController.to;

  @override
  String get searchFieldLabel => hintText;

  @override
  ThemeData appBarTheme(BuildContext context) =>
      CustomSearchTheme.instance.appBarTheme;

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isEmpty) return [];
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios,size: 20.r),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _ctrl.addQuery(query);
    return SearchListItem(
      query: query,
      onSearch: onSearch,
      onResultTap: onResultTap,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.trim().isEmpty) {
      return SearchItemEmpty(
        onItemTap: (q) {
          query = q;
          showResults(context);
        },
      );
    }
    return SearchListItem(
      query: query,
      onSearch: onSearch,
      onResultTap: (item) {
        _ctrl.addQuery(query);
        onResultTap?.call(item);
      },
    );
  }
}


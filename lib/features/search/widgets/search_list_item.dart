import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/widgets/search_item.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SearchListItem extends StatelessWidget {
  const SearchListItem({
    super.key,
    required this.query,
    required this.onSearch,
    this.onResultTap,
  });

  final String query;
  final Future<List<SearchModel>> Function(String query) onSearch;
  final void Function(SearchModel selectedItem)? onResultTap;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<List<SearchModel>>(
      future: onSearch(query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CustomText(
              text: 'Searching...',
              color: Colors.grey.shade400,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 56.r, color: Colors.grey.shade300),
                SizedBox(height: 12.h),
                CustomText(text:
                  snapshot.error.toString(),
                      fontSize: 14.sp, color: Colors.grey.shade400),
              ],
            ),
          );
        }

        final results = snapshot.data ?? [];
        if (results.isEmpty) return _buildNoResult();
        return SearchItem(
          results: results,
          onTap: onResultTap,
        );
      },
    );
  }

  Widget _buildNoResult() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 56.r, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          CustomText(text:
            'No result for "$query"',
                fontSize: 14.sp, color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }
}
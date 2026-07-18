import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/search/controller/search_controller.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class SearchItemEmpty extends StatelessWidget {
  const SearchItemEmpty({super.key, required this.onItemTap});

  final void Function(String query) onItemTap;

  SearchHistoryController get _ctrl => SearchHistoryController.to;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final history = _ctrl.history;
      if (history.isEmpty) return _buildEmpty();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          Expanded(child: _buildList(history)),
        ],
      );
    });
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, size: 48.r, color: Colors.grey.shade300),
          SizedBox(height: 10.h),
          CustomText(
            text: 'No recent searches',
            fontSize: 14.sp,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomText(
            text: 'Recent Searches',
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
          TextButton(
            onPressed: _ctrl.clearAll,
            child: CustomText(
              text: 'Clear All',
              fontSize: 12.sp,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<String> history) {
    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, _) =>
          Divider(height: 1, indent: 16.w, endIndent: 16.w,thickness: 0.1,),
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          minTileHeight: 30.h,
          contentPadding: EdgeInsets.symmetric(vertical: 0,horizontal: 16.h),
          leading: Icon(Icons.history, size: 20.r, color: Colors.grey.shade400),
          title: Text(item, style: TextStyle(fontSize: 14.sp)),
          trailing: IconButton(
            icon: Icon(Icons.close, size: 18.r, color: Colors.grey.shade400),
            onPressed: () => _ctrl.removeQuery(item),
          ),
          onTap: () => onItemTap(item),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  int selectedTab = 0; // 0: All clients, 1: Pending

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        FeedAppBarSliver(
          pinned: true,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(116.h),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w,0,16.w,8.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomSearchField(hintText: 'Search by name or condition'),

                  SizedBox(height: 12.h),

                  CustomContainer(
                    radiusAll: 14.r,
                    color: Colors.white,
                    paddingAll: 4.r,
                    child: Row(
                      children: [
                        _buildTabItem('Paid', 0),
                        _buildTabItem('Invoice sent', 1),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0 ,16.w, 130.h),
          sliver: SliverList.builder(
            itemCount: 20,
            itemBuilder: (context, index) {
              return ClientCardWidget();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, int index) {
    bool isSelected = selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedTab = index),

        child: CustomContainer(
          radiusAll: 12.r,

          paddingVertical: 12.h,

          color: isSelected ? Colors.black : Colors.transparent,

          alignment: Alignment.center,

          child: CustomText(
            text: label,

            fontSize: 14.sp,

            fontWeight: FontWeight.w600,

            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }
}

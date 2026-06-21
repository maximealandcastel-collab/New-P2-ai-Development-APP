import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/screens/clients_details_screen.dart';
import 'package:pler_to_pler_app/features/trainer/clients/presentation/widgets/client_card_widget.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final TextEditingController searchController = TextEditingController();
  int selectedTab = 0; // 0: All clients, 1: Pending

  final List<Map<String, String>> clientList = [
    {
      'name': 'Oliver Westwood',
      'subtitle': 'Last Session 12 hour ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Throbbing discomfort in the lumbar region',
      'insight': 'Try gentle stretches or heat to ease lower back pain.',
      'message':
          "I've been experiencing a nagging pain in my lower back, and I'm eager to get back to moving freely and feeling great.",
    },
    {
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight':
          'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message':
          "There's a persistent ache in my lower back, and I hope we can address it soon.",
    },{
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight':
          'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message':
          "There's a persistent ache in my lower back, and I hope we can address it soon.",
    },{
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight':
          'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message':
          "There's a persistent ache in my lower back, and I hope we can address it soon.",
    },{
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight':
          'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message':
          "There's a persistent ache in my lower back, and I hope we can address it soon.",
    },{
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight':
          'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message':
          "There's a persistent ache in my lower back, and I hope we can address it soon.",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const FeedAppBarSliver(),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            children: [
              SizedBox(height: 10.h),
              CustomSearchField(
                hintText: 'Search by name or condition',
              ),

              SizedBox(height: 12.h),

              CustomContainer(
                radiusAll: 14.r,
                color: Colors.white,
                paddingAll: 4.r,
                child: Row(
                  children: [
                    _buildTabItem('All clients', 0),
                    _buildTabItem('Pending (2)', 1),
                  ],
                ),
              ),

              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                // Horizontal padding set to 0 because the Parent Body has 16.w
                padding: EdgeInsets.only(top: 12.h, bottom: 80.h),
                itemCount: clientList.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () =>
                        Get.to(() => ClientDetailsScreen(client: clientList[index])),
                    child: ClientCardWidget(
                      client: clientList[index],
                      isPending: selectedTab == 1,
                      onAccept: () {},
                      onReject: () {},
                      onChat: () {},
                    ),
                  );
                },
              )

            ],
          ),
        ).asSliver,
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

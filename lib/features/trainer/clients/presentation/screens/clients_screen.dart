import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../custom_assets/assets.gen.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_container.dart';
import '../../../../../widgets/custom_image_avatar.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';
import '../../../../../widgets/custom_text_field.dart';
import '../../../../common/notification/presentation/screen/notification_screen.dart';
import '../../../../profile/profile_screen.dart';
import '../widgets/client_card_widget.dart';
import 'chat_screen.dart';
import 'clients_details_screen.dart';

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
      'message': "I've been experiencing a nagging pain in my lower back, and I'm eager to get back to moving freely and feeling great.",
      'isPending': 'true',
    },
    {
      'name': 'Mason Prescott',
      'subtitle': 'Last session 3 days ago',
      'pendingSubtitle': 'Pending client',
      'condition': 'Dull ache in the lower spine',
      'insight': 'Consider gentle applying heat to relieve the dull ache in your lower spine.',
      'message': "There's a persistent ache in my lower back, and I hope we can address it soon.",
      'isPending': 'true',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      appBar: CustomAppBar(
        titleWidget: Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CustomImageAvatar(
                image: 'https://picsum.photos/300',
                radius: 20.r,
                showBorder: true,
              ),
              title: Row(
                children: [
                  CustomText(
                    fontWeight: FontWeight.w600,
                    fontSize: 17.sp,
                    text: 'Hi Maxime!!',
                  ),
                  SizedBox(width: 6.w),
                  _buildOnlineBadge(),
                ],
              ),
              subtitle: CustomText(
                textAlign: TextAlign.start,
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                text: 'Let’s Manage your users',
              ),
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 4.w),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    Get.to(() => NotificationsScreen());
                  },
                  icon: Assets.icons.notification.svg(height: 42.r, width: 42.r),
                ),
                Positioned(
                  right: 10.w,
                  top: 12.h,
                  child: Container(
                    padding: EdgeInsets.all(3.r),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: CustomText(
                      text: '5',
                      color: Colors.white,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Wrapped the entire content in Padding for side-to-side consistency
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w),
        child: Column(
          children: [
            SizedBox(height: 12.h),

            // Search Bar (Padding removed here since it's in the body parent)
            CustomTextField(
              controller: searchController,
              hintText: 'Search by name or condition',
              prefixIcon: Icon(Icons.search, color: Colors.grey, size: 22.r),
              borderRadio: 12,
              contentPaddingHorizontal: 12.w,
            ),

            SizedBox(height: 12.h),

            // Custom Tab Toggle
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

            // Client List
            Expanded(
              child: clientList.isEmpty
                  ? const Center(child: _EmptyClientsView())
                  : _buildClientList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
    final visibleClients = selectedTab == 1
        ? clientList.where((client) => client['isPending'] == 'true').toList()
        : clientList;
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      // Horizontal padding set to 0 because the Parent Body has 16.w
      padding: EdgeInsets.only(top: 12.h, bottom: 80.h),
      itemCount: visibleClients.length,
      itemBuilder: (context, index) {
        final client = visibleClients[index];
        return GestureDetector(
          onTap: () => Get.to(() => ClientDetailsScreen(client: client)),
          child: ClientCardWidget(
            client: client,
            isPending: selectedTab == 1,
            onAccept: () {
              setState(() => client['isPending'] = 'false');
              Get.snackbar('Client accepted', '${client['name']} is now an active client.');
            },
            onReject: () {
              setState(() => clientList.remove(client));
              Get.snackbar('Request declined', '${client['name']} was removed from pending requests.');
            },
            onChat: () => Get.to(
              () => const ChatScreen(),
              arguments: ChatScreenArgs(
                displayName: client['name'] ?? 'Client',
                subtitle: 'client',
              ),
            ),
          ),
        );
      },
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

  Widget _buildOnlineBadge() {
    return CustomContainer(
      paddingHorizontal: 8.w,

      radiusAll: 100.r,

      bordersColor: AppColors.textSecondary.withOpacity(0.2),

      child: Row(
        mainAxisSize: MainAxisSize.min,

        children: [
          Icon(Icons.circle, color: Colors.green, size: 10.r),

          CustomText(text: 'Online', fontSize: 12.sp, left: 4.w),
        ],
      ),
    );
  }
}

class _EmptyClientsView extends StatelessWidget {
  const _EmptyClientsView();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomContainer(
          height: 100.r,
          width: 100.r,
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.06),
          child: Icon(
            Icons.person_add_alt_1,
            size: 40.r,
            color: Colors.black45,
          ),
        ),
        SizedBox(height: 24.h),
        CustomText(
          text: 'No clients found',
          fontSize: 18.sp,
          color: Colors.black45,
          fontWeight: FontWeight.w500,
        ),
      ],
    );
  }
}

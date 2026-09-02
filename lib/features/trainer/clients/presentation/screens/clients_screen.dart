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
import '../../../../../services/api_urls.dart';
import '../../../../../services/network/api_client.dart';
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
  List<Map<String, String>> activeClients = [];
  List<Map<String, String>> pendingClients = [];
  bool isLoading = true;
  String? loadError;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        loadError = null;
      });
    }

    final results = await Future.wait([
      ApiClient.getData(ApiUrls.trainerClients),
      ApiClient.getData('/trainer-request/incoming?limit=100'),
    ]);
    if (!mounted) return;

    final activeResponse = results[0];
    final pendingResponse = results[1];
    final activeData =
        activeResponse.body is Map ? activeResponse.body['data'] : null;
    final pendingData =
        pendingResponse.body is Map ? pendingResponse.body['data'] : null;

    if (activeResponse.statusCode == 200 && activeData is List) {
      activeClients = activeData
          .whereType<Map>()
          .map(_mapActiveClient)
          .toList();
    }
    if (pendingResponse.statusCode == 200 && pendingData is List) {
      pendingClients = pendingData
          .whereType<Map>()
          .map(_mapPendingClient)
          .toList();
    }

    setState(() {
      isLoading = false;
      if (activeResponse.statusCode != 200 ||
          (pendingResponse.statusCode != 200 &&
              pendingResponse.statusCode != 404)) {
        loadError = 'Client data could not be refreshed.';
      }
    });
  }

  Map<String, String> _mapActiveClient(Map raw) {
    return {
      'id': '${raw['id'] ?? ''}',
      'name': '${raw['name'] ?? 'Unnamed client'}',
      'subtitle': raw['joinedAt'] == null
          ? 'Active client'
          : 'Active since ${_dateLabel('${raw['joinedAt']}')}',
      'profilePicture': '${raw['profilePicture'] ?? ''}',
      'condition': '',
      'insight': '',
      'message': '',
      'isPending': 'false',
    };
  }

  Map<String, String> _mapPendingClient(Map raw) {
    final user = raw['userId'] is Map ? Map.from(raw['userId']) : const {};
    final fullName = '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
    return {
      'id': '${user['_id'] ?? ''}',
      'requestId': '${raw['_id'] ?? ''}',
      'name': '${user['fullName'] ?? fullName}'.trim().isEmpty
          ? 'Unnamed client'
          : '${user['fullName'] ?? fullName}'.trim(),
      'subtitle': 'Pending client',
      'pendingSubtitle': 'Pending client',
      'profilePicture': '${user['profilePicture'] ?? ''}',
      'condition': '${user['primaryGoal'] ?? ''}',
      'insight': '',
      'message': '${raw['note'] ?? ''}',
      'isPending': 'true',
    };
  }

  String _dateLabel(String value) {
    final parsed = DateTime.tryParse(value);
    if (parsed == null) return value.split('T').first;
    return '${parsed.month}/${parsed.day}/${parsed.year}';
  }

  List<Map<String, String>> get _visibleClients {
    final clients = selectedTab == 1 ? pendingClients : activeClients;
    final search = searchController.text.trim().toLowerCase();
    if (search.isEmpty) return clients;
    return clients
        .where((client) =>
            (client['name'] ?? '').toLowerCase().contains(search) ||
            (client['condition'] ?? '').toLowerCase().contains(search))
        .toList();
  }

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
              onChanged: (_) => setState(() {}),
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
                  _buildTabItem('Pending (${pendingClients.length})', 1),
                ],
              ),
            ),

            // Client List
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : loadError != null && activeClients.isEmpty
                      ? _buildErrorView()
                      : _visibleClients.isEmpty
                          ? const Center(child: _EmptyClientsView())
                          : _buildClientList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      // Horizontal padding set to 0 because the Parent Body has 16.w
      padding: EdgeInsets.only(top: 12.h, bottom: 80.h),
      itemCount: _visibleClients.length,
      itemBuilder: (context, index) {
        final client = _visibleClients[index];
        return GestureDetector(
          onTap: () => Get.to(() => ClientDetailsScreen(client: client)),
          child: ClientCardWidget(
            client: client,
            isPending: selectedTab == 1,
            onAccept: () => _respondToRequest(client, accept: true),
            onReject: () => _respondToRequest(client, accept: false),
            onChat: () => Get.to(
              () => const ChatScreen(),
              arguments: ChatScreenArgs(
                displayName: client['name'] ?? 'Client',
                subtitle: 'client',
                otherUserId: client['id'],
                otherUserImage: client['profilePicture'],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _respondToRequest(
    Map<String, String> client, {
    required bool accept,
  }) async {
    final requestId = client['requestId'];
    if (requestId == null || requestId.isEmpty) return;

    final response = await ApiClient.patchData(
      '/trainer-request/$requestId/${accept ? 'accept' : 'reject'}',
      accept ? const {} : {'rejectionReason': 'Not a fit at this time.'},
    );
    if (!mounted) return;
    if (response.statusCode == 200) {
      Get.snackbar(
        accept ? 'Client accepted' : 'Request declined',
        accept
            ? '${client['name']} is now an active client.'
            : '${client['name']} was removed from pending requests.',
      );
      await _loadClients();
      return;
    }

    Get.snackbar(
      'Could not update request',
      response.statusText ?? 'Please try again.',
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 42, color: Colors.black45),
          SizedBox(height: 12.h),
          const Text('Client data is unavailable'),
          TextButton(onPressed: _loadClients, child: const Text('Retry')),
        ],
      ),
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

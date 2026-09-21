import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../core/themes/app_typography.dart';
import '../../../../../core/utils/constants/app_colors.dart';
import '../../../../../custom_assets/assets.gen.dart';
import '../../../../../features/bottom_nav_bar/data/models/nav_item_model.dart';
import '../../../../../features/bottom_nav_bar/presentation/controller/bottom_nav_bar_controller.dart';
import '../../../../../widgets/custom_app_bar.dart';
import '../../../../../widgets/custom_image_avatar.dart';
import '../../../../../widgets/custom_scaffold.dart';
import '../../../../../widgets/custom_text.dart';
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
  int selectedTab = 0;
  List<Map<String, String>> activeClients = [];
  List<Map<String, String>> pendingClients = [];
  bool isLoading = true;
  String? loadError;

  Color get _orange => Theme.of(context).colorScheme.primary;
  static const _ink = Color(0xFF17181B);
  static const _muted = Color(0xFF737780);
  static const _line = Color(0xFFE8E9EC);

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
      activeClients =
          activeData.whereType<Map>().map(_mapActiveClient).toList();
    }
    if (pendingResponse.statusCode == 200 && pendingData is List) {
      pendingClients =
          pendingData.whereType<Map>().map(_mapPendingClient).toList();
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
    final fullName =
        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim();
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
        .where(
          (client) =>
              (client['name'] ?? '').toLowerCase().contains(search) ||
              (client['condition'] ?? '').toLowerCase().contains(search),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      backgroundColor: const Color(0xFFFAFAFB),
      appBar: CustomAppBar(
        titleWidget: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: GestureDetector(
            onTap: () => Get.to(() => const ProfileScreen()),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                CustomImageAvatar(
                  image: 'https://picsum.photos/300',
                  radius: 21.r,
                  showBorder: true,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Hi Maxime! 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: _ink,
                                fontSize: 18.sp,
                                height: 1.05,
                                fontWeight: AppFontWeight.display,
                                letterSpacing: -0.35,
                              ),
                            ),
                          ),
                          SizedBox(width: 7.w),
                          _buildOnlineBadge(),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        'Let’s manage your users',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _muted,
                          fontSize: 11.5.sp,
                          height: 1.15,
                          fontWeight: AppFontWeight.body,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Semantics(
              button: true,
              label: 'Notifications, 5 unread',
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    onPressed: () => Get.to(() => NotificationsScreen()),
                    icon: Assets.icons.notification.svg(
                      height: 27.r,
                      width: 27.r,
                    ),
                  ),
                  Positioned(
                    right: 5.w,
                    top: 5.h,
                    child: Container(
                      width: 17.r,
                      height: 17.r,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF4B3E),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9.sp,
                          height: 1,
                          fontWeight: AppFontWeight.label,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
        child: Column(
          children: [
            _buildSearchField(),
            SizedBox(height: 14.h),
            _buildTabs(),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: _orange,
                        strokeWidth: 2.5,
                      ),
                    )
                  : loadError != null && activeClients.isEmpty
                      ? _buildErrorView()
                      : _visibleClients.isEmpty
                          ? _EmptyClientsView(
                              hasSearch:
                                  searchController.text.trim().isNotEmpty,
                              isPending: selectedTab == 1,
                              accent: _orange,
                              onAddClient: _openClientRequests,
                            )
                          : _buildClientList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17.r),
        border: Border.all(color: _line),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        style: TextStyle(
          color: _ink,
          fontSize: 13.sp,
          fontWeight: AppFontWeight.body,
        ),
        decoration: InputDecoration(
          hintText: 'Search by name or condition…',
          hintStyle: TextStyle(
            color: const Color(0xFFB0B3BA),
            fontSize: 13.sp,
            fontWeight: AppFontWeight.body,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: const Color(0xFF747780),
            size: 21.r,
          ),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear search',
                  onPressed: () {
                    searchController.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    Icons.close_rounded,
                    color: _muted,
                    size: 18.r,
                  ),
                ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15.h),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFF0F0F2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(
            label: 'All clients',
            index: 0,
            icon: Icons.group_rounded,
          ),
          _buildTabItem(
            label: 'Pending (${pendingClients.length})',
            index: 1,
            icon: Icons.schedule_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return RefreshIndicator(
      color: _orange,
      onRefresh: _loadClients,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.only(top: 14.h, bottom: 88.h),
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
      ),
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

  void _openClientRequests() {
    final controller = BottomNavBarController.to;
    final requestIndex = controller.indexOfTab(NavItemId.request);
    if (requestIndex >= 0) {
      controller.onChange(requestIndex);
      return;
    }
    Get.snackbar(
      'Requests unavailable',
      'Client requests are not available for this account.',
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(22.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(color: _line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 35.r, color: _muted),
            SizedBox(height: 12.h),
            Text(
              'Client data is unavailable',
              style: TextStyle(
                color: _ink,
                fontSize: 15.sp,
                fontWeight: AppFontWeight.section,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              loadError ?? 'Please try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _muted,
                fontSize: 11.5.sp,
                fontWeight: AppFontWeight.body,
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: _loadClients,
              child: Text(
                'Retry',
                style: TextStyle(fontWeight: AppFontWeight.label),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required String label,
    required int index,
    required IconData icon,
  }) {
    final isSelected = selectedTab == index;

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        label: label,
        child: InkWell(
          onTap: () => setState(() => selectedTab = index),
          borderRadius: BorderRadius.circular(14.r),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected ? _orange : Colors.transparent,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _orange.withOpacity(0.18),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 17.r,
                  color: isSelected ? Colors.white : _muted,
                ),
                SizedBox(width: 7.w),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.white : _muted,
                      fontSize: 12.5.sp,
                      height: 1,
                      fontWeight: AppFontWeight.label,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOnlineBadge() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: _line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, color: const Color(0xFF25C56B), size: 8.r),
          SizedBox(width: 5.w),
          Text(
            'Online',
            style: TextStyle(
              color: _ink,
              fontSize: 10.5.sp,
              height: 1,
              fontWeight: AppFontWeight.label,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyClientsView extends StatelessWidget {
  const _EmptyClientsView({
    required this.hasSearch,
    required this.isPending,
    required this.accent,
    required this.onAddClient,
  });

  final bool hasSearch;
  final bool isPending;
  final Color accent;
  final VoidCallback onAddClient;

  @override
  Widget build(BuildContext context) {
    final title = hasSearch
        ? 'No matching clients'
        : isPending
            ? 'No pending requests'
            : 'No clients found';
    final description = hasSearch
        ? 'Try another name, goal, or condition.'
        : isPending
            ? 'New client requests will appear here.'
            : 'Start building your client list and help them reach their goals.';

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(18.w, 42.h, 18.w, 90.h),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: (constraints.maxHeight - 132.h).clamp(0, double.infinity),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 86.r,
                    height: 86.r,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.075),
                      shape: BoxShape.circle,
                      border: Border.all(color: accent.withOpacity(0.10)),
                    ),
                    child: Icon(
                      hasSearch
                          ? Icons.manage_search_rounded
                          : isPending
                              ? Icons.schedule_rounded
                              : Icons.person_add_alt_1_rounded,
                      size: 38.r,
                      color: accent,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _ink,
                      fontSize: 19.sp,
                      height: 1.1,
                      fontWeight: AppFontWeight.display,
                      letterSpacing: -0.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 265.w),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 12.5.sp,
                        height: 1.35,
                        fontWeight: AppFontWeight.body,
                      ),
                    ),
                  ),
                  if (!hasSearch) ...[
                    SizedBox(height: 22.h),
                    SizedBox(
                      width: 220.w,
                      height: 46.h,
                      child: ElevatedButton.icon(
                        onPressed: onAddClient,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        icon: Icon(Icons.add_rounded, size: 21.r),
                        label: Text(
                          isPending ? 'Open Requests' : 'Add New Client',
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: AppFontWeight.label,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

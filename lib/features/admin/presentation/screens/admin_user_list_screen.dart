import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/admin/presentation/controllers/admin_dashboard_controller.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  late final AdminDashboardController _c;
  late final String _baseFilter;
  late final String _title;
  final _search = TextEditingController();

  // Local sub-filter & sort state
  String _subFilter = 'all';
  String _sort = 'newest';

  static const _sorts = {
    'newest':  'Newest First',
    'oldest':  'Oldest First',
    'name_az': 'Name A–Z',
    'name_za': 'Name Z–A',
  };

  // Sub-filters vary by base filter
  List<Map<String, String>> get _subFilters {
    switch (_baseFilter) {
      case 'verified':
      case 'unverified':
        return [
          {'value': 'all',     'label': 'All'},
          {'value': 'trainer', 'label': 'Trainers'},
          {'value': 'user',    'label': 'Clients'},
          {'value': 'active',  'label': 'Active'},
          {'value': 'suspended','label': 'Suspended'},
        ];
      case 'active_subs':
        return [
          {'value': 'all',     'label': 'All'},
          {'value': 'annual',  'label': 'Annual'},
          {'value': 'monthly', 'label': 'Monthly'},
          {'value': 'trainer', 'label': 'Trainers'},
          {'value': 'user',    'label': 'Clients'},
        ];
      case 'today':
      case 'week':
      case 'month':
        return [
          {'value': 'all',      'label': 'All'},
          {'value': 'verified', 'label': 'Verified'},
          {'value': 'unverified','label':'Unverified'},
          {'value': 'trainer',  'label': 'Trainers'},
          {'value': 'user',     'label': 'Clients'},
        ];
      case 'admin_bypass':
        return [
          {'value': 'all',    'label': 'All'},
          {'value': 'active', 'label': 'Active'},
          {'value': 'suspended','label':'Suspended'},
        ];
      default:
        return [
          {'value': 'all',       'label': 'All'},
          {'value': 'trainer',   'label': 'Trainers'},
          {'value': 'user',      'label': 'Clients'},
          {'value': 'admin',     'label': 'Admins'},
          {'value': 'verified',  'label': 'Verified'},
          {'value': 'unverified','label': 'Unverified'},
          {'value': 'active_subs','label':'Active Subs'},
          {'value': 'no_sub',    'label': 'No Sub'},
          {'value': 'active',    'label': 'Active'},
          {'value': 'suspended', 'label': 'Suspended'},
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _c = Get.isRegistered<AdminDashboardController>()
        ? AdminDashboardController.to
        : Get.put(AdminDashboardController());
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _baseFilter = args['filter'] as String? ?? 'all';
    _title      = args['title']  as String? ?? 'Users';
    _c.fetchFilteredUsers(_baseFilter);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  // ─── Derived list (sub-filter + search + sort) ───────────────────────────

  List<AdminUserModel> get _derived {
    var list = List<AdminUserModel>.from(_c.filteredUsers);

    // Sub-filter
    list = list.where((u) {
      switch (_subFilter) {
        case 'trainer':    return u.role == 'trainer';
        case 'user':       return u.role == 'user';
        case 'admin':      return u.role == 'admin';
        case 'verified':   return u.isVerified;
        case 'unverified': return !u.isVerified;
        case 'active_subs':return u.hasActiveSub;
        case 'no_sub':     return !u.hasActiveSub;
        case 'active':     return !u.isSuspended;
        case 'suspended':  return u.isSuspended;
        case 'annual':     return u.subscriptionTier == 'annual';
        case 'monthly':    return u.subscriptionTier == 'monthly';
        default:           return true;
      }
    }).toList();

    // Search
    final q = _c.filterSearchQuery.value.toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((u) =>
        u.email.toLowerCase().contains(q) ||
        u.fullName.toLowerCase().contains(q)).toList();
    }

    // Sort
    switch (_sort) {
      case 'oldest':
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'name_az':
        list.sort((a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()));
        break;
      case 'name_za':
        list.sort((a, b) => b.fullName.toLowerCase().compareTo(a.fullName.toLowerCase()));
        break;
      default: // newest
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildSubFilters(),
          _buildSortBar(),
          Expanded(child: _buildList()),
        ],
      ),
    );
  }

  // ─── App bar ─────────────────────────────────────────────────────────────

  AppBar _buildAppBar() => AppBar(
    backgroundColor: Colors.white,
    elevation: 0,
    surfaceTintColor: Colors.transparent,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_ios_new,
          size: 18.sp, color: AppColors.textPrimary),
      onPressed: Get.back,
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_title,
            style: TextStyle(
                fontSize: 16.sp,
                fontWeight: AppFontWeight.section,
                color: AppColors.textPrimary)),
        Obx(() => Text(
              '${_c.filteredUsers.length} users',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
            )),
      ],
    ),
    actions: [
      IconButton(
        icon: Icon(Icons.refresh_rounded,
            color: AppColors.textSecondary, size: 20.sp),
        onPressed: () {
          setState(() => _subFilter = 'all');
          _c.fetchFilteredUsers(_baseFilter);
        },
      ),
    ],
  );

  // ─── Search bar ──────────────────────────────────────────────────────────

  Widget _buildSearchBar() => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 10.h),
    child: TextField(
      controller: _search,
      onChanged: (v) => setState(() => _c.filterSearchQuery.value = v.trim()),
      decoration: InputDecoration(
        hintText: 'Search name or email…',
        hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
        prefixIcon: Icon(Icons.search, size: 18.sp, color: Colors.grey.shade400),
        suffixIcon: _search.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, size: 16.sp, color: Colors.grey.shade400),
                onPressed: () {
                  _search.clear();
                  setState(() => _c.filterSearchQuery.value = '');
                })
            : null,
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide.none,
        ),
      ),
    ),
  );

  // ─── Sub-filter chips ────────────────────────────────────────────────────

  Widget _buildSubFilters() => Container(
    color: Colors.white,
    padding: EdgeInsets.only(bottom: 10.h),
    child: SizedBox(
      height: 32.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _subFilters.length,
        separatorBuilder: (_, __) => SizedBox(width: 6.w),
        itemBuilder: (_, i) {
          final f = _subFilters[i];
          final active = _subFilter == f['value'];
          return GestureDetector(
            onTap: () => setState(() => _subFilter = f['value']!),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: active ? AppColors.primary : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                f['label']!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: AppFontWeight.label,
                  color: active ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  // ─── Sort bar ────────────────────────────────────────────────────────────

  Widget _buildSortBar() => Container(
    color: Colors.white,
    padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
    child: Row(
      children: [
        Icon(Icons.sort_rounded, size: 14.sp, color: AppColors.textSecondary),
        SizedBox(width: 6.w),
        Text('Sort:',
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
        SizedBox(width: 8.w),
        DropdownButton<String>(
          value: _sort,
          isDense: true,
          underline: const SizedBox.shrink(),
          style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: AppFontWeight.label),
          items: _sorts.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: (v) => setState(() => _sort = v ?? 'newest'),
        ),
      ],
    ),
  );

  // ─── User list ───────────────────────────────────────────────────────────

  Widget _buildList() => Obx(() {
    if (_c.filteredUsersLoading && _c.filteredUsers.isEmpty) {
      return Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    final list = _derived;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline,
                size: 48.sp, color: Colors.grey.shade300),
            SizedBox(height: 12.h),
            Text('No users found',
                style: TextStyle(
                    color: AppColors.textSecondary, fontSize: 14.sp)),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 40.h),
      itemCount: list.length,
      separatorBuilder: (_, __) => SizedBox(height: 8.h),
      itemBuilder: (ctx, i) => _UserCard(
        user: list[i],
        controller: _c,
        onActionDone: () => setState(() {}),
      ),
    );
  });
}

// ─── User card ────────────────────────────────────────────────────────────────

class _UserCard extends StatelessWidget {
  final AdminUserModel user;
  final AdminDashboardController controller;
  final VoidCallback onActionDone;

  const _UserCard({
    required this.user,
    required this.controller,
    required this.onActionDone,
  });

  Color get _roleColor {
    switch (user.role) {
      case 'trainer': return const Color(0xFF4F46E5);
      case 'admin':   return const Color(0xFFDC2626);
      default:        return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14.r),
        onTap: () => _showDetail(context),
        child: Ink(
          decoration: BoxDecoration(
            color: user.isSuspended
                ? const Color(0xFFFFF7F7)
                : Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: user.isSuspended
                ? Border.all(color: const Color(0xFFDC2626).withOpacity(0.2))
                : null,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2)),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                _buildAvatar(),
                SizedBox(width: 12.w),
                Expanded(child: _buildInfo()),
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = user.fullName.isNotEmpty
        ? user.fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : user.email.isNotEmpty ? user.email[0].toUpperCase() : '?';

    return Stack(
      children: [
        CircleAvatar(
          radius: 22.r,
          backgroundColor: _roleColor.withOpacity(0.12),
          backgroundImage: user.profilePicture != null && user.profilePicture!.isNotEmpty
              ? CachedNetworkImageProvider(user.profilePicture!)
              : null,
          child: user.profilePicture == null || user.profilePicture!.isEmpty
              ? Text(initials,
                  style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: AppFontWeight.display,
                      color: _roleColor))
              : null,
        ),
        if (user.isSuspended)
          Positioned(
            bottom: 0, right: 0,
            child: Container(
              width: 12.w, height: 12.h,
              decoration: BoxDecoration(
                  color: const Color(0xFFDC2626),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5)),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (user.fullName.trim().isNotEmpty)
        Text(user.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 13.sp,
                fontWeight: AppFontWeight.label,
                color: AppColors.textPrimary)),
      Text(user.email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary)),
      SizedBox(height: 5.h),
      Wrap(spacing: 4.w, runSpacing: 3.h, children: [
        _chip(user.role, _roleColor),
        _chip(
          user.isVerified ? '✓ verified' : 'unverified',
          user.isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
        ),
        if (user.hasActiveSub)
          _chip(user.subscriptionTier, const Color(0xFF7C3AED)),
        if (user.isSuspended)
          _chip('suspended', const Color(0xFFDC2626)),
      ]),
    ],
  );

  Widget _buildTrailing() => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(_fmtDate(user.createdAt),
          style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400)),
      SizedBox(height: 4.h),
      Icon(Icons.chevron_right_rounded,
          size: 18.sp, color: Colors.grey.shade300),
    ],
  );

  Widget _chip(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r)),
    // 9sp inside a tinted pill — micro-type, so it keeps w700 like the other
    // badges in the app rather than dropping to the lighter label weight.
    child: Text(label,
        style: TextStyle(
            fontSize: 9.sp,
            fontWeight: FontWeight.w600,
            color: color)),
  );

  String _fmtDate(DateTime d) =>
      '${d.month}/${d.day}/${d.year}';

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _UserDetailSheet(
        user: user,
        controller: controller,
        onActionDone: onActionDone,
      ),
    );
  }
}

// ─── User detail bottom sheet ─────────────────────────────────────────────────

class _UserDetailSheet extends StatefulWidget {
  final AdminUserModel user;
  final AdminDashboardController controller;
  final VoidCallback onActionDone;

  const _UserDetailSheet({
    required this.user,
    required this.controller,
    required this.onActionDone,
  });

  @override
  State<_UserDetailSheet> createState() => _UserDetailSheetState();
}

class _UserDetailSheetState extends State<_UserDetailSheet> {
  late AdminUserModel _user;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;
  }

  Color get _roleColor {
    switch (_user.role) {
      case 'trainer': return const Color(0xFF4F46E5);
      case 'admin':   return const Color(0xFFDC2626);
      default:        return const Color(0xFF0284C7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (ctx, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: ListView(
          controller: scrollCtrl,
          padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
          children: [
            // Handle
            Center(
              child: Container(
                width: 40.w, height: 4.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(99.r)),
              ),
            ),

            _buildHeader(),
            SizedBox(height: 20.h),
            _buildSection('Account Information', _accountRows()),
            SizedBox(height: 16.h),
            _buildSection('Subscription', _subscriptionRows()),
            SizedBox(height: 16.h),
            if (_loading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildSection('Admin Actions', const []),
              SizedBox(height: 12.h),
              _buildActions(context),
            ],
          ],
        ),
      ),
    );
  }

  // ─── Header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final initials = _user.fullName.isNotEmpty
        ? _user.fullName.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : _user.email.isNotEmpty ? _user.email[0].toUpperCase() : '?';

    return Row(children: [
      CircleAvatar(
        radius: 28.r,
        backgroundColor: _roleColor.withOpacity(0.12),
        backgroundImage: _user.profilePicture != null && _user.profilePicture!.isNotEmpty
            ? CachedNetworkImageProvider(_user.profilePicture!)
            : null,
        child: (_user.profilePicture == null || _user.profilePicture!.isEmpty)
            ? Text(initials,
                style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: AppFontWeight.display,
                    color: _roleColor))
            : null,
      ),
      SizedBox(width: 14.w),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_user.fullName.trim().isNotEmpty)
            Text(_user.fullName,
                style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: AppFontWeight.title,
                    color: AppColors.textPrimary)),
          Text(_user.email,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          SizedBox(height: 6.h),
          Wrap(spacing: 4.w, children: [
            _chip(_user.role, _roleColor),
            _chip(
              _user.isVerified ? '✓ verified' : 'unverified',
              _user.isVerified ? const Color(0xFF059669) : const Color(0xFFD97706),
            ),
            if (_user.isSuspended) _chip('suspended', const Color(0xFFDC2626)),
          ]),
        ],
      )),
    ]);
  }

  // ─── Info sections ────────────────────────────────────────────────────────

  Widget _buildSection(String title, List<Widget> rows) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title,
          style: TextStyle(
              fontSize: 13.sp,
              fontWeight: AppFontWeight.display,
              color: AppColors.textPrimary)),
      SizedBox(height: 10.h),
      ...rows,
    ],
  );

  List<Widget> _accountRows() => [
    _row('User ID',     _user.id, copyable: true),
    _row('Role',        _user.role),
    _row('Verified',    _user.isVerified ? '✅ Yes' : '❌ No'),
    _row('Status',      _user.isSuspended ? '🔴 Suspended' : '🟢 Active'),
    _row('Phone',       _user.phoneNumber ?? '—'),
    if (_user.referredByCode != null && _user.referredByCode!.isNotEmpty)
      _row('Referred By', _user.referredByCode!),
    _row('Joined',      _fmtFull(_user.createdAt)),
  ];

  List<Widget> _subscriptionRows() => [
    _row('Plan',    _user.subscriptionTier.isEmpty ? 'Free' : _user.subscriptionTier),
    _row('Active',  _user.hasActiveSub ? '✅ Yes' : '❌ No'),
    if (_user.subscriptionEndDate != null)
      _row('Expires', _fmtFull(_user.subscriptionEndDate!)),
  ];

  Widget _row(String label, String value, {bool copyable = false}) => Padding(
    padding: EdgeInsets.symmetric(vertical: 5.h),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 90.w,
        child: Text(label,
            style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
                fontWeight: AppFontWeight.emphasis)),
      ),
      Expanded(
        child: GestureDetector(
          onTap: copyable
              ? () {
                  Clipboard.setData(ClipboardData(text: value));
                  Get.snackbar('Copied', label,
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 1));
                }
              : null,
          child: Text(value,
              style: TextStyle(
                  fontSize: 11.sp,
                  color: copyable ? AppColors.primary : AppColors.textPrimary,
                  fontWeight: AppFontWeight.label,
                  decoration: copyable ? TextDecoration.underline : null)),
        ),
      ),
    ]),
  );

  // ─── Actions ─────────────────────────────────────────────────────────────

  Widget _buildActions(BuildContext context) => Column(children: [
    // Row 1: Verify + Role
    Row(children: [
      Expanded(child: _actionBtn(
        label: _user.isVerified ? 'Remove Verification' : 'Verify User',
        icon: _user.isVerified ? Icons.cancel_outlined : Icons.verified_outlined,
        color: _user.isVerified ? const Color(0xFFD97706) : const Color(0xFF059669),
        onTap: () => _toggleVerify(context),
      )),
      SizedBox(width: 8.w),
      Expanded(child: _actionBtn(
        label: _user.role == 'user' ? 'Make Trainer' :
               _user.role == 'trainer' ? 'Make Admin' : 'Make User',
        icon: Icons.manage_accounts_outlined,
        color: const Color(0xFF4F46E5),
        onTap: () => _changeRole(context),
      )),
    ]),
    SizedBox(height: 8.h),

    // Row 2: Suspend + Grant Access
    Row(children: [
      Expanded(child: _actionBtn(
        label: _user.isSuspended ? 'Reactivate Account' : 'Suspend Account',
        icon: _user.isSuspended ? Icons.lock_open_outlined : Icons.block_outlined,
        color: _user.isSuspended ? const Color(0xFF059669) : const Color(0xFFDC2626),
        onTap: () => _toggleSuspend(context),
        destructive: !_user.isSuspended,
      )),
      SizedBox(width: 8.w),
      Expanded(child: _actionBtn(
        label: _user.hasActiveSub ? 'Extend Access' : 'Grant Access',
        icon: Icons.star_border_outlined,
        color: const Color(0xFF7C3AED),
        onTap: () => _grantAccess(context),
      )),
    ]),
    SizedBox(height: 8.h),

    // Row 3: Reset password (full width)
    _actionBtn(
      label: 'Reset Password',
      icon: Icons.lock_reset_outlined,
      color: const Color(0xFF0284C7),
      onTap: () => Get.snackbar(
          'Coming Soon', 'Password reset will be available in a future update',
          snackPosition: SnackPosition.BOTTOM),
    ),
  ]);

  Widget _actionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool destructive = false,
  }) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: onTap,
          child: Ink(
            padding: EdgeInsets.symmetric(vertical: 13.h, horizontal: 8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: color.withOpacity(destructive ? 0.4 : 0.2)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 14.sp, color: color),
              SizedBox(width: 6.w),
              Flexible(child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: AppFontWeight.label,
                      color: color))),
            ]),
          ),
        ),
      );

  Widget _chip(String label, Color color) => Container(
    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r)),
    child: Text(label,
        style: TextStyle(
            fontSize: 10.sp,
            fontWeight: AppFontWeight.label,
            color: color)),
  );

  // ─── Action handlers ──────────────────────────────────────────────────────

  Future<void> _toggleVerify(BuildContext context) async {
    final confirm = await _confirm(
      context,
      title: _user.isVerified ? 'Remove Verification?' : 'Verify User?',
      message: _user.isVerified
          ? 'This will mark ${_user.email} as unverified.'
          : 'This will mark ${_user.email} as verified.',
      confirmLabel: _user.isVerified ? 'Remove' : 'Verify',
      destructive: _user.isVerified,
    );
    if (!confirm) return;
    final target = !_user.isVerified;
    if (!await _tryAction(() => widget.controller.setVerified(_user.id, target))) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _user = _user.copyWith(isVerified: target);
      _loading = false;
    });
    widget.onActionDone();
    Get.snackbar(
      target ? '✅ Verified' : '❌ Unverified',
      _user.email,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Performs an admin write and reports honestly.
  ///
  /// Returns true only when the API call succeeded. These actions used to
  /// swallow every error and announce success unconditionally, so a failed
  /// suspend still showed "🔴 Suspended" while the account stayed active.
  Future<bool> _tryAction(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      return true;
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        Get.snackbar(
          'Action failed',
          'Nothing was changed. Check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return false;
    }
  }

  Future<void> _changeRole(BuildContext context) async {
    final roles = ['user', 'trainer', 'admin']
        .where((r) => r != _user.role)
        .toList();
    final picked = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        title: Text('Change Role', style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label)),
        children: roles.map((r) => SimpleDialogOption(
          onPressed: () => Navigator.pop(context, r),
          child: Text(r.capitalizeFirst ?? r,
              style: TextStyle(fontSize: 14.sp)),
        )).toList(),
      ),
    );
    if (picked == null) return;

    final confirm = await _confirm(context,
      title: 'Change role to $picked?',
      message: '${_user.email} will be assigned the role: $picked',
      confirmLabel: 'Change',
    );
    if (!confirm) return;
    if (!await _tryAction(() => widget.controller.setRole(_user.id, picked))) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _user = _user.copyWith(role: picked);
      _loading = false;
    });
    widget.onActionDone();
    Get.snackbar('Role Updated', '${_user.email} → $picked',
        snackPosition: SnackPosition.BOTTOM);
  }

  Future<void> _toggleSuspend(BuildContext context) async {
    final suspending = !_user.isSuspended;
    String reason = '';
    if (suspending) {
      final ctrl = TextEditingController();
      final entered = await showDialog<String>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Reason for suspension',
              style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label)),
          content: TextField(
            controller: ctrl,
            maxLines: 3,
            decoration: const InputDecoration(
                hintText: 'Enter reason…',
                border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, ctrl.text.trim()),
              child: const Text('Suspend'),
            ),
          ],
        ),
      );
      if (entered == null) return;
      reason = entered;
    } else {
      final ok = await _confirm(context,
        title: 'Reactivate Account?',
        message: '${_user.email} will be reactivated.',
        confirmLabel: 'Reactivate',
      );
      if (!ok) return;
    }
    if (!await _tryAction(
        () => widget.controller.suspendUser(_user.id, suspending, reason: reason))) {
      return;
    }
    if (!mounted) return;
    setState(() {
      _user = _user.copyWith(isSuspended: suspending);
      _loading = false;
    });
    widget.onActionDone();
    Get.snackbar(
      suspending ? '🔴 Suspended' : '🟢 Reactivated',
      _user.email,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  Future<void> _grantAccess(BuildContext context) async {
    String tier = 'annual';
    int days = 365;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setSt) => AlertDialog(
          title: Text('Grant Subscription Access',
              style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('User: ${_user.email}',
                style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            SizedBox(height: 12.h),
            DropdownButtonFormField<String>(
              value: tier,
              decoration: const InputDecoration(labelText: 'Plan', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'annual',  child: Text('Annual')),
                DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
              ],
              onChanged: (v) => setSt(() => tier = v ?? 'annual'),
            ),
            SizedBox(height: 10.h),
            DropdownButtonFormField<int>(
              value: days,
              decoration: const InputDecoration(labelText: 'Duration', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 30,   child: Text('30 days')),
                DropdownMenuItem(value: 90,   child: Text('90 days')),
                DropdownMenuItem(value: 180,  child: Text('6 months')),
                DropdownMenuItem(value: 365,  child: Text('1 year')),
                DropdownMenuItem(value: 3650, child: Text('Permanent (10 yr)')),
              ],
              onChanged: (v) => setSt(() => days = v ?? 365),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Grant'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    if (!await _tryAction(
        () => widget.controller.grantAccess(_user.id, tier: tier, days: days))) {
      return;
    }
    if (!mounted) return;
    final expiry = DateTime.now().add(Duration(days: days));
    setState(() {
      _user = _user.copyWith(subscriptionTier: tier, subscriptionEndDate: expiry);
      _loading = false;
    });
    widget.onActionDone();
    Get.snackbar('✅ Access Granted', '$tier plan for $days days',
        snackPosition: SnackPosition.BOTTOM);
  }

  // ─── Confirm dialog ───────────────────────────────────────────────────────

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    bool destructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title,
            style: TextStyle(fontSize: 15.sp, fontWeight: AppFontWeight.label)),
        content: Text(message,
            style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style: destructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626))
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result == true;
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────

  String _fmtFull(DateTime d) =>
      '${d.month}/${d.day}/${d.year} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/profile/presentation/screens/trainer_profile_screen.dart' show ProfileScreen;
import 'package:pler_to_pler_app/features/profile/presentation/screens/user_profile_screen.dart';

// ─── Feed App Bar ─────────────────────────────────────────────────────────────
class FeedAppBar extends StatefulWidget {
  const FeedAppBar({super.key});

  @override
  State<FeedAppBar> createState() => _FeedAppBarState();
}

class _FeedAppBarState extends State<FeedAppBar> {
  String _role = '';
  String _name = '';
  String _profilePicture = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((__) async {
      await _loadUserData();
    });
  }

  Future<void> _loadUserData() async {
    final role    = await PrefsHelper.getString('role');
    final name    = await PrefsHelper.getString(AppConstants.name);
    final photo   = await PrefsHelper.getString(AppConstants.profilePicture);
    if (!mounted) return;
    setState(() {
      _role           = role  ?? '';
      _name           = name  ?? '';
      _profilePicture = photo ?? '';
    });
  }

  /// First name only for the greeting — keeps it clean and personal.
  String get _firstName {
    if (_name.trim().isEmpty) return 'there';
    return _name.trim().split(' ').first;
  }

  /// First initial for the avatar fallback.
  String get _initial =>
      _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : 'P';

  @override
  Widget build(BuildContext context) {
    // Avatar: real photo if available, orange initial circle otherwise.
    final Widget avatar = _profilePicture.isNotEmpty
        ? CircleAvatar(
            radius: 22.r,
            backgroundColor: const Color(0xFFFF6B35),
            backgroundImage: NetworkImage(_profilePicture),
          )
        : CircleAvatar(
            radius: 22.r,
            backgroundColor: const Color(0xFFFF6B35),
            child: Text(
              _initial,
              style: TextStyle(
                color: Colors.white,
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          );

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          // ── Avatar ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: () => Get.to(
              () => _role == 'Trainer' ? ProfileScreen() : UserProfileScreen(),
            ),
            child: avatar,
          ),
          SizedBox(width: 10.w),

          // ── Greeting ────────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hi $_firstName!',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Let\'s Manage your users',
                  style: TextStyle(
                      fontSize: 12.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // ── Notification bell ────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: () => Get.to(() => NotificationsScreen()),
                child: Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.notifications_none,
                      size: 20.sp, color: Colors.black87),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

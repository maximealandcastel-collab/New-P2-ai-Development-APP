import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
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
  // Sourced from ProfileController, not SharedPreferences.
  //
  // This used to read three prefs keys — 'role', AppConstants.name and
  // AppConstants.profilePicture — and **nothing in the app has ever written
  // any of them**. `PrefsHelper.setString` is called in exactly two places in
  // the whole codebase: the admin bypass token, and a commented-out FCM line.
  // So `_name` was always empty, which meant the greeting was permanently
  // "Hi there!" and the avatar permanently showed the 'P' fallback initial,
  // for every user, forever. It was not a loading race — the data had no
  // writer at all.
  //
  // ProfileController does have it (verified on device: firstName=ali), it is
  // already loaded as part of the dashboard's own load, and it is observable —
  // so the greeting now updates when the profile arrives instead of being read
  // once in a post-frame callback and never again.
  ProfileController get _profile => ProfileController.to;

  String get _name {
    final u = _profile.userData;
    final first = u?.firstName?.trim() ?? '';
    if (first.isNotEmpty) return first;
    final preferred = u?.preferredName?.trim() ?? '';
    if (preferred.isNotEmpty) return preferred;
    return '';
  }

  String get _profilePicture => _profile.userData?.profilePicture?.trim() ?? '';

  /// Lower-cased on purpose. The API returns 'trainer' / 'admin' / 'user', and
  /// the tap handler below compared against 'Trainer' with a capital T, so it
  /// never matched and a trainer was always sent to the subscriber profile.
  String get _role => (_profile.userData?.role ?? '').toLowerCase();

  bool get _isTrainer => _role == 'trainer' || _role == 'admin';

  /// First name only for the greeting — keeps it clean and personal.
  String get _firstName {
    if (_name.trim().isEmpty) return 'there';
    return _name.trim().split(' ').first;
  }

  /// First initial for the avatar fallback.
  String get _initial =>
      _name.trim().isNotEmpty ? _name.trim()[0].toUpperCase() : 'P';

  @override
  Widget build(BuildContext context) => Obx(_content);

  Widget _content() {
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
                fontSize: 15.sp,
                fontWeight: AppFontWeight.section,
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
              () => _isTrainer ? ProfileScreen() : UserProfileScreen(),
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
                    fontSize: 15.sp,
                    fontWeight: AppFontWeight.title,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 2.h),
                // Was "Let's Manage your users" for everyone — trainer copy
                // shown to subscribers, who manage nobody. Role is finally
                // available here, so the line matches who is reading it.
                Text(
                  _isTrainer
                      ? 'Let’s manage your clients'
                      : 'Let’s crush today’s workout',
                  style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: AppFontWeight.body,
                      color: Colors.grey.shade500),
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

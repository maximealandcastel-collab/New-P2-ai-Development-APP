import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Trainer App Bar Component
/// Displays user profile, greeting, and notification icon
class TrainerAppBar extends StatelessWidget {
  final String userName;
  final String? profileImageUrl;
  final bool isOnline;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const TrainerAppBar({
    super.key,
    this.userName = 'Maxime',
    this.profileImageUrl,
    this.isOnline = true,
    this.notificationCount = 0,
    this.onProfileTap,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          // Profile Avatar
          GestureDetector(
            onTap: onProfileTap,
            child: CircleAvatar(
              radius: 22.r,
              backgroundImage: profileImageUrl != null
                  ? NetworkImage(profileImageUrl!)
                  : null,
              backgroundColor: Colors.grey.shade200,
              child: profileImageUrl == null
                  ? Icon(Icons.person, size: 22.r, color: Colors.grey.shade400)
                  : null,
            ),
          ),
          SizedBox(width: 10.w),

          // Greeting Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hi $userName !',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (isOnline) _OnlineStatusBadge(),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  "Let's Manage your users",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // Notification Icon
          _NotificationIcon(count: notificationCount, onTap: onNotificationTap),
        ],
      ),
    );
  }
}

class _OnlineStatusBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            'Online',
            style: TextStyle(
              fontSize: 10.sp,
              color: const Color(0xFF4CAF50),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationIcon extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const _NotificationIcon({required this.count, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38.w,
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 6),
              ],
            ),
            child: Icon(
              Icons.notifications_none,
              size: 20.sp,
              color: Colors.black87,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -3.h,
              right: -2.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

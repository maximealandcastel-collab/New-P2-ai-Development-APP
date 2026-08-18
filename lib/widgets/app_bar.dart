import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';
import 'package:pler_to_pler_app/features/common/notification/presentation/screen/notification_screen.dart';
import 'package:pler_to_pler_app/features/profile/profile_screen.dart';
import 'package:pler_to_pler_app/features/user/user_profile/presentation/user_profile_screen.dart';

// ─── Feed App Bar ─────────────────────────────────────────────────────────────
class FeedAppBar extends StatefulWidget {
  const FeedAppBar({super.key});

  @override
  State<FeedAppBar> createState() => _FeedAppBarState();
}

class _FeedAppBarState extends State<FeedAppBar> {
  String _role = '';
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((__)async{
      getRole();
    });
  }
  Future<void> getRole()async{
    String? role = await PrefsHelper.getString('role');
    _role = role;
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
      child: Row(
        children: [
          // Avatar
          GestureDetector(
            onTap: (){
              Get.to(() =>_role=='Trainer'? ProfileScreen(): UserProfileScreen());
            },
            child: CircleAvatar(
              radius: 22.r,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
              ),
            ),
          ),
          SizedBox(width: 10.w),

          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Hi Ethen!',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
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
                              fontSize: 11.sp,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  'Stay consistent, Stay strong',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),

          // Notification bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              GestureDetector(
                onTap: (){
                  Get.to(() => NotificationsScreen());
                },
                child: Container(
                  width: 38.w,
                  height: 38.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Icon(Icons.notifications_none, size: 20.sp, color: Colors.black87),
                ),
              ),
              Positioned(
                top: -4.h,
                right: -2.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '5',
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
        ],
      ),
    );
  }
}
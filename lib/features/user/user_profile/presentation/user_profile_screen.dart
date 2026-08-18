import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/settings/settings_screen.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// SCREEN 1 — PROFILE
// ═══════════════════════════════════════════════════════════════════════════════

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ProfileHeader(),
            _ProfileBody(),
          ],
        ),
      ),
    );
  }
}

// ─── Header (dark bg with avatar) ────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Background image
        Container(
          height: 180.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            image: DecorationImage(
              image: NetworkImage(
                'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
              ),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(Colors.black45, BlendMode.darken),
            ),
          ),
        ),

        // Top bar
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleBtn(icon: Icons.chevron_left, onTap: () => Navigator.maybePop(context)),
                Text('Profile',
                    style: TextStyle(
                        fontSize: 17.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                _CircleBtn(
                  icon: Icons.settings_outlined,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Avatar + edit button
        Positioned(
          bottom: -50.h,
          left: 16.w,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      image: const DecorationImage(
                        image: NetworkImage(
                          'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2.h,
                    right: -2.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5.w, height: 5.h,
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          ),
                          SizedBox(width: 3.w),
                          Text('1',
                              style: TextStyle(fontSize: 9.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 2)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, size: 13.sp, color: Colors.black87),
                        SizedBox(width: 5.w),
                        Text('Edit Profile',
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Profile Body ─────────────────────────────────────────────────────────────
class _ProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 64.h, 16.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name
          Text('Ethen carter',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.black)),
          SizedBox(height: 12.h),

          // Bio
          _LabelText(label: 'Bio', value: 'New to the app trying to gain'),
          SizedBox(height: 10.h),

          // Specialties
          _LabelText(label: 'Specialties', value: 'losing weight , building body this year'),
          SizedBox(height: 18.h),

          // Stats card
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                _StatItem(icon: Icons.fitness_center, iconColor: Color(0xFF4CAF50), label: 'Workout\nConsistency', value: '87%'),
                _StatItem(icon: Icons.local_fire_department, iconColor: Color(0xFFFF7A00), label: 'Calories\nBurned', value: '3,240', unit: 'kcal'),
                _StatItem(icon: Icons.directions_run, iconColor: Color(0xFF2196F3), label: 'Exercise\nduration', value: '450', unit: 'min'),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Trainer card
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trainer',
                              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                          SizedBox(height: 4.h),
                          Text('Maxime Castel',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.black)),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 22.r,
                      backgroundImage: const NetworkImage(
                        'https://images.unsplash.com/photo-1552058544-f2b08422138a?w=200',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F8F8),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Specialties',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade400)),
                      SizedBox(height: 4.h),
                      Text('Strength, Rehab, Post-Op Recovery',
                          style: TextStyle(fontSize: 13.sp, color: Colors.black87)),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  children: [
                    Expanded(
                      child: _OutlineBtn(
                        icon: Icons.phone_outlined,
                        label: 'Call',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _FilledBtn(
                        icon: Icons.chat_bubble_outline,
                        label: 'Message',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelText extends StatelessWidget {
  final String label;
  final String value;

  const _LabelText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade500)),
        SizedBox(height: 3.h),
        Text(value, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String unit;

  const _StatItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 22.sp, color: iconColor),
        SizedBox(height: 6.h),
        Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade400, height: 1.4)),
        SizedBox(height: 4.h),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontSize: 16.sp, fontWeight: FontWeight.w800, color: Colors.black)),
              if (unit.isNotEmpty)
                TextSpan(
                    text: unit,
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OutlineBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.black87),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _FilledBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _FilledBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44.h,
        decoration: BoxDecoration(
          color: const Color(0xFFFF7A00),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: Colors.white),
            SizedBox(width: 6.w),
            Text(label,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.w, height: 34.h,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.sp, color: Colors.white),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/gyms/data/models/enterprise_gym_model.dart';
import 'package:pler_to_pler_app/features/gyms/presentation/widgets/enterprise_gym_card.dart';

class GymsScreen extends StatefulWidget {
  const GymsScreen({super.key});

  @override
  State<GymsScreen> createState() => _GymsScreenState();
}

class _GymsScreenState extends State<GymsScreen> {
  final _searchController = TextEditingController();
  List<EnterpriseGymModel> _filtered = EnterpriseGymModel.partners;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filtered = q.isEmpty
          ? EnterpriseGymModel.partners
          : EnterpriseGymModel.partners
              .where((g) =>
                  g.name.toLowerCase().contains(q) ||
                  g.category.toLowerCase().contains(q))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final total = EnterpriseGymModel.partners.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand row
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        alignment: Alignment.center,
                        child: Text('P2',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w900)),
                      ),
                      SizedBox(width: 10.w),
                      Text('P2P FitTech AI',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87)),
                      const Spacer(),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6.r,
                              height: 6.r,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF00C853),
                                  shape: BoxShape.circle),
                            ),
                            SizedBox(width: 5.w),
                            Text('$total Gym Partners',
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Title
                  Text('Gym Demo Logins',
                      style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          letterSpacing: -0.5)),
                  SizedBox(height: 2.h),
                  Text('Tap any gym to preview its fully branded login experience',
                      style: TextStyle(
                          fontSize: 13.sp, color: Colors.black45)),

                  SizedBox(height: 14.h),

                  // Search + count row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F3F5),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearch,
                            style: TextStyle(fontSize: 14.sp),
                            decoration: InputDecoration(
                              hintText: 'Search gyms...',
                              hintStyle: TextStyle(
                                  color: Colors.black38, fontSize: 14.sp),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: Colors.black38, size: 20.sp),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12.h),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F3F5),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          '${_filtered.length} / $total gyms',
                          style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black54,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Grid ─────────────────────────────────────────────────────
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off_rounded,
                              size: 48.sp, color: Colors.black26),
                          SizedBox(height: 12.h),
                          Text('No gyms found',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.black38,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16.r),
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 0.78,
                      ),
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        return EnterpriseGymCard(gym: _filtered[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

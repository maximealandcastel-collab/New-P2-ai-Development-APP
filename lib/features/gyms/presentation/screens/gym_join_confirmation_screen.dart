import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/enterprise_gym_model.dart';
import 'gym_detail_screen.dart';
import '../widgets/gym_brand_logo.dart';

/// Confirms the exact facility before entering the existing authenticated
/// member flow. This screen never creates a membership by itself.
class GymJoinConfirmationScreen extends StatefulWidget {
  const GymJoinConfirmationScreen({
    super.key,
    required this.gym,
    this.locations = const [],
    required this.onContinue,
  });

  final EnterpriseGymModel gym;
  final List<EnterpriseGymModel> locations;
  final ValueChanged<EnterpriseGymModel> onContinue;

  @override
  State<GymJoinConfirmationScreen> createState() =>
      _GymJoinConfirmationScreenState();
}

class _GymJoinConfirmationScreenState
    extends State<GymJoinConfirmationScreen> {
  late EnterpriseGymModel _selectedGym;
  late List<EnterpriseGymModel> _locations;

  @override
  void initState() {
    super.initState();
    _selectedGym = widget.gym;
    final seen = <String>{};
    _locations = <EnterpriseGymModel>[widget.gym, ...widget.locations]
        .where((gym) => gym.isActivated && seen.add(gym.id))
        .toList(growable: false);
  }

  String _locationLabel(EnterpriseGymModel gym) {
    if (gym.address.isNotEmpty) return gym.address;
    final city = [gym.city, gym.state]
        .where((part) => part.trim().isNotEmpty)
        .join(', ');
    return city.isEmpty ? gym.name : city;
  }

  Future<void> _chooseLocation() async {
    if (_locations.length <= 1) return;
    final selected = await showFranchiseLocationPicker(
      context,
      selectedGym: _selectedGym,
      locations: _locations,
    );
    if (selected != null && mounted) {
      setState(() => _selectedGym = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final gym = _selectedGym;
    return Scaffold(
        backgroundColor: const Color(0xFFF8F8F9),
        appBar: AppBar(
          title: Text('Confirm your gym',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                const Spacer(),
                GymBrandLogo(gym: gym, size: 84.r, borderRadius: 20.r),
                SizedBox(height: 18.h),
                Text(gym.name, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600,
                        color: const Color(0xFF171820))),
                if (gym.address.isNotEmpty || gym.city.isNotEmpty) ...[
                  SizedBox(height: 7.h),
                  Text(gym.address.isNotEmpty ? gym.address : [gym.city, gym.state]
                      .where((part) => part.isNotEmpty).join(', '),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, color: const Color(0xFF747680))),
                ],
                if (_locations.length > 1) ...[
                  SizedBox(height: 16.h),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    child: InkWell(
                      onTap: _chooseLocation,
                      borderRadius: BorderRadius.circular(14.r),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 11.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: const Color(0xFFE6E7EA),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18.sp,
                              color: gym.entryColor,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Choose city, town or location',
                                    style: TextStyle(
                                      fontSize: 9.5.sp,
                                      color: const Color(0xFF898B94),
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    _locationLabel(gym),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF292B33),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 20.sp,
                              color: const Color(0xFF777983),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
                SizedBox(height: 18.h),
                Text('Continue to sign in or create an account. Your gym access is verified by P2P.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.sp, height: 1.4,
                        color: const Color(0xFF747680))),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: FilledButton(
                    onPressed: () => widget.onContinue(gym),
                    style: FilledButton.styleFrom(
                      backgroundColor: gym.entryColor,
                      foregroundColor: gym.entryTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                    ),
                    child: Text('Continue with ${gym.name}', maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                ),
                TextButton(
                  onPressed: _locations.length > 1
                      ? _chooseLocation
                      : () => Navigator.pop(context),
                  child: Text(_locations.length > 1
                      ? 'Choose another location'
                      : 'Change location'),
                ),
              ],
            ),
          ),
        ),
      );
  }
}

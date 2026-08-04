// NavBar is an alias kept for compatibility with any remaining call-sites.
// The real implementation lives in BottomNavBarMain.
export 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/bottom_nav_bar.dart'
    show BottomNavBarMain;

import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/bottom_nav_bar.dart';

/// Thin alias so `Get.offAll(() => NavBar())` keeps working.
typedef NavBar = BottomNavBarMain;

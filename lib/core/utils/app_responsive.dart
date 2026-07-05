import 'dart:math';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppResponsive {
  AppResponsive._();

  /// Caps scaling on large phones (e.g. Pro Max) while keeping smaller devices unchanged.
  static const double maxScale = 1.08;

  static double get scaleW => min(ScreenUtil().scaleWidth, maxScale);

  static double get scaleH => min(ScreenUtil().scaleHeight, maxScale);

  static double get scaleSp => min(ScreenUtil().scaleText, maxScale);

  static double get scaleR =>
      min(min(ScreenUtil().scaleWidth, ScreenUtil().scaleHeight), maxScale);
}

extension ResponsiveNum on num {
  double get rw => this * AppResponsive.scaleW;

  double get rh => this * AppResponsive.scaleH;

  double get rsp => this * AppResponsive.scaleSp;

  double get rr => this * AppResponsive.scaleR;
}

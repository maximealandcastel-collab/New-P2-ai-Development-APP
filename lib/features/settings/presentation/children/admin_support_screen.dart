import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class AdminSupportScreen extends StatelessWidget {
  const AdminSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      appBar: CustomSliverAppBar(title: 'Admin Support'),
      bodyList: [
        SizedBox(height: 24.h).asSliver,
        Assets.images.support.image().asSliverWithPadding(horizontal: 16.w),

      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleSize = 20,
    this.centerTitle = true,
    this.titleWidget,
    this.flexibleSpace,
    this.showLeading = true,
    this.actions,
    this.backAction,
    this.leading,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.toolbarHeight, this.foregroundColor,
  });

  final String? title;
  final double titleSize;
  final bool centerTitle;
  final Widget? titleWidget;
  final Widget? flexibleSpace;
  final bool showLeading;
  final Color? borderColor;
  final double? borderWidth;
  final List<Widget>? actions;
  final VoidCallback? backAction;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? toolbarHeight;

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    return AppBar(
      toolbarHeight: toolbarHeight,
      titleSpacing: 0,
      shape: borderColor != null
          ? Border(
        bottom: BorderSide(color: borderColor ?? AppColors.textPrimary , width: borderWidth ?? 1),
      )
          : null,
      centerTitle: centerTitle,
      elevation: 0,
      automaticallyImplyLeading: false,
      backgroundColor: backgroundColor ?? AppColors.backgroundLight,
      foregroundColor: foregroundColor ?? Colors.white,
      scrolledUnderElevation: 0,
      flexibleSpace: flexibleSpace,
      leading: leading ??
          ((showLeading && (parentRoute?.canPop ?? false))
              ? IconButton(
            icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
            onPressed: backAction ?? () => Navigator.maybePop(context),
          )
              : null),
      title: title != null && title!.isNotEmpty
          ? Text(
        title!,
        style: TextStyle(
          fontFamily: FontFamily.figtree,
          fontWeight: FontWeight.w600,
          fontSize: titleSize.sp,
          color: foregroundColor ?? AppColors.textPrimary,
        ),
      )
          : titleWidget,
      actions: actions,
    );
  }

  @override
  Size get preferredSize =>  Size.fromHeight(toolbarHeight ?? 60);
}

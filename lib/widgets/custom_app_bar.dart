import 'package:pler_to_pler_app/core/themes/app_typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/constants/app_colors.dart';
import 'package:pler_to_pler_app/custom_assets/assets.gen.dart';
import 'package:pler_to_pler_app/widgets/custom_container.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    this.title,
    this.titleSize = 18,
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
      backgroundColor: backgroundColor ?? Color(0xffF0F0F0),
      foregroundColor: foregroundColor ?? Colors.white,
      scrolledUnderElevation: 0,
      flexibleSpace: flexibleSpace,
      leading: leading ??
          ((showLeading && (parentRoute?.canPop ?? false))
              ? IconButton(
            icon: Assets.icons.arrowBack.svg(),
            onPressed: backAction ?? () => Navigator.pop(context),
          )
              : null),
      title: title != null && title!.isNotEmpty
          ? Text(
        title!,
        style: TextStyle(
          fontWeight: AppFontWeight.label,
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

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

class CustomSliverAppBar extends StatelessWidget {
  const CustomSliverAppBar({
    super.key,
    this.title,
    this.titleSize = 20,
    this.centerTitle = true,
    this.titleWidget,
    this.collapsedTitle,
    this.collapsedTitleColor,
    this.showLeading = true,
    this.actions,
    this.backAction,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth,
    this.toolbarHeight,
    this.expandedHeight,
    this.flexibleBackground,
    this.flexibleChild,
    this.flexiblePaddingTop,
    this.flexibleAlignment = Alignment.topCenter,
    this.safeArea = true,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.bottom,
    this.innerBoxIsScrolled = false,
  });

  final String? title;
  final double titleSize;
  final bool centerTitle;
  final Widget? titleWidget;
  final String? collapsedTitle;
  final Color? collapsedTitleColor;
  final bool showLeading;
  final List<Widget>? actions;
  final VoidCallback? backAction;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? toolbarHeight;
  final double? expandedHeight;
  final Widget? flexibleBackground;
  final Widget? flexibleChild;
  final double? flexiblePaddingTop;
  final AlignmentGeometry flexibleAlignment;
  final bool safeArea;
  final bool pinned;
  final bool floating;
  final bool snap;
  final PreferredSizeWidget? bottom;
  final bool innerBoxIsScrolled;

  double get _toolbarH => toolbarHeight ?? 60;

  bool get _hasFlexible => flexibleBackground != null || flexibleChild != null;

  double? get _expandedH => _hasFlexible ? (expandedHeight ?? _toolbarH) : null;

  Color get _foreground => foregroundColor ?? AppColors.textPrimary;

  Widget? get _flexibleContent {
    if (flexibleBackground != null) return flexibleBackground;

    if (flexibleChild != null) {
      final content = Align(
        alignment: flexibleAlignment,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: kToolbarHeight + (flexiblePaddingTop ?? 0),
          ),
          child: flexibleChild,
        ),
      );
      return safeArea ? SafeArea(child: content) : content;
    }

    return null;
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    if (!showLeading || !(parentRoute?.canPop ?? false)) return null;

    return IconButton(
      padding: EdgeInsets.only(left: 8.w),
      onPressed: backAction ?? () => Navigator.maybePop(context),
      icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
    );
  }

  Widget _buildTitle(bool showCollapsedTitle) {
    final titleText = showCollapsedTitle
        ? (collapsedTitle ?? title ?? '')
        : (title ?? '');

    final child = titleWidget ??
        Text(
          titleText,
          style: TextStyle(
            fontFamily: FontFamily.figtree,
            fontWeight: FontWeight.w600,
            fontSize: titleSize.sp,
            color: showCollapsedTitle
                ? (collapsedTitleColor ?? _foreground)
                : _foreground,
          ),
        );

    if (collapsedTitle == null) return child;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: KeyedSubtree(
        key: ValueKey(showCollapsedTitle),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final showCollapsedTitle =
        innerBoxIsScrolled && collapsedTitle != null;
    final content = _flexibleContent;

    return SliverAppBar(
      pinned: pinned,
      floating: floating,
      snap: snap,
      elevation: 0,
      scrolledUnderElevation: 10,
      shadowColor: AppColors.backgroundLight.withValues(alpha: 0.1),
      surfaceTintColor: AppColors.backgroundLight.withValues(alpha: 0.1),
      backgroundColor: backgroundColor?.withValues(alpha: 0.6) ??
          AppColors.backgroundLight.withValues(alpha: 0.6),
      foregroundColor: _foreground,
      toolbarHeight: _toolbarH,
      expandedHeight: _expandedH,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: centerTitle,
      leading: _buildLeading(context),
      title: _buildTitle(showCollapsedTitle),
      actions: actions,
      bottom: bottom,
      shape: borderColor != null
          ? Border(
              bottom: BorderSide(
                color: borderColor!,
                width: borderWidth ?? 1,
              ),
            )
          : null,
      flexibleSpace: content != null
          ? FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: content,
            )
          : null,
    );
  }

  CustomSliverAppBar copyWith({bool? innerBoxIsScrolled}) {
    return CustomSliverAppBar(
      title: title,
      titleSize: titleSize,
      centerTitle: centerTitle,
      titleWidget: titleWidget,
      collapsedTitle: collapsedTitle,
      collapsedTitleColor: collapsedTitleColor,
      showLeading: showLeading,
      actions: actions,
      backAction: backAction,
      leading: leading,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      borderColor: borderColor,
      borderWidth: borderWidth,
      toolbarHeight: toolbarHeight,
      expandedHeight: expandedHeight,
      flexibleBackground: flexibleBackground,
      flexibleChild: flexibleChild,
      flexiblePaddingTop: flexiblePaddingTop,
      flexibleAlignment: flexibleAlignment,
      safeArea: safeArea,
      pinned: pinned,
      floating: floating,
      snap: snap,
      bottom: bottom,
      innerBoxIsScrolled: innerBoxIsScrolled ?? this.innerBoxIsScrolled,
    );
  }
}

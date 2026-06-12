import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

class SliverScaffold extends StatelessWidget {
  const SliverScaffold({
    super.key,
    this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.scrollPhysics,
    // AppBar
    this.appBarTitle,
    this.appBarTitleSize = 20,
    this.centerTitle = true,
    this.titleWidget,
    this.showLeading = true,
    this.actions,
    this.backAction,
    this.leading,
    this.appBarBackgroundColor,
    this.appBarForegroundColor,
    this.appBarBorderColor,
    this.appBarBorderWidth,
    this.toolbarHeight,
    // Flexible
    this.flexibleBackground,
    this.flexibleChild,
    this.flexiblePaddingTop,
    this.flexibleAlignment = Alignment.topCenter,
    this.safeArea = true,
    this.expandedHeight,
    this.pinned = true,
    this.floating = false,
  });

  // ── Scaffold ──────────────────────────────────────────────
  final List<Widget> Function(BuildContext context)? slivers;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final ScrollPhysics? scrollPhysics;

  // ── AppBar ────────────────────────────────────────────────
  final String? appBarTitle;
  final double appBarTitleSize;
  final bool centerTitle;
  final Widget? titleWidget;
  final bool showLeading;
  final List<Widget>? actions;
  final VoidCallback? backAction;
  final Widget? leading;
  final Color? appBarBackgroundColor;
  final Color? appBarForegroundColor;
  final Color? appBarBorderColor;
  final double? appBarBorderWidth;
  final double? toolbarHeight;

  // ── Flexible ──────────────────────────────────────────────
  final Widget? flexibleBackground;
  final Widget? flexibleChild;
  final double? flexiblePaddingTop;
  final AlignmentGeometry flexibleAlignment;
  final bool safeArea;
  final double? expandedHeight;
  final bool pinned;
  final bool floating;

  // ── Helpers ───────────────────────────────────────────────
  double get _toolbarH => toolbarHeight ?? 60;

  double get _expandedH => expandedHeight?.h ?? _toolbarH;

  bool get _hasFlexible => flexibleBackground != null || flexibleChild != null;

  Widget? get _flexibleWidget {
    if (flexibleBackground != null) return flexibleBackground;

    if (flexibleChild != null) {
      Widget content = Align(
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

  @override
  Widget build(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final Widget? leadingWidget =
        leading ??
        ((showLeading && (parentRoute?.canPop ?? false))
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed: backAction ?? () => Navigator.maybePop(context),
              )
            : null);

    final Widget? titleW = (appBarTitle != null && appBarTitle!.isNotEmpty)
        ? Text(
            appBarTitle!,
            style: TextStyle(
              fontFamily: FontFamily.figtree,
              fontWeight: FontWeight.w600,
              fontSize: appBarTitleSize.sp,
              color: appBarForegroundColor ?? AppColors.textPrimary,
            ),
          )
        : titleWidget;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: _body(leadingWidget, titleW, context),
    );
  }

  Widget _body(Widget? leadingWidget, Widget? titleW, BuildContext context) {
    return CustomScrollView(
      physics:
          scrollPhysics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // ── SliverAppBar ──────────────────────────────
        SliverAppBar(
          backgroundColor:
              appBarBackgroundColor?.withValues(alpha: 0.7) ??
              AppColors.backgroundLight.withValues(alpha: 0.7),
          foregroundColor: appBarForegroundColor ?? Colors.white,
          pinned: pinned,
          floating: floating,
          elevation: 0,
          scrolledUnderElevation: 10,
          shadowColor: AppColors.backgroundLight.withValues(alpha: 0.2),
          surfaceTintColor: AppColors.backgroundLight.withValues(alpha: 0.1),
          toolbarHeight: _toolbarH,
          expandedHeight: _hasFlexible ? _expandedH : null,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          centerTitle: centerTitle,
          leading: leadingWidget,
          title: titleW,
          actions: actions,
          shape: appBarBorderColor != null
              ? Border(
                  bottom: BorderSide(
                    color: appBarBorderColor!,
                    width: appBarBorderWidth ?? 1,
                  ),
                )
              : null,
          flexibleSpace: _hasFlexible
              ? FlexibleSpaceBar(
                  background: _flexibleWidget,
                  collapseMode: CollapseMode.pin,
                )
              : null,
        ),

        // ── User slivers ──────────────────────────────
        if (slivers != null) ...slivers!(context),
      ],
    );
  }
}

extension WidgetSliverX on Widget {
  Widget get asSliver => SliverToBoxAdapter(child: this);

  Widget asSliverWithPadding({
    double? horizontal,
    double? vertical,
    EdgeInsets? padding,
  }) => SliverPadding(
    padding:
        padding ??
        EdgeInsets.symmetric(
          horizontal: horizontal ?? 0,
          vertical: vertical ?? 0,
        ),
    sliver: SliverToBoxAdapter(child: this),
  );
}

extension SliverWidgetX on Widget {
  Widget asPaddedSliver({
    double? horizontal,
    double? vertical,
    EdgeInsets? padding,
  }) => SliverPadding(
    padding:
        padding ??
        EdgeInsets.symmetric(
          horizontal: horizontal ?? 0,
          vertical: vertical ?? 0,
        ),
    sliver: this,
  );
}

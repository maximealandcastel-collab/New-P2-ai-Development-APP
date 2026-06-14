import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

class SliverScaffold extends StatefulWidget {
  const SliverScaffold({
    super.key,
    this.slivers,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.scrollPhysics,
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
    this.flexibleBackground,
    this.flexibleChild,
    this.flexiblePaddingTop,
    this.flexibleAlignment = Alignment.topCenter,
    this.safeArea = true,
    this.expandedHeight,
    this.pinned = true,
    this.floating = true,
    this.collapsedTitle,
    this.collapsedTitleColor,
  }) : assert(slivers == null || body == null);

  final List<Widget> Function(BuildContext context)? slivers;
  final Widget? body;

  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final ScrollPhysics? scrollPhysics;
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
  final Color? collapsedTitleColor;
  final Color? appBarBorderColor;
  final double? appBarBorderWidth;
  final double? toolbarHeight;
  final Widget? flexibleBackground;
  final Widget? flexibleChild;
  final double? flexiblePaddingTop;
  final AlignmentGeometry flexibleAlignment;
  final bool safeArea;
  final double? expandedHeight;
  final bool pinned;
  final bool floating;
  final String? collapsedTitle;

  @override
  State<SliverScaffold> createState() => _SliverScaffoldState();
}

class _SliverScaffoldState extends State<SliverScaffold> {
  bool _isCollapsed = false;

  double get _toolbarH => widget.toolbarHeight ?? 60;

  double get _expandedH => widget.expandedHeight ?? _toolbarH;

  bool get _hasFlexible =>
      widget.flexibleBackground != null || widget.flexibleChild != null;

  Widget? get _flexibleWidget {
    if (widget.flexibleBackground != null) return widget.flexibleBackground;

    if (widget.flexibleChild != null) {
      Widget content = Align(
        alignment: widget.flexibleAlignment,
        child: Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: kToolbarHeight + (widget.flexiblePaddingTop ?? 0),
          ),
          child: widget.flexibleChild,
        ),
      );
      return widget.safeArea ? SafeArea(child: content) : content;
    }

    return null;
  }

  SliverAppBar _buildSliverAppBar(BuildContext context) {
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);

    final Widget? leadingWidget =
        widget.leading ??
        ((widget.showLeading && (parentRoute?.canPop ?? false))
            ? IconButton(
                icon: Assets.icons.arrowBack.svg(height: 48.h, width: 48.w),
                onPressed:
                    widget.backAction ?? () => Navigator.maybePop(context),
              )
            : null);

    final Widget titleW = Text(
      _isCollapsed
          ? (widget.collapsedTitle ?? widget.appBarTitle ?? '')
          : (widget.appBarTitle ?? ''),
      style: TextStyle(
        fontFamily: FontFamily.figtree,
        fontWeight: FontWeight.w600,
        fontSize: widget.appBarTitleSize.sp,
        color: _isCollapsed
            ? (widget.collapsedTitleColor ?? AppColors.textPrimary)
            : (widget.appBarForegroundColor ?? AppColors.textPrimary),
      ),
    );

    return SliverAppBar(
      snap: widget.floating,
      backgroundColor:
          widget.appBarBackgroundColor?.withValues(alpha: 0.6) ??
          AppColors.backgroundLight.withValues(alpha: 0.6),
      foregroundColor: widget.appBarForegroundColor ?? Colors.white,
      pinned: widget.pinned,
      floating: widget.floating,
      elevation: 0,
      scrolledUnderElevation: 10,
      shadowColor: AppColors.backgroundLight.withValues(alpha: 0.1),
      surfaceTintColor: AppColors.backgroundLight.withValues(alpha: 0.1),
      toolbarHeight: _toolbarH,
      expandedHeight: _hasFlexible ? _expandedH : null,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      centerTitle: widget.centerTitle,
      leading: leadingWidget,
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(0, -0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: offsetAnimation, child: child),
          );
        },
        child: KeyedSubtree(key: ValueKey(_isCollapsed), child: titleW),
      ),
      actions: widget.actions,
      shape: widget.appBarBorderColor != null
          ? Border(
              bottom: BorderSide(
                color: widget.appBarBorderColor!,
                width: widget.appBarBorderWidth ?? 1,
              ),
            )
          : null,
      flexibleSpace: _hasFlexible
          ? FlexibleSpaceBar(
              background: _flexibleWidget,
              collapseMode: CollapseMode.pin,
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundLight,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      bottomNavigationBar: widget.bottomNavigationBar != null
          ? Container(
              color: AppColors.backgroundLight.withValues(alpha: 0.6),
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 10.h,
                bottom: MediaQuery.of(context).padding.bottom + 10.h,
              ),
              child: widget.bottomNavigationBar!,
            )
          : null,
      body: NestedScrollView(
        physics:
            widget.scrollPhysics ??
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          if (widget.collapsedTitle != null && _hasFlexible) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (innerBoxIsScrolled != _isCollapsed) {
                setState(() => _isCollapsed = innerBoxIsScrolled);
              }
            });
          }
          return [_buildSliverAppBar(context)];
        },
        body: widget.body != null
            ? _buildBodyFromWidget(context)
            : _buildBodyFromSlivers(context),
      ),
    );
  }

  Widget _buildBodyFromWidget(BuildContext context) {
    return widget.body!;
  }

  Widget _buildBodyFromSlivers(BuildContext context) {
    return CustomScrollView(
      slivers: [
        if (widget.slivers != null) ...widget.slivers!(context),
        if (widget.bottomNavigationBar != null)
          SizedBox(height: 120.h).asSliver
        else
          const SliverToBoxAdapter(child: SizedBox.shrink()),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Extensions
// ---------------------------------------------------------------------------

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

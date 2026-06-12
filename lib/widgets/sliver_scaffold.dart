import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

class SliverScaffold extends StatefulWidget {
  const SliverScaffold({
    super.key,
    this.slivers,
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
    this.floating = false,
    this.collapsedTitle,
    this.collapsedTitleColor,
  });

  final List<Widget> Function(BuildContext context)? slivers;
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
  late ScrollController _scrollController;
  bool _isCollapsed = false;

  double get _toolbarH => widget.toolbarHeight ?? 60;

  double get _expandedH => widget.expandedHeight ?? _toolbarH;

  bool get _hasFlexible =>
      widget.flexibleBackground != null || widget.flexibleChild != null;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    if (widget.collapsedTitle != null && _hasFlexible) {
      final collapseAt = _expandedH - _toolbarH;
      _scrollController.addListener(() {
        final collapsed = _scrollController.offset >= collapseAt;
        if (collapsed != _isCollapsed) {
          setState(() => _isCollapsed = collapsed);
        }
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
      bottomNavigationBar: widget.bottomNavigationBar,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: CustomScrollView(
        controller: _scrollController,
        physics:
            widget.scrollPhysics ??
            const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
        slivers: [
          SliverAppBar(
            backgroundColor:
                widget.appBarBackgroundColor?.withValues(alpha: 0.7) ??
                AppColors.backgroundLight.withValues(alpha: 0.7),
            foregroundColor: widget.appBarForegroundColor ?? Colors.white,
            pinned: widget.pinned,
            floating: widget.floating,
            elevation: 0,
            scrolledUnderElevation: 10,
            shadowColor: AppColors.backgroundLight.withValues(alpha: 0.2),
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
                final offsetAnimation =
                    Tween<Offset>(
                      begin: const Offset(0, -0.5),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: animation, curve: Curves.easeOut),
                    );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  ),
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
          ),
          if (widget.slivers != null) ...widget.slivers!(context),
        ],
      ),
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

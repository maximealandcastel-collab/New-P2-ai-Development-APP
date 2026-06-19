import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/core/utils/assets.gen.dart';
import 'package:pler_to_pler_app/core/utils/fonts.gen.dart';

/// Shared scaffold for scrollable screens.
///
/// Scroll modes (auto-selected):
/// - **Simple** (`slivers` only, no flexible header): single [CustomScrollView]
/// - **Unified** (`slivers` + flexible header, no collapsed title): single [CustomScrollView]
/// - **Collapsing** (collapsed title or `body` mode): [NestedScrollView]
/// - **Body** (`body` with simple app bar): [NestedScrollView] with pinned header
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
    this.scrollController,
    this.onRefresh,
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
  final ScrollController? scrollController;
  final Future<void> Function()? onRefresh;

  @override
  State<SliverScaffold> createState() => _SliverScaffoldState();
}

class _SliverScaffoldState extends State<SliverScaffold> {
  double get _toolbarH => widget.toolbarHeight ?? 60;

  double get _expandedH => widget.expandedHeight ?? _toolbarH;

  bool get _hasFlexible =>
      widget.flexibleBackground != null || widget.flexibleChild != null;

  bool get _hasCollapsingHeader =>
      _hasFlexible || widget.collapsedTitle != null;

  bool get _usesBodyMode => widget.body != null;

  bool get _useUnifiedScroll =>
      widget.slivers != null &&
      widget.collapsedTitle == null &&
      !_usesBodyMode;

  bool get _effectiveFloating => widget.floating && _hasCollapsingHeader;

  ScrollPhysics get _scrollPhysics =>
      widget.scrollPhysics ??
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

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

  List<Widget> _contentSlivers(BuildContext context) {
    if (widget.slivers == null) return const [];
    return widget.slivers!(context);
  }

  Widget get _bottomSpacerSliver {
    if (widget.bottomNavigationBar == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(child: SizedBox(height: 120.h));
  }

  SliverAppBar _buildSliverAppBar(
    BuildContext context, {
    bool innerBoxIsScrolled = false,
  }) {
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

    final showCollapsedTitle =
        innerBoxIsScrolled && widget.collapsedTitle != null;
    final titleText = showCollapsedTitle
        ? widget.collapsedTitle!
        : (widget.appBarTitle ?? '');

    final titleW = widget.titleWidget ??
        Text(
          titleText,
          style: TextStyle(
            fontFamily: FontFamily.figtree,
            fontWeight: FontWeight.w600,
            fontSize: widget.appBarTitleSize.sp,
            color: showCollapsedTitle
                ? (widget.collapsedTitleColor ?? AppColors.textPrimary)
                : (widget.appBarForegroundColor ?? AppColors.textPrimary),
          ),
        );

    return SliverAppBar(
      snap: _effectiveFloating,
      backgroundColor:
          widget.appBarBackgroundColor?.withValues(alpha: 0.6) ??
          AppColors.backgroundLight.withValues(alpha: 0.6),
      foregroundColor: widget.appBarForegroundColor ?? Colors.white,
      pinned: widget.pinned,
      floating: _effectiveFloating,
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
      title: widget.collapsedTitle != null
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                final offsetAnimation = Tween<Offset>(
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
              child: KeyedSubtree(
                key: ValueKey(showCollapsedTitle),
                child: titleW,
              ),
            )
          : titleW,
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

  ScrollPhysics get _refreshablePhysics => widget.onRefresh != null
      ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
      : _scrollPhysics;

  Widget _wrapRefreshable(Widget child) {
    if (widget.onRefresh == null) return child;
    return RefreshIndicator(
      backgroundColor: AppColors.backgroundLight,
      color: AppColors.primary,
      edgeOffset: (widget.expandedHeight  ?? 0) + 16.h,
      onRefresh: widget.onRefresh!,
      child: child,
    );
  }

  Widget _buildSingleScrollView(BuildContext context) {
    return _wrapRefreshable(
      CustomScrollView(
        controller: widget.scrollController,
        physics: _refreshablePhysics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          _buildSliverAppBar(context),
          ..._contentSlivers(context),
          _bottomSpacerSliver,
        ],
      ),
    );
  }

  Widget _buildNestedScrollView(BuildContext context) {
    return NestedScrollView(
      physics: _scrollPhysics,
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverAppBar(
          context,
          innerBoxIsScrolled: innerBoxIsScrolled,
        ),
      ],
      body: widget.body ?? _buildNestedSliverBody(context),
    );
  }

  Widget _buildNestedSliverBody(BuildContext context) {
    return _wrapRefreshable(
      CustomScrollView(
        controller: widget.scrollController,
        physics: _refreshablePhysics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          ..._contentSlivers(context),
          _bottomSpacerSliver,
        ],
      ),
    );
  }

  Widget _buildScrollBody(BuildContext context) {
    if (_useUnifiedScroll || (!_hasCollapsingHeader && !_usesBodyMode)) {
      return _buildSingleScrollView(context);
    }
    return _buildNestedScrollView(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundLight,
      endDrawer: widget.endDrawer,
      floatingActionButton: widget.floatingActionButton,
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset ?? true,
      bottomNavigationBar: widget.bottomNavigationBar != null
          ? RepaintBoundary(
              child: Container(
                color: AppColors.backgroundLight.withValues(alpha: 0.6),
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 10.h,
                  bottom: MediaQuery.of(context).padding.bottom + 10.h,
                ),
                child: widget.bottomNavigationBar!,
              ),
            )
          : null,
      body: _buildScrollBody(context),
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

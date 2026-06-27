import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/services/paginated_list.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_sliver_app_bar.dart';
import 'package:pler_to_pler_app/widgets/keyboard_dismiss_on_tap.dart';

class SliverScaffold extends StatelessWidget {
  const SliverScaffold({
    super.key,
    this.appBar,
    required this.bodyList,
    this.paginationList,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.scrollPhysics,
    this.onRefresh,
    this.refreshEdgeOffset,
  });

  final CustomSliverAppBar? appBar;
  final List<Widget> bodyList;
  final PaginatedList<dynamic>? paginationList;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final ScrollPhysics? scrollPhysics;
  final Future<void> Function()? onRefresh;
  final double? refreshEdgeOffset;

  ScrollPhysics get _scrollPhysics =>
      scrollPhysics ??
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  ScrollPhysics get _refreshablePhysics => onRefresh != null
      ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
      : _scrollPhysics;

  Widget _buildBody(BuildContext context) {
    return Builder(
      builder: (context) {
        final slivers = <Widget>[
          if (appBar != null)
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
          ...bodyList,
        ];

        return CustomScrollView(
          physics: _refreshablePhysics,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: slivers,
        );
      },
    );
  }

  Widget _wrapPagination(Widget child) {
    if (paginationList == null) return child;
    return NotificationListener<ScrollNotification>(
      onNotification: paginationList!.handleScrollNotification,
      child: child,
    );
  }

  Widget _wrapRefreshable(Widget child) {
    if (onRefresh == null) return child;
    return RefreshIndicator(
      backgroundColor: AppColors.backgroundLight,
      color: AppColors.primary,
      edgeOffset: refreshEdgeOffset ?? 0,
      onRefresh: onRefresh!,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: AppColors.backgroundLight,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset ?? true,
      bottomNavigationBar: bottomNavigationBar != null
          ? RepaintBoundary(
              child: Container(
                color: AppColors.backgroundLight.withValues(alpha: 0.6),
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 10.h,
                  bottom: MediaQuery.of(context).padding.bottom + 10.h,
                ),
                child: bottomNavigationBar!,
              ),
            )
          : null,
      body: KeyboardDismissOnTap(
        child: NestedScrollView(
          physics: _scrollPhysics,
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            if (appBar != null)
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: appBar!.copyWith(
                  innerBoxIsScrolled: innerBoxIsScrolled,
                ),
              ),
          ],
          body: _wrapPagination(_wrapRefreshable(_buildBody(context))),
        ),
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
  }) =>
      SliverPadding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: horizontal ?? 0,
              vertical: vertical ?? 0,
            ),
        sliver: SliverToBoxAdapter(child: this),
      );
  Widget asFillRemainingSliver({
    bool hasScrollBody = false,
    AlignmentGeometry? alignment,
  }) =>
      SliverFillRemaining(
        hasScrollBody: hasScrollBody,
        child: alignment != null ? Align(alignment: alignment, child: this) : this,
      );
}

extension SliverWidgetX on Widget {
  Widget asPaddedSliver({
    double? horizontal,
    double? vertical,
    EdgeInsets? padding,
  }) =>
      SliverPadding(
        padding: padding ??
            EdgeInsets.symmetric(
              horizontal: horizontal ?? 0,
              vertical: vertical ?? 0,
            ),
        sliver: this,
      );
}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/widgets/custom_sliver_app_bar.dart';
import 'package:pler_to_pler_app/widgets/keyboard_dismiss_on_tap.dart';

/// Scaffold-like wrapper powered by [NestedScrollView] + slivers.
///
/// ```dart
/// SliverScaffold(
///   appBar: CustomSliverAppBar(title: 'Settings'),
///   body: CustomScrollView(
///     slivers: [
///       MyContent().asSliver,
///     ],
///   ),
/// )
/// ```
class SliverScaffold extends StatelessWidget {
  const SliverScaffold({
    super.key,
    this.appBar,
    this.body,
    this.slivers,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.endDrawer,
    this.resizeToAvoidBottomInset,
    this.scrollPhysics,
    this.scrollController,
    this.onRefresh,
    this.refreshEdgeOffset,
  }) : assert(body != null || slivers != null);

  final CustomSliverAppBar? appBar;
  final Widget? body;
  final List<Widget> Function(BuildContext context)? slivers;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? endDrawer;
  final bool? resizeToAvoidBottomInset;
  final ScrollPhysics? scrollPhysics;
  final ScrollController? scrollController;
  final Future<void> Function()? onRefresh;
  final double? refreshEdgeOffset;

  ScrollPhysics get _scrollPhysics =>
      scrollPhysics ??
      const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics());

  ScrollPhysics get _refreshablePhysics => onRefresh != null
      ? const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics())
      : _scrollPhysics;

  Widget _bottomSpacerSliver() {
    if (bottomNavigationBar == null) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }
    return SliverToBoxAdapter(child: SizedBox(height: 120.h));
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

  Widget _buildBody(BuildContext context) {
    if (body != null) return _wrapRefreshable(body!);

    return _wrapRefreshable(
      CustomScrollView(
        controller: scrollController,
        physics: _refreshablePhysics,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          ...slivers!(context),
          _bottomSpacerSliver(),
        ],
      ),
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
              appBar!.copyWith(innerBoxIsScrolled: innerBoxIsScrolled),
          ],
          body: _buildBody(context),
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

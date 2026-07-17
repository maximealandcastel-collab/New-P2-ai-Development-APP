import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/content_reel_item.dart';
import 'package:preload_page_view/preload_page_view.dart' hide PageScrollPhysics;

/// Keeps scroll position stable when pagination appends items.
class ContentsReelPageView extends StatefulWidget {
  const ContentsReelPageView({super.key});

  @override
  State<ContentsReelPageView> createState() => _ContentsReelPageViewState();
}

class _ContentsReelPageViewState extends State<ContentsReelPageView> {
  Worker? _itemsWorker;
  int _itemCount = 0;

  @override
  void initState() {
    super.initState();
    final controller = ContentController.to;
    _itemCount = controller.contents.length;
    _itemsWorker = ever<List<ContentModel>>(controller.reelFeed!.feed.items, (_) {
      final count = controller.contents.length;
      if (count != _itemCount && mounted) setState(() => _itemCount = count);
    });
  }

  @override
  void dispose() {
    _itemsWorker?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ContentController.to;

    return ColoredBox(
      color: Colors.black,
      child: PreloadPageView.builder(
        controller: controller.pageController,
        scrollDirection: Axis.vertical,
        preloadPagesCount: 1,
        physics: const AlwaysScrollableScrollPhysics(
          parent: PageScrollPhysics(),
        ),
        itemCount: _itemCount,
        onPageChanged: controller.onReelPageChanged,
        itemBuilder: (context, index) {
          final content = controller.contents[index];
          return ContentReelItem(
            key: ValueKey(content.id ?? 'content_$index'),
            content: content,
            index: index,
          );
        },
      ),
    );
  }
}

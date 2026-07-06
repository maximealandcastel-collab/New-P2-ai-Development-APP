import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pler_to_pler_app/core/routes/app_routes.dart';
import 'package:pler_to_pler_app/core/utils/app_colors.dart';
import 'package:pler_to_pler_app/features/contents/data/models/content_model.dart';
import 'package:pler_to_pler_app/features/contents/presentation/controllers/content_controller.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_header_section.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_list_section.dart';
import 'package:pler_to_pler_app/features/contents/presentation/screens/widgets/contents_upload_progress.dart';
import 'package:pler_to_pler_app/features/home/widgets/feed_app_bar.dart';
import 'package:pler_to_pler_app/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pler_to_pler_app/features/search/model/search_model.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/widgets/widgets.dart';

class ContentsScreen extends StatelessWidget {
  const ContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final contentController = ContentController.to;
    final isTrainer = ProfileController.to.userData?.role == 'trainer';

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundLight,
      onRefresh: contentController.refresh,
      edgeOffset: MediaQuery.heightOf(context) * 0.25,
      child: CustomScrollView(
        controller: contentController.scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          FeedAppBarSliver(
            pinned: true,
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(
                ContentsHeaderSection.preferredHeight(isTrainer: isTrainer),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                child: ContentsHeaderSection(
                  onSearchTap: () => _openSearch(context, contentController),
                ),
              ),
            ),
          ),
          const ContentsUploadProgress(),
          const ContentsListSection(),
          PaginationLoaderSliver(controller: contentController),
          SliverToBoxAdapter(child: SizedBox(height: 120.h)),
        ],
      ),
    );
  }

  void _openSearch(BuildContext context, ContentController controller) {
    showSearch(
      context: context,
      delegate: SearchScreen(
        hintText: 'Search default exercises...',
        onSearch: (String query) async {
          await controller.search.search(query);
          return controller.search.results
              .map(
                (content) => SearchModel(
                  model: content,
                  title: content.title ?? content.exerciseName,
                  image: content.thumbnailUrl,
                  subtitle: content.categoryId?.category ?? content.difficulty,
                ),
              )
              .toList();
        },
        onResultTap: (result) {
          controller.search.clear();
          Get.toNamed(
            AppRoute.contentDetailsScreen,
            arguments: result.model as ContentModel,
          );
        },
      ),
    );
  }
}

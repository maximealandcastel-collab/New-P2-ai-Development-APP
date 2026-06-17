import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pler_to_pler_app/features/search/search_screen.dart';
import 'package:pler_to_pler_app/features/subscribe/data/models/find_trainer_model.dart';
import 'package:pler_to_pler_app/features/subscribe/presentation/screens/widgets/find_trainer_card.dart';
import 'package:pler_to_pler_app/widgets/custom_search_field.dart';
import 'package:pler_to_pler_app/widgets/sliver_scaffold.dart';

class FindTrainerScreen extends StatelessWidget {
  const FindTrainerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverScaffold(
      floating: false,
      appBarTitle: 'Find trainer',
      expandedHeight: 140.h,
      flexiblePaddingTop: 20.h,
      flexibleChild: CustomSearchField(
        readOnly: true,
        onTap: () {
          showSearch(
            context: context,
            delegate: SearchScreen(
              hintText: 'Search trainer by name or needs',
              onSearch: (String query) async {
                return [];
              },
              onResultTap: (result) {
                // controller.search.clear();
                // Get.toNamed(AppRoutes.pollDetailsScreen, arguments: result.model.sId as String);
              },
            ),
          );
        },

        // searchController: controller.searchController,
        hintText: 'Search trainer by name or needs',
      ),

      slivers: _buildSlivers,
    );
  }

  List<Widget> _buildSlivers(BuildContext context) => [
        SliverList.separated(
          itemCount: FindTrainerModel.trainers.length,
          itemBuilder: (_, i) {
            final data = FindTrainerModel.trainers[i];
            return FindTrainerCard(trainer: data);
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(height: 10.h);
          },
        ).asPaddedSliver(horizontal: 16.w),

        SizedBox(height: 70.h).asSliver,
      ];
}

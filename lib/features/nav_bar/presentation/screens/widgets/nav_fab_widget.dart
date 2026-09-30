import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/data/models/nav_fab_model.dart';
import 'package:pler_to_pler_app/features/bottom_nav_bar/presentation/widgets/nav_fab_widget.dart' as shared;

/// Compatibility entry point for the older navigation shell.
class NavFabWidget {
  NavFabWidget._();
  static final NavFabWidget instance = NavFabWidget._();

  Future<void> show(BuildContext context, {
    VoidCallback? onPostContent,
    VoidCallback? onAddSchedule,
    String? findActionLabel,
    VoidCallback? onAddExercise,
  }) {
    final items = NavFabModel.userFabItems;
    final post = items.last;
    return shared.NavFabWidget.show(context, [
      items[0],
      items[1],
      NavFabModel(icon: post.icon, label: post.label,
        onTap: onPostContent ?? post.onTap),
    ]);
  }
}

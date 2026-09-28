import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/features/community/presentation/screens/post_photo_video_screen.dart';

/// Kept as a route alias for older links into the community composer.
/// Every photo entry now uses the same single-photo journey flow.
class BeforeAfterScreen extends StatelessWidget {
  const BeforeAfterScreen({super.key});

  @override
  Widget build(BuildContext context) => const PostPhotoVideoScreen();
}

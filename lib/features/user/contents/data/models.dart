class VideoPost {
  final String title;
  final String category;
  final String views;
  final String imageUrl;
  final bool isNew;

  const VideoPost({
    required this.title,
    required this.category,
    required this.views,
    required this.imageUrl,
    this.isNew = false,
  });
}

class Comment {
  final String user;
  final String avatarUrl;
  final String timeAgo;
  final String text;
  final int likes;
  final int dislikes;
  final int replies;

  const Comment({
    required this.user,
    required this.avatarUrl,
    required this.timeAgo,
    required this.text,
    required this.likes,
    required this.dislikes,
    required this.replies,
  });
}
class UserPostModel {
  final String id;
  final String userId;
  final String? caption;
  final String beforeImageUrl;
  final String afterImageUrl;
  final DateTime createdAt;

  UserPostModel({
    required this.id,
    required this.userId,
    this.caption,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    required this.createdAt,
  });

  factory UserPostModel.fromJson(Map<String, dynamic> json) => UserPostModel(
        id: json['_id'] ?? '',
        userId: json['userId'] ?? '',
        caption: json['caption'],
        beforeImageUrl: json['beforeImageUrl'] ?? '',
        afterImageUrl: json['afterImageUrl'] ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      );
}

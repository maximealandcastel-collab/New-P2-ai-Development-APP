class ContentCategoryRef {
  String? id;
  String? category;
  String? slug;

  ContentCategoryRef({this.id, this.category, this.slug});

  ContentCategoryRef.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    category = json['category'];
    slug = json['slug'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'slug': slug,
    };
  }
}

class ContentModel {
  String? id;
  String? trainerId;
  ContentCategoryRef? categoryId;
  String? title;
  String? description;
  String? contentType;
  String? videoUrl;
  String? thumbnailUrl;
  int? durationSeconds;
  String? exerciseName;
  List<String>? muscleGroups;
  String? difficulty;
  List<String>? equipment;
  List<String>? tags;
  bool? isPublished;
  bool? isActive;
  int? viewCount;
  String? createdAt;
  String? updatedAt;

  // ── Mux video infrastructure (Phase 2) ───────────────────────
  // When muxPlaybackId is set and processingStatus == 'ready',
  // the player uses HLS: https://stream.mux.com/{muxPlaybackId}.m3u8
  // Falls back to legacy videoUrl during migration.
  String? muxPlaybackId;
  String? muxAssetId;
  String? processingStatus; // 'pending'|'uploading'|'processing'|'ready'|'failed'|'legacy'

  /// True when this content has a live Mux HLS stream ready to play.
  bool get hasMuxHls =>
      muxPlaybackId != null &&
      muxPlaybackId!.isNotEmpty &&
      processingStatus == 'ready';

  ContentModel({
    this.id,
    this.trainerId,
    this.categoryId,
    this.title,
    this.description,
    this.contentType,
    this.videoUrl,
    this.thumbnailUrl,
    this.durationSeconds,
    this.exerciseName,
    this.muscleGroups,
    this.difficulty,
    this.equipment,
    this.tags,
    this.isPublished,
    this.isActive,
    this.viewCount,
    this.createdAt,
    this.updatedAt,
    this.muxPlaybackId,
    this.muxAssetId,
    this.processingStatus,
  });

  ContentModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    trainerId = json['trainerId'];
    categoryId = json['categoryId'] != null
        ? ContentCategoryRef.fromJson(json['categoryId'])
        : null;
    title = json['title'];
    description = json['description'];
    contentType = json['contentType'];
    videoUrl = json['videoUrl'] ?? json['videoPath'];
    thumbnailUrl = _readThumbnail(json);
    durationSeconds = json['durationSeconds'];
    exerciseName = json['exerciseName'];
    muscleGroups = json['muscleGroups']?.cast<String>();
    difficulty = json['difficulty'];
    equipment = json['equipment']?.cast<String>();
    tags = json['tags']?.cast<String>();
    isPublished = json['isPublished'];
    isActive = json['isActive'];
    viewCount = json['viewCount'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    // Mux fields
    muxPlaybackId    = json['muxPlaybackId'] as String?;
    muxAssetId       = json['muxAssetId'] as String?;
    processingStatus = json['processingStatus'] as String?;
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'trainerId': trainerId,
      'categoryId': categoryId?.toJson(),
      'title': title,
      'description': description,
      'contentType': contentType,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'exerciseName': exerciseName,
      'muscleGroups': muscleGroups,
      'difficulty': difficulty,
      'equipment': equipment,
      'tags': tags,
      'isPublished': isPublished,
      'isActive': isActive,
      'viewCount': viewCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'muxPlaybackId': muxPlaybackId,
      'muxAssetId': muxAssetId,
      'processingStatus': processingStatus,
    };
  }

  Map<String, dynamic> toRequestBody() {
    return {
      'categoryId': categoryId?.id,
      'title': title,
      'description': description,
      'contentType': contentType,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'durationSeconds': durationSeconds,
      'exerciseName': exerciseName,
      'muscleGroups': muscleGroups,
      'difficulty': difficulty,
      'equipment': equipment,
      'tags': tags,
    };
  }

  static String? _readThumbnail(Map<String, dynamic> json) {
    const keys = [
      'thumbnailUrl',
      'thumbnailPath',
      'thumbnail',
      'coverImage',
      'imageUrl',
      'image',
    ];

    for (final key in keys) {
      final value = json[key];
      final resolved = _readMediaPath(value);
      if (resolved != null) return resolved;
    }

    return null;
  }

  static String? _readMediaPath(dynamic value) {
    if (value == null) return null;
    if (value is String && value.isNotEmpty) return value;
    if (value is Map) {
      final url = value['url'] ?? value['path'] ?? value['src'];
      if (url is String && url.isNotEmpty) return url;
    }
    return null;
  }
}

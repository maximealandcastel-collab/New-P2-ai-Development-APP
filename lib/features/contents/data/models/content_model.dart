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
    videoUrl = json['videoUrl'];
    thumbnailUrl = json['thumbnailUrl'];
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
}

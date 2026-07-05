class CategoryModel {
  String? id;
  String? trainerId;
  String? category;
  String? slug;
  String? description;
  bool? isActive;
  String? createdAt;
  String? updatedAt;

  CategoryModel({
    this.id,
    this.trainerId,
    this.category,
    this.slug,
    this.description,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  CategoryModel.fromJson(Map<String, dynamic> json) {
    id = json['_id'];
    trainerId = json['trainerId'];
    category = json['category'];
    slug = json['slug'];
    description = json['description'];
    isActive = json['isActive'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'trainerId': trainerId,
      'category': category,
      'slug': slug,
      'description': description,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

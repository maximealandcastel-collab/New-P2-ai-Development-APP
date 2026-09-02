class TrainerDashboardStatsModel {
  final bool? success;
  final String? message;
  final TrainerDashboardData? data;

  TrainerDashboardStatsModel({
    this.success,
    this.message,
    this.data,
  });

  factory TrainerDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final payload = json['data'] is Map
        ? Map<String, dynamic>.from(json['data'] as Map)
        : json;

    return TrainerDashboardStatsModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: TrainerDashboardData.fromJson(payload),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class TrainerDashboardData {
  final String? trainerId;
  final String? trainerName;
  final int? activeUsersCount;
  final NewUsersThisWeek? newUsersThisWeek;
  final ContentStats? contentStats;
  final int? mealsAssigned;
  final WorkoutBlocksStats? workoutBlocksStats;

  TrainerDashboardData({
    this.trainerId,
    this.trainerName,
    this.activeUsersCount,
    this.newUsersThisWeek,
    this.contentStats,
    this.mealsAssigned,
    this.workoutBlocksStats,
  });

  factory TrainerDashboardData.fromJson(Map<String, dynamic> json) {
    return TrainerDashboardData(
      trainerId: json['trainerId']?.toString(),
      trainerName: json['trainerName']?.toString(),
      activeUsersCount: json['activeUsersCount'] as int?,
      newUsersThisWeek: json['newUsersThisWeek'] != null
          ? NewUsersThisWeek.fromJson(Map<String, dynamic>.from(json['newUsersThisWeek'] as Map))
          : null,
      contentStats: json['contentStats'] != null
          ? ContentStats.fromJson(Map<String, dynamic>.from(json['contentStats'] as Map))
          : null,
      mealsAssigned: json['mealsAssigned'] as int?,
      workoutBlocksStats: json['workoutBlocksStats'] != null
          ? WorkoutBlocksStats.fromJson(Map<String, dynamic>.from(json['workoutBlocksStats'] as Map))
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'trainerId': trainerId,
      'trainerName': trainerName,
      'activeUsersCount': activeUsersCount,
      'newUsersThisWeek': newUsersThisWeek?.toJson(),
      'contentStats': contentStats?.toJson(),
      'mealsAssigned': mealsAssigned,
      'workoutBlocksStats': workoutBlocksStats?.toJson(),
    };
  }
}

class NewUsersThisWeek {
  final int? calendarWeek;
  final int? rolling7Days;

  NewUsersThisWeek({
    this.calendarWeek,
    this.rolling7Days,
  });

  factory NewUsersThisWeek.fromJson(Map<String, dynamic> json) {
    return NewUsersThisWeek(
      calendarWeek: json['calendarWeek'] as int?,
      rolling7Days: json['rolling7Days'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calendarWeek': calendarWeek,
      'rolling7Days': rolling7Days,
    };
  }
}

class ContentStats {
  final int? total;
  final int? published;
  final int? draft;

  ContentStats({
    this.total,
    this.published,
    this.draft,
  });

  factory ContentStats.fromJson(Map<String, dynamic> json) {
    return ContentStats(
      total: json['total'] as int?,
      published: json['published'] as int?,
      draft: json['draft'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'published': published,
      'draft': draft,
    };
  }
}

class WorkoutBlocksStats {
  final int? total;
  final int? approved;
  final int? aiGenerated;

  WorkoutBlocksStats({
    this.total,
    this.approved,
    this.aiGenerated,
  });

  factory WorkoutBlocksStats.fromJson(Map<String, dynamic> json) {
    return WorkoutBlocksStats(
      total: json['total'] as int?,
      approved: json['approved'] as int?,
      aiGenerated: json['aiGenerated'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'approved': approved,
      'aiGenerated': aiGenerated,
    };
  }
}

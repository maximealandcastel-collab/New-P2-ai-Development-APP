class AnamUsageModel {
  AnamUsageModel({
    required this.monthlyMinutesLimit,
    required this.minutesUsedThisMonth,
    required this.minutesRemaining,
    required this.isLimitReached,
    required this.periodResetDate,
    this.totalMinutesAllTime,
  });

  factory AnamUsageModel.fromJson(Map<String, dynamic> json) {
    return AnamUsageModel(
      monthlyMinutesLimit: json['monthlyMinutesLimit'] as int? ?? 0,
      minutesUsedThisMonth: json['minutesUsedThisMonth'] as int? ?? 0,
      minutesRemaining: json['minutesRemaining'] as int? ?? 0,
      isLimitReached: json['isLimitReached'] as bool? ?? false,
      periodResetDate: DateTime.tryParse(
            json['periodResetDate']?.toString() ?? '',
          ) ??
          DateTime.now(),
      totalMinutesAllTime: json['totalMinutesAllTime'] as int?,
    );
  }

  final int monthlyMinutesLimit;
  final int minutesUsedThisMonth;
  final int minutesRemaining;
  final bool isLimitReached;
  final DateTime periodResetDate;
  final int? totalMinutesAllTime;
}

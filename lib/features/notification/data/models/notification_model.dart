import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String title;
  final String action;
  final String target;
  final String date;
  final String? preview;
  final String? imageUrl;
  final bool isRead;
  final String? type;
  final String? createdAt;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.action,
    required this.target,
    required this.date,
    this.preview,
    this.imageUrl,
    this.isRead = true,
    this.type,
    this.createdAt,
  });

  bool get hasTarget => target.isNotEmpty;

  bool get hasPreview => preview != null && preview!.isNotEmpty;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasAction => action.isNotEmpty;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      action: action,
      target: target,
      date: date,
      preview: preview,
      imageUrl: imageUrl,
      isRead: isRead ?? this.isRead,
      type: type,
      createdAt: createdAt,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt =
        json['createdAt']?.toString() ??
        json['date']?.toString() ??
        json['updatedAt']?.toString() ??
        '';

    final preview =
        json['preview']?.toString() ??
        json['body']?.toString() ??
        json['message']?.toString();

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      date: _formatDisplayDate(rawCreatedAt),
      preview: preview,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      isRead: json['isRead'] == true || json['read'] == true,
      type: json['type']?.toString(),
      createdAt: rawCreatedAt.isEmpty ? null : rawCreatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'action': action,
      'target': target,
      'date': date,
      'preview': preview,
      'imageUrl': imageUrl,
      'isRead': isRead,
      'type': type,
      'createdAt': createdAt,
    };
  }

  static String _formatDisplayDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final parsed = DateTime.parse(raw).toLocal();
      return DateFormat('M/d/yy').format(parsed);
    } catch (_) {
      return raw;
    }
  }
}

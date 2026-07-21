import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String message;
  final String date;
  final bool isRead;
  final bool isReadable;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  /// Legacy/demo fields — kept for older payloads.
  final String title;
  final String action;
  final String target;
  final String? preview;
  final String? imageUrl;
  final String? type;

  const NotificationModel({
    required this.id,
    required this.message,
    required this.date,
    this.isRead = true,
    this.isReadable = true,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.title = '',
    this.action = '',
    this.target = '',
    this.preview,
    this.imageUrl,
    this.type,
  });

  bool get hasTarget => target.isNotEmpty;

  bool get hasPreview =>
      (preview != null && preview!.isNotEmpty) ||
      (message.isNotEmpty && !usesLegacyLayout);

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  bool get hasAction => action.isNotEmpty;

  bool get hasStatus => status != null && status!.isNotEmpty;

  bool get usesLegacyLayout =>
      title.isNotEmpty || action.isNotEmpty || target.isNotEmpty;

  String get displayMessage =>
      message.isNotEmpty ? message : (preview ?? '');

  NotificationModel copyWith({
    bool? isRead,
    bool? isReadable,
    String? status,
  }) {
    return NotificationModel(
      id: id,
      message: message,
      date: date,
      isRead: isRead ?? this.isRead,
      isReadable: isReadable ?? this.isReadable,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      title: title,
      action: action,
      target: target,
      preview: preview,
      imageUrl: imageUrl,
      type: type,
    );
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt =
        json['createdAt']?.toString() ??
        json['date']?.toString() ??
        json['updatedAt']?.toString() ??
        '';

    final message =
        json['msg']?.toString() ??
        json['message']?.toString() ??
        json['body']?.toString() ??
        '';

    final preview =
        json['preview']?.toString() ??
        (message.isEmpty ? json['title']?.toString() : null);

    final isRead = _parseIsRead(json);

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      message: message,
      date: _formatDisplayDate(rawCreatedAt),
      isRead: isRead,
      isReadable: json.containsKey('isReadable')
          ? json['isReadable'] == true
          : isRead,
      status: json['status']?.toString(),
      createdAt: rawCreatedAt.isEmpty ? null : rawCreatedAt,
      updatedAt: json['updatedAt']?.toString(),
      title: json['title']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      preview: preview,
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
      type: json['type']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'msg': message,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isRead': isRead,
      'isReadable': isReadable,
      'status': status,
      'title': title,
      'action': action,
      'target': target,
      'preview': preview,
      'imageUrl': imageUrl,
      'type': type,
    };
  }

  /// Prefer [isRead]; fall back to legacy [isReadable] / [read].
  static bool _parseIsRead(Map<String, dynamic> json) {
    if (json.containsKey('isRead')) {
      return json['isRead'] == true;
    }
    if (json.containsKey('isReadable')) {
      return json['isReadable'] == true;
    }
    if (json.containsKey('read')) {
      return json['read'] == true;
    }
    return true;
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

class NotificationUserInfo {
  final String? id;
  final String? name;
  final String? email;

  const NotificationUserInfo({
    this.id,
    this.name,
    this.email,
  });

  factory NotificationUserInfo.fromJson(Map<String, dynamic> json) {
    return NotificationUserInfo(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
    );
  }
}

class NotificationListPayload {
  final NotificationUserInfo? userInfo;
  final List<NotificationModel> notifications;

  const NotificationListPayload({
    this.userInfo,
    this.notifications = const [],
  });

  factory NotificationListPayload.fromJson(Map<String, dynamic> json) {
    final userInfoRaw = json['userInfo'];
    final notificationsRaw = json['notifications'];

    return NotificationListPayload(
      userInfo: userInfoRaw is Map
          ? NotificationUserInfo.fromJson(
              Map<String, dynamic>.from(userInfoRaw),
            )
          : null,
      notifications: notificationsRaw is List
          ? notificationsRaw
                .whereType<Map>()
                .map(
                  (item) => NotificationModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList()
          : const [],
    );
  }
}

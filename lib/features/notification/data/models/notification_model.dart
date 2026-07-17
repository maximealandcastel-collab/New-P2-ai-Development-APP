class NotificationModel {
  final String id;
  final String title;
  final String action;
  final String target;
  final String date;
  final String? preview;
  final String? imageUrl;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.action,
    required this.target,
    required this.date,
    this.preview,
    this.imageUrl,
  });

  bool get hasTarget => target.isNotEmpty;

  bool get hasPreview => preview != null && preview!.isNotEmpty;

  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      target: json['target']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      preview: json['preview']?.toString(),
      imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'action': action,
      'target': target,
      'date': date,
      'preview': preview,
      'imageUrl': imageUrl,
    };
  }

  static const List<NotificationModel> demoNotifications = [
    NotificationModel(
      id: '1',
      title: 'Sam Alex',
      action: 'commented on',
      target: '5 days of losing body weight',
      date: '8/12/25',
      preview: 'A awesome tips',
      imageUrl: 'https://picsum.photos/200/200?random=10',
    ),
    NotificationModel(
      id: '2',
      title: 'Liza Martine',
      action: 'Messaged you',
      target: '',
      date: '8/12/25',
      preview: 'I am getting pain on my knees, what should i do?',
    ),
    NotificationModel(
      id: '3',
      title: '40',
      action: 'new view on',
      target: '5 days of losing body weight',
      date: '8/12/25',
      preview: 'I am getting pain on my knees, what should i do?',
      imageUrl: 'https://picsum.photos/200/200?random=11',
    ),
    NotificationModel(
      id: '4',
      title: '25',
      action: 'new like on',
      target: '5 days of losing body weight',
      date: '8/12/25',
      imageUrl: 'https://picsum.photos/200/200?random=12',
    ),
  ];
}

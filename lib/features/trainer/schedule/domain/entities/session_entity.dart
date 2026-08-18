/// Domain Entity representing a training session
class SessionEntity {
  final String id;
  final DateTime date;
  final String time;
  final String clientName;
  final String clientId;
  final SessionType type;
  final String? aiNote;
  final String? sessionNote;
  final String? sessionId;
  final bool isCompleted;
  final bool isCancelled;

  const SessionEntity({
    required this.id,
    required this.date,
    required this.time,
    required this.clientName,
    required this.clientId,
    required this.type,
    this.aiNote,
    this.sessionNote,
    this.sessionId,
    this.isCompleted = false,
    this.isCancelled = false,
  });

  String get dateLabel => _formatDate(date);

  String _formatDate(DateTime date) {
    final months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  String get shortDateLabel => dateLabel.split(' ')[0];
  String get monthLabel => dateLabel.split(' ')[1];

  bool get isVirtual => type == SessionType.virtualTherapy;
  String get sessionTitle => isVirtual 
      ? 'Virtual physical therapy session.' 
      : 'Quick follow-up chat.';
}

enum SessionType {
  virtualTherapy,
  followUpChat,
}

class AnamCallArgs {
  const AnamCallArgs({
    required this.trainerId,
    required this.trainerName,
    this.continueStoredSession = false,
  });

  final String trainerId;
  final String trainerName;
  final bool continueStoredSession;
}

class ChatScreenArgs {
  const ChatScreenArgs({
    required this.displayName,
    this.trainerId,
    this.subtitle = 'Active now',
    this.isAnamEnabled = false,
  });

  final String displayName;
  final String? trainerId;
  final String subtitle;
  final bool isAnamEnabled;
}

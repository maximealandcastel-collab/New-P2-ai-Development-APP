import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'api_urls.dart';

class TrainerChatMessage {
  const TrainerChatMessage({
    required this.id,
    required this.senderUserId,
    required this.senderRole,
    required this.content,
    required this.createdAt,
    this.readAt,
  });

  final String id;
  final String senderUserId;
  final String senderRole;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;

  bool isMine(String currentUserId) => senderUserId == currentUserId;

  factory TrainerChatMessage.fromJson(Map<String, dynamic> json) {
    return TrainerChatMessage(
      id: json['id']?.toString() ?? '',
      senderUserId: json['senderUserId']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      readAt: DateTime.tryParse(json['readAt']?.toString() ?? ''),
    );
  }
}

class TrainerChatPerson {
  const TrainerChatPerson({
    required this.id,
    required this.name,
    this.userId,
    this.firstName,
    this.specialty,
    this.profileImage,
  });

  final String id;
  final String name;
  final String? userId;
  final String? firstName;
  final String? specialty;
  final String? profileImage;

  factory TrainerChatPerson.fromJson(Map<String, dynamic> json) {
    return TrainerChatPerson(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      userId: json['userId']?.toString(),
      firstName: json['firstName']?.toString(),
      specialty: json['specialty']?.toString(),
      profileImage: json['profileImage']?.toString(),
    );
  }
}

class TrainerConversation {
  const TrainerConversation({
    required this.id,
    required this.currentUserId,
    required this.customer,
    required this.trainer,
    required this.messages,
  });

  final String id;
  final String currentUserId;
  final TrainerChatPerson customer;
  final TrainerChatPerson trainer;
  final List<TrainerChatMessage> messages;

  factory TrainerConversation.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] is List
        ? json['messages'] as List
        : const <dynamic>[];
    return TrainerConversation(
      id: json['id']?.toString() ?? '',
      currentUserId: json['currentUserId']?.toString() ?? '',
      customer: TrainerChatPerson.fromJson(
        Map<String, dynamic>.from(json['customer'] as Map? ?? const {}),
      ),
      trainer: TrainerChatPerson.fromJson(
        Map<String, dynamic>.from(json['trainer'] as Map? ?? const {}),
      ),
      messages: rawMessages
          .whereType<Map>()
          .map((message) => TrainerChatMessage.fromJson(
                Map<String, dynamic>.from(message),
              ))
          .toList(),
    );
  }
}

class TrainerMessagingException implements Exception {
  const TrainerMessagingException(this.message);
  final String message;

  @override
  String toString() => message;
}

class TrainerMessagingService {
  TrainerMessagingService._();
  static final instance = TrainerMessagingService._();

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    for (final key in const [
      'accessToken',
      'bearerToken',
      'token',
      'authToken',
      'jwt',
    ]) {
      final value = prefs.getString(key);
      if (value != null && value.isNotEmpty) return value;
    }
    throw const TrainerMessagingException(
      'Please sign in again to open trainer messages.',
    );
  }

  Future<Map<String, String>> _headers() async => {
        'Authorization': 'Bearer ${await _token()}',
        'Content-Type': 'application/json',
      };

  Future<TrainerConversation> load({String? customerUserId}) async {
    final query = customerUserId == null || customerUserId.isEmpty
        ? ''
        : '?userId=${Uri.encodeQueryComponent(customerUserId)}';
    final response = await http.get(
      Uri.parse('${ApiUrls.baseUrl}${ApiUrls.trainerConversation}$query'),
      headers: await _headers(),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TrainerMessagingException(
        body['message']?.toString() ?? 'Unable to load messages.',
      );
    }
    return TrainerConversation.fromJson(
      Map<String, dynamic>.from(body['data'] as Map? ?? const {}),
    );
  }

  Future<TrainerChatMessage> send({
    required String message,
    String? customerUserId,
  }) async {
    final response = await http.post(
      Uri.parse(
        '${ApiUrls.baseUrl}${ApiUrls.trainerConversationMessages}',
      ),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
        if (customerUserId != null && customerUserId.isNotEmpty)
          'userId': customerUserId,
      }),
    );
    final body = _decode(response);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TrainerMessagingException(
        body['message']?.toString() ?? 'Your message could not be sent.',
      );
    }
    final data = Map<String, dynamic>.from(body['data'] as Map? ?? const {});
    return TrainerChatMessage.fromJson(
      Map<String, dynamic>.from(data['message'] as Map? ?? const {}),
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    try {
      return Map<String, dynamic>.from(jsonDecode(response.body) as Map);
    } catch (_) {
      throw const TrainerMessagingException(
        'The messaging service returned an invalid response.',
      );
    }
  }
}
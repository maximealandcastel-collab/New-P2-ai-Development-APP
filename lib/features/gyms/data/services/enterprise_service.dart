import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/services/api_urls.dart';
import '../models/tenant_configuration.dart';

class EnterpriseException implements Exception {
  final String message;
  final int? status;
  const EnterpriseException(this.message, [this.status]);
  @override
  String toString() => message;
}

/// No protected data is persisted. Each request belongs to a session generation.
/// Backend authorization is mandatory; these guards only protect client state.
class EnterpriseService {
  static EnterpriseService _instance = EnterpriseService();
  static EnterpriseService get instance => _instance;
  @visibleForTesting
  static void replaceForTesting(EnterpriseService service) {
    _instance = service;
  }

  final http.Client _client;
  final void Function(String) _diagnostic;
  final String baseUrl;
  final String? Function() _token;
  final active = ValueNotifier<EnterpriseContext?>(null);
  int _generation = 0;
  bool _switching = false;
  EnterpriseService({
    http.Client? client,
    void Function(String)? diagnostic,
    String? baseUrl,
    String? Function()? token,
  }) : _client = client ?? http.Client(),
       _diagnostic =
           diagnostic ??
           ((message) {
             if (kDebugMode) debugPrint(message);
           }),
       baseUrl = baseUrl ?? ApiUrls.baseUrl,
       _token = token ?? (() => CacheService().get<String>('accessToken'));

  void clear() {
    _generation++;
    active.value = null;
  }

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final generation = _generation;
    final token = authenticated ? _token() : null;
    if (authenticated && (token == null || token.isEmpty)) {
      throw const EnterpriseException('Please sign in to continue.', 401);
    }
    final request = http.Request(method, Uri.parse('$baseUrl$path'))
      ..followRedirects = false;
    request.headers.addAll({
      'Accept': 'application/json',
      if (authenticated) 'Authorization': 'Bearer $token',
    });
    if (body != null) {
      request.headers['Content-Type'] = 'application/json';
      request.body = jsonEncode(body);
    }
    // Deliberately exclude headers, query strings, credentials and payloads.
    final target = '${request.url.origin}${request.url.path}';
    late http.Response response;
    try {
      response = await (() async => http.Response.fromStream(
        await _client.send(request),
      ))().timeout(const Duration(seconds: 25));
    } catch (_) {
      _diagnostic('[Enterprise] $method $target: transport failure');
      rethrow;
    }
    _diagnostic('[Enterprise] $method $target: HTTP ${response.statusCode}');
    if (generation != _generation) {
      throw const EnterpriseException('Gym context changed. Please reload.');
    }
    if (response.statusCode == 401 || response.statusCode == 403) {
      if (authenticated) clear();
      throw EnterpriseException(
        'Your gym access is unavailable. Please sign in or select a gym again.',
        response.statusCode,
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw EnterpriseException(
        'Unable to complete this request. Please retry.',
        response.statusCode,
      );
    }
    if (response.statusCode == 204) return {};
    final decoded = jsonDecode(response.body);
    if (decoded is! Map ||
        decoded['success'] == false ||
        decoded['data'] is! Map) {
      throw const EnterpriseException('Invalid enterprise service response.');
    }
    return Map<String, dynamic>.from(decoded['data'] as Map);
  }

  /// Public intake only. The server must verify licensing and authority before
  /// creating a tenant, membership, or admin privileges.
  Future<String> submitGymApplication(Map<String, dynamic> application) async {
    final data = await request(
      '/enterprise/gym-applications',
      method: 'POST',
      authenticated: false,
      body: application,
    );
    final id = data['applicationId'];
    if (id is! String ||
        id.trim().isEmpty ||
        data['status'] != 'pending_review') {
      throw const EnterpriseException('Invalid application receipt.');
    }
    return id;
  }

  /// Public intake. Requested roles and codes never grant client-side access.
  Future<String> requestStaffAccess(Map<String, dynamic> application) async {
    final data = await request(
      '/enterprise/staff-access-requests',
      method: 'POST',
      authenticated: false,
      body: application,
    );
    final id = data['requestId'];
    if (id is! String || id.trim().isEmpty || data['status'] != 'pending_review') {
      throw const EnterpriseException('Invalid staff access receipt.');
    }
    return id;
  }

  Future<EnterprisePage> directory({
    String? cursor,
    String query = '',
    String? tag,
  }) async {
    final params = Uri(
      queryParameters: {
        'limit': '30',
        if (cursor != null) 'cursor': cursor,
        if (query.isNotEmpty) 'q': query,
        if (tag != null) 'tag': tag,
      },
    ).query;
    return EnterprisePage.fromJson(
      await request('/enterprise/tenants?$params', authenticated: false),
    );
  }

  Future<EnterprisePage> memberships({
    String? cursor,
  }) async => EnterprisePage.fromJson(
    await request(
      '/enterprise/me/memberships?limit=30${cursor == null ? '' : '&cursor=${Uri.encodeQueryComponent(cursor)}'}',
    ),
  );

  Future<void> restore() async {
    clear();
    final generation = _generation;
    final data = await request('/enterprise/me/context');
    if (generation != _generation)
      throw const EnterpriseException('Session changed.');
    active.value = data['context'] == null
        ? null
        : EnterpriseContext.fromJson(
            Map<String, dynamic>.from(data['context'] as Map),
          );
  }

  Future<void> switchTenant(String? tenantId) async {
    if (_switching)
      throw const EnterpriseException('A gym switch is already in progress.');
    _switching = true;
    clear();
    final generation = _generation;
    try {
      final data = await request(
        '/enterprise/me/context',
        method: 'PUT',
        body: {'tenantId': tenantId},
      );
      if (generation != _generation)
        throw const EnterpriseException('Session changed.');
      final context = data['context'] == null
          ? null
          : EnterpriseContext.fromJson(
              Map<String, dynamic>.from(data['context'] as Map),
            );
      if (context?.tenant.id != tenantId)
        throw const EnterpriseException('Invalid gym context.');
      active.value = context;
    } finally {
      _switching = false;
    }
  }

  Future<Map<String, dynamic>> scoped(
    String resource, {
    String method = 'GET',
    Map<String, dynamic>? body,
    bool admin = false,
  }) {
    final context = active.value;
    if (context == null || (admin && !context.isAdmin)) {
      throw const EnterpriseException(
        'An authorized gym session is required.',
        403,
      );
    }
    return request(
      '/enterprise/tenants/${Uri.encodeComponent(context.tenant.id)}/${admin ? 'admin' : 'member'}/$resource',
      method: method,
      body: body,
    );
  }
}

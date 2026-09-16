import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
  /// Address/location discovery only; never grants gym ownership or access.
  Future<List<TenantConfiguration>> searchFacilities(String address, {double? latitude, double? longitude, String? kind}) async {
    if(address.trim().length<3 && (latitude==null || longitude==null)) return const [];
    final query=Uri(queryParameters:{'address':address.trim(),if(kind!=null)'kind':kind,if(latitude!=null)'lat':'$latitude',if(longitude!=null)'lng':'$longitude'}).query;
    final result=await request('/enterprise/gym-search?$query',authenticated:false);
    return (result['items'] as List? ?? []).whereType<Map>().where((item) {
      final locations=item['locations'];
      return locations is List && locations.isNotEmpty && locations.first is Map && locations.first['countryCode']=='US';
    }).map((item)=>TenantConfiguration.fromJson(Map<String,dynamic>.from(item))).toList();
  }


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
  final bootstrapData = ValueNotifier<Map<String, dynamic>>({});
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
    bootstrapData.value = {};
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
    if (generation != _generation || (authenticated && token != _token())) {
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

  Future<String> uploadGymLogo(String filePath) async {
    final token = _token();
    if (token == null || token.isEmpty) {
      throw const EnterpriseException('Please sign in to upload a gym logo.', 401);
    }
    final upload = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/enterprise/gym-assets/logo'),
    )
      ..headers['Accept'] = 'application/json'
      ..headers['Authorization'] = 'Bearer $token'
      ..files.add(await http.MultipartFile.fromPath('logo', filePath));
    final response = await http.Response.fromStream(
      await _client.send(upload).timeout(const Duration(seconds: 30)),
    );
    final decoded = jsonDecode(response.body);
    if (response.statusCode < 200 || response.statusCode >= 300 || decoded is! Map) {
      throw EnterpriseException('Unable to upload the gym logo.', response.statusCode);
    }
    final data = decoded['data'];
    final logoUrl = data is Map ? data['logoUrl'] : null;
    if (logoUrl is! String || !logoUrl.startsWith('https://')) {
      throw const EnterpriseException('The gym logo upload returned an invalid address.');
    }
    return logoUrl;
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
    if (id is! String ||
        id.trim().isEmpty ||
        data['status'] != 'pending_review') {
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

  Future<void> refreshAccess() async {
    try {
      final data = await request('/enterprise/me/bootstrap');
      final unchanged =
          jsonEncode(data['context']) ==
          jsonEncode(bootstrapData.value['context']);
      bootstrapData.value = data;
      if (!unchanged)
        active.value = data['context'] == null
            ? null
            : EnterpriseContext.fromJson(
                Map<String, dynamic>.from(data['context'] as Map),
              );
    } catch (_) {
      clear();
      rethrow;
    }
  }

  Future<void> restore() async {
    clear();
    final generation = _generation;
    final data = await request('/enterprise/me/bootstrap');
    if (generation != _generation)
      throw const EnterpriseException('Session changed.');
    bootstrapData.value = data;
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
      bootstrapData.value = data;
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

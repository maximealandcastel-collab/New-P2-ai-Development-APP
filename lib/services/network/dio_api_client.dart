
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:pler_to_pler_app/core/utils/helpers/prefs_helper.dart';

class NetworkResponseModel {
  final int statusCode;
  final bool isSuccess;
  dynamic responseBody;
  String errorMassage;

  NetworkResponseModel({
    required this.statusCode,
    required this.isSuccess,
    this.responseBody,
    this.errorMassage = 'something went wrong',
  });
}
// ============================================================================
// LOGGER CONFIGURATION
// ============================================================================
final log = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    colors: true,
    printEmojis: true,
  ),
);

// ============================================================================
// HTTP METHODS ENUM
// ============================================================================
enum HttpMethod { get, post, put, patch, delete }

// ============================================================================
// NETWORK CALLER - SINGLETON CLASS
// ============================================================================
/// Centralized network service using Dio
///
/// Features:
/// - Automatic token management
/// - Comprehensive error handling
/// - Support for all HTTP methods
/// - File upload/download support
/// - Request/Response logging
///
/// Usage:
/// ```dart
/// final response = await NetworkCaller.instance.getRequest(url: 'https://api.example.com/data');
/// if (response.isSuccess) {
///   // Handle success
/// }
/// ```
class NetworkCaller {
  // ==========================================================================
  // SINGLETON SETUP
  // ==========================================================================
  NetworkCaller._();
  static final NetworkCaller _instance = NetworkCaller._();
  static NetworkCaller get instance => _instance;

  // ==========================================================================
  // PROPERTIES
  // ==========================================================================
  String? _cachedBearerToken;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  // ==========================================================================
  // TOKEN MANAGEMENT
  // ==========================================================================

  /// Initialize or refresh bearer token from storage
  Future<void> updateToken() async {
    _cachedBearerToken = await PrefsHelper.getString('token');
    log.i('🔑 Token updated');
  }

  /// Clear cached token (call on logout)
  void clearToken() {
    _cachedBearerToken = null;
    log.i('🔓 Token cleared');
  }

  // ==========================================================================
  // PRIVATE HELPERS
  // ==========================================================================

  /// Build request headers with optional bearer token
  Future<Map<String, String>> _getHeaders([Map<String, String>? customHeaders]) async {
    _cachedBearerToken = await PrefsHelper.getString('token');
    print(_cachedBearerToken);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_cachedBearerToken?.isNotEmpty ?? false)
        'Authorization': 'Bearer $_cachedBearerToken',
    };

    if (customHeaders != null) headers.addAll(customHeaders);
    return headers;
  }

  /// Execute HTTP request with comprehensive error handling
  Future<NetworkResponseModel> _executeRequest({
    required Future<Response> Function() requestFunction,
    required String url,
    required String method,
  }) async {
    try {
      _logRequestStart(method, url);

      final response = await requestFunction();

      _logResponse(method, url, response);

      return _buildResponse(response);

    } on DioException catch (e) {
      _logDioError(method, e);
      return _handleDioException(e);

    } catch (e, stackTrace) {
      _logUnexpectedError(method, e, stackTrace);
      return _handleUnexpectedException();
    }
  }

  /// Build NetworkResponseModel from HTTP response
  NetworkResponseModel _buildResponse(Response response) {
    final statusCode = response.statusCode ?? -1;
    final isSuccess = statusCode >= 200 && statusCode < 300;

    if (isSuccess) {
      return NetworkResponseModel(
        statusCode: statusCode,
        isSuccess: true,
        responseBody: response.data,
      );
    }

    final errorMessage = _extractErrorMessage(response.data);
    log.w('⚠️ Request failed [$statusCode]: $errorMessage');

    return NetworkResponseModel(
      statusCode: statusCode,
      isSuccess: false,
      errorMassage: errorMessage,
    );
  }

  /// Extract error message from response data
  String _extractErrorMessage(dynamic data) {
    if (data is Map) {
      return data['message']?.toString() ??
          data['error']?.toString() ??
          'Request failed';
    }
    return 'Request failed';
  }

  /// Handle DioException and return appropriate NetworkResponseModel
  NetworkResponseModel _handleDioException(DioException e) {
    return NetworkResponseModel(
      statusCode: e.response?.statusCode ?? -1,
      isSuccess: false,
      errorMassage: _getDioErrorMessage(e),
    );
  }

  /// Handle unexpected exceptions
  NetworkResponseModel _handleUnexpectedException() {
    return NetworkResponseModel(
      statusCode: -1,
      isSuccess: false,
      errorMassage: 'An unexpected error occurred',
    );
  }

  /// Get user-friendly error message from DioException
  String _getDioErrorMessage(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet.';

      case DioExceptionType.badResponse:
        return _getStatusCodeMessage(e.response?.statusCode, e.response?.data);

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.connectionError:
        return 'No internet connection';

      case DioExceptionType.badCertificate:
        return 'Security certificate error';

      default:
        return e.message ?? 'Network error occurred';
    }
  }

  /// Get specific error message based on HTTP status code
  String _getStatusCodeMessage(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access forbidden';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Server error. Please try again later.';
      default:
        return data?['message'] ?? 'Request failed';
    }
  }

  // ==========================================================================
  // LOGGING HELPERS
  // ==========================================================================

  void _logRequestStart(String method, String url) {
    log.i('|📍|---------- [$method] REQUEST ----------|📍|');
    log.i('URL: $url');
  }

  void _logResponse(String method, String url, Response response) {
    log.i('=====> Response [$method]: ${response.statusCode}');
    log.i('=====> API: [${response.statusCode}] $url');
    log.i('Body: ${response.data}');
  }

  void _logDioError(String method, DioException e) {
    log.e('🐞 DioException [$method]: ${e.message}');
    log.e('Type: ${e.type}');
    if (e.response != null) {
      log.e('Response: ${e.response?.data}');
    }
  }

  void _logUnexpectedError(String method, Object error, StackTrace stackTrace) {
    log.e('🐞 Unexpected Error [$method]: $error');
    log.e('Stacktrace: $stackTrace');
  }

  // ==========================================================================
  // PUBLIC HTTP METHODS
  // ==========================================================================

  /// GET request
  Future<NetworkResponseModel> getRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final requestHeaders = await _getHeaders(headers);
    log.i('Headers: $requestHeaders');

    if (queryParameters != null) {
      log.i('Query: $queryParameters');
    }

    return _executeRequest(
      requestFunction: () => _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: requestHeaders),
      ),
      url: url,
      method: 'GET',
    );
  }

  /// POST request
  Future<NetworkResponseModel> postRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _requestWithBody(
      url: url,
      method: HttpMethod.post,
      body: body,
      headers: headers,
    );
  }

  /// PUT request
  Future<NetworkResponseModel> putRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _requestWithBody(
      url: url,
      method: HttpMethod.put,
      body: body,
      headers: headers,
    );
  }

  /// PATCH request
  Future<NetworkResponseModel> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    return _requestWithBody(
      url: url,
      method: HttpMethod.patch,
      body: body,
      headers: headers,
    );
  }

  /// DELETE request
  Future<NetworkResponseModel> deleteRequest({
    required String url,
    Map<String, String>? headers,
    Map<String, dynamic>? body,
  }) async {
    final requestHeaders = await _getHeaders(headers);
    log.i('Headers: $requestHeaders');

    if (body != null) {
      log.i('Body: $body');
    }

    return _executeRequest(
      requestFunction: () => _dio.delete(
        url,
        data: body,
        options: Options(headers: requestHeaders),
      ),
      url: url,
      method: 'DELETE',
    );
  }

  /// Generic request with body (POST, PUT, PATCH)
  Future<NetworkResponseModel> _requestWithBody({
    required String url,
    required HttpMethod method,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    final requestHeaders = await _getHeaders(headers);
    log.i('Headers: $requestHeaders');
    log.i('Body: $body');

    return _executeRequest(
      requestFunction: () => _getDioMethodWithBody(method, url, body, requestHeaders),
      url: url,
      method: method.name.toUpperCase(),
    );
  }

  /// Get appropriate Dio method for request with body
  Future<Response> _getDioMethodWithBody(
      HttpMethod method,
      String url,
      Map<String, dynamic>? body,
      Map<String, String> headers,
      ) {
    final options = Options(headers: headers);

    switch (method) {
      case HttpMethod.post:
        return _dio.post(url, data: body, options: options);
      case HttpMethod.put:
        return _dio.put(url, data: body, options: options);
      case HttpMethod.patch:
        return _dio.patch(url, data: body, options: options);
      default:
        throw UnsupportedError('Method $method not supported');
    }
  }

  // ==========================================================================
  // FILE UPLOAD
  // ==========================================================================

  /// Upload files using multipart/form-data
  Future<NetworkResponseModel> multipartRequest({
    required String url,
    required Map<String, dynamic> body,
    Map<String, String>? headers,
    HttpMethod method = HttpMethod.post,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final methodName = method.name.toUpperCase();
      log.i('|📍|---------- [$methodName MULTIPART] ----------|📍|');
      log.i('URL: $url');

      final requestHeaders = await _getHeaders(headers);
      requestHeaders.remove('Content-Type'); // Let Dio set multipart Content-Type

      log.i('Headers: $requestHeaders');
      _logMultipartBody(body);

      final formData = FormData.fromMap(body);
      final response = await _executeMultipartRequest(
        method: method,
        url: url,
        formData: formData,
        headers: requestHeaders,
        onSendProgress: onSendProgress,
      );

      log.i('=====> Response [$methodName Multipart]: ${response.statusCode}');
      log.i('Body: ${response.data}');

      return _buildResponse(response);

    } on DioException catch (e) {
      _logDioError('MULTIPART', e);
      return _handleDioException(e);

    } catch (e, stackTrace) {
      _logUnexpectedError('MULTIPART', e, stackTrace);
      return NetworkResponseModel(
        statusCode: -1,
        isSuccess: false,
        errorMassage: 'Upload failed: ${e.toString()}',
      );
    }
  }

  /// Execute multipart request based on HTTP method
  Future<Response> _executeMultipartRequest({
    required HttpMethod method,
    required String url,
    required FormData formData,
    required Map<String, String> headers,
    ProgressCallback? onSendProgress,
  }) {
    final options = Options(headers: headers);

    switch (method) {
      case HttpMethod.post:
        return _dio.post(url, data: formData, options: options, onSendProgress: onSendProgress);
      case HttpMethod.put:
        return _dio.put(url, data: formData, options: options, onSendProgress: onSendProgress);
      case HttpMethod.patch:
        return _dio.patch(url, data: formData, options: options, onSendProgress: onSendProgress);
      default:
        throw UnsupportedError('Method $method not supported for multipart');
    }
  }

  /// Log multipart request body with file count
  void _logMultipartBody(Map<String, dynamic> body) {
    int fileCount = 0;
    body.forEach((key, value) {
      if (value is MultipartFile) {
        fileCount++;
        log.i('File: $key - ${value.filename}');
      }
    });
    log.i('Body Keys: ${body.keys.toList()} | Files: $fileCount');
  }

  // ── Create MultipartFile from path ────────────────────
   Future<MultipartFile> toMultipartFile(String filePath, {String? fileName}) async {
    final name = fileName ?? filePath.split('/').last;
    final mimeType = _getMimeType(filePath);

    return MultipartFile.fromFile(
      filePath,
      filename: name,
      contentType: DioMediaType.parse(mimeType),
    );
  }

  // ── Detect mime type from extension ──────────────────
   String _getMimeType(String filePath) {
    final ext = filePath.split('.').last.toLowerCase();

    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png'           => 'image/png',
      'gif'           => 'image/gif',
      'webp'          => 'image/webp',
      'pdf'           => 'application/pdf',
      'mp4'           => 'video/mp4',
      'mov'           => 'video/quicktime',
      'mp3'           => 'audio/mpeg',
      'doc'           => 'application/msword',
      'docx'          => 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls'           => 'application/vnd.ms-excel',
      'xlsx'          => 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'zip'           => 'application/zip',
      'txt'           => 'text/plain',
      _               => 'application/octet-stream',
    };
  }

  // ==========================================================================
  // FILE DOWNLOAD
  // ==========================================================================

  /// Download file with progress tracking
  Future<NetworkResponseModel> downloadFile({
    required String url,
    required String savePath,
    Map<String, String>? headers,
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      log.i('|📍|---------- [DOWNLOAD] ----------|📍|');
      log.i('URL: $url');
      log.i('Path: $savePath');

      final requestHeaders = await _getHeaders(headers);
      log.i('Headers: $requestHeaders');

      await _dio.download(
        url,
        savePath,
        options: Options(headers: requestHeaders),
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
      );

      log.i('✅ Download completed: $savePath');

      return NetworkResponseModel(
        statusCode: 200,
        isSuccess: true,
        responseBody: {'path': savePath},
      );

    } on DioException catch (e) {
      _logDioError('DOWNLOAD', e);
      return _handleDioException(e);

    } catch (e, stackTrace) {
      _logUnexpectedError('DOWNLOAD', e, stackTrace);
      return NetworkResponseModel(
        statusCode: -1,
        isSuccess: false,
        errorMassage: 'Download failed: ${e.toString()}',
      );
    }
  }

  // ==========================================================================
  // INTERCEPTOR MANAGEMENT
  // ==========================================================================

  /// Add custom interceptor (for logging, token refresh, etc.)
  void addInterceptor(Interceptor interceptor) {
    _dio.interceptors.add(interceptor);
    log.i('✅ Interceptor added');
  }

  /// Remove all interceptors
  void clearInterceptors() {
    _dio.interceptors.clear();
    log.i('🗑️ Interceptors cleared');
  }
}
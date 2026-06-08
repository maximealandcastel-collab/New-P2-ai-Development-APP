import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pler_to_pler_app/core/constants/api_constants.dart';
import 'package:pler_to_pler_app/core/constants/app_constants.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';
import 'package:pler_to_pler_app/core/services/cache_service.dart';
import 'package:pler_to_pler_app/core/services/connectivity_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  late CacheService _cacheService;

  factory ApiService() => _instance;

  ApiService._internal();

  static Options get withoutAuth =>
      Options(headers: {ApiConstants.requiresAuthHeader: false});

  void init(
    ConnectivityService connectivityService,
    CacheService cacheService,
  ) {
    _cacheService = cacheService;
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        headers: ApiConstants.headers,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    //  _dio.interceptors.add(ConnectivityInterceptor(connectivityService));

    // ✅ Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final requiresAuth =
              options.headers[ApiConstants.requiresAuthHeader] != false;
          options.headers.remove(ApiConstants.requiresAuthHeader);

          if (requiresAuth) {
            final token = _cacheService.get<String>(AppConstants.accessToken);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }

          return handler.next(options);
        },

        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            await _cacheService.clear();
          }
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            final sep = '─' * 50;
            debugPrint(
              '\n🔵 ──── REQUEST ────────────────────────────────────',
            );
            debugPrint('   METHOD : ${options.method}');
            debugPrint('   PATH   : ${options.path}');
            if (options.headers.isNotEmpty) {
              debugPrint('   HEADERS: ${options.headers}');
            }
            if (options.queryParameters.isNotEmpty) {
              debugPrint('   PARAMS : ${options.queryParameters}');
            }
            if (options.data != null) {
              debugPrint('   BODY   : ${options.data}');
            }
            debugPrint('$sep\n');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            final sep = '─' * 50;
            debugPrint(
              '\n🟢 ──── RESPONSE ───────────────────────────────────',
            );
            debugPrint('   STATUS : ${response.statusCode}');
            debugPrint('   PATH   : ${response.requestOptions.path}');
            debugPrint('   BODY   : ${response.data}');
            debugPrint('$sep\n');
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          if (kDebugMode) {
            final sep = '─' * 50;
            debugPrint(
              '\n🔴 ──── ERROR ──────────────────────────────────────',
            );
            debugPrint('   STATUS    : ${error.response?.statusCode}');
            debugPrint('   PATH      : ${error.requestOptions.path}');
            debugPrint('   ERROR BODY: ${error.response?.data}');
            debugPrint('   SENT DATA : ${error.requestOptions.data}');
            debugPrint('$sep\n');
          }
          return handler.next(error);
        },
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Sends a POST request to the specified [path].
  ///
  /// Used for creating new resources on the server.
  ///
  /// **Parameters:**
  /// - [path]: API endpoint path
  /// - [data]: Request body data (can be Map, FormData, etc.)
  /// - [queryParameters]: Optional URL query parameters
  /// - [options]: Optional request configuration
  /// - [cancelToken]: Optional token to cancel the request
  ///
  /// **Example:**
  /// ```dart
  /// final response = await apiService.post(
  ///   '/users',
  ///   data: {'name': 'John', 'email': 'john@example.com'},
  /// );
  /// ```
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Sends a PUT request to the specified [path].
  ///
  /// Used for completely replacing an existing resource on the server.
  ///
  /// **Parameters:**
  /// - [path]: API endpoint path
  /// - [data]: Complete resource data to replace existing resource
  /// - [queryParameters]: Optional URL query parameters
  /// - [options]: Optional request configuration
  /// - [cancelToken]: Optional token to cancel the request
  ///
  /// **Example:**
  /// ```dart
  /// final response = await apiService.put(
  ///   '/users/123',
  ///   data: {'name': 'John Doe', 'email': 'john@example.com', 'age': 30},
  /// );
  /// ```
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Sends a PATCH request to the specified [path].
  ///
  /// Used for partially updating an existing resource on the server.
  ///
  /// **Parameters:**
  /// - [path]: API endpoint path
  /// - [data]: Partial resource data containing only fields to update
  /// - [queryParameters]: Optional URL query parameters
  /// - [options]: Optional request configuration
  /// - [cancelToken]: Optional token to cancel the request
  ///
  /// **Example:**
  /// ```dart
  /// final response = await apiService.patch(
  ///   '/users/123',
  ///   data: {'email': 'newemail@example.com'}, // Only updating email
  /// );
  /// ```
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Sends a DELETE request to the specified [path].
  ///
  /// Used for deleting an existing resource from the server.
  ///
  /// **Parameters:**
  /// - [path]: API endpoint path
  /// - [data]: Optional request body data
  /// - [queryParameters]: Optional URL query parameters
  /// - [options]: Optional request configuration
  /// - [cancelToken]: Optional token to cancel the request
  ///
  /// **Example:**
  /// ```dart
  /// final response = await apiService.delete('/users/123');
  /// ```
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Uploads a single file to the specified path
  ///
  /// Example usage:
  /// ```dart
  /// final file = await MultipartFile.fromFile('/path/to/file.jpg');
  /// final response = await _apiService.uploadFile(
  ///   '/api/upload',
  ///   file: file,
  ///   fileName: 'avatar.jpg',
  /// );
  /// ```
  Future<Response> uploadFile(
    String path, {
    MultipartFile? file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final map = <String, dynamic>{...?data};
      if (file != null) {
        map[fieldName] = file;
      }

      final formData = FormData.fromMap(map);

      return await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> uploadFilePatch(
    String path, {
    MultipartFile? file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final map = <String, dynamic>{...?data};
      if (file != null) {
        map[fieldName] = file;
      }

      final formData = FormData.fromMap(map);

      return await _dio.patch(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Uploads multiple files to the specified path
  ///
  /// Example usage:
  /// ```dart
  /// final files = [
  ///   await MultipartFile.fromFile('/path/to/file1.jpg', filename: 'file1.jpg'),
  ///   await MultipartFile.fromFile('/path/to/file2.jpg', filename: 'file2.jpg'),
  /// ];
  /// final response = await _apiService.uploadMultipleFiles(
  ///   '/api/upload',
  ///   files: files,
  ///   fieldName: 'images',
  /// );
  /// ```
  Future<Response> uploadMultipleFiles(
    String path, {
    required List<MultipartFile> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({fieldName: files, ...?data});

      return await _dio.post(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  Future<Response> uploadMultipleFilesPatch(
    String path, {
    required List<MultipartFile> files,
    String fieldName = 'files',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final formData = FormData.fromMap({fieldName: files, ...?data});

      return await _dio.patch(
        path,
        data: formData,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Uploads a file with progress tracking
  ///
  /// Example usage:
  /// ```dart
  /// final file = await MultipartFile.fromFile('/path/to/file.jpg');
  /// final response = await _apiService.uploadFileWithProgress(
  ///   '/api/upload',
  ///   file: file,
  ///   onSendProgress: (int sent, int total) {
  ///     double progress = (sent / total) * 100;
  ///     print('Upload progress: $progress%');
  ///   },
  /// );
  /// ```
  Future<Response> uploadFileWithProgress(
    String path, {
    required MultipartFile file,
    String fieldName = 'file',
    Map<String, dynamic>? data,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({fieldName: file, ...?data});

      return await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw UnknownException(e.toString());
    }
  }

  /// Converts DioException to typed AppException for better error handling.
  ///
  /// This method maps Dio's generic exceptions to our custom exception types,
  /// allowing for more specific error handling in the UI layer.
  ///
  /// **Mapping:**
  /// - Connection/Send/Receive Timeout → [TimeoutException]
  /// - Connection Error → [NoInternetException]
  /// - Bad Response (4xx, 5xx) → [ServerException]
  /// - Request Cancelled → [UnknownException]
  /// - Bad Certificate → [ServerException]
  /// - Socket Exception → [NoInternetException]
  /// - Other Unknown Errors → [UnknownException]
  ///
  /// **Example:**
  /// ```dart
  /// try {
  ///   await dio.get('/api/data');
  /// } on DioException catch (e) {
  ///   throw _handleDioError(e); // Converts to typed exception
  /// }
  /// ```
  AppException _handleDioError(DioException error) {
    switch (error.type) {
      // ─── Network ────────────────────────────────
      case DioExceptionType.connectionTimeout:
        return TimeoutException(
          'Connection timeout. Check your internet',
          error.message,
        );

      case DioExceptionType.sendTimeout:
        return TimeoutException(
          'Request took too long to send. Try again',
          error.message,
        );

      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          'Server took too long to respond. Try again',
          error.message,
        );

      case DioExceptionType.connectionError:
        return NoInternetException(error.message);

      case DioExceptionType.badCertificate:
        return SSLException(error.message);

      case DioExceptionType.cancel:
        return UnknownException('Request was cancelled');

      // ─── HTTP Response ───────────────────────────
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _parseErrorMessage(error.response?.data);

        return switch (statusCode) {
          // 4xx
          400 => BadRequestException(message, error.message),
          401 => UnauthorizedException(message, error.message),
          403 => ForbiddenException(message, error.message),
          404 => ResourceNotFoundException(message, error.message),
          405 => MethodNotAllowedException(error.message),
          406 => NotAcceptableException(error.message),
          408 => RequestTimeoutException(error.message),
          409 => ConflictException(message, error.message),
          410 => GoneException(error.message),
          415 => UnprocessableException(
            'Unsupported media type',
            error.message,
          ),
          422 => ValidationException([message], error.message),
          429 => TooManyRequestsException(error.message),
          // 5xx
          500 => InternalServerException(error.message),
          501 => NotImplementedException(error.message),
          502 => ServerDownException(502, error.message),
          503 => ServiceUnavailableException(error.message),
          504 => GatewayTimeoutException(error.message),
          505 => HttpVersionException(error.message),
          507 => InsufficientStorageException(error.message),
          511 => NetworkAuthException(error.message),
          // fallback
          _ => ServerException(message, statusCode, error.message),
        };

      // ─── Unknown ─────────────────────────────────
      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return NoInternetException(error.message);
        }
        if (error.message?.contains('HandshakeException') ?? false) {
          return SSLException(error.message);
        }
        if (error.message?.contains('HttpException') ?? false) {
          return ServerException('HTTP error occurred', null, error.message);
        }
        return UnknownException(error.message);
    }
  }

  String _parseErrorMessage(dynamic data) {
    if (data is! Map<String, dynamic>) return 'Server error';
    return data['message'] ??
        data['error'] ??
        data['msg'] ??
        data['errors']?[0]?['message'] ??
        'Server error';
  }

  void dispose() {
    _dio.close();
  }
}

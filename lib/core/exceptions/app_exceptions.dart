abstract class AppException implements Exception {
  final String message;
  final String? details;
  final String? errorCode;
  final bool isOffline;

  AppException(this.message, {this.details, this.errorCode, this.isOffline = false});

  /// Only [message] — never [details].
  ///
  /// `details` carries the underlying transport error, which for Dio is a
  /// paragraph explaining `validateStatus`, quoting the HTTP spec and linking
  /// to MDN. Appending it here put that paragraph on screen: a user who
  /// mistyped their password was shown "Wrong password! 3 attempts
  /// remaining.: This exception was thrown because the response has a status
  /// code of 401 … you have to fix the server code."
  ///
  /// `details` is still available on the object for logging; it just no longer
  /// rides along into anything that stringifies an exception for display.
  @override
  String toString() => message;
}

// ═══════════════════════════════════════════════
// NETWORK
// ═══════════════════════════════════════════════
class NoInternetException extends AppException {
  NoInternetException([String? details])
      : super('No internet connection', details: details, errorCode: 'NO_INTERNET', isOffline: true);
}

class TimeoutException extends AppException {
  TimeoutException([String? message, String? details])
      : super(message ?? 'Request timeout', details: details, errorCode: 'TIMEOUT');
}

class SSLException extends AppException {
  SSLException([String? details])
      : super('Secure connection failed', details: details, errorCode: 'SSL_ERROR');
}

// ═══════════════════════════════════════════════
// 4xx CLIENT ERRORS
// ═══════════════════════════════════════════════
class BadRequestException extends AppException {
  BadRequestException([String? message, String? details])
      : super(message ?? 'Bad request. Please check your input', details: details, errorCode: 'BAD_REQUEST');
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message, String? details])
      : super(message ?? 'Unauthorized access', details: details, errorCode: 'UNAUTHORIZED');
}

class ForbiddenException extends AppException {
  ForbiddenException([String? message, String? details])
      : super(message ?? 'Access forbidden', details: details, errorCode: 'FORBIDDEN');
}

class ResourceNotFoundException extends AppException {
  ResourceNotFoundException([String? message, String? details])
      : super(message ?? 'Requested resource not found', details: details, errorCode: 'NOT_FOUND');
}

class MethodNotAllowedException extends AppException {
  MethodNotAllowedException([String? details])
      : super('Method not allowed', details: details, errorCode: 'METHOD_NOT_ALLOWED');
}

class NotAcceptableException extends AppException {
  NotAcceptableException([String? details])
      : super('Request not acceptable', details: details, errorCode: 'NOT_ACCEPTABLE');
}

class RequestTimeoutException extends AppException {
  RequestTimeoutException([String? details])
      : super('Request timeout. Try again', details: details, errorCode: 'REQUEST_TIMEOUT');
}

class ConflictException extends AppException {
  ConflictException([String? message, String? details])
      : super(message ?? 'Conflict. Resource already exists', details: details, errorCode: 'CONFLICT');
}

class GoneException extends AppException {
  GoneException([String? details])
      : super('Resource no longer available', details: details, errorCode: 'GONE');
}

class ValidationException extends AppException {
  final List<String> errors;
  ValidationException(this.errors, [String? details])
      : super(errors.first, details: details, errorCode: 'VALIDATION_ERROR');
}

class UnprocessableException extends AppException {
  UnprocessableException([String? message, String? details])
      : super(message ?? 'Unprocessable request', details: details, errorCode: 'UNPROCESSABLE');
}

class TooManyRequestsException extends AppException {
  TooManyRequestsException([String? details])
      : super('Too many requests. Please slow down', details: details, errorCode: 'RATE_LIMIT');
}

// ═══════════════════════════════════════════════
// 5xx SERVER ERRORS
// ═══════════════════════════════════════════════
class InternalServerException extends AppException {
  InternalServerException([String? details])
      : super('Something went wrong on our end', details: details, errorCode: 'INTERNAL_SERVER_ERROR');
}

class NotImplementedException extends AppException {
  NotImplementedException([String? details])
      : super('Feature not implemented', details: details, errorCode: 'NOT_IMPLEMENTED');
}

class ServerDownException extends AppException {
  final int? statusCode;
  ServerDownException([this.statusCode, String? details])
      : super('Server is down. Please try again later', details: details, errorCode: 'SERVER_DOWN');
}

class ServiceUnavailableException extends AppException {
  ServiceUnavailableException([String? details])
      : super('Service unavailable. Please try again later', details: details, errorCode: 'SERVICE_UNAVAILABLE');
}

class GatewayTimeoutException extends AppException {
  GatewayTimeoutException([String? details])
      : super('Gateway timeout. Please try again', details: details, errorCode: 'GATEWAY_TIMEOUT');
}

class HttpVersionException extends AppException {
  HttpVersionException([String? details])
      : super('HTTP version not supported', details: details, errorCode: 'HTTP_VERSION_ERROR');
}

class InsufficientStorageException extends AppException {
  InsufficientStorageException([String? details])
      : super('Server storage is full', details: details, errorCode: 'INSUFFICIENT_STORAGE');
}

class NetworkAuthException extends AppException {
  NetworkAuthException([String? details])
      : super('Network authentication required', details: details, errorCode: 'NETWORK_AUTH_REQUIRED');
}

// ═══════════════════════════════════════════════
// DATA
// ═══════════════════════════════════════════════
class ParsingException extends AppException {
  ParsingException([String? details])
      : super('Failed to parse data', details: details, errorCode: 'PARSING_ERROR');
}

class CacheException extends AppException {
  CacheException([String? details])
      : super('Cache operation failed', details: details, errorCode: 'CACHE_ERROR');
}

class NotFoundException extends AppException {
  NotFoundException([String? details])
      : super('Data not found', details: details, errorCode: 'NOT_FOUND');
}

class UnknownException extends AppException {
  UnknownException([String? details])
      : super('An unexpected error occurred', details: details, errorCode: 'UNKNOWN');
}

// ═══════════════════════════════════════════════
// SERVER (generic fallback)
// ═══════════════════════════════════════════════
class ServerException extends AppException {
  final int? statusCode;

  ServerException(super.message, [this.statusCode, String? details])
      : super(details: details, errorCode: 'SERVER_ERROR');

  @override
  String toString() {
    if (statusCode != null) {
      return 'ServerException ($statusCode): $message${details != null ? ' - $details' : ''}';
    }
    return super.toString();
  }
}
// ═══════════════════════════════════════════════
// AUTH
// ═══════════════════════════════════════════════
/// Kept as an alias so existing `on UnAuthorizedException` handlers keep
/// compiling, but it is now the *same type* as [UnauthorizedException].
///
/// There were two classes here differing only by the capital A, and the
/// difference was invisible until someone typed a wrong password:
/// `api_service` threw `UnauthorizedException`, while `login_controller`
/// caught `UnAuthorizedException`. They never matched, so a 401 fell past its
/// own handler into the generic `catch (e)` and got stringified onto the
/// screen. One was thrown and never caught; the other caught and never thrown.
typedef UnAuthorizedException = UnauthorizedException;

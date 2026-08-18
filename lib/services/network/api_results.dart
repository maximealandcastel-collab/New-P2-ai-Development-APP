// core/network/api_result.dart

sealed class ApiResult<T> {
  const ApiResult();
  factory ApiResult.success(T data) = Success<T>;
  factory ApiResult.failure(String message) = Failure<T>;
}

class Success<T> extends ApiResult<T> {
  final T data;
  const Success(this.data);
}

class Failure<T> extends ApiResult<T> {
  final String message;
  const Failure(this.message);
}
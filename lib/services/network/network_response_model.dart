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
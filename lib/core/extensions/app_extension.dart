import 'package:flutter/material.dart';
import 'package:pler_to_pler_app/core/enums/loading_state.dart';
import 'package:pler_to_pler_app/core/exceptions/app_exceptions.dart';


extension LoadingStateX on LoadingState {
  bool get isLoading => this == LoadingState.loading;

  bool get isError => this == LoadingState.error;

  bool get isLoaded => this == LoadingState.loaded;

  bool get isInitial => this == LoadingState.initial;
}




extension AppExceptionX on Object {
  String get errorMessage {
    if (this is AppException) {
      final e = this as AppException;
      debugPrint('====================================>> Errored: ${e.toString()}');
      return e.message;
    }
    return toString();
  }
}





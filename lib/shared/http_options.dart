import 'package:dio/dio.dart';

bool acceptRedirectStatus(int? status) => status != null && status < 400;

Options requestOptions({ResponseType? responseType, String? contentType}) {
  return Options(
    responseType: responseType,
    contentType: contentType,
    validateStatus: acceptRedirectStatus,
    receiveDataWhenStatusError: true,
  );
}

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:sorting/widgets/message.dart';

var api = () {
  var dio = Dio(BaseOptions(
    contentType: ContentType.json.toString(),
    responseType: ResponseType.json,
    connectTimeout: 2000,
    sendTimeout: 1000,
    receiveTimeout: 1000,
  ));
  dio.interceptors.add(CookieManager(CookieJar()));
  dio.interceptors.add(InterceptorsWrapper(
    onResponse: (Response response) {},
    onError: (DioError e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        Messager.error('连接服务器超时');
      } else if (e.response?.statusCode == 401) {
        Messager.error('登录状态失效，请重新登录');
      } else {
        Messager.error(e.message);
      }
    },
  ));
  return dio;
}();

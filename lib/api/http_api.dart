import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:sorting/widgets/message.dart';

var api = () {
  var dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.1.109:9999',
    contentType: ContentType.json.toString(),
    responseType: ResponseType.json,
  ));
  dio.interceptors.add(CookieManager(CookieJar()));
  dio.interceptors.add(InterceptorsWrapper(
    onError: (DioError e) {
      Messager.error(e.message);
    },
  ));
  return dio;
}();

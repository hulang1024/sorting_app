import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

var api = () {
    var dio = new Dio(
        new BaseOptions(
            baseUrl: 'http://192.168.1.109:9999',
            contentType: ContentType.json.toString(),
            responseType: ResponseType.json
        ));
    dio.interceptors.add(CookieManager(CookieJar()));
    return dio;
}();


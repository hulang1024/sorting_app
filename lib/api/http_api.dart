import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:sorting/config.dart';
import 'package:sorting/widgets/message.dart';

bool _prepared = false;

/// 准备HTTP API。
/// 配置项server.hostname和server.port必须先存在，如果准备好了，返回true，否则返回false。
Future<bool> prepareHTTPAPI({bool reload = false}) async {
  if (reload) {
    api.options.baseUrl = '';
    _prepared = false;
  }
  if (_prepared) {
    return true;
  }
  var prefs = await ConfigurationManager.configuration();
  String hostname = prefs.getString('server.hostname') ?? '';
  String port = prefs.getString('server.port') ?? '';
  if (hostname.isEmpty || port.isEmpty) {
    return false;
  }
  api.options.baseUrl = 'http://$hostname:$port';
  _prepared = true;
  api.unlock();
  return _prepared;
}

var api = () {
  var dio = Dio(BaseOptions(
    contentType: ContentType.json.toString(),
    responseType: ResponseType.json,
    connectTimeout: 3000,
    sendTimeout: 3000,
    receiveTimeout: 3000,
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (RequestOptions request) {
      if (request.baseUrl.isEmpty) {
        dio.lock();
        request.connectTimeout = 0;
        Messager.warning('请先设置服务器');
        return null;
      }
    },
    onError: (DioError e) {
      if (e.type == DioErrorType.CONNECT_TIMEOUT) {
        Messager.error('连接服务器超时');
      } else if (e.response?.statusCode == 401) {
        Messager.warning('登录状态失效，请重新登录');
      } else {
        Messager.error(e.message);
      }
    },
  ));
  dio.interceptors.add(CookieManager(CookieJar()));

  prepareHTTPAPI();

  return dio;
}();
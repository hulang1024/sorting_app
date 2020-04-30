library api;

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../config.dart';
import '../widgets/message.dart';
part 'model/result.dart';
part '../entity/page.dart';

class HttpApi {
  Dio _dio;
  bool _prepared = false;
  bool _available = false;

  get options => _dio.options;

  get isAvailable => _available;

  HttpApi() {
    _dio = Dio(BaseOptions(
      contentType: ContentType.json.toString(),
      responseType: ResponseType.json,
      connectTimeout: 3000,
      sendTimeout: 3000,
      receiveTimeout: 3000,
    ));
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (RequestOptions request) {
        if (request.baseUrl.isEmpty) {
          _dio.lock();
          request.connectTimeout = 0;
          Messager.warning('请先设置服务器');
          return null;
        }
      },
      onResponse: (Response response) {
        // 判断是否返回的是Result的map，如果是就转换为Result对象
        if (response.data is Map) {
          Map<String, dynamic> map = response.data;
          if (['code', 'msg', 'data'].every((key) => map.containsKey(key))) {
            response.data = Result.fromMap(map);
          }
        }
        // 标记网络为可用状态
        if (!_available) {
          _available = true;
        }
      },
      onError: (DioError e) {
        if (e.type == DioErrorType.CONNECT_TIMEOUT) {
          Messager.error('连接服务器超时，请重试');
        } else if (e.response?.statusCode == 401) {
          Messager.warning('登录状态失效，请重新登录');
        } else {
          Messager.error(e.message);
        }
        // 标记网络为不可用状态
        _available = false;
      },
    ));
    _dio.interceptors.add(CookieManager(CookieJar()));

    prepare();
  }

  /// 准备HTTP API。
  /// 如果准备好了，返回true，否则返回false。
  Future<bool> prepare({bool reload = false}) async {
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

  Future<T> get<T>(
    String path, {
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onReceiveProgress,
    verbose : false,
  }) async {
    Response<T> response = await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
    return verbose ? response : response.data;
  }

  Future<T> post<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    verbose : false,
  }) async {
    Response<T> response = await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onReceiveProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return verbose ? response : response.data;
  }

  Future<T> delete<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    verbose : false,
  }) async {
    Response<T> response = await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
    return verbose ? response : response.data;
  }

  Future<T> put<T>(
    String path, {
    data,
    Map<String, dynamic> queryParameters,
    Options options,
    CancelToken cancelToken,
    ProgressCallback onSendProgress,
    ProgressCallback onReceiveProgress,
    verbose : false,
  }) async {
    Response<T> response = await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
    return verbose ? response : response.data;
  }

  void unlock() {
    _dio.unlock();
  }
}

var api = HttpApi();
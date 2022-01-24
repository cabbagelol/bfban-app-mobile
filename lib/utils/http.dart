/// http请求

import 'dart:async';

import 'package:flutter/material.dart';

export 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:bfban/constants/api.dart';

class Http extends ScaffoldState {
  static Dio dio = Dio();

  /// default options
  static const int CONNECT_TIMEOUT = 20000;
  static const int RECEIVE_TIMEOUT = 20000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  /// token
  static String? TOKEN = "";
  static BuildContext? CONTENT;

  static String setToken(String value) {
    return TOKEN = value;
  }

  static of(BuildContext content) {
    return CONTENT = content;
  }

  /// request method
  static Future request(
    String url, {
    typeUrl = "url",
    data,
    Map<String, dynamic>? parame,
    method,
    headers,
  }) async {
    Response result =
        Response(data: {}, requestOptions: RequestOptions(path: '/'));
    data = data ?? {};
    headers = headers ??
        {
          "token": "",
        };
    method = method ?? 'GET';

    if (TOKEN != "") {
      headers["token"] = TOKEN;
      headers["x-access-token"] = TOKEN;
    }

    /// restful 请求处理
    if (data is Map || data is List) {
      data.forEach((key, value) {
        if (url.contains(key)) {
          url = url.replaceAll(':$key', value.toString());
        }
      });
    }

    print('请求地址：【' + method + '  ${Config.apiHost[typeUrl] + '/' + url}】');

    Dio dio = createInstance();
    try {
      Response response = await dio.request(
        Config.apiHost[typeUrl] + url,
        data: data,
        queryParameters: parame,
        options: Options(
          method: method,
          headers: headers,
        ),
      );
      result = response;
      print('响应数据：' + response.toString());
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
          return Response(
            data: {'error': -1},
            requestOptions: RequestOptions(path: url),
          );
        case DioErrorType.response:
          return Response(
            data: {'error': -2},
            requestOptions: RequestOptions(path: url),
          );
        case DioErrorType.cancel:
          return Response(
            data: {'error': -3},
            requestOptions: RequestOptions(path: url),
          );
        case DioErrorType.connectTimeout:
          return Response(
            data: {'error': -4},
            requestOptions: RequestOptions(path: url),
          );
        case DioErrorType.sendTimeout:
          return Response(
            data: {'error': -6},
            requestOptions: RequestOptions(path: url),
          );
        case DioErrorType.other:
          // TODO: Handle this case.
          break;
      }
    }
    return result;
  }

  static Dio createInstance() {
    if (dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = BaseOptions(
        baseUrl: Config.apiHost['url'] + '/',
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );
      dio = Dio(options);
      dio.interceptors.add(
        CookieManager(CookieJar()),
      );
    }
    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio.clear();
  }
}

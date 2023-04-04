/// http请求

// ignore_for_file: constant_identifier_names, non_constant_identifier_names

import 'dart:async';

import 'package:bfban/utils/index.dart';
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
    String typeUrl = "network_service_request",
    data,
    Map<String, dynamic>? parame,
    method,
    headers,
  }) async {
    Response result = Response(data: {}, requestOptions: RequestOptions(path: '/'));
    data = data ?? {};
    headers = headers ?? {"x-access-token": ""};
    method = method ?? 'GET';

    if (TOKEN!.isNotEmpty) {
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

    String _domain = typeUrl.isEmpty ? "" : Config.apiHost[typeUrl];
    String _url = "$_domain/$url";

    Dio dio = createInstance();
    try {
      Response response = await dio.request(
        _url,
        data: data,
        queryParameters: parame,
        options: Options(
          method: method,
          headers: headers,
        ),
      );

      result = response;
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
          return Response(
            data: {'error': -1},
            requestOptions: RequestOptions(path: _url, method: method),
          );
        case DioErrorType.response:
          return Response(
            data: Map.from({'error': -2})..addAll(e.response!.data),
            requestOptions: e.requestOptions,
          );
        case DioErrorType.cancel:
          return Response(
            data: {'error': -3},
            requestOptions: RequestOptions(path: _url, method: method),
          );
        case DioErrorType.connectTimeout:
          return Response(
            data: {'error': -4},
            requestOptions: RequestOptions(path: _url, method: method),
          );
        case DioErrorType.sendTimeout:
          return Response(
            data: {'error': -6},
            requestOptions: RequestOptions(path: _url, method: method),
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

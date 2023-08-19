/// http请求

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:bfban/utils/index.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';

export 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:bfban/constants/api.dart';

class Http extends ScaffoldState {
  static Dio dio = createInstance();

  /// default options
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 10000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  /// token
  static String? TOKEN = "";
  static BuildContext? CONTENT;

  static String get USERAGENT {
    return "Bfban-Mobile-Client";
  }

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
    headers = headers ?? {"x-access-token": "", "user-agent": "client-phone"};
    method = method ?? 'GET';

    if (headers.isNotEmpty && Http.USERAGENT.isNotEmpty) {
      headers.addAll({HttpHeaders.userAgentHeader: Http.USERAGENT});
    }
    if (headers.isNotEmpty && TOKEN!.isNotEmpty) {
      headers["x-access-token"] = TOKEN;
    }

    /// restful 请求处理
    if (data is Map && data.isNotEmpty) {
      data.forEach((key, value) {
        if (url.contains(key)) {
          url = url.replaceAll(':$key', value.toString());
        }
      });
    }

    String domain = typeUrl.isEmpty ? "" : Config.apiHost[typeUrl]!.url;
    String path = "$domain/$url";

    try {
      Response response = await dio.request(
        path,
        data: data,
        queryParameters: parame,
        options: buildCacheOptions(
          const Duration(days: 1),
          maxStale: const Duration(days: 7),
          options: Options(
            method: method,
            headers: headers,
          ),
          forceRefresh: true,
        ),
      );

      if (response.data["code"] == "user.tokenExpired") {
        UrlUtil().opEnPage(CONTENT!, "/login/panel");
        StorageAccount().clearAll(CONTENT!);
      }

      result = response;
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.receiveTimeout:
          return Response(
            data: {'error': -1},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioErrorType.response:
          return Response(
            data: Map.from({'error': -2})..addAll(e.response!.data as Map),
            requestOptions: e.requestOptions,
          );
        case DioErrorType.cancel:
          return Response(
            data: {'error': -3},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioErrorType.connectTimeout:
          return Response(
            data: {'error': -4},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioErrorType.sendTimeout:
          return Response(
            data: {'error': -6},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioErrorType.other:
          // TODO: Handle this case.
          break;
      }
    }
    return result;
  }

  static Dio createInstance() {
    /// 全局属性：请求前缀、连接超时时间、响应超时时间
    BaseOptions options = BaseOptions(
      connectTimeout: CONNECT_TIMEOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
    );
    dio = Dio(options);

    // Cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));

    // 缓存实例
    Config.apiHost.forEach((key, value) {
      dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: value.baseHost)).interceptor);
    });
    // dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: Config.apiHost[typeUrl]!.baseHost)).interceptor);

    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio.clear();
  }
}

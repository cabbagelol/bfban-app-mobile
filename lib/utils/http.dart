/// http请求

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';

export 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import '../constants/api.dart';
import '../utils/index.dart';

enum HttpDioType {
  none,
  api,
  upload,
}

class Http extends ScaffoldState {
  static Dio dio = createInstance();

  /// default options
  static const Duration CONNECT_TIEMOUT = Duration(seconds: 20);
  static const Duration RECEIVE_TIMEOUT = Duration(seconds: 10);

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  static BuildContext? CONTENT;

  static String get USERAGENT {
    return "client-phone";
  }

  static of(BuildContext content) {
    return CONTENT = content;
  }

  /// request method
  static Future request(
    String url, {
    String httpDioValue = "network_service_request",
    HttpDioType httpDioType = HttpDioType.api,
    Object? data = const {},
    Map<String, dynamic>? parame,
    method = GET,
    Map<String, dynamic>? headers,
  }) async {
    Response result = Response(data: {}, requestOptions: RequestOptions(path: '/', validateStatus: (_) => true));
    headers = headers ?? {};

    if (headers.isNotEmpty && Http.USERAGENT.isNotEmpty) {
      headers.addAll({HttpHeaders.userAgentHeader: Http.USERAGENT});
    }

    String domain = "";
    switch (httpDioType) {
      case HttpDioType.api:
        domain = httpDioValue.isEmpty ? "" : Config.apiHost[httpDioValue]!.url;
        break;
      case HttpDioType.upload:
        domain = Config.apiUpload.url;
        break;
      case HttpDioType.none:
      default:
        domain = "";
        break;
    }

    String path = "${domain.isEmpty ? "" : "$domain/"}$url";

    try {
      Response response = await dio.request(
        path,
        data: data,
        queryParameters: parame,
        options: Options(
          method: method,
          headers: headers,
          validateStatus: (_) => true,
        ),
      );

      result = response;
    } on DioExceptionType catch (e) {
      switch (e) {
        case DioExceptionType.receiveTimeout:
          return Response(
            data: {'error': -1},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.connectionTimeout:
          return Response(
            data: {'error': -4},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.sendTimeout:
          return Response(
            data: {'error': -6},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.badCertificate:
          return Response(
            data: {'error': -2, 'message': 'bad certificate'},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.badResponse:
          return Response(
            data: {'error': -2, 'message': 'bad response'},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.cancel:
          return Response(
            data: {'error': -3},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.connectionError:
          return Response(
            data: {'error': -2, 'message': 'connection error'},
            requestOptions: RequestOptions(path: url, method: method),
          );
        case DioExceptionType.unknown:
          return Response(
            data: {'error': -2, 'message': 'unknown'},
            requestOptions: RequestOptions(path: url, method: method),
          );
      }
    }
    return result;
  }

  static Future<Response> fetchJsonPData(
    String url, {
    String httpDioValue = "network_service_request",
    HttpDioType httpDioType = HttpDioType.api,
  }) async {
    try {
      final method = 'JSONP';
      final dio = Dio();

      String domain = "";
      switch (httpDioType) {
        case HttpDioType.api:
          domain = httpDioValue.isEmpty ? "" : Config.apiHost[httpDioValue]!.url;
          break;
        case HttpDioType.none:
        default:
          domain = "";
          break;
      }

      String path = "${domain.isEmpty ? "" : "$domain/"}$url?callback=run";

      final response = await dio.get<String>(
        path,
        options: Options(responseType: ResponseType.plain), // 以文本形式接收响应
      );

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.data as String);

          return Response(
            data: data,
            requestOptions: RequestOptions(path: path, method: method),
          );
        } catch (e) {
          return Response(
            statusCode: 404,
            statusMessage: e.toString(),
            requestOptions: RequestOptions(path: path, method: method),
          );
        }
      } else {
        return Response(
          statusCode: 404,
          statusMessage: '请求失败，状态码：${response.statusCode}',
          requestOptions: RequestOptions(path: path, method: method),
        );
      }
    } on DioException catch (e) {
      return Response(
        statusCode: 404,
        statusMessage: e.toString(),
        requestOptions: RequestOptions(),
      );
    } catch (e) {
      rethrow;
    }
  }

  static Dio createInstance() {
    /// 全局属性：请求前缀、连接超时时间、响应超时时间
    BaseOptions options = BaseOptions(
      connectTimeout: CONNECT_TIEMOUT,
      receiveTimeout: RECEIVE_TIMEOUT,
    );
    dio = Dio(options);

    // Cookie管理
    dio.interceptors.add(CookieManager(CookieJar()));

    // 缓存实例
    // by https://pub.dev/packages/dio_cache_interceptor
    dio.interceptors.add(DioCacheInterceptor(
      options: CacheOptions(
        store: MemCacheStore(),
        policy: CachePolicy.request,
        hitCacheOnErrorExcept: [],
        maxStale: const Duration(days: 7),
        priority: CachePriority.normal,
        cipher: null,
        keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        allowPostMethod: false,
      ),
    ));

    // Add the interceptor
    dio.interceptors.add(RetryInterceptor(
      dio: dio,
      logPrint: print,
      retries: 2,
      retryDelays: const [
        Duration(seconds: 3),
        Duration(seconds: 10),
      ],
    ));

    return dio;
  }
}

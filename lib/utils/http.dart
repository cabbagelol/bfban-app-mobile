/// http请求

import 'dart:async';

import 'package:flutter/material.dart';

export 'package:dio/dio.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';

import 'package:bfban/constants/api.dart';

class Http extends ScaffoldState {
  static Dio dio;

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
  static String TOKEN = "";

  static void setToken (value) {
    return TOKEN = value;
  }

  /// request method
  static Future request(
    String url, {
    typeUrl = "url",
    data,
    Map<String, dynamic> parame,
    method,
    headers,
  }) async {
    Response result;
    data = data ?? {};
    headers = headers ?? {
      "token": "",
    };
    method = method ?? 'GET';

    if (TOKEN != "") {
      headers["token"] = TOKEN;
    }

    /// restful 请求处理
    if (data is Map || data is List) {
      data.forEach((key, value) {
        if (url.indexOf(key) != -1) {
          url = url.replaceAll(':$key', value.toString());
        }
      });
    }

//    print('请求地址：【' + method + '  ${Config.apiHost[typeUrl] + '/' + url}】');
//    print(data);

    Dio dio = createInstance();
    try {
      Response response = await dio.request(
        Config.apiHost[typeUrl] + '/' + url,
        data: data,
        queryParameters: parame,
        options: new Options(
          method: method,
          headers: headers,
        ),
      );
      result = response;
      print('响应数据：' + response.toString());
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
          return Response(
            data: {'error': -1},
          );
          break;
        case DioErrorType.RESPONSE:
          return Response(
            data: {'error': -2},
          );
          break;
        case DioErrorType.CANCEL:
          return Response(
            data: {'error': -3},
          );
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          return Response(
            data: {'error': -4},
          );
          break;
        case DioErrorType.DEFAULT:
          return Response(
            data: {'error': -5},
          );
          break;
        case DioErrorType.SEND_TIMEOUT:
          return Response(
            data: {'error': -6},
          );
          break;
        case DioErrorType.DEFAULT:
          return Response(
            data: {'error': -7},
          );
          break;
      }
      print('请求出错：' + e.toString());
    }
    return result;
  }

  static Dio createInstance() {
    if (dio == null) {
      /// 全局属性：请求前缀、连接超时时间、响应超时时间
      BaseOptions options = new BaseOptions(
        baseUrl: Config.apiHost['url'] + '/',
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );
      dio = new Dio(options);
      dio.interceptors.add(
        CookieManager(CookieJar()),
      );
    }
    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio = null;
  }
}

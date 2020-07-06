/**
 * 功能：http请求模块
 * 描述：
 * By 向堂 2019/8/23
 */

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'dart:async';

import 'package:bfban/constants/api.dart';
export 'package:dio/dio.dart';

class Http extends ScaffoldState {
  static Dio dio;

  /// default options
  static String API_PREFIX = Config.apiHost['url'] + '/';
  static const int CONNECT_TIMEOUT = 10000;
  static const int RECEIVE_TIMEOUT = 10000;

  /// http request methods
  static const String GET = 'get';
  static const String POST = 'post';
  static const String PUT = 'put';
  static const String PATCH = 'patch';
  static const String DELETE = 'delete';

  /// request method
  static Future request(
    String url, {
    data,
    method,
    headers,
  }) async {
    data = data ?? {};
    method = method ?? 'GET';

    /// restful 请求处理
    data.forEach((key, value) {
      if (url.indexOf(key) != -1) {
        url = url.replaceAll(':$key', value.toString());
      }
    });

    print('请求地址：【' + method + '  ${API_PREFIX + url}】');
    print('请求参数：' + data.toString());

    Dio dio = createInstance();
    var result;
    try {
      Response response = await dio.request(url,
          data: data, options: new Options(method: method, headers: headers));
      result = response;
      print('响应数据：' + response.toString());
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
          return {'code': -1};
          break;
        case DioErrorType.RESPONSE:
          return {'code': -2};
          break;
        case DioErrorType.CANCEL:
          return {'code': -3};
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          return {'code': -4};
          break;
        case DioErrorType.DEFAULT:
          return {'code': -5};
          break;
        case DioErrorType.SEND_TIMEOUT:
          return {'code': -6};
          break;
        case DioErrorType.DEFAULT:
          return {'code': -7};
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
        baseUrl: API_PREFIX, // ignore: undefined_named_parameter
        connectTimeout: CONNECT_TIMEOUT,
        receiveTimeout: RECEIVE_TIMEOUT,
      );
      dio = new Dio(options);
//      dio.interceptors.add(CookieManager(CookieJar()));
    }
    return dio;
  }

  /// 清空 dio 对象
  static clear() {
    dio = null;
  }
}

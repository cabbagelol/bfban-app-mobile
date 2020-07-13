import 'dart:async';

import 'package:bfban/constants/api.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
/**
 * 功能：http请求模块
 * 描述：
 * By 向堂 2019/8/23
 */

import 'package:flutter/material.dart';

export 'package:dio/dio.dart';

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

  /// request method
  static Future request(
    String url, {
    typeUrl = "url",
    data,
    Map<String, dynamic> parame,
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

    print('请求地址：【' + method + '  ${Config.apiHost[typeUrl] + '/' + url}】');
    print('请求参数：' + data.toString());

    Dio dio = createInstance();
    var result;
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
//      print('响应数据：' + response.toString());
    } on DioError catch (e) {
      switch (e.type) {
        case DioErrorType.RECEIVE_TIMEOUT:
          return {'error': -1};
          break;
        case DioErrorType.RESPONSE:
          return {'error': -2};
          break;
        case DioErrorType.CANCEL:
          return {'error': -3};
          break;
        case DioErrorType.CONNECT_TIMEOUT:
          return {'error': -4};
          break;
        case DioErrorType.DEFAULT:
          return {'error': -5};
          break;
        case DioErrorType.SEND_TIMEOUT:
          return {'error': -6};
          break;
        case DioErrorType.DEFAULT:
          return {'error': -7};
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
        baseUrl: Config.apiHost['url'] + '/', // ignore: undefined_named_parameter
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

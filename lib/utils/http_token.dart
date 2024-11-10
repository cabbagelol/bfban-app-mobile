import 'dart:collection';

import 'package:bfban/utils/index.dart';

import '../constants/api.dart';

class HttpToken {
  /// token
  static String? TOKEN = "";

  static String setToken(String value) {
    return TOKEN = value;
  }

  // static checkToken() {
  //   // Token有效
  //   Http.dio.interceptors.add(TokenInterceptor());
  // }

  /// [Event]
  /// 检查token是否失效
  static Future<bool> isTokenVain(Response<dynamic> response) async {
    const errorCode = ['user.tokenClientException', 'user.tokenExpired', 'user.invalid'];
    if ((response.data as Map).isNotEmpty && errorCode.contains(response.data['code'])) {
      eventUtil.emit('user-token-expired', response);
      HttpToken.TOKEN = "";
      return true;
    }

    return false;
  }

  static Future request(
    String url, {
    String httpDioValue = "network_service_request",
    HttpDioType httpDioType = HttpDioType.api,
    Object? data = const {},
    Map<String, dynamic>? parame,
    method = Http.GET,
    Map<String, dynamic>? headers,
  }) {
    headers = headers ?? {"x-access-token": ""};

    if (headers.isNotEmpty && TOKEN!.isNotEmpty) {
      headers["x-access-token"] = TOKEN;
    }

    return Http.request(
      url,
      httpDioValue: httpDioValue,
      httpDioType: HttpDioType.api,
      data: data,
      parame: parame,
      method: method,
      headers: headers,
    );
  }
}

class TokenInterceptor extends Interceptor {
  bool isReLogin = false;
  Queue queue = Queue();

  TokenInterceptor();

  @override
  Future onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.requestOptions.path.contains(Config.apiHost["network_service_request"]!.url)) _checkToken(response);
    return super.onResponse(response, handler);
  }

  /// [Event]
  /// 检查token
  static _checkToken(Response<dynamic> response) {
    const errorCode = ['user.tokenClientException', 'user.tokenExpired', 'user.invalid'];
    if ((response.data as Map).isNotEmpty && errorCode.contains(response.data['code'])) {
      eventUtil.emit('user-token-expired', response);
      HttpToken.TOKEN = "";
    }
  }
}

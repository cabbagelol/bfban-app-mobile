/// 账户持久管理

import 'package:bfban/utils/provider.dart';
import 'package:flutter/cupertino.dart';

import "storage.dart";

class StorageAccount extends Storage {
  List ACCOUNTDATA = [{
    "name": "com.bfban.cookie"
  }, {
    "name": "com.bfban.token"
  }, {
    "name": "com.bfban.login"
  }];

  /// 擦除本地账户数据
  Future clearAll (BuildContext context) async {
    List<Future> Futures = [];

    for (var element in ACCOUNTDATA) {
      Futures.add(super.remove(element["name"]));
    }

    await Future.wait(Futures);

    // 清空 用户状态管理机
    ProviderUtil().ofUser(context).clear();
  }
}
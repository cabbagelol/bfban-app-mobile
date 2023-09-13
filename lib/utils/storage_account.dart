/// 账户持久管理

import 'package:bfban/utils/provider.dart';
import 'package:flutter/cupertino.dart';

import "storage.dart";

class StorageAccount extends Storage {
  String NAME = 'user.configuration';

  List ACCOUNTDATA = [
    {"name": "cookie"},
    {"name": "token"},
    {"name": "login"}
  ];

  /// 擦除本地账户数据
  Future clearAll(BuildContext context) async {
    List<Future> Futures = [];

    for (var element in ACCOUNTDATA) {
      Futures.add(super.remove(element["name"]));
    }

    await Future.wait(Futures);

    // 清空 用户状态管理机
    ProviderUtil().ofUser(context).clear();
    // 清空 用户消息内容
    ProviderUtil().ofChat(context).messageStatus.total = 0;
  }

  /// 用户一类 本地配置
  updateConfiguration(String key, dynamic value) async {
    StorageData userData = await get(NAME);
    Map data = userData.value ??= {};

    data[key] = value;
    // store.commit("syncLoaclConfiguration", data.data.value)
    super.set(NAME, value: data);
  }

  /// 取得attr的值
  getConfiguration(String key) async {
    StorageData userData = await get(NAME);
    Map data = userData.value ??= {};

    if (userData.code != 0) return false;
    // * The configuration is usually of type bool
    return Map.from(data).containsKey(key) ? data[key] : false;
  }
}

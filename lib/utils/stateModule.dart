/**
 * 状态管理
 * 关于更多信息请参考： https://juejin.im/post/5b97fa0d5188255c5546dcf8
 */

import 'package:scoped_model/scoped_model.dart';
export 'package:scoped_model/scoped_model.dart';

class CountModel extends Model {
  int _counter = 0;
  Map _data = {};

  get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners();
  }

  Map set (String name_, var data_) {
    _data[name_] = data_;
    notifyListeners();
  }

  get (String name_) {
    try {
      return _data[name_]??null;
    } catch (e) {
      print(e);
    }
  }
}

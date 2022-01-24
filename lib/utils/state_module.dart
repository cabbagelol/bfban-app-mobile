///// 状态管理
///// 关于更多信息请参考： https://juejin.im/post/5b97fa0d5188255c5546dcf8
//
//import 'package:scoped_model/scoped_model.dart';
//export 'package:scoped_model/scoped_model.dart';
//
//class CountModel extends Model {
//  int _counter = 0;
//  Map _data = {};
//
//  get counter => _counter;
//
//  void increment() {
//    _counter++;
//    notifyListeners();
//  }
//
//  Map set (String name, var data) {
//    _data[name] = data;
//    notifyListeners();
//  }
//
//  get (String name) {
//    try {
//      return _data[name]??null;
//    } catch (e) {
//      print(e);
//    }
//  }
//}

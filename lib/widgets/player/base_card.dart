class BaseCardStatelessWidget {
  // 单条数据
  late Map _data;

  // 数据数量
  late num _maxDataCount;

  // 位置
  late int _index;

  // 只读
  get data => _data;

  get maxDataCount => _maxDataCount;

  get index => _index;

  BaseCardStatelessWidget init({required Map data, required num maxDataCount, required int index}) {
    _data = data;
    _maxDataCount = maxDataCount;
    _index = index;
    return this;
  }
}

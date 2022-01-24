/// 统计数据
class Statistics {
  late num page;
  late bool load;
  Map<String, dynamic>? data;
  Map<String, dynamic>? params;

  Statistics({
    this.page = 0,
    this.load = false,
    required this.data,
    this.params,
  });
}
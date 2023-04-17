import 'package:bfban/data/Url.dart';

/// 网络
class AppNetworkStatus {
  List<AppNetworkItem>? list;

  AppNetworkStatus({
    this.list,
  });
}

class AppNetworkItem extends BaseUrl {
  bool load;
  int status;
  int statusCode;
  num ms;
  String name;

  AppNetworkItem({
    this.load = false,
    this.status = 0,
    this.statusCode = 0, // Success should be >= 200 < 300
    this.ms = 0,
    this.name = "",
  });

  get toBaseUrl {
    BaseUrl url = BaseUrl();
    url.protocol = protocol;
    url.host = host;
    url.pathname = pathname;
    return url;
  }
}

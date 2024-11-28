import 'dart:io';

import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  // 以下配置都是需要各项项目配置好本地运行
  // 包括BFBAN APP的网站、BFBAN前后本体服务，如果条件有限可以使用线上地址来代替
  Config.dev(
    api: {
      "sentry": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io", pathname: "/5403628"),
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": {
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:4000", pathname: "/public"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:4000", pathname: "/public"),
      }[Platform.operatingSystem] as BaseUrl,
      "web_site": {
        "macos": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:8080"),
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:8080"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:8080"),
      }[Platform.operatingSystem] as BaseUrl,
      "network_bfv_hackers_request": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfvhackers.com", pathname: "/api/v1"),
      "network_service_request": {
        "macos": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"),
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:3000", pathname: "/api"),
      }[Platform.operatingSystem] as BaseUrl,
    },
    apiUpload: BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.gametools.network", pathname: "/api/"),
  );

  runMain();
}

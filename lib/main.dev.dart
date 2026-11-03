import 'dart:io';

import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  // 本地服务开关：若本地未启动前后端服务或在真机调试，默认为 false 使用线上服务
  bool useLocalServer = Platform.environment["USE_LOCAL_SERVER"] == "true";

  Config.dev(
    api: {
      "sentry": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io", pathname: "/5403628"),
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": useLocalServer
          ? ({
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:4000", pathname: "/public"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:4000", pathname: "/public"),
      }[Platform.operatingSystem] ?? BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:4000", pathname: "/public"))
          : BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban-app.cabbagelol.net"),
      "web_site": useLocalServer
          ? ({
        "macos": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:8080"),
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:8080"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:8080"),
      }[Platform.operatingSystem] ?? BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:8080"))
          : BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.com"),
      "network_bfv_hackers_request": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfvhackers.com", pathname: "/api/v1"),
      "network_service_request": useLocalServer
          ? ({
        "macos": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"),
        "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"),
        "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:3000", pathname: "/api"),
      }[Platform.operatingSystem] ?? BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"))
          : BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "api.bfban.com", pathname: "/api"),
    },
    apiUpload: BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.gametools.network", pathname: "/api/"),
  );

  runMain();
}

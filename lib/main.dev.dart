import 'dart:io';

import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  Config.dev(
    api: {
      "sentry": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io", pathname: "/5403628"),
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban-app.cabbagelol.net"),
      "web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.com"),
      "network_bfv_hackers_request": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfvhackers.com", pathname: "/api/v1/"),
      "network_service_request": {"macos": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"), "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"), "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:3000", pathname: "/api")}[Platform.operatingSystem] as BaseUrl,
    },
    jiguan: {
      // In Disuse
      "appKey": "",
    },
    apiUpload: BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.gametools.network", pathname: "/api/"),
  );

  runMain();
}

import 'constants/api.dart';
import 'data/Url.dart';
import 'main.dart';

void main() async {
  Config.prod(
    api: {
      "sentry": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io", pathname: "/5403628"),
      "web_github": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "github.com"),
      "app_web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban-app.cabbagelol.net"),
      "web_site": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.com"),
      "network_bfv_hackers_request": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfvhackers.com", pathname: "/api/v1"),
      "network_service_request": BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "api.bfban.com", pathname: "/api"),
    },
    apiUpload: BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.gametools.network", pathname: "/api/"),
  );

  // google ads 初始
  // MobileAds.instance.initialize();

  runMain();
}

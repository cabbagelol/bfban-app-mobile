import 'constants/api.dart';
import 'main.dart';

// impockage:jpush_flutter/jpush_flutter.dart';

void main () async {
  Config.prod(
    api: {
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "app_web_site": "https://bfban-app.cabbagelol.net",
      "web_site": "https://bfban.gametools.network",
      "network_service_request": "https://bfban.gametools.network/api",
    }
  );

  // google ads 初始
  // MobileAds.instance.initialize();

  // 极光
  // JPush().setup(
  //   appKey: Config.jiguan["appKey"],
  //   channel: Config.jiguan["channel"],
  // );

  runMain();
}
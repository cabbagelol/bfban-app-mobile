import 'constants/api.dart';
import 'main.dart';

void main() async {
  Config.dev(
    api: {
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "app_web_site": "https://bfban-app.cabbagelol.net",
      "web_site": "https://bfban.gametools.network",
      "network_service_request": "https://8315-141-11-125-123.ap.ngrok.io/api",
    },
    jiguan: {
      "appKey": "966c3770c8bb47ffcbaacff1",
    },
  );

  runMain();
}

import 'constants/api.dart';
import 'main.dart';

void main() async {
  Config.dev(
    api: {
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "app_web_site": "https://bfban-app.cabbagelol.net",
      "web_site": "https://bfban.gametools.network",
      "network_service_request": "https://85b7-2603-c022-8000-54ee-3434-95c7-2417-de0b.jp.ngrok.io/api",
    },
    jiguan: {
      "appKey": "966c3770c8bb47ffcbaacff1",
    },
  );

  runMain();
}

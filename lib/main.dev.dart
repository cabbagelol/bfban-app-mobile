import 'constants/api.dart';
import 'main.dart';

void main () async {
  Config.dev(
    api: {
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "app_web_site": "https://bfban-app.cabbagelol.net",
      "web_site": "https://bfban.gametools.network",
      "network_service_request": "https://60bb-2a09-bac5-55fe-15f-00-23-317.ap.ngrok.io/api",
    }
  );

  runMain();
}
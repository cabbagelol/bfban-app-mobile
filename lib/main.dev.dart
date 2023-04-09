import 'constants/api.dart';
import 'main.dart';

void main() async {
  Config.dev(
    api: {
      "sentry": "https://475f587d2c9a44f38cbe58978c0429c7@o438603.ingest.sentry.io/5403628",
      "app_web_site": "https://bfban-app.cabbagelol.net",
      "web_site": "https://bfban.gametools.network",
      "network_service_request": "http://10.0.2.2:3000/api",
    },
    jiguan: {
      "appKey": "966c3770c8bb47ffcbaacff1",
    },
    apiUpload: BaseUrl(
        protocol: BaseUrlProtocol.HTTPS,
        host: "bfban.gametools.network",
        pathname: "/api/"
    ),
  );

  runMain();
}

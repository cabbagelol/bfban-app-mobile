import 'package:bfban/data/Url.dart';

import 'constants/api.dart';
import 'main.dart';

void main() async {
  // Production mode configuration registration
  Config.prod(
    api: {
      "sentry": BaseUrl(host: "YOU sentry url"),
      // A showcase site for mobile applications
      "app_web_site": BaseUrl(host: "app website url"),
      // bfban website address
      "web_site": BaseUrl(host: "website"),
      // Request address
      // Use the development address in the Android emulator, which should be 10.0.2.2:3000/api
      // by https://developer.android.google.cn/studio/run/emulator-networking
      "network_service_request": BaseUrl(host: "bfban.com", pathname: "/api"),
      // In development mode it can be written like this:
      // "network_service_request": {
      //   "ios": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "127.0.0.1:3000", pathname: "/api"),
      //   "android": BaseUrl(protocol: BaseUrlProtocol.HTTP, host: "10.0.2.2:3000", pathname: "/api")
      // }[Platform.operatingSystem] as BaseUrl,
    },

    // Here the upload is started independently, you can see how the bfban website project is set up
    apiUpload: BaseUrl(protocol: BaseUrlProtocol.HTTPS, host: "bfban.gametools.network", pathname: "/api/"),
  );

  // Development pattern registration:
  // Config.dev(
  //     api: {
  //       "key": "value",
  //     }
  // );

  // Third party injection can be written below
  // TO-DO

  // Execute APP
  runMain();
}

import 'constants/api.dart';
import 'main.dart';

void main () async {
  // Production mode configuration registration
  Config.prod(
      api: {
        "sentry": "YOU sentry url",
        // A showcase site for mobile applications
        "app_web_site": "app website url",
        // bfban website address
        "web_site": "website",
        // Request address
        // Use the development address in the Android emulator, which should be 10.0.2.2:3000/api
        // by https://developer.android.google.cn/studio/run/emulator-networking
        "network_service_request": "https://bfban.gametools.network/api",
      }
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
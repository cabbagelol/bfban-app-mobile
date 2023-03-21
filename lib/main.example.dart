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
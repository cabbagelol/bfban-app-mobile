import 'package:bfban/utils/logger.dart';
import 'package:flutter/cupertino.dart';
import 'package:sentry/sentry.dart';

import '../constants/api.dart';

class LogItemData {
  final dynamic error;
  StackTrace? stackTrace;
  final dynamic time;

  LogItemData({
    required this.time,
    required this.error,
    this.stackTrace,
  });
}

class LogProvider with ChangeNotifier {
  final List<LogItemData> _logsList = [];

  List<LogItemData> get list => _logsList;

  init() {
    // Sentry
    if (Config.env == Env.PROD) {
      Sentry.init((options) {
        options.dsn = Config.apiHost["sentry"]!.url;
      });
    }

    FlutterError.onError = (FlutterErrorDetails details) {
      _logsList.add(LogItemData(
        time: DateTime.now(),
        error: details.exception,
        stackTrace: details.stack!,
      ));
      logger.e(details.context, stackTrace: details.stack);
    };
  }
}

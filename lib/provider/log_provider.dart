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

  List<LogItemData> get reverseList => _logsList.reversed.toList();

  void clear() {
    if (_logsList.isEmpty) return;

    _logsList.clear();
    notifyListeners();
  }

  init() {
    // Sentry
    if (Config.env == Env.PROD) {
      Sentry.init((options) {
        options.dsn = Config.apiHost["sentry"]!.url;
      });
    }

    // Logs
    if (Config.env == Env.PROD) {
      FlutterError.onError = (FlutterErrorDetails details) {
        _logsList.add(LogItemData(
          time: DateTime.now(),
          error: details.exception,
          stackTrace: details.stack!,
        ));
        logger.i(details.context, time: DateTime.now(), stackTrace: details.stack);
      };
    }
  }
}

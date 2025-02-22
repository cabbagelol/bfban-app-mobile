import 'package:logger/logger.dart' show Level, Logger, PrettyPrinter;

var logger = Logger(
  filter: null, // Use the default LogFilter (-> only log in debug mode)
  printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
  output: null, // Use the default LogOutput (-> send everything to console)
  level: Level.info,
);

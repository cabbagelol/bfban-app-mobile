import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

enum GamesTagSize {
  no2,
  no3,
}

class GamesTagWidget extends StatefulWidget {
  final dynamic data;
  final Widget? splitChar;
  late GamesTagSize? size;

  List<GamesTagSizeConfig>? sizeType = [
    GamesTagSizeConfig(
      height: 14,
      padding: const EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 7,
      ),
      border: 3,
    ),
    GamesTagSizeConfig(
      height: 20,
      padding: const EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 7,
      ),
      border: 3,
    ),
  ];

  GamesTagSizeConfig currentSizeType = GamesTagSizeConfig(
    height: 16,
    padding: const EdgeInsets.symmetric(
      vertical: 2,
      horizontal: 7,
    ),
    border: 3,
  );

  GamesTagWidget({
    super.key,
    this.data,
    this.splitChar,
    GamesTagSize size = GamesTagSize.no2,
  }) {
    currentSizeType = sizeType![size.index];
  }

  @override
  State<GamesTagWidget> createState() => _GamesTagWidgetState();
}

class _GamesTagWidgetState extends State<GamesTagWidget> {
  List gameListWidgets = [];

  @override
  void initState() {
    switch (widget.data.runtimeType) {
      case String:
        gameListWidgets.add(widget.data);
        break;
      case List:
      default:
        gameListWidgets.addAll(widget.data);
        break;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;

    return Wrap(
      children: gameListWidgets.map<Widget>((e) {
        index++;
        return Wrap(
          children: [
            Tooltip(
              message: FlutterI18n.translate(context, "basic.games.$e"),
              child: Container(
                padding: widget.currentSizeType.padding,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  border: Border.all(color: Theme.of(context).dividerTheme.color!),
                  borderRadius: BorderRadius.circular(widget.currentSizeType.border),
                ),
                child: Image.asset(
                  "assets/images/games/$e/logo.png",
                  height: widget.currentSizeType.height,
                ),
              ),
            ),
            if (widget.splitChar != null)
              widget.splitChar!
            else if (widget.splitChar == null && index < gameListWidgets.length)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: const Text(","),
              ),
          ],
        );
      }).toList(),
    );
  }
}

class GamesTagSizeConfig {
  double height = 16;
  EdgeInsets padding = const EdgeInsets.symmetric(vertical: 2, horizontal: 7);
  double border = 3;

  GamesTagSizeConfig({
    required this.height,
    required this.padding,
    required this.border,
  });
}

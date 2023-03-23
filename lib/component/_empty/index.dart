import 'package:flutter/cupertino.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: I18nText("basic.tip.notContent"),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class HomeHintLogin extends StatelessWidget {
  const HomeHintLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 50),
          SizedBox(height: 5),
          Opacity(
            opacity: .5,
            child: Text(FlutterI18n.translate(context, "app.home.needAccount")),
          ),
        ],
      ),
    );
  }
}

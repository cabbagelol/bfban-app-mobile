import 'package:flutter/material.dart';

class PublishResultsPage extends StatefulWidget {
  const PublishResultsPage({Key? key}) : super(key: key);

  @override
  _PublishResultsPageState createState() => _PublishResultsPageState();
}

class _PublishResultsPageState extends State<PublishResultsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed("/");
              },
            );
          },
        ),
        title: const Text(
          "完成",
        ),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Wrap(
              spacing: 5,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: Colors.green,
                ),
                Text(
                  "非常感谢您的举报信息",
                  style: TextStyle(
                    color: Theme.of(context).primaryTextTheme.headline1!.color ?? Colors.white,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

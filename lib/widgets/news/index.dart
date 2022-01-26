/// 新闻面板

import 'dart:async';

import 'package:flutter/material.dart';

import 'package:webview_flutter/webview_flutter.dart';
export 'package:webview_flutter/webview_flutter.dart';

class NewsComponentPanel extends StatefulWidget {
  final Completer<WebViewController>? controller;

  final String? src;

  const NewsComponentPanel({
    Key? key,
    this.src,
    this.controller,
  }) : super(key: key);

  @override
  _NewsComponentPanelState createState() => _NewsComponentPanelState();
}

class _NewsComponentPanelState extends State<NewsComponentPanel> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.src,
      javascriptMode: JavascriptMode.unrestricted,
      onWebViewCreated: (WebViewController webViewController) {
        widget.controller!.complete(webViewController);
      },
    );
  }
}

class NavigationControls extends StatelessWidget {
  const NavigationControls(
    this._webViewControllerFuture, {
    Key? key,
  }) : super(key: key);

  final Future<WebViewController> _webViewControllerFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<WebViewController>(
      future: _webViewControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<WebViewController> snapshot) {
        final bool webViewReady = snapshot.connectionState == ConnectionState.done;
        final WebViewController? controller = snapshot.data;
        return Row(
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoBack()) {
                        await controller.goBack();
                      } else {
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: !webViewReady
                  ? null
                  : () async {
                      if (await controller!.canGoForward()) {
                        await controller.goForward();
                      } else {
                        return;
                      }
                    },
            ),
            IconButton(
              icon: const Icon(Icons.replay),
              onPressed: !webViewReady
                  ? null
                  : () {
                      controller!.reload();
                    },
            ),
          ],
        );
      },
    );
  }
}

/// 新闻面板

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_elui_plugin/_message/index.dart';

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
  Map webview = {
    "load": false,
    "loadProgress": 0,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Visibility(
          child: const LinearProgressIndicator(
            minHeight: 2,
          ),
          visible: webview["load"],
        ),
        Expanded(
          child: WebView(
            initialUrl: widget.src,
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              widget.controller!.complete(webViewController);
            },
            onPageStarted: (String url) {
              setState(() {
                webview["load"] = true;
              });
            },
            onPageFinished: (String url) {
              setState(() {
                webview["load"] = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              EluiMessageComponent.warning(context)(
                child: Text(error.description.toString()),
              );
            },
            onProgress: (int progress) {
              setState(() {
                webview["loadProgress"] = (progress * 0.01).toDouble();
              });
            },
          ),
          flex: 1,
        ),
      ],
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

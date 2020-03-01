import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:webview_flutter/webview_flutter.dart';

class CustomWebView extends StatefulWidget {
  final bool popOnMessage;
  final String selectedUrl;
  CustomWebView({this.popOnMessage, this.selectedUrl});

  @override
  _CustomWebViewstate createState() => _CustomWebViewstate();
}

class _CustomWebViewstate extends State<CustomWebView> {

  final Completer<WebViewController> _controller = Completer<WebViewController>();

    @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.selectedUrl,
      javascriptMode: JavascriptMode.unrestricted,
      javascriptChannels: <JavascriptChannel>[
        JavascriptChannel(name: 'Print', onMessageReceived: (msg) {
          Map response = json.decode(msg.message);
          print(response);
          if (widget.popOnMessage) Navigator.pop(context, response);
        }),
      ].toSet(),
      gestureRecognizers: Set()
        ..add(Factory<VerticalDragGestureRecognizer>(
          () => VerticalDragGestureRecognizer())
      ),
      onWebViewCreated: (WebViewController webViewController) {
        _controller.complete(webViewController);
      },
    );
  }
}
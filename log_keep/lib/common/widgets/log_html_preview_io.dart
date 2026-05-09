import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

Widget buildLogHtmlPreview({
  required String html,
  required String plainTextFallback,
}) {
  if (Platform.isAndroid || Platform.isIOS) {
    return _MobileHtmlWebView(html: html);
  }
  return SingleChildScrollView(
    child: SelectableText(
      plainTextFallback,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    ),
  );
}

class _MobileHtmlWebView extends StatefulWidget {
  const _MobileHtmlWebView({required this.html});

  final String html;

  @override
  State<_MobileHtmlWebView> createState() => _MobileHtmlWebViewState();
}

class _MobileHtmlWebViewState extends State<_MobileHtmlWebView> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(widget.html);
  }

  @override
  void didUpdateWidget(covariant _MobileHtmlWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _controller.loadHtmlString(widget.html);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: _controller);
  }
}

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Renders [html] in a WebView (iframe on web). [maxContentWidth] caps width
/// like the legacy WebBrowser iframe setting.
class LogHtmlPreview extends StatefulWidget {
  const LogHtmlPreview({
    super.key,
    required this.html,
    required this.maxContentWidth,
  });

  final String html;
  final double maxContentWidth;

  @override
  State<LogHtmlPreview> createState() => _LogHtmlPreviewState();
}

class _LogHtmlPreviewState extends State<LogHtmlPreview> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(widget.html);
  }

  @override
  void didUpdateWidget(LogHtmlPreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _controller.loadHtmlString(widget.html);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = min(widget.maxContentWidth, constraints.maxWidth);
        final height = constraints.maxHeight.isFinite && constraints.maxHeight > 0
            ? constraints.maxHeight
            : 400.0;
        return SizedBox(
          width: width,
          height: height,
          child: WebViewWidget(controller: _controller),
        );
      },
    );
  }
}

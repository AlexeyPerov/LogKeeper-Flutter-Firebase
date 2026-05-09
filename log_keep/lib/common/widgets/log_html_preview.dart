import 'dart:math';

import 'package:flutter/material.dart';

import 'log_html_preview_stub.dart'
    if (dart.library.html) 'log_html_preview_web.dart'
    if (dart.library.io) 'log_html_preview_io.dart';

/// Renders HTML inline where supported (iframe on web, WebView on Android/iOS).
/// On desktop (macOS, Windows, Linux), uses [plainTextFallback] instead — native
/// WebView does not implement `setJavaScriptMode` there.
class LogHtmlPreview extends StatelessWidget {
  const LogHtmlPreview({
    super.key,
    required this.html,
    required this.maxContentWidth,
    required this.plainTextFallback,
  });

  final String html;
  final double maxContentWidth;

  /// Raw log text used when inline HTML rendering is unavailable (desktop).
  final String plainTextFallback;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = min(maxContentWidth, constraints.maxWidth);
        final height =
            constraints.maxHeight.isFinite && constraints.maxHeight > 0
                ? constraints.maxHeight
                : 400.0;
        return SizedBox(
          width: width,
          height: height,
          child: buildLogHtmlPreview(
            html: html,
            plainTextFallback: plainTextFallback,
          ),
        );
      },
    );
  }
}

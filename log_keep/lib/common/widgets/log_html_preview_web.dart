// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

Widget buildLogHtmlPreview({
  required String html,
  required String plainTextFallback,
}) {
  return _WebIframePreview(html: html);
}

class _WebIframePreview extends StatefulWidget {
  const _WebIframePreview({required this.html});

  final String html;

  @override
  State<_WebIframePreview> createState() => _WebIframePreviewState();
}

class _WebIframePreviewState extends State<_WebIframePreview> {
  late final String _viewType = 'log-html-iframe-${identityHashCode(this)}';
  html.IFrameElement? _iframe;

  @override
  void initState() {
    super.initState();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int _viewId) {
      final element = html.IFrameElement()
        ..style.border = '0'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.backgroundColor = 'transparent'
        ..srcdoc = widget.html;
      _iframe = element;
      return element;
    });
  }

  @override
  void didUpdateWidget(covariant _WebIframePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.html != widget.html) {
      _iframe?.srcdoc = widget.html;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: _viewType);
  }
}

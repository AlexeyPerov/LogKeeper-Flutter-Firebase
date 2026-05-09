import 'package:flutter/material.dart';

/// Fallback when neither dart:html nor dart:io is available (should not run).
Widget buildLogHtmlPreview({
  required String html,
  required String plainTextFallback,
}) {
  return SingleChildScrollView(
    child: SelectableText(
      plainTextFallback,
      style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
    ),
  );
}

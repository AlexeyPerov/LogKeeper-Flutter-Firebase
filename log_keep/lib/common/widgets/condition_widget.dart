import 'package:flutter/material.dart';

/// Renders [widget] when [condition] is true, otherwise [fallback] or an empty box.
class ConditionWidget extends StatelessWidget {
  const ConditionWidget({
    super.key,
    required this.condition,
    required this.widget,
    this.fallback,
  });

  final bool condition;
  final Widget widget;
  final Widget? fallback;

  @override
  Widget build(BuildContext context) {
    if (condition) {
      return widget;
    }
    return fallback ?? const SizedBox.shrink();
  }
}

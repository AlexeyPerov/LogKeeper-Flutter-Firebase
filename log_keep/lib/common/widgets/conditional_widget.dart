import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  final Widget child;
  final bool condition;

  const ConditionalWidget({
    Key key,
    this.child, this.condition
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return condition ? child : Container();
  }
}
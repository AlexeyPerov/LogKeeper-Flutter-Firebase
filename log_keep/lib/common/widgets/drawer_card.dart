import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hovering/hovering.dart';
import 'package:log_keep/app/theme/themes.dart';

class DrawerCard extends StatelessWidget {
  final String text;
  final Color color;
  final Function() onTap;

  const DrawerCard({Key key, this.text, this.color, this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HoverAnimatedContainer(
      margin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      hoverMargin: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
      height: 85.0,
      width: 100.0,
      hoverDecoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [commonBoxShadow()],
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [slightBoxShadow()],
      ),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => onTap(),
        child: Align(
          alignment: Alignment.center,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

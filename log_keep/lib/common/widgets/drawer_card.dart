
import 'package:flutter/material.dart';
import 'package:log_keep/app/theme/themes.dart';

class DrawerCard extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const DrawerCard({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
  });

  @override
  State<DrawerCard> createState() => _DrawerCardState();
}

class _DrawerCardState extends State<DrawerCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final baseDecoration = BoxDecoration(
      color: widget.color,
      borderRadius: BorderRadius.circular(20.0),
      boxShadow: [_hover ? commonBoxShadow() : slightBoxShadow()],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: kThemeChangeDuration,
        margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
        height: 85.0,
        width: 100.0,
        decoration: baseDecoration,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          child: Align(
            alignment: Alignment.center,
            child: Text(
              widget.text,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

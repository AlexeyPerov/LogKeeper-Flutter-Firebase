import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// TODO simplify with tuples
class HoverContainer extends StatefulWidget {
  final AlignmentGeometry alignment;
  final AlignmentGeometry hoverAlignment;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry hoverPadding;
  final Color color;
  final Color hoverColor;
  final Decoration decoration;
  final Decoration hoverDecoration;
  final Decoration foregroundDecoration;
  final Decoration hoverForegroundDecoration;
  final double width;
  final double hoverWidth;
  final double height;
  final double hoverHeight;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry hoverMargin;
  final Matrix4 transform;
  final Matrix4 hoverTransform;
  final Widget child;
  final Clip clipBehavior;
  final MouseCursor cursor;
  HoverContainer(
      {Key key,
        this.alignment,
        this.hoverAlignment,
        this.color,
        this.hoverColor,
        this.width,
        this.hoverWidth,
        this.height,
        this.hoverHeight,
        this.decoration,
        this.hoverDecoration,
        this.foregroundDecoration,
        this.hoverForegroundDecoration,
        this.child,
        this.clipBehavior = Clip.none,
        this.constraints,
        this.margin,
        this.hoverMargin,
        this.padding,
        this.hoverPadding,
        this.transform,
        this.cursor = SystemMouseCursors.basic,
        this.hoverTransform})
      : assert(margin == null || margin.isNonNegative),
        assert(hoverMargin == null || hoverMargin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(hoverPadding == null || hoverPadding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(hoverDecoration == null || hoverDecoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        assert(clipBehavior != null),
        super(key: key);
  @override
  _HoverContainerState createState() => _HoverContainerState();
}

class _HoverContainerState extends State<HoverContainer> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHover = true;
        });
      },
      cursor: widget.cursor,
      onExit: (event) {
        setState(() {
          _isHover = false;
        });
      },
      child: Container(
        key: widget.key,
        margin: _isHover ? widget.hoverMargin : widget.margin,
        width: _isHover ? widget.hoverWidth ?? widget.width : widget.width,
        height: _isHover ? widget.hoverHeight ?? widget.height : widget.height,
        alignment: _isHover
            ? widget.hoverAlignment ?? widget.alignment
            : widget.alignment,
        padding:
        _isHover ? widget.hoverPadding ?? widget.padding : widget.padding,
        color: _isHover ? widget.hoverColor ?? widget.color : widget.color,
        decoration: _isHover
            ? widget.hoverDecoration ?? widget.decoration
            : widget.decoration,
        foregroundDecoration: _isHover
            ? widget.hoverForegroundDecoration ?? widget.foregroundDecoration
            : widget.foregroundDecoration,
        clipBehavior: widget.clipBehavior,
        constraints: widget.constraints,
        child: widget.child,
      ),
    );
  }
}

class HoverAnimatedContainer extends StatefulWidget {
  final AlignmentGeometry alignment;
  final AlignmentGeometry hoverAlignment;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry hoverPadding;
  final Color color;
  final Color hoverColor;
  final Decoration decoration;
  final Decoration hoverDecoration;
  final Decoration foregroundDecoration;
  final Decoration hoverForegroundDecoration;
  final double width;
  final double hoverWidth;
  final double height;
  final double hoverHeight;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry hoverMargin;
  final Matrix4 transform;
  final Matrix4 hoverTransform;
  final Widget child;
  final Duration duration;
  final Curve curve;
  final MouseCursor cursor;
  HoverAnimatedContainer(
      {Key key,
        this.alignment,
        this.hoverAlignment,
        this.color,
        this.duration = const Duration(milliseconds: 200),
        this.hoverColor,
        this.width,
        this.hoverWidth,
        this.height,
        this.hoverHeight,
        this.decoration,
        this.hoverDecoration,
        this.foregroundDecoration,
        this.hoverForegroundDecoration,
        this.child,
        this.constraints,
        this.margin,
        this.hoverMargin,
        this.padding,
        this.hoverPadding,
        this.transform,
        this.curve = Curves.linear,
        this.cursor = SystemMouseCursors.basic,
        this.hoverTransform})
      : assert(margin == null || margin.isNonNegative),
        assert(hoverMargin == null || hoverMargin.isNonNegative),
        assert(padding == null || padding.isNonNegative),
        assert(hoverPadding == null || hoverPadding.isNonNegative),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(hoverDecoration == null || hoverDecoration.debugAssertIsValid()),
        assert(constraints == null || constraints.debugAssertIsValid()),
        super(key: key);
  @override
  _HoverAnimatedContainerState createState() => _HoverAnimatedContainerState();
}

class _HoverAnimatedContainerState extends State<HoverAnimatedContainer> {
  bool _isHover = false;
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _isHover = true;
        });
      },
      cursor: widget.cursor,
      onExit: (event) {
        setState(() {
          _isHover = false;
        });
      },
      child: AnimatedContainer(
        key: widget.key,
        margin: _isHover ? widget.hoverMargin : widget.margin,
        width: _isHover ? widget.hoverWidth ?? widget.width : widget.width,
        height: _isHover ? widget.hoverHeight ?? widget.height : widget.height,
        alignment: _isHover
            ? widget.hoverAlignment ?? widget.alignment
            : widget.alignment,
        padding:
        _isHover ? widget.hoverPadding ?? widget.padding : widget.padding,
        color: _isHover ? widget.hoverColor ?? widget.color : widget.color,
        decoration: _isHover
            ? widget.hoverDecoration ?? widget.decoration
            : widget.decoration,
        foregroundDecoration: _isHover
            ? widget.hoverForegroundDecoration ?? widget.foregroundDecoration
            : widget.foregroundDecoration,
        constraints: widget.constraints,
        duration: widget.duration,
        curve: widget.curve,
        child: widget.child,
      ),
    );
  }
}
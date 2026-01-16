import 'dart:io';

import 'package:flashly/src/colors.dart';
import 'package:flashly/src/press_effect.dart';
import 'package:flashly/src/txt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertActionButton extends StatefulWidget {
  const AlertActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.radius,
    this.isDestructive = false,
    this.isDestrutiveCancel = false,
    this.isPositive = false,
  });

  final VoidCallback? onPressed;
  final FontWeight? fontWeight;
  final String text;
  final double? fontSize;
  final bool isDestructive, isPositive, isDestrutiveCancel;
  final double? radius;

  @override
  State<AlertActionButton> createState() => _AlertActionButtonState();
}

class _AlertActionButtonState extends State<AlertActionButton> {
  BorderRadius get _borderRadius => BorderRadius.circular(widget.radius ?? 16);

  Color get _primaryColor => Theme.of(context).primaryColor;

  Widget _buildButtonDecoration(
    BuildContext context, {
    required Widget child,
  }) {
    late Color backgroungColor;

    if (widget.isDestrutiveCancel) {
      backgroungColor = destructiveRed.withValues(alpha: .15);
    } else if (widget.isDestructive) {
      backgroungColor = destructiveRed;
    } else if (widget.isPositive) {
      backgroungColor = _primaryColor.withValues(alpha: 1);
    } else {
      backgroungColor = _primaryColor.withValues(alpha: .15);
    } 

    return PressEffect(
      onPressed: widget.onPressed,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: backgroungColor,
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    late Color overlayColor;
    late Color color;

    if (widget.isDestrutiveCancel || widget.isDestructive) {
      overlayColor = destructiveRed;
    } else {
      overlayColor = _primaryColor;
    } 

    if (widget.isDestrutiveCancel) {
      color = destructiveRed;
    } else if (widget.isPositive || widget.isDestructive) {
      color = Theme.of(context).cardColor;
    } else {
      color = _primaryColor;
    }

    final child = Txt(
      widget.text, 
      fontSize: 17,
      color: color,
      fontWeight: FontWeight.w800,
      maxLines: 1,
      overflow: .ellipsis,
    );

    if (Platform.isIOS) {
      return _buildButtonDecoration(
        context,
        child: CupertinoButton.filled(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          borderRadius: _borderRadius,
          color: Colors.transparent,
          onPressed: widget.onPressed,
          child: child, 
        ),
      );
    }

    return _buildButtonDecoration(
      context,
      child: ElevatedButton(
        onPressed: widget.onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          overlayColor: overlayColor.withValues(alpha: .04),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedSuperellipseBorder(borderRadius: _borderRadius),
        ), 
        child: child,
      ),
    );
  }
}

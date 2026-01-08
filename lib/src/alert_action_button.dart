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
    this.isPositive = false,
    this.color,
  });

  final VoidCallback? onPressed;
  final FontWeight? fontWeight;
  final String text;
  final double? fontSize;
  final bool isDestructive, isPositive;
  final double? radius;
  final Color? color;

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
    final backgroungColor = widget.isDestructive 
    ? destructiveRed 
    : _primaryColor.withValues(alpha: widget.isPositive ? 1 : .2);

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
    final materialBackgroundColor = widget.isDestructive 
    ? destructiveRed : _primaryColor;

    final child = Txt(
      widget.text, 
      fontSize: 17,
      color: widget.isPositive || widget.isDestructive 
      ? Theme.of(context).cardColor : _primaryColor,
      fontWeight: FontWeight.bold,
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
          overlayColor: materialBackgroundColor.withValues(alpha: .04),
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedSuperellipseBorder(borderRadius: _borderRadius),
        ), 
        child: child,
      ),
    );
  }
}

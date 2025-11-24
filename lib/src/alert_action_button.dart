import 'dart:io';

import 'package:flashly/src/colors.dart';
import 'package:flashly/src/press_effect.dart';
import 'package:flashly/src/txt.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AlertActionButton extends StatelessWidget {
  const AlertActionButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.radius,
    this.isDestructive = false,
  });

  final VoidCallback? onPressed;
  final FontWeight? fontWeight;
  final String text;
  final double? fontSize;
  final bool isDestructive;
  final double? radius;

  BorderRadius get _borderRadius => BorderRadius.circular(radius ?? 12);

  Widget _buildButtonDecoration(
    BuildContext context, {
    required Widget child,
  }) {
    final backgroungColor = isDestructive 
    ? destructiveRed 
    : Theme.of(context).primaryColor;

    return PressEffect(
      onPressed: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              backgroungColor.withValues(alpha: .8),
              backgroungColor,
            ],
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final materialBackgroundColor = isDestructive ? destructiveRed : primaryColor;

    final child = Txt(
      text, 
      fontSize: 16,
      color: Theme.of(context).cardColor,
      fontWeight: FontWeight.bold,
    );

    if (Platform.isIOS) {
      return _buildButtonDecoration(
        context,
        child: CupertinoButton.filled(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          borderRadius: _borderRadius,
          color: Colors.transparent,
          onPressed: onPressed,
          child: child, 
        ),
      );
    }

    return _buildButtonDecoration(
      context,
      child: ElevatedButton(
        onPressed: onPressed,
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

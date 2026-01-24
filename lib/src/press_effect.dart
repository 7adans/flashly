import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PressEffect extends StatefulWidget {
  const PressEffect({
    super.key, 
    required this.child, 
    required this.onPressed,
  });

  final Widget child;
  final VoidCallback? onPressed;

  @override
  State<PressEffect> createState() => _PressEffectState();
}

class _PressEffectState extends State<PressEffect> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
      onTapUp: widget.onPressed == null ? null : (_) => setState(() => _pressed = false),
      onTapCancel: widget.onPressed == null ? null : () => setState(() => _pressed = false),
      onTap: widget.onPressed == null ? null : () {
        setState(() => _pressed = true);
        HapticFeedback.heavyImpact(); 
        Timer(Duration(milliseconds: 200), () {
          setState(() => _pressed = false);
        });
        widget.onPressed?.call();
      },
      child: AnimatedOpacity(
        opacity: _pressed ? 0.4 : 1,
        duration: const Duration(milliseconds: 200),
        child: AnimatedScale(
          scale: _pressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}
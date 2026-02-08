import 'dart:async';

import 'package:flashly/flashly.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAnimatedToast(
  String message, {
  IconData? icon,
  Color? iconColor,
  ToastState? state = ToastState.success,
  bool enableHaptics = false,
  bool enableSound = false,
}) {
  final overlay = Flashly.navigatorKey.currentState?.overlay;
  if (overlay == null) return;

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedToast(
      message: message,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class AnimatedToast extends StatefulWidget {
  final String message;
  final IconData? icon;
  final Color? iconColor;
  final ToastState? state;
  final VoidCallback onDismissed;

  const AnimatedToast({
    super.key, 
    required this.message, 
    required this.onDismissed,
    this.icon,
    this.iconColor,
    this.state = ToastState.success,
  });

  @override
  State<AnimatedToast> createState() => _AnimatedToastState();
}

class _AnimatedToastState extends State<AnimatedToast> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;
  late Animation<double> _opacityAnimation;
  double _dragOffset = 0.0;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Cubic(0.175, 0.885, 0.32, 1.07), 
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, .4, curve: Curves.linear),
    );

    _controller.forward();
    _startTimer();
  }

  void _startTimer() {
    _dismissTimer = Timer(const Duration(seconds: 3), _reverseAndDismiss);
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      _dismissTimer?.cancel();
      await _controller.animateTo(0, 
        curve: Curves.easeInOutCubic, 
        duration: const Duration(milliseconds: 450)
      );
      widget.onDismissed();
    }
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 10;

    return Positioned(
      bottom: bottomPadding,
      left: 12,
      right: 12,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final double slideTranslation = (1 - _slideAnimation.value) * 160;
          
          return Transform.translate(
            offset: Offset(0, slideTranslation + _dragOffset),
            child: Opacity(
              opacity: _opacityAnimation.value, 
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            _dismissTimer?.cancel();
            setState(() {
              _dragOffset += details.delta.dy;
              if (_dragOffset < 0) _dragOffset = 0; 
            });
          },
          onVerticalDragEnd: (details) {
            if (_dragOffset > 40 || details.primaryVelocity! > 100) {
              _reverseAndDismiss();
            } else {
              setState(() => _dragOffset = 0);
              _startTimer();
            }
          },
          // iOS feel Container design 17/18
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E).withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                spacing: 12,
                children: [
                  Icon(
                    widget.icon ??
                    (widget.state == ToastState.error 
                      ? CupertinoIcons.exclamationmark_circle
                      : widget.state == ToastState.info 
                          ? CupertinoIcons.info_circle
                          : CupertinoIcons.check_mark_circled), 
                    color: widget.iconColor ??
                      (widget.state == ToastState.error 
                        ? Colors.red.shade300 
                        : widget.state == ToastState.info ? Colors.amber.shade300 : Colors.green.shade300), 
                    size: 22,
                  ),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
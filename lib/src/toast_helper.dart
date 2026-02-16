import 'dart:async';
import 'dart:io';

import 'package:flashly/src/hapticsound_helper.dart';
import 'package:flashly/src/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'rich_txt.dart';

enum ToastState { error, info, success }

void showToast(
  String message, {
  String? richMessage,
  FontStyle? richMessageFontStyle,
  IconData? icon,
  Color? iconColor,
  ToastState? state = ToastState.success,
  double? fontSize,
  Duration? duration,
  bool enableHaptics = false,
  bool enableSound = false,
}) {
  final overlay = Flashly.navigatorKey.currentState?.overlay;
  if (overlay == null) return;

  if (enableHaptics) haptics();
  if (enableSound) playSound(state == ToastState.error);

  late OverlayEntry overlayEntry;
  overlayEntry = OverlayEntry(
    builder: (context) => AnimatedToast(
      message: message,
      richMessage: richMessage,
      richMessageFontStyle: richMessageFontStyle,
      icon: icon,
      iconColor: iconColor,
      state: state,
      fontSize: fontSize,
      duration: duration,
      onDismissed: () => overlayEntry.remove(),
    ),
  );

  overlay.insert(overlayEntry);
}

class AnimatedToast extends StatefulWidget {
  final String message;
  final String? richMessage;
  final IconData? icon;
  final Color? iconColor;
  final ToastState? state;
  final double? fontSize;
  final Duration? duration;
  final FontStyle? richMessageFontStyle;
  final VoidCallback onDismissed;

  const AnimatedToast({
    super.key, 
    required this.message, 
    this.richMessage,
    required this.onDismissed,
    this.icon,
    this.iconColor,
    this.fontSize,
    this.duration,
    this.richMessageFontStyle,
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
    _dismissTimer = Timer(
      widget.duration ?? const Duration(seconds: 3), 
      _reverseAndDismiss,
    );
  }

  void _reverseAndDismiss() async {
    if (mounted) {
      _dismissTimer?.cancel();
      await _controller.animateTo(
        0, 
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

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: 330,
        maxHeight: 250,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2E).withValues(alpha: Platform.isIOS ? .8 : 0.96),
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
        mainAxisSize: MainAxisSize.min,
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
                : widget.state == ToastState.info 
                  ? Colors.amber.shade300 
                  : Colors.green.shade300), 
            size: 22,
          ),
          Flexible(
            fit: FlexFit.loose,
            child: widget.richMessage != null
              ? RichTxt(
                  text1: widget.message, 
                  text2: widget.richMessage!,
                  color: Colors.white,
                  textOverflow1: .ellipsis,
                  textOverflow2: .ellipsis,
                  fontStyle2: widget.richMessageFontStyle,
                  fontSize: widget.fontSize ?? 15,
                  fontWeight: .w500,
                  decoration: .none,
                  letterSpacing: -0.4,
                )
              : Text(
                  widget.message,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: widget.fontSize ?? 15,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none,
                    letterSpacing: -0.4,
                  ),
                ),
          ),
        ],
      ),
    );
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
              child: Center(child: child),
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
          child: Material(
            color: Colors.transparent,
            child: Platform.isIOS
              ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                    filter: .blur(sigmaX: 8, sigmaY: 8),
                    child: _buildContent(),  
                  ),
              )
              : _buildContent(),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';
import 'dart:ui';

import 'package:flashly/src/colors.dart';
import 'package:flashly/src/hapticsound_helper.dart';
import 'package:flashly/src/txt.dart';
import 'package:flashly/src/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum ToastState {error, info, success}

void showToast(
  String message, {
  IconData? icon,
  Color? iconColor,
  ToastState? state = ToastState.success,
  bool enableHaptics = false,
  bool enableSound = false,
}) {
  if (enableHaptics) haptics();
  if (enableSound) playSound(state == ToastState.error);
  _showSnackBar(message, state, icon, iconColor);
}

ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _showSnackBar(
  String text, [
    ToastState? state,
    IconData? icon,
    Color? iconColor,
  ]
) {
  final content = Container(
    padding: EdgeInsets.fromLTRB(18, 14, 20, 14),
    constraints: BoxConstraints(maxWidth: 300, maxHeight: 220),
    decoration: BoxDecoration(
      color: gray.withValues(alpha: Platform.isIOS ? .9 : 1),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      spacing: 11,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon ??
          (state == ToastState.error 
            ? CupertinoIcons.exclamationmark_circle
            : state == ToastState.info 
                ? CupertinoIcons.info_circle
                : CupertinoIcons.check_mark_circled), 
          color: iconColor ??
            (state == ToastState.error 
              ? Colors.red.shade300 
              : state == ToastState.info ? Colors.amber.shade300 : Colors.green.shade300), 
          size: 20,
        ),
        Flexible(
          fit: FlexFit.loose,
          child: Txt(
            text,
            maxLines: 4,
            color: Colors.white, 
            fontSize: 13,
            fontWeight: FontWeight.w600,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );

  return Flashly.scaffoldMessengerKey.currentState!.showSnackBar(
    SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: Platform.isIOS 
        ? SnackBarBehavior.fixed 
        : SnackBarBehavior.floating,
      content: Center(
        child: Card(
          elevation: Platform.isIOS ? 20 : 0,
          color: Colors.transparent,
          shape: RoundedSuperellipseBorder(borderRadius: BorderRadius.circular(30)),
          shadowColor: Colors.black38,
          margin: EdgeInsets.zero,
          child: Platform.isIOS ? ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: content,
            ),
          ) : content,
        ),
      ),
    ),
  );
}

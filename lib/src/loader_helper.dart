import 'dart:async';
import 'dart:io';

import 'package:flashly/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'alert_helper.dart';

Widget buildAnimation(String icon, [double? size]) {
  return Lottie.asset(
    icon,
    width: size ?? 70,
    height: size ?? 70,
    fit: BoxFit.cover,
    repeat: true,
    package: 'flashly',
  );
}

Widget loader({
  double? size = 24, 
  Color? color, 
  Key? key, 
  double? scaleFactor,
  double? androidStrokeWidth,
  bool asNative = true,
}) {
  final indicator = Transform.scale(
    scale: scaleFactor ?? (Platform.isIOS ? 1.2 : 1),
    child: asNative ? CircularProgressIndicator.adaptive(
      valueColor: AlwaysStoppedAnimation(color),
      strokeWidth: androidStrokeWidth ?? 2,
    ) : buildAnimation('assets/animations/loading.json', 50),
  );

  return Center(
    child: SizedBox(
      width: size, height: size,
      child: color != null ? ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
        child: indicator,
      ) : indicator,
    ),
  );
}

void showTimingLoaderAlert(
  String placeholder, 
  [int? secs]
) {
  WidgetsBinding.instance.addPostFrameCallback((_) => showLoaderAlert(placeholder: placeholder));
  Timer(Duration(seconds: secs ?? 2), () => Navigator.pop(Flashly.context));
}

void showLoaderAlert({
  String? placeholder,
  int? closeLoaderAfterSecs,
  BuildContext? context,
}) {
  final placeholdr = placeholder != null ? '$placeholder...' : '';
  showAlert(
    placeholdr, 
    context: context,
    asLoader: true, 
    isDestructive: true,
    negativeTitle: 'Fechar',
    closeLoaderAfterSecs: closeLoaderAfterSecs ?? 45,
  );
}

void closeLoaderAlert([BuildContext? context]) {
  if (Navigator.canPop(context ?? Flashly.context)) {
    Navigator.pop(context ?? Flashly.context);
  }
} 
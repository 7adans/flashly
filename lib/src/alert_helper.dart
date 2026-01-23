import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flashly/src/alert_action_button.dart';
import 'package:flashly/src/hapticsound_helper.dart';
import 'package:flashly/src/txt.dart';
import 'package:flashly/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'rich_txt.dart';

enum AlertState { error, warning, info, success }

Future<T?> showAlert<T>(
  String title, {
  String? description,
  String? negativeTitle,
  String? positiveTitle,
  BuildContext? context,
  AlertState? state,
  bool isDestructive = false,
  bool asLoader = false,
  VoidCallback? onNegative,
  int? closeLoaderAfterSecs,
  Future<void> Function()? onPositive,
  bool enableHaptics = false,
  bool enableSound = false,
  bool success = false,
  bool info = false,
  bool error = false,
  Color? infoIconColor,
  double? radius,
  double? actionButtonRadius,
}) async {
  if (!asLoader) {
    if (enableHaptics) haptics();
    if (enableSound) playSound(state == AlertState.error);
  }

  return await _showDialog<T>(
    title,
    description: description,
    negativeTitle: negativeTitle,
    positiveTitle: positiveTitle,
    isDestructive: isDestructive,
    onNegative: onNegative,
    onPositive: onPositive,
    asLoader: asLoader,
    closeLoaderAfterSecs: closeLoaderAfterSecs,
    state: state,
    infoIconColor: infoIconColor,
    context: context,
    radius: radius,
    actionButtonRadius: actionButtonRadius,
  );
}

Future<T?> _showDialog<T>(
  String title, {
  String? richTitle,
  String? description,
  String? negativeTitle,
  String? positiveTitle,
  BuildContext? context,
  bool isDestructive = false,
  bool asLoader = false,
  VoidCallback? onNegative,
  int? closeLoaderAfterSecs,
  Future<void> Function()? onPositive,
  AlertState? state,
  Color? infoIconColor,
  double? radius,
  double? actionButtonRadius,
}) async {
  bool showButton = false;
  bool timerStarted = false;

  Widget buildDefaultActionButton() {
    return AlertActionButton(
      text: negativeTitle ?? 'Cancelar',
      isDestructive: positiveTitle == null && isDestructive,
      isDestrutiveCancel: positiveTitle != null && isDestructive,
      isPositive: positiveTitle == null,
      radius: actionButtonRadius,
      onPressed: () {
        Navigator.pop(Flashly.context);
        if (onNegative != null) onNegative();
      },
    );
  }

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

  Widget buildChild(BuildContext context) => AnimatedSize(
    duration: Duration(milliseconds: 500),
    curve: Curves.easeInOut,
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: asLoader ? 14 : 25),
      child: StatefulBuilder(
        builder: (context, setState) {
          if (!timerStarted && closeLoaderAfterSecs != null) {
            timerStarted = true;
            Future.delayed(Duration(seconds: closeLoaderAfterSecs), () {
              if (context.mounted && Navigator.canPop(Flashly.context)) {
                setState(() => showButton = true);
              }
            });
          }
      
          return Column(
            spacing: (asLoader && showButton) || !asLoader ? 20 : 0,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: asLoader ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              if (state != null && !asLoader) ...[
                if (state == AlertState.success)
                  buildAnimation('assets/animations/alert_success.json')
                else if (state == AlertState.error)
                  buildAnimation('assets/animations/alert_error.json')
                else if (state == AlertState.info)
                  buildAnimation('assets/animations/alert_info.json')
                else if (state == AlertState.warning)
                  buildAnimation('assets/animations/warning.json'),
              ],
              if (asLoader) Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    buildAnimation('assets/animations/loading.json', 50),
                    Expanded(child: Txt(title, fontWeight: FontWeight.w500, fontSize: 16)),
                  ],
                ),
              ) 
              else SizedBox(
                width: double.maxFinite,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 12,
                  children: [
                    if (title.isNotEmpty) ...[
                      if (richTitle != null)
                        RichTxt(
                          text1: title, 
                          text2: richTitle,
                          fontSize: 18,
                          fontWeight: FontWeight.bold, 
                          color2: Theme.of(context).primaryColor,
                          textAlign: TextAlign.center,
                          textOverflow1: TextOverflow.ellipsis,
                          textOverflow2: .ellipsis,
                        )
                      else 
                        Txt(
                          title, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 18,
                          maxLines: 2,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                    if (description != null)
                      Txt(
                        description, 
                        color: Theme.of(context).colorScheme.onSurface, 
                        fontSize: 15, 
                        maxLines: 7,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w500,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              Row(
                spacing: 10,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (asLoader) Expanded(
                      child: AnimatedScale(
                        scale: showButton ? 1.0 : .5,
                        duration: const Duration(milliseconds: 500),
                        child: Visibility(
                          visible: showButton,
                          maintainSize: false,
                          maintainAnimation: true,
                          maintainState: true,
                          child: buildDefaultActionButton(),
                        ),
                      ),
                    )
                  else
                    Expanded(child: buildDefaultActionButton()),

                  if (positiveTitle != null && !asLoader)
                    Expanded(
                      child: AlertActionButton(
                        text: positiveTitle,
                        isPositive: !isDestructive,
                        isDestructive: isDestructive,
                        radius: actionButtonRadius,
                        onPressed: () {
                          Navigator.pop(Flashly.context);
                          if (onPositive != null) onPositive();
                        },
                      ),
                    ),
                ],
              ),
            ],
          );
        }
      ),
    ),
  );

  return showDialog<T>(
    context: context ?? Flashly.context,
    barrierDismissible: false,
    barrierColor: Colors.black45,
    builder: (context) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(
            1, (index) => _AlertContainer(
              asLoader: asLoader, 
              radius: radius,
              child: buildChild(context), 
            ),
          ),
        ),
      ),
    ),
  );
}

class _AlertContainer extends StatelessWidget {
  final bool asLoader;
  final Widget child;
  final double? radius;

  const _AlertContainer({
    required this.asLoader, 
    required this.child,
    this.radius,
  });

  BorderRadius get _borderRadius => BorderRadius.circular(radius ?? 16);

  @override
  Widget build(BuildContext context) {
    final content = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 326, maxHeight: 450),
      child: Dialog(
        elevation: 0,
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: Platform.isIOS ? 6 : 3, 
              sigmaY: Platform.isIOS ? 6 : 3
            ),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                gradient: Platform.isIOS ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).cardColor.withValues(alpha: 0.55),
                    Theme.of(context).cardColor.withValues(alpha: 0.45),
                    Theme.of(context).cardColor.withValues(alpha: 0.38),
                    Theme.of(context).cardColor.withValues(alpha: 0.42),
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ) : null,
                color: Platform.isIOS ? null : Theme.of(Flashly.context).cardColor,
                border: Platform.isIOS ? Border.all(
                  width: .6,
                  color: Theme.of(context).cardColor.withValues(alpha: 0.4),
                ) : null,
                boxShadow: Platform.isIOS ? [
                  BoxShadow(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.6),
                    offset: Offset(0, 1),
                    blurRadius: 0,
                    spreadRadius: 0,
                    blurStyle: BlurStyle.inner,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: Offset(0, 8),
                    blurRadius: 32,
                    spreadRadius: -8,
                  ),
                ] : null,
              ),
              child: Container(
                decoration: Platform.isIOS ? BoxDecoration(
                  borderRadius: _borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).cardColor.withValues(alpha: 0.08),
                      Theme.of(context).cardColor.withValues(alpha: 0.02),
                    ],
                  ),
                ) : null,
                child: ClipRRect(
                  borderRadius: _borderRadius,
                  child: BackdropFilter(
                    filter: Platform.isIOS 
                      ? ImageFilter.blur(sigmaX: 4, sigmaY: 4)
                      : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      decoration: Platform.isIOS ? BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment.topLeft,
                          radius: 2.0,
                          colors: [
                            Theme.of(context).cardColor.withValues(alpha: 0.03),
                            Colors.transparent,
                          ],
                        ),
                      ) : null,
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (asLoader) return Center(child: content);
    return content;
  }
}
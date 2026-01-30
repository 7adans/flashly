import 'package:flashly/src/utils.dart';
import 'package:flutter/services.dart';

enum HapticImpact {medium, vibrate, light, heavy}

void haptics({
  HapticImpact impact = HapticImpact.medium,
}) {
  if (impact == HapticImpact.heavy) {
    HapticFeedback.heavyImpact();
  }
  if (impact == HapticImpact.medium) {
    HapticFeedback.mediumImpact();
  }
  if (impact == HapticImpact.light) {
    HapticFeedback.lightImpact();
  }
  if (impact == HapticImpact.vibrate) {
    HapticFeedback.vibrate();
  }
}

Future<void> playSound([bool error = false]) async {
  await playAlert(
    isError: error,
    path: 'success.mp3',
    errorPath: error ? 'error.mp3' : null,
  );
}
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Flashly {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => navigatorKey.currentState!.context;
}

Future<void> playAudio(String path) async {
  final player = AudioPlayer();

  await player.setReleaseMode(ReleaseMode.stop);

  await player.setAudioContext(
    AudioContext(
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.ambient,
        options: { AVAudioSessionOptions.mixWithOthers },
      ),
    ),
  );

  await player.play(AssetSource(path));

  player.onPlayerComplete.listen((event) {
    player.dispose();
  });
}

Future<void> playAlert({
  String? errorPath,
  required String path,
  bool isError = false,
}) async {
  if (isError && errorPath != null) {
    await playAudio(errorPath);

    return;
  }
  await playAudio(path);
}
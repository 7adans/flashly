import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class Flashly {
  static final navigatorKey = GlobalKey<NavigatorState>();
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  static BuildContext get context => navigatorKey.currentState!.context;
}

final _player = AudioPlayer();

Future<void> playAudio(String path) async {
  await _player.setReleaseMode(ReleaseMode.stop);
  await _player.play(AssetSource(path));
  await _player.dispose();
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
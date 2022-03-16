import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:just_audio/just_audio.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class SoundRecorder {
  FlutterSoundRecorder? _audioRecorder;

  String pathToSaveAudio = 'audio.aac';
  bool isRecorderInicializado = false;

  bool get isRecording => _audioRecorder!.isRecording;

  Future init(String nameAudio) async {
    pathToSaveAudio = nameAudio;
    _audioRecorder = FlutterSoundRecorder();

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Micrófono denegado');
    }

    await _audioRecorder!.openAudioSession();
    isRecorderInicializado = true;
  }

  void dispose() {
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    isRecorderInicializado = false;
  }

  Future _record() async {
    Directory directory = await getApplicationDocumentsDirectory();
    await _audioRecorder!.startRecorder(
        toFile: directory.path + '/' + pathToSaveAudio, codec: Codec.aacMP4);
  }

  Future _stop() async {
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      await _record();
    } else {
      await _stop();
    }
  }
}

class SoundPlaying {
  //of progress bar and button Sound Player
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  FlutterSoundPlayer? _audioPlayer;

  bool get isPlaying => _audioPlayer!.isPlaying;

  AudioPlayer? _player;

  String pathToSaveAudio = 'audio.aac';

  Future init(String nameAudio) async {
    pathToSaveAudio = nameAudio;
    _audioPlayer = FlutterSoundPlayer();
    _player = AudioPlayer();
    await _audioPlayer!.openAudioSession();
    // await _player!.setUrl(
    //     'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3');
    setFile();

    _player!.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        // completed
        _player!.seek(Duration.zero);
        _player!.pause();
      }
    });

    _player!.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
    _player!.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
    _player!.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  Future dispose() async {
    _audioPlayer!.closeAudioSession();
    _audioPlayer = null;
    _player!.dispose();
  }

  void pauseAudio() async {
    if (await existFile()) {
      _player!.pause();
    }
  }

  void seek(Duration position) async {
    if (await existFile()) {
      _player!.seek(position);
    }
  }

  Future<bool> existFile() async {
    File file =
        File((await _audioPlayer!.getResourcePath())! + "/" + pathToSaveAudio);
    if (await file.exists()) {
      return true;
    } else {
      return false;
    }
  }

  void setFile() async {
    if (await existFile()) {
      await _player!.setFilePath(
          (await _audioPlayer!.getResourcePath())! + "/" + pathToSaveAudio);
    }
  }

  Future<String> getUrlAudio() async {
    if (await existFile()) {
      return (await _audioPlayer!.getResourcePath())! + "/" + pathToSaveAudio;
    } else {
      return '';
    }
  }

  void playAudio() async {
    if (await existFile()) {
      _player!.play();
    }
  }
}

class SoundPlayingOnline {
  //of progress bar and button Sound Player
  final progressNotifier = ValueNotifier<ProgressBarState>(
    ProgressBarState(
      current: Duration.zero,
      buffered: Duration.zero,
      total: Duration.zero,
    ),
  );
  final buttonNotifier = ValueNotifier<ButtonState>(ButtonState.paused);

  AudioPlayer? _player;

  // String pathToSaveAudio = 'audio.aac';

  Future init(String urlAudio) async {
    // pathToSaveAudio = nameAudio;

    _player = AudioPlayer();

    setFile(urlAudio);

    _player!.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier.value = ButtonState.loading;
      } else if (!isPlaying) {
        buttonNotifier.value = ButtonState.paused;
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier.value = ButtonState.playing;
      } else {
        // completed
        _player!.seek(Duration.zero);
        _player!.pause();
      }
    });

    _player!.positionStream.listen((position) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
    });
    _player!.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
    });
    _player!.durationStream.listen((totalDuration) {
      final oldState = progressNotifier.value;
      progressNotifier.value = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
    });
  }

  Future dispose() async {
    _player!.dispose();
  }

  void pauseAudio() async {
    // if (await existFile()) {
    _player!.pause();
    // }
  }

  void seek(Duration position) async {
    // if (await existFile()) {
    _player!.seek(position);
    // }
  }

  void setFile(String urlAudio) async {
    // if (await existFile()) {
    await _player!.setUrl(urlAudio);
    // }
  }

  void playAudio() async {
    // if (await existFile()) {
    _player!.play();
    // }
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }

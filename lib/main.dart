import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class TimerController extends GetxController {
  late final Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();

  int _targetTimeMillis = 0;

  int _remainingTimeMillis = 0;
  final RxString remainingTime = '00:00'.obs;

  final RxBool isTimerRunning = false.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioRunning = false;

  @override
  void onInit() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _updateRemainingTime();
      _soundOnTimerEnd();
      isTimerRunning.value = _stopwatch.isRunning;
    });
    super.onInit();
  }

  void _updateRemainingTime() {
    int elapsedTimeMillis = _stopwatch.elapsedMilliseconds;
    _remainingTimeMillis =
        (_targetTimeMillis - elapsedTimeMillis).clamp(0, _targetTimeMillis);
    if (_remainingTimeMillis >= 0) {
      int minutes = (_remainingTimeMillis ~/ (1000 * 60)) % 60;
      int seconds = (_remainingTimeMillis ~/ 1000) % 60;
      remainingTime.value = '${_padZero(minutes)}:${_padZero(seconds)}';
    }
  }

  void _soundOnTimerEnd() {
    if (_remainingTimeMillis == 0 && _stopwatch.isRunning && !_isAudioRunning) {
      _audioPlayer.play(AssetSource('kitchen_timer1.mp3'));
      _isAudioRunning = true;
    }
    if (!_stopwatch.isRunning && _isAudioRunning) {
      _audioPlayer.stop();
      _isAudioRunning = false;
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  void setTimer(int timeMillis) {
    if (!_stopwatch.isRunning) {
      _stopwatch.reset();
      _targetTimeMillis = _remainingTimeMillis + timeMillis;
    }
  }

  void startStopTimer() {
    if (_stopwatch.isRunning) {
      _stopwatch.stop();
    } else {
      _stopwatch.start();
    }
  }

  void resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _targetTimeMillis = 0;
  }

  String _padZero(int num) => num.toString().padLeft(2, '0');
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final timerController = Get.put(TimerController());

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Obx(
                () => Text(
                  timerController.remainingTime.value,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () => timerController.setTimer(5 * 60 * 1000),
                    child: const Text('5分'),
                  ),
                  ElevatedButton(
                    onPressed: () => timerController.setTimer(3 * 60 * 1000),
                    child: const Text('3分'),
                  ),
                  ElevatedButton(
                    onPressed: () => timerController.setTimer(1 * 60 * 1000),
                    child: const Text('1分'),
                  ),
                  ElevatedButton(
                    onPressed: () => timerController.setTimer(10 * 1000),
                    child: const Text('10秒'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => timerController.startStopTimer(),
                child: Obx(
                  () => Text(
                    timerController.isTimerRunning.value ? 'ストップ' : 'スタート',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => timerController.resetTimer(),
                child: const Text('リセット'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

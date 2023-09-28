import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(MyApp());

class StopwatchController extends GetxController {
  late final Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();

  int _targetTimeMillis = 0;

  int _remainingTimeMillis = 0;
  final RxString remainingTime = '00:00'.obs;

  final RxBool isTimerRunning = false.obs;

  @override
  void onInit() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      int elapsedMillis = _stopwatch.elapsedMilliseconds;
      int remainingMillis =
          (_targetTimeMillis - elapsedMillis).clamp(0, _targetTimeMillis);
      if (remainingMillis >= 0) {
        int minutes = (remainingMillis ~/ (1000 * 60)) % 60;
        int seconds = (remainingMillis ~/ 1000) % 60;
        remainingTime.value = '${_padZero(minutes)}:${_padZero(seconds)}';
      }
      _remainingTimeMillis = remainingMillis;
      isTimerRunning.value = _stopwatch.isRunning;
    });
    super.onInit();
  }

  @override
  void dispose() {
    _timer.cancel();
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

  final stopwatchController = Get.put(StopwatchController());

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
                  stopwatchController.remainingTime.value,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () =>
                        stopwatchController.setTimer(5 * 60 * 1000),
                    child: const Text('5分'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        stopwatchController.setTimer(3 * 60 * 1000),
                    child: const Text('3分'),
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        stopwatchController.setTimer(1 * 60 * 1000),
                    child: const Text('1分'),
                  ),
                  ElevatedButton(
                    onPressed: () => stopwatchController.setTimer(10 * 1000),
                    child: const Text('10秒'),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => stopwatchController.startStopTimer(),
                child: Obx(
                  () => Text(
                    stopwatchController.isTimerRunning.value ? 'ストップ' : 'スタート',
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => stopwatchController.resetTimer(),
                child: const Text('リセット'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

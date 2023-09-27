import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() => runApp(MyApp());

class StopwatchController extends GetxController {
  late final Timer _timer;
  final Stopwatch _stopwatch = Stopwatch();

  final RxString elapsedTime = '00:00'.obs;

  @override
  void onInit() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      int elapsedMillis = _stopwatch.elapsedMilliseconds;
      int seconds = (elapsedMillis ~/ 1000) % 60;
      int millisec = (elapsedMillis % 1000) ~/ 10;

      elapsedTime.value = '${_padZero(seconds)}:${_padZero(millisec)}';
    });
    super.onInit();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
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
                  stopwatchController.elapsedTime.value,
                  style: const TextStyle(fontSize: 50),
                ),
              ),
              ElevatedButton(
                onPressed: () => stopwatchController.startStopTimer(),
                child: const Text('スタート/ストップ'),
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

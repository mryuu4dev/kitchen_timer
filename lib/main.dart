import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:vibration/vibration.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(MyApp()));
}

class TimerController extends GetxController {
  late final Timer _timer;
  Timer? _timerVibrate;
  final Stopwatch _stopwatch = Stopwatch();

  int _targetTimeMillis = 0;

  int _remainingTimeMillis = 0;
  final RxString remainingTime = '00:00'.obs;

  final RxBool isTimerRunning = false.obs;
  final RxBool isTimerFinished = false.obs;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isAudioRunning = false;

  final RxBool _isAudioActive = true.obs;
  bool get isAudioActive => _isAudioActive.value;

  final RxDouble timerProgress = 0.0.obs;

  @override
  void onInit() {
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      _updateRemainingTime();
      _soundOnTimerEnd();
      isTimerRunning.value = _stopwatch.isRunning;
      isTimerFinished.value = _remainingTimeMillis == 0 && _stopwatch.isRunning;
      timerProgress.value =
          _targetTimeMillis == 0 ? 0 : _remainingTimeMillis / _targetTimeMillis;
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
    if (isTimerFinished.value && !_isAudioRunning) {
      if (_isAudioActive.value) {
        _audioPlayer.play(AssetSource('kitchen_timer.mp3'));
      }
      _timerVibrate = Timer.periodic(const Duration(seconds: 1), (timer) {
        Vibration.vibrate(duration: 500);
      });
      _isAudioRunning = true;
    }
    if (!_stopwatch.isRunning && _isAudioRunning) {
      _audioPlayer.stop();
      _timerVibrate?.cancel();
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
    } else if (_remainingTimeMillis != 0) {
      _stopwatch.start();
    }
  }

  void resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _targetTimeMillis = 0;
  }

  void toggleAudioActive() {
    if (!_isAudioRunning) {
      _isAudioActive.value = !_isAudioActive.value;
    }
  }

  String _padZero(int num) => num.toString().padLeft(2, '0');
}

class AppColor {
  static const Color primary = Color(0xFF7A8ECD);
  static const Color secondary = Color(0xFF4D6BCB);
  static const Color accent = Color(0xFF4DACCC);
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    ever(timerController.isTimerFinished, (bool flag) {
      if (flag) {
        Get.defaultDialog(
          title: '時間になりました',
          titleStyle: const TextStyle(fontSize: 20),
          middleText: 'ボタンをタップしてタイマーを止める',
          confirm: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              timerController.resetTimer();
              Get.back();
            },
            child:
                const Text('ストップ', style: TextStyle(color: AppColor.primary)),
          ),
          barrierDismissible: false,
        );
      }
    });
  }

  final timerController = Get.put(TimerController());

  Widget _buildCircularProgress({
    double size = 250,
    required Widget child,
  }) =>
      SizedBox(
        width: size,
        height: size,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Obx(
              () => CircularProgressIndicator(
                value: timerController.timerProgress.value,
                valueColor: const AlwaysStoppedAnimation(AppColor.secondary),
                strokeWidth: 6,
                // 0xFF4D80CC, 0xFF4DACCC, 0xFF4DCCB1
                backgroundColor: timerController.isTimerRunning.value ||
                        timerController.timerProgress.value != 0
                    ? AppColor.accent
                    : AppColor.secondary,
              ),
            ),
            Center(child: child),
          ],
        ),
      );

  Widget _buildSquareButton(
          {required VoidCallback onPressed, required Widget child}) =>
      OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColor.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          side: const BorderSide(color: Colors.white),
        ),
        child: child,
      );

  Widget _buildTimeButton({
    required VoidCallback onPressed,
    required int timeValue,
    required String timeUnit,
    double padding = 10,
  }) =>
      OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColor.primary,
          padding: EdgeInsets.all(padding),
          shape: const CircleBorder(),
          side: const BorderSide(color: Colors.white),
        ),
        child: Column(
          children: <Widget>[
            Text('+${timeValue.toString()}',
                style: const TextStyle(color: Colors.white)),
            Text(timeUnit, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      theme: ThemeData(
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
        scaffoldBackgroundColor: AppColor.primary,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'キッチンタイマー',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => timerController.toggleAudioActive(),
              icon: Obx(
                () => Icon(
                  timerController.isAudioActive
                      ? Icons.volume_up
                      : Icons.volume_off,
                ),
              ),
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        drawer: Drawer(
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: 180,
                decoration: const BoxDecoration(color: AppColor.primary),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('キッチンタイマー',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                    SizedBox(
                      height: 15,
                    ),
                    Text('ver.1.0.0', style: TextStyle(color: Colors.white)),
                    SizedBox(
                      height: 5,
                    ),
                    Text('開発者: ゆとり', style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              ListTile(
                onTap: () => Get.to(() => const ContactView()),
                title: const Text('お問い合わせ'),
              ),
            ],
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildCircularProgress(
                child: Obx(
                  () => Text(
                    timerController.remainingTime.value,
                    style: const TextStyle(
                      fontSize: 65,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildTimeButton(
                    onPressed: () => timerController.setTimer(5 * 60 * 1000),
                    timeValue: 5,
                    timeUnit: '分',
                  ),
                  const SizedBox(width: 10),
                  _buildTimeButton(
                    onPressed: () => timerController.setTimer(3 * 60 * 1000),
                    timeValue: 3,
                    timeUnit: '分',
                  ),
                  const SizedBox(width: 10),
                  _buildTimeButton(
                    onPressed: () => timerController.setTimer(1 * 60 * 1000),
                    timeValue: 1,
                    timeUnit: '分',
                  ),
                  const SizedBox(width: 10),
                  _buildTimeButton(
                    onPressed: () => timerController.setTimer(10 * 1000),
                    timeValue: 10,
                    timeUnit: '秒',
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  _buildSquareButton(
                    onPressed: () => timerController.resetTimer(),
                    child: const Text('リセット',
                        style: TextStyle(fontSize: 20, color: Colors.white)),
                  ),
                  const SizedBox(width: 10),
                  _buildSquareButton(
                    onPressed: () => timerController.startStopTimer(),
                    child: Obx(
                      () => Text(
                        timerController.isTimerRunning.value ? 'ストップ' : 'スタート',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'お問い合わせ',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          '準備中',
          style: TextStyle(
            color: Colors.white,
            fontSize: 30,
          ),
        ),
      ),
    );
  }
}

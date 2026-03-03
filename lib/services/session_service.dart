import 'dart:async';
import 'package:flutter/material.dart';

class SessionService extends ChangeNotifier {
  Timer? _timer;
  final int timeoutMinutes;
  VoidCallback? onTimeout;

  SessionService({required this.timeoutMinutes, this.onTimeout});

  void startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(minutes: timeoutMinutes), () {
      if (onTimeout != null) onTimeout!();
    });
  }

  void resetTimer() {
    startTimer();
  }

  void stopTimer() {
    _timer?.cancel();
  }
}

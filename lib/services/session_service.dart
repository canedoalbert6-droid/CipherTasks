import 'dart:async';
import 'package:flutter/material.dart';

class SessionService extends ChangeNotifier with WidgetsBindingObserver {
  Timer? _timer;
  Timer? _warningTimer;
  final int timeoutMinutes;
  VoidCallback? onTimeout;
  VoidCallback? onWarning;

  SessionService({required this.timeoutMinutes, this.onTimeout, this.onWarning}) {
    WidgetsBinding.instance.addObserver(this);
  }

  // setContext no longer needed as we removed the background lock logic
  void setContext(BuildContext context) {}

  void startTimer() {
    stopTimer();
    
    // Set warning timer (30 seconds before timeout)
    final warningDuration = Duration(minutes: timeoutMinutes) - const Duration(seconds: 30);
    if (warningDuration > Duration.zero) {
      _warningTimer = Timer(warningDuration, () {
        if (onWarning != null) onWarning!();
      });
    }

    _timer = Timer(Duration(minutes: timeoutMinutes), () {
      if (onTimeout != null) onTimeout!();
    });
  }

  void resetTimer() {
    startTimer();
  }

  void stopTimer() {
    _timer?.cancel();
    _warningTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Background lock logic removed as per user request
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    stopTimer();
    super.dispose();
  }
}

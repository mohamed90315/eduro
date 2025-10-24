import 'dart:async';
import 'package:flutter/material.dart';
import 'global_notification_service.dart';

// Global timer service to persist across navigation
class PomodoroTimerService {
  static final PomodoroTimerService _instance = PomodoroTimerService._internal();
  factory PomodoroTimerService() => _instance;
  PomodoroTimerService._internal();

  Timer? _timer;
  
  // Focus mode state
  final int _focusTotalSeconds = 25 * 60;
  int _focusRemainingSeconds = 25 * 60;
  bool _focusIsRunning = false;
  bool _focusIsPaused = false;
  
  // Break mode state
  final int _breakTotalSeconds = 5 * 60;
  int _breakRemainingSeconds = 5 * 60;
  bool _breakIsRunning = false;
  bool _breakIsPaused = false;

  // Current display mode
  bool _currentDisplayMode = true; // true for focus, false for break

  // Callbacks for UI updates
  final List<VoidCallback> _listeners = [];

  // Getters
  bool get currentDisplayMode => _currentDisplayMode;
  
  // Focus getters
  int get focusRemainingSeconds => _focusRemainingSeconds;
  int get focusTotalSeconds => _focusTotalSeconds;
  bool get focusIsRunning => _focusIsRunning;
  bool get focusIsPaused => _focusIsPaused;
  double get focusProgress => (_focusTotalSeconds - _focusRemainingSeconds) / _focusTotalSeconds;
  
  // Break getters
  int get breakRemainingSeconds => _breakRemainingSeconds;
  int get breakTotalSeconds => _breakTotalSeconds;
  bool get breakIsRunning => _breakIsRunning;
  bool get breakIsPaused => _breakIsPaused;
  double get breakProgress => (_breakTotalSeconds - _breakRemainingSeconds) / _breakTotalSeconds;
  
  // Current mode getters (based on display mode)
  int get currentRemainingSeconds => _currentDisplayMode ? _focusRemainingSeconds : _breakRemainingSeconds;
  int get currentTotalSeconds => _currentDisplayMode ? _focusTotalSeconds : _breakTotalSeconds;
  bool get currentIsRunning => _currentDisplayMode ? _focusIsRunning : _breakIsRunning;
  bool get currentIsPaused => _currentDisplayMode ? _focusIsPaused : _breakIsPaused;
  double get currentProgress => _currentDisplayMode ? focusProgress : breakProgress;

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void setDisplayMode(bool isFocus) {
    _currentDisplayMode = isFocus;
    _notifyListeners();
  }

  void startTimer(bool isFocus) {
    if (isFocus) {
      // Stop and reset break timer if it's running
      if (_breakIsRunning || _breakIsPaused) {
        _breakIsRunning = false;
        _breakIsPaused = false;
        _breakRemainingSeconds = _breakTotalSeconds;
      }
      
      if (_focusIsPaused) {
        _focusIsRunning = true;
        _focusIsPaused = false;
      } else {
        _focusIsRunning = true;
        _focusRemainingSeconds = _focusTotalSeconds;
      }
    } else {
      // Stop and reset focus timer if it's running
      if (_focusIsRunning || _focusIsPaused) {
        _focusIsRunning = false;
        _focusIsPaused = false;
        _focusRemainingSeconds = _focusTotalSeconds;
      }
      
      if (_breakIsPaused) {
        _breakIsRunning = true;
        _breakIsPaused = false;
      } else {
        _breakIsRunning = true;
        _breakRemainingSeconds = _breakTotalSeconds;
      }
    }

    _startPeriodicTimer();
    _notifyListeners();
  }

  void _startPeriodicTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      bool shouldContinue = false;

      if (_focusIsRunning && _focusRemainingSeconds > 0) {
        _focusRemainingSeconds--;
        shouldContinue = true;
      } else if (_focusIsRunning && _focusRemainingSeconds <= 0) {
        _focusIsRunning = false;
        _onTimerComplete(true);
      }

      if (_breakIsRunning && _breakRemainingSeconds > 0) {
        _breakRemainingSeconds--;
        shouldContinue = true;
      } else if (_breakIsRunning && _breakRemainingSeconds <= 0) {
        _breakIsRunning = false;
        _onTimerComplete(false);
      }

      if (!shouldContinue) {
        _timer?.cancel();
      }

      _notifyListeners();
    });
  }

  void pauseTimer(bool isFocus) {
    if (isFocus) {
      _focusIsRunning = false;
      _focusIsPaused = true;
    } else {
      _breakIsRunning = false;
      _breakIsPaused = true;
    }

    // Check if we should stop the periodic timer
    if (!_focusIsRunning && !_breakIsRunning) {
      _timer?.cancel();
    }

    _notifyListeners();
  }

  void resetTimer(bool isFocus) {
    if (isFocus) {
      _focusIsRunning = false;
      _focusIsPaused = false;
      _focusRemainingSeconds = _focusTotalSeconds;
    } else {
      _breakIsRunning = false;
      _breakIsPaused = false;
      _breakRemainingSeconds = _breakTotalSeconds;
    }

    // Check if we should stop the periodic timer
    if (!_focusIsRunning && !_breakIsRunning) {
      _timer?.cancel();
    }

    _notifyListeners();
  }

  void _onTimerComplete(bool wasFocus) {
    // Use global notification service for app-wide dialogs
    GlobalNotificationService().showTimerCompletionDialog(wasFocus);
  }

  String formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  bool get hasAnyRunningTimer => _focusIsRunning || _breakIsRunning;
  
  void dispose() {
    _timer?.cancel();
    _listeners.clear();
  }
}

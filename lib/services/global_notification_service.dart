import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'timer_service.dart';
import '../screen/pomodoro.dart';

class GlobalNotificationService {
  static final GlobalNotificationService _instance = GlobalNotificationService._internal();
  factory GlobalNotificationService() => _instance;
  GlobalNotificationService._internal();

  // Create the navigator key as a static field that's always available
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void showTimerCompletionDialog(bool wasFocus) {
    if (navigatorKey.currentContext == null) return;

    // Play alarm sound and haptic feedback
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    
    // Create vibration pattern
    _playAlarmVibration();

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7), // Dark blur background
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon and title
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: wasFocus 
                          ? [Colors.green.withOpacity(0.2), Colors.green.withOpacity(0.1)]
                          : [Colors.orange.withOpacity(0.2), Colors.orange.withOpacity(0.1)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      wasFocus ? Icons.celebration : Icons.coffee,
                      color: wasFocus ? Colors.green : Colors.orange,
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  Text(
                    wasFocus ? 'Focus Complete! 🎉' : 'Break Time Over! ⏰',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    wasFocus 
                      ? 'Great job focusing! Ready for a break?'
                      : 'Time to get back to work!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    wasFocus 
                      ? 'You\'ve completed a full focus session. Take a well-deserved break to recharge!'
                      : 'Your break time is over. Ready to start another focused work session?',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text(
                            'Dismiss',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      
                      const SizedBox(width: 12),
                      
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: wasFocus 
                                ? [Colors.greenAccent, Colors.green]
                                : [Colors.blueAccent, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: wasFocus 
                                  ? Colors.green.withOpacity(0.3)
                                  : Colors.blue.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _switchModeAndStart(!wasFocus);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              wasFocus ? 'Start Break' : 'Start Focus',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
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
      },
    );
  }

  void showDailyGoalCompletedDialog(int currentStreak) {
    if (navigatorKey.currentContext == null) return;

    // Play celebration sound and haptic feedback
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);
    _playCelebrationVibration();

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Celebration icon
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Color(0xFF2A7DE1),
                      size: 40,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Daily Goal Completed! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  const Text(
                    'Congratulations! You\'ve completed all your study sessions for today!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Current Streak: $currentStreak days 🔥',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Close button
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Awesome! 🎊',
                        style: TextStyle(
                          color: Color(0xFF2A7DE1),
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showAlreadyCompletedDialog(int dailyGoal) {
    if (navigatorKey.currentContext == null) return;

    // Play gentle notification
    HapticFeedback.lightImpact();

    showDialog(
      context: navigatorKey.currentContext!,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 3,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Info icon
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 30,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  const Text(
                    'Already at Max! 📊',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    'You\'ve already completed all $dailyGoal sessions for today!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  const Text(
                    'Take a rest and come back tomorrow for more! 😊',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Close button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF2A7DE1),
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _playCelebrationVibration() async {
    // Create a celebration vibration pattern
    for (int i = 0; i < 4; i++) {
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void _playAlarmVibration() async {
    // Create an alarm-like vibration pattern
    for (int i = 0; i < 3; i++) {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 200));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void _switchModeAndStart(bool isFocusMode) {
    // Get the timer service instance
    final timerService = PomodoroTimerService();
    
    // Switch to the requested mode
    timerService.setDisplayMode(isFocusMode);
    
    // Start the timer for that mode
    timerService.startTimer(isFocusMode);
    
    // Navigate to Pomodoro screen if not already there
    _navigateToPomodoroScreen();
  }

  void _navigateToPomodoroScreen() {
    if (navigatorKey.currentContext != null) {
      // Check if we're already on the Pomodoro screen by checking the current route
      final currentRoute = ModalRoute.of(navigatorKey.currentContext!);
      final isOnPomodoroScreen = currentRoute?.settings.name == 'PomodoroScreen' ||
          currentRoute?.settings.arguments is PomodoroScreen;
      
      if (!isOnPomodoroScreen) {
        // Navigate to Pomodoro screen
        Navigator.of(navigatorKey.currentContext!).push(
          MaterialPageRoute(builder: (context) => const PomodoroScreen()),
        );
      }
    }
  }
}

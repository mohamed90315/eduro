import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/timer_service.dart';

class PomodoroScreen extends StatefulWidget {
  const PomodoroScreen({super.key});

  @override
  State<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends State<PomodoroScreen> {
  late PomodoroTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = PomodoroTimerService();
    _timerService.addListener(_onTimerUpdate);
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerUpdate);
    super.dispose();
  }

  void _onTimerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (_timerService.hasAnyRunningTimer) {
          String runningMode = _timerService.focusIsRunning ? "Focus" : "Break";
          int remainingTime = _timerService.focusIsRunning 
            ? _timerService.focusRemainingSeconds 
            : _timerService.breakRemainingSeconds;
            
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$runningMode timer continues in background! (${_timerService.formatTime(remainingTime)} left)',
                    ),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            children: [
              const Text(
                'Pomodoro',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '⏱️',
                style: TextStyle(fontSize: 20),
              ),
              if (_timerService.hasAnyRunningTimer) ...[
                const SizedBox(width: 12),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.5),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Running',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // Focus/Break Mode Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Focus Button
                    Container(
                      decoration: _timerService.currentDisplayMode 
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.blueAccent, Colors.blue],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : null,
                      child: ElevatedButton(
                        onPressed: () => _timerService.setDisplayMode(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _timerService.currentDisplayMode ? Colors.transparent : Colors.white,
                          foregroundColor: _timerService.currentDisplayMode ? Colors.white : Colors.black,
                          shadowColor: _timerService.currentDisplayMode ? Colors.transparent : Colors.cyanAccent.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: _timerService.currentDisplayMode ? 0 : 3,
                        ),
                        child: Text(
                          'Focus (25min)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: _timerService.currentDisplayMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Break Button
                    Container(
                      decoration: !_timerService.currentDisplayMode 
                        ? BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.greenAccent, Colors.green],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.2),
                                blurRadius: 6,
                                spreadRadius: 1,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          )
                        : null,
                      child: ElevatedButton(
                        onPressed: () => _timerService.setDisplayMode(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: !_timerService.currentDisplayMode ? Colors.transparent : Colors.white,
                          foregroundColor: !_timerService.currentDisplayMode ? Colors.white : Colors.black,
                          shadowColor: !_timerService.currentDisplayMode ? Colors.transparent : Colors.cyanAccent.withOpacity(0.4),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: !_timerService.currentDisplayMode ? 0 : 3,
                        ),
                        child: Text(
                          'Break (5min)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: !_timerService.currentDisplayMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Other mode timer indicator - only show if opposite mode has any activity
                if ((_timerService.currentDisplayMode && 
                     (_timerService.breakRemainingSeconds < _timerService.breakTotalSeconds)) ||
                    (!_timerService.currentDisplayMode && 
                     (_timerService.focusRemainingSeconds < _timerService.focusTotalSeconds)))
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _timerService.currentDisplayMode 
                            ? 'Previous Break: ${_timerService.formatTime(_timerService.breakRemainingSeconds)}'
                            : 'Previous Focus: ${_timerService.formatTime(_timerService.focusRemainingSeconds)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 40),
                
                // Timer Circle
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Circular Timer
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withOpacity(0.3),
                                blurRadius: 12,
                                spreadRadius: 5,
                                offset: const Offset(0, 4),
                              ),
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.15),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.greenAccent.withOpacity(0.1),
                                blurRadius: 20,
                                spreadRadius: 1,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Background Circle
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: CustomPaint(
                                  painter: BackgroundCirclePainter(strokeWidth: 12),
                                ),
                              ),
                              // Progress Circle
                              SizedBox(
                                width: 240,
                                height: 240,
                                child: CustomPaint(
                                  painter: GradientCircularProgressPainter(
                                    progress: _timerService.currentProgress,
                                    strokeWidth: 12,
                                    gradient: const LinearGradient(
                                      colors: [Colors.blueAccent, Colors.greenAccent],
                                    ),
                                  ),
                                ),
                              ),
                              // Timer Content
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _timerService.currentDisplayMode ? 'Focus' : 'Break',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _timerService.formatTime(_timerService.currentRemainingSeconds),
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Control Buttons
                        _buildControlButtons(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    bool isCurrentModeRunning = _timerService.currentIsRunning;
    bool isCurrentModePaused = _timerService.currentIsPaused;
    bool currentDisplayMode = _timerService.currentDisplayMode;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Resume Button (when running or paused)
        if (isCurrentModeRunning)
          _buildGradientButton(
            onPressed: () => _timerService.pauseTimer(currentDisplayMode),
            text: 'Pause',
            gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.green]),
          ),
        
        if (isCurrentModePaused)
          _buildGradientButton(
            onPressed: () => _timerService.startTimer(currentDisplayMode),
            text: 'Resume',
            gradient: const LinearGradient(colors: [Colors.greenAccent, Colors.green]),
          ),
        
        // Start Button (when not running and not paused)
        if (!isCurrentModeRunning && !isCurrentModePaused)
          _buildGradientButton(
            onPressed: () => _timerService.startTimer(currentDisplayMode),
            text: 'Start',
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
          ),
        
        // Reset Button (when running or paused)
        if (isCurrentModeRunning || isCurrentModePaused) ...[
          const SizedBox(width: 16),
          _buildGradientButton(
            onPressed: () => _timerService.resetTimer(currentDisplayMode),
            text: 'Reset',
            gradient: const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
          ),
        ],
      ],
    );
  }

  Widget _buildGradientButton({
    required VoidCallback onPressed,
    required String text,
    required Gradient gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.15),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class GradientCircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Gradient gradient;

  GradientCircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (size.width / 2) - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    double sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class BackgroundCirclePainter extends CustomPainter {
  final double strokeWidth;

  BackgroundCirclePainter({required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    double radius = (size.width / 2) - strokeWidth / 2;
    Offset center = Offset(size.width / 2, size.height / 2);
    
    final gradient = LinearGradient(
      colors: [
        Colors.grey.withOpacity(0.1),
        Colors.grey.withOpacity(0.05),
        Colors.blue.withOpacity(0.05),
      ],
      stops: const [0.0, 0.5, 1.0],
    );
    
    Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
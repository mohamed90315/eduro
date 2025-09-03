import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/global_notification_service.dart';

enum GoalType {
  syllabusCoverage('Syllabus Coverage', 'chapters/lessons per week'),
  practiceProblems('Practice Problems', 'questions daily'),
  timeSpent('Time Spent', 'hours per day'),
  custom('Custom', 'custom unit');

  const GoalType(this.displayName, this.unit);
  final String displayName;
  final String unit;
}

enum CoursePriority {
  math('Math', '🧮'),
  science('Science', '🔬'),
  physics('Physics', '⚛️'),
  history('History', '📚'),
  english('English', '📝'),
  chemistry('Chemistry', '🧪'),
  biology('Biology', '🧬'),
  computerScience('Computer Science', '💻'),
  economics('Economics', '📊'),
  psychology('Psychology', '🧠'),
  custom('Custom', '✏️');

  const CoursePriority(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

class Goal {
  final GoalType type;
  final int target;
  final String course;
  final bool isActive;
  final String? customGoalTypeName;
  final String? customUnit;

  Goal({
    required this.type,
    required this.target,
    required this.course,
    this.isActive = true,
    this.customGoalTypeName,
    this.customUnit,
  });
  
  String get displayName {
    return type == GoalType.custom && customGoalTypeName != null 
        ? customGoalTypeName! 
        : type.displayName;
  }
  
  String get unit {
    return type == GoalType.custom && customUnit != null 
        ? customUnit! 
        : type.unit;
  }
  
  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'target': target,
      'course': course,
      'isActive': isActive,
      'customGoalTypeName': customGoalTypeName,
      'customUnit': customUnit,
    };
  }
  
  static Goal fromJson(Map<String, dynamic> json) {
    return Goal(
      type: GoalType.values[json['type'] ?? 0],
      target: json['target'] ?? 0,
      course: json['course'] ?? '',
      isActive: json['isActive'] ?? true,
      customGoalTypeName: json['customGoalTypeName'],
      customUnit: json['customUnit'],
    );
  }
}

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  // Core settings with defaults
  int _studySessionsPerDay = 3;
  int _daysPerWeek = 7;
  int _sessionDurationMinutes = 25;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 20, minute: 0);
  bool _breakReminders = true;
  int _breakDurationMinutes = 10;
  String _motivationalMessage = 'Stay focused and achieve your goals! 🎯';
  String _rewardMessage = 'Great job! Keep up the excellent work! 🌟';
  
  // Course goals
  List<Goal> _courseGoals = [];
  
  // Progress tracking
  int _todayCompleted = 0;
  int _weekCompleted = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;

  // Getters
  int get studySessionsPerDay => _studySessionsPerDay;
  int get daysPerWeek => _daysPerWeek;
  int get sessionDurationMinutes => _sessionDurationMinutes;
  TimeOfDay get notificationTime => _notificationTime;
  bool get breakReminders => _breakReminders;
  int get breakDurationMinutes => _breakDurationMinutes;
  String get motivationalMessage => _motivationalMessage;
  String get rewardMessage => _rewardMessage;
  List<Goal> get courseGoals => _courseGoals;
  int get todayCompleted => _todayCompleted;
  int get weekCompleted => _weekCompleted;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  
  // Dynamic weekly target calculation
  int get weeklyTarget => _studySessionsPerDay * _daysPerWeek;
  
  // Progress calculations
  double get dailyProgress => _studySessionsPerDay > 0 ? (_todayCompleted / _studySessionsPerDay).clamp(0.0, 1.0) : 0.0;
  double get weeklyProgress => weeklyTarget > 0 ? (_weekCompleted / weeklyTarget).clamp(0.0, 1.0) : 0.0;

  // Setters with persistence
  void setStudySessionsPerDay(int value) {
    _studySessionsPerDay = value;
    _updateProgressAfterGoalChange();
    _saveToPreferences();
  }

  void setDaysPerWeek(int value) {
    _daysPerWeek = value;
    _updateProgressAfterGoalChange();
    _saveToPreferences();
  }

  void setSessionDuration(int value) {
    _sessionDurationMinutes = value;
    _saveToPreferences();
  }

  void setNotificationTime(TimeOfDay value) {
    _notificationTime = value;
    _saveToPreferences();
  }

  void setBreakReminders(bool value) {
    _breakReminders = value;
    _saveToPreferences();
  }

  void setBreakDuration(int value) {
    _breakDurationMinutes = value;
    _saveToPreferences();
  }

  void setMotivationalMessage(String value) {
    _motivationalMessage = value;
    _saveToPreferences();
  }

  void setRewardMessage(String value) {
    _rewardMessage = value;
    _saveToPreferences();
  }

  // Persistence methods
  Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('studySessionsPerDay', _studySessionsPerDay);
    await prefs.setInt('daysPerWeek', _daysPerWeek);
    await prefs.setInt('sessionDurationMinutes', _sessionDurationMinutes);
    await prefs.setInt('notificationTimeHour', _notificationTime.hour);
    await prefs.setInt('notificationTimeMinute', _notificationTime.minute);
    await prefs.setBool('breakReminders', _breakReminders);
    await prefs.setInt('breakDurationMinutes', _breakDurationMinutes);
    await prefs.setString('motivationalMessage', _motivationalMessage);
    await prefs.setString('rewardMessage', _rewardMessage);
    await prefs.setInt('todayCompleted', _todayCompleted);
    await prefs.setInt('weekCompleted', _weekCompleted);
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('longestStreak', _longestStreak);
    
    // Save course goals
    final courseGoalsJson = _courseGoals.map((goal) => goal.toJson()).toList();
    await prefs.setString('courseGoals', jsonEncode(courseGoalsJson));
  }

  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _studySessionsPerDay = prefs.getInt('studySessionsPerDay') ?? 3;
    _daysPerWeek = prefs.getInt('daysPerWeek') ?? 7;
    _sessionDurationMinutes = prefs.getInt('sessionDurationMinutes') ?? 25;
    int hour = prefs.getInt('notificationTimeHour') ?? 20;
    int minute = prefs.getInt('notificationTimeMinute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    _breakReminders = prefs.getBool('breakReminders') ?? true;
    _breakDurationMinutes = prefs.getInt('breakDurationMinutes') ?? 10;
    _motivationalMessage = prefs.getString('motivationalMessage') ?? 'Stay focused and achieve your goals! 🎯';
    _rewardMessage = prefs.getString('rewardMessage') ?? 'Great job! Keep up the excellent work! 🌟';
    _todayCompleted = prefs.getInt('todayCompleted') ?? 0;
    _weekCompleted = prefs.getInt('weekCompleted') ?? 0;
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _longestStreak = prefs.getInt('longestStreak') ?? 0;
    
    // Load course goals
    final courseGoalsString = prefs.getString('courseGoals');
    if (courseGoalsString != null) {
      try {
        final courseGoalsJson = jsonDecode(courseGoalsString) as List;
        _courseGoals = courseGoalsJson.map((json) => Goal.fromJson(json)).toList();
      } catch (e) {
        // If parsing fails, clear the stored data and use defaults
        _courseGoals.clear();
      }
    }
    
    // Initialize hardcoded example course goals if none exist
    if (_courseGoals.isEmpty) {
      _courseGoals.addAll([
        Goal(
          type: GoalType.practiceProblems,
          target: 25,
          course: 'Math',
        ),
        Goal(
          type: GoalType.timeSpent,
          target: 3,
          course: 'Science',
        ),
        Goal(
          type: GoalType.syllabusCoverage,
          target: 5,
          course: 'History',
        ),
      ]);
      // Save the initial examples
      _saveToPreferences();
    }
  }

  // Course goal management
  void addCourseGoal(Goal goal) {
    _courseGoals.add(goal);
    _saveToPreferences();
  }

  void removeCourseGoal(int index) {
    if (index >= 0 && index < _courseGoals.length) {
      _courseGoals.removeAt(index);
      _saveToPreferences();
    }
  }

  void updateCourseGoal(int index, Goal goal) {
    if (index >= 0 && index < _courseGoals.length) {
      _courseGoals[index] = goal;
      _saveToPreferences();
    }
  }

  // Progress tracking
  Map<String, dynamic> completeSession() {
    // Check if goal is already completed
    if (_todayCompleted >= _studySessionsPerDay) {
      // Show message that goal is already completed
      GlobalNotificationService().showGoalAlreadyCompleteMessage();
      return {'canComplete': false, 'isFullyCompleted': true};
    }
    
    _todayCompleted++;
    _weekCompleted++;
    
    // Cap the progress at the maximum goal
    if (_todayCompleted > _studySessionsPerDay) {
      _todayCompleted = _studySessionsPerDay;
    }
    
    // Check if goal is just completed
    bool justCompleted = _todayCompleted >= _studySessionsPerDay;
    if (justCompleted) {
      _currentStreak++;
      if (_currentStreak > _longestStreak) {
        _longestStreak = _currentStreak;
      }
      
      // Show goal completion notification for 5/5
      GlobalNotificationService().showGoalCompletionDialog();
    }
    
    _saveToPreferences();
    return {
      'canComplete': true, 
      'isFullyCompleted': justCompleted,
      'currentProgress': _todayCompleted,
      'totalSessions': _studySessionsPerDay
    };
  }

  // Helper method to reset progress when goals change
  void _updateProgressAfterGoalChange() {
    // Ensure progress doesn't exceed new limits
    if (_todayCompleted > _studySessionsPerDay) {
      _todayCompleted = _studySessionsPerDay;
    }
    if (_weekCompleted > weeklyTarget) {
      _weekCompleted = weeklyTarget;
    }
  }

  void resetDaily() {
    _todayCompleted = 0;
    _saveToPreferences();
  }

  void resetWeekly() {
    _weekCompleted = 0;
    _saveToPreferences();
  }
}

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> with SingleTickerProviderStateMixin {
  final GoalsService _goalsService = GoalsService();
  final TextEditingController _sessionsController = TextEditingController();
  final TextEditingController _daysPerWeekController = TextEditingController();
  late TabController _tabController;

  // Local notification state
  String _notificationMessage = '';
  bool _showNotification = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAndInitialize();
  }

  Future<void> _loadAndInitialize() async {
    await _goalsService.loadFromPreferences();
    _initializeControllers();
    if (mounted) setState(() {});
  }

  void _initializeControllers() {
    _sessionsController.text = _goalsService.studySessionsPerDay.toString();
    _daysPerWeekController.text = _goalsService.daysPerWeek.toString();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _sessionsController.dispose();
    _daysPerWeekController.dispose();
    super.dispose();
  }

  void _showLocalNotification(String message) {
    setState(() {
      _notificationMessage = message;
      _showNotification = true;
    });

    // Auto-hide after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showNotification = false;
        });
      }
    });
  }

  Widget _buildLocalNotification() {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2A7DE1).withOpacity(0.95),
            const Color(0xFF2BD46E).withOpacity(0.95),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _notificationMessage,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                _showNotification = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              child: const Icon(
                Icons.close,
                color: Colors.white70,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _goalsService.notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF00838F), // Updated to requested color
              secondary: const Color(0xFF00838F), // Updated to requested color
              surface: Colors.white,
              onSurface: Colors.black87,
              onPrimary: Colors.white,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black87,
              hourMinuteColor: Colors.grey.shade100,
              dayPeriodTextColor: Colors.black87, // Text color for unselected state
              dayPeriodColor: const Color(0xFF00838F), // Background color when selected
              dayPeriodBorderSide: BorderSide.none, // Remove outline/border
              dialHandColor: const Color(0xFF00838F), // Clock arm color
              dialBackgroundColor: const Color(0xFFF0F8FF), // Light blue/white for clock background
              dialTextColor: Colors.black87,
              entryModeIconColor: const Color(0xFF00838F),
              helpTextStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F), // Bottom row buttons
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00838F), // Bottom row text buttons
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20)),
              ),
              titleTextStyle: TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _goalsService.setNotificationTime(picked);
      setState(() {});
    }
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
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
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.blue.withOpacity(0.2), Colors.green.withOpacity(0.2)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Goals Updated! 🎯',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your learning goals have been updated successfully!',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text(
                        'Great!',
                        style: TextStyle(
                          color: Colors.white,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            const Text(
              'Goals',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '🎯',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Streak: ${_goalsService.currentStreak}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF00838F),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Daily Goals'),
            Tab(text: 'Courses'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: Stack(
        children: [
          TabBarView(
            controller: _tabController,
            children: [
              _buildDailyGoalsTab(),
              _buildCoursesTab(),
              _buildProgressTab(),
            ],
          ),
          // Local notification overlay
          if (_showNotification)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                opacity: _showNotification ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: AnimatedSlide(
                  offset: _showNotification ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  child: _buildLocalNotification(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Overview
          _buildProgressOverview(),
          const SizedBox(height: 30),

          // Study Sessions Setting
          _buildSettingCard(
            icon: Icons.school,
            title: 'Study Sessions Per Day',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _sessionsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                    suffixText: 'sessions',
                  ),
                  onChanged: (value) {
                    int sessions = int.tryParse(value) ?? _goalsService.studySessionsPerDay;
                    _goalsService.setStudySessionsPerDay(sessions);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Weekly target: ${_goalsService.weeklyTarget} sessions',
                  style: const TextStyle(
                    color: Color(0xFF00838F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Days Per Week Setting
          _buildSettingCard(
            icon: Icons.calendar_view_week,
            title: 'Days Per Week',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _daysPerWeekController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                    ),
                    suffixText: 'days',
                  ),
                  onChanged: (value) {
                    int daysPerWeek = int.tryParse(value) ?? _goalsService.daysPerWeek;
                    _goalsService.setDaysPerWeek(daysPerWeek);
                    setState(() {});
                  },
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF2A7DE1).withOpacity(0.1),
                        const Color(0xFF2BD46E).withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2A7DE1).withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(Icons.calculate, color: Colors.white, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Weekly Target: ${_goalsService.weeklyTarget} sessions',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_goalsService.studySessionsPerDay} × ${_goalsService.daysPerWeek}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Session Duration
          _buildSettingCard(
            icon: Icons.timer,
            title: 'Session Duration',
            child: Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _goalsService.sessionDurationMinutes.toDouble(),
                    min: 15,
                    max: 120,
                    divisions: 21,
                    activeColor: const Color(0xFF00838F),
                    onChanged: (value) {
                      _goalsService.setSessionDuration(value.round());
                      setState(() {});
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${_goalsService.sessionDurationMinutes} min',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Notification Time
          _buildSettingCard(
            icon: Icons.notifications,
            title: 'Daily Notification Time',
            child: InkWell(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black54),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Color(0xFF00838F)),
                    const SizedBox(width: 12),
                    Text(
                      _goalsService.notificationTime.format(context),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.edit, color: Colors.black54, size: 20),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Break Reminders
          _buildSettingCard(
            icon: Icons.coffee,
            title: 'Break Reminders (Pomodoro)',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Break Reminders',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Transform.scale(
                      scale: 1.2,
                      child: Switch(
                        value: _goalsService.breakReminders,
                        onChanged: (value) {
                          _goalsService.setBreakReminders(value);
                          setState(() {});
                        },
                        activeColor: const Color(0xFF00838F),
                        inactiveThumbColor: Colors.grey.shade600,
                        inactiveTrackColor: Colors.grey.shade200,
                        trackOutlineColor: MaterialStateProperty.all(Colors.transparent),
                      ),
                    ),
                  ],
                ),
                if (_goalsService.breakReminders) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text('Break Duration: ', style: TextStyle(color: Colors.black87)),
                      Expanded(
                        child: Slider(
                          value: _goalsService.breakDurationMinutes.toDouble(),
                          min: 5,
                          max: 30,
                          divisions: 5,
                          activeColor: const Color(0xFF00838F),
                          onChanged: (value) {
                            _goalsService.setBreakDuration(value.round());
                            setState(() {});
                          },
                        ),
                      ),
                      Text(
                        '${_goalsService.breakDurationMinutes} min',
                        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Motivational Message (Read-only)
          _buildSettingCard(
            icon: Icons.psychology,
            title: 'Motivational Message',
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF2A7DE1).withOpacity(0.1),
                    const Color(0xFF2BD46E).withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF2A7DE1).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(Icons.format_quote, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _goalsService.motivationalMessage,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          

          // Save Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.heavyImpact();
                _showSaveSuccessDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Update Goals',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoursesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Priority Courses',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Set specific goals for each course',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),

          // Course Goals List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _goalsService.courseGoals.length,
            itemBuilder: (context, index) {
              final goal = _goalsService.courseGoals[index];
              return _buildCourseGoalCard(goal, index);
            },
          ),

          const SizedBox(height: 20),

          // Add New Course Goal Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: const Color(0xFF2A7DE1).withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _showAddCourseDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Add Course Goal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Stats Cards
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Current Streak',
                  '${_goalsService.currentStreak}',
                  Icons.local_fire_department,
                  Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Longest Streak',
                  '${_goalsService.longestStreak}',
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Today',
                  '${_goalsService.todayCompleted.clamp(0, _goalsService.studySessionsPerDay)}/${_goalsService.studySessionsPerDay}',
                  Icons.today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'This Week',
                  '${_goalsService.weekCompleted}/${_goalsService.weeklyTarget}',
                  Icons.calendar_view_week,
                  Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // Daily Progress
          _buildProgressCard(
            'Daily Progress',
            _goalsService.dailyProgress,
            '${_goalsService.todayCompleted.clamp(0, _goalsService.studySessionsPerDay)} of ${_goalsService.studySessionsPerDay} sessions completed',
            Icons.today,
          ),

          const SizedBox(height: 20),

          // Weekly Progress
          _buildProgressCard(
            'Weekly Progress',
            _goalsService.weeklyProgress,
            '${_goalsService.weekCompleted} of ${_goalsService.weeklyTarget} sessions completed',
            Icons.calendar_view_week,
          ),

          const SizedBox(height: 30),

          // Motivational Message Display
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Container(
              margin: const EdgeInsets.all(2),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF8FFFE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _goalsService.motivationalMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Complete Session Button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: _goalsService.todayCompleted >= _goalsService.studySessionsPerDay
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2BD46E)],
                    )
                  : const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                    ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: _goalsService.todayCompleted >= _goalsService.studySessionsPerDay
                      ? const Color(0xFF4CAF50).withOpacity(0.2)
                      : const Color(0xFF2A7DE1).withOpacity(0.2),
                  blurRadius: 12,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                final result = _goalsService.completeSession();
                setState(() {});
                HapticFeedback.heavyImpact();
                
                // Show local notification only for partial completion (not 5/5)
                if (result['canComplete'] && !result['isFullyCompleted']) {
                  _showLocalNotification(_goalsService.rewardMessage);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _goalsService.todayCompleted >= _goalsService.studySessionsPerDay
                        ? Icons.star
                        : Icons.check_circle,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _goalsService.todayCompleted >= _goalsService.studySessionsPerDay
                        ? 'Goal Completed! ⭐'
                        : 'Complete Session',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientProgressIndicator(double value) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: SizedBox(
          height: 12,
          child: Stack(
            children: [
              Container(color: Colors.white70),
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                builder: (context, animatedValue, _) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: animatedValue,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressOverview() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF2A7DE1).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Today\'s Progress',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${_goalsService.todayCompleted.clamp(0, _goalsService.studySessionsPerDay)}/${_goalsService.studySessionsPerDay}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGradientProgressIndicator(_goalsService.dailyProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCourseGoalCard(Goal goal, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: const Color(0xFF2A7DE1).withOpacity(0.1),
            blurRadius: 12,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(
                _getCourseIcon(goal.course),
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.course,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '${goal.target} ${goal.displayName}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _goalsService.removeCourseGoal(index);
                setState(() {});
              },
              icon: const Icon(Icons.delete_outline, color: Colors.red),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(String title, double progress, String description, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.all(2),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF8FFFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildGradientProgressIndicator(progress),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCourseDialog() {
    GoalType selectedType = GoalType.practiceProblems;
    String selectedCourse = 'Math';
    int targetValue = 20;
    bool isCustomGoalType = false;
    final TextEditingController customGoalTypeController = TextEditingController();
    final TextEditingController customUnitController = TextEditingController();

    Map<String, Map<GoalType, int>> predefinedExamples = {
      'Math': {
        GoalType.practiceProblems: 25,
        GoalType.timeSpent: 2,
        GoalType.syllabusCoverage: 3,
      },
      'Science': {
        GoalType.practiceProblems: 20,
        GoalType.timeSpent: 3,
        GoalType.syllabusCoverage: 2,
      },
      'Physics': {
        GoalType.practiceProblems: 15,
        GoalType.timeSpent: 2,
        GoalType.syllabusCoverage: 2,
      },
    };

    void updateTargetFromExample() {
      if (predefinedExamples.containsKey(selectedCourse)) {
        targetValue = predefinedExamples[selectedCourse]![selectedType] ?? 20;
      }
    }

    // Set initial target based on default selection
    updateTargetFromExample();

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: SingleChildScrollView(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Course Goal',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Course Selection
                    const Text(
                      'Course:', 
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.5),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedCourse,
                            dropdownColor: Colors.white,
                            elevation: 8,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            menuMaxHeight: 200,
                            borderRadius: BorderRadius.circular(12),
                            items: CoursePriority.values.where((course) => course != CoursePriority.custom).map((course) {
                              return DropdownMenuItem(
                                value: course.displayName,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  child: Row(
                                    children: [
                                      Text(
                                        course.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        course.displayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                            selectedItemBuilder: (context) {
                              return CoursePriority.values.where((course) => course != CoursePriority.custom).map((course) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12),
                                    child: Row(
                                      children: [
                                        Text(
                                          course.emoji,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          course.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList();
                            },
                            onChanged: (value) {
                              if (value != null) {
                                selectedCourse = value;
                                updateTargetFromExample();
                                setDialogState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Goal Type Selection
                    const Text(
                      'Goal Type:', 
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Goal Type Dropdown or Custom Input
                    if (!isCustomGoalType) ...[
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.5),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<GoalType>(
                              isExpanded: true,
                              value: selectedType,
                              dropdownColor: Colors.white,
                              elevation: 8,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                              menuMaxHeight: 200,
                              borderRadius: BorderRadius.circular(12),
                              items: GoalType.values.map((type) {
                                return DropdownMenuItem(
                                  value: type,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          type == GoalType.custom ? Icons.edit : _getGoalTypeIcon(type),
                                          size: 18,
                                          color: Colors.black87,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          type.displayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                              selectedItemBuilder: (context) {
                                return GoalType.values.map((type) {
                                  return Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Row(
                                        children: [
                                          Icon(
                                            type == GoalType.custom ? Icons.edit : _getGoalTypeIcon(type),
                                            size: 18,
                                            color: Colors.black87,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            type.displayName,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.black87,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList();
                              },
                              onChanged: (value) {
                                if (value != null) {
                                  if (value == GoalType.custom) {
                                    isCustomGoalType = true;
                                    customGoalTypeController.text = '';
                                    customUnitController.text = '';
                                  } else {
                                    selectedType = value;
                                    updateTargetFromExample();
                                  }
                                  setDialogState(() {});
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      // Custom Goal Type Input
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyanAccent.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(1.5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10.5),
                          ),
                          child: TextFormField(
                            controller: customGoalTypeController,
                            decoration: const InputDecoration(
                              hintText: 'Enter custom goal type (e.g., Essays Written, Books Read)',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      TextButton(
                        onPressed: () {
                          isCustomGoalType = false;
                          selectedType = GoalType.practiceProblems;
                          customGoalTypeController.clear();
                          customUnitController.clear();
                          setDialogState(() {});
                        },
                        child: const Text('← Back to predefined goal types'),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Target Value
                    const Text(
                      'Target:', 
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(1.5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.5),
                        ),
                        child: TextFormField(
                          key: ValueKey('${selectedCourse}_${selectedType.displayName}'),
                          initialValue: targetValue.toString(),
                          keyboardType: TextInputType.number,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                            hintText: 'Enter target value...',
                            hintStyle: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          onChanged: (value) {
                            targetValue = int.tryParse(value) ?? targetValue;
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Example note
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2A7DE1).withOpacity(0.1),
                            const Color(0xFF2BD46E).withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF2A7DE1).withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.lightbulb, color: Colors.white, size: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Suggested target: ${predefinedExamples[selectedCourse]?[selectedType] ?? 20} ${selectedType.unit}',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel', style: TextStyle(color: Colors.black54)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyanAccent.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                final newGoal = Goal(
                                  type: isCustomGoalType ? GoalType.custom : selectedType,
                                  target: targetValue,
                                  course: selectedCourse,
                                  customGoalTypeName: isCustomGoalType ? customGoalTypeController.text.trim() : null,
                                  customUnit: isCustomGoalType ? 'per day' : null,
                                );
                                _goalsService.addCourseGoal(newGoal);
                                setState(() {});
                                Navigator.of(context).pop();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Add Goal',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
          ),
        ),
      ),
    );
  }

  IconData _getCourseIcon(String course) {
    switch (course.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'science':
        return Icons.science;
      case 'physics':
        return Icons.scatter_plot;
      case 'chemistry':
        return Icons.biotech;
      case 'history':
        return Icons.history_edu;
      case 'english':
        return Icons.book;
      case 'biology':
        return Icons.nature;
      case 'computer science':
        return Icons.computer;
      default:
        return Icons.school;
    }
  }

  IconData _getGoalTypeIcon(GoalType type) {
    switch (type) {
      case GoalType.practiceProblems:
        return Icons.quiz;
      case GoalType.timeSpent:
        return Icons.schedule;
      case GoalType.syllabusCoverage:
        return Icons.book_outlined;
      case GoalType.custom:
        return Icons.edit;
    }
  }
}

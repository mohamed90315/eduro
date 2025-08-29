import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/global_notification_service.dart';

enum GoalType {
  syllabusCoverage('Syllabus Coverage', 'chapters/lessons per week'),
  practiceProblems('Practice Problems', 'questions daily'),
  timeSpent('Time Spent', 'hours per day'),
  custom('Custom', 'units per day');

  const GoalType(this.displayName, this.unit);
  final String displayName;
  final String unit;
}

enum CoursePriority {
  math('Mathematics', '📐'),
  science('Science', '🔬'),
  history('History', '📚'),
  english('English', '📝'),
  physics('Physics', '⚛️'),
  chemistry('Chemistry', '🧪');

  const CoursePriority(this.displayName, this.emoji);
  final String displayName;
  final String emoji;
}

class Goal {
  final GoalType type;
  final int target;
  final String course;
  final bool isActive;
  final String? customTypeName;

  Goal({
    required this.type,
    required this.target,
    required this.course,
    this.isActive = true,
    this.customTypeName,
  });
}

class GoalsService {
  static final GoalsService _instance = GoalsService._internal();
  factory GoalsService() => _instance;
  GoalsService._internal();

  // Daily Goals Settings
  int _studySessionsPerDay = 3;
  int _sessionDurationMinutes = 25;
  TimeOfDay _notificationTime = const TimeOfDay(hour: 9, minute: 0);
  bool _breakReminders = true;
  int _breakDurationMinutes = 5;
  
  // Weekly Goals - configurable
  int _daysPerWeek = 7; // User can modify this
  String _motivationalMessage = "Stay focused! You're building your future! 🚀";
  
  // Course Goals
  final List<Goal> _courseGoals = [
    Goal(type: GoalType.practiceProblems, target: 20, course: 'Mathematics'),
    Goal(type: GoalType.syllabusCoverage, target: 2, course: 'Science'),
    Goal(type: GoalType.timeSpent, target: 1, course: 'Physics'),
  ];
  
  // Reward System
  String _rewardMessage = "Great job! You've completed your daily goal! 🎉";
  int _currentStreak = 0;
  int _longestStreak = 0;
  
  // Progress tracking
  int _todayCompleted = 0;
  int _weekCompleted = 0;

  // Getters
  int get studySessionsPerDay => _studySessionsPerDay;
  int get sessionDurationMinutes => _sessionDurationMinutes;
  TimeOfDay get notificationTime => _notificationTime;
  bool get breakReminders => _breakReminders;
  int get breakDurationMinutes => _breakDurationMinutes;
  int get daysPerWeek => _daysPerWeek;
  int get weeklyTarget => _studySessionsPerDay * _daysPerWeek;
  String get motivationalMessage => _motivationalMessage;
  List<Goal> get courseGoals => _courseGoals;
  String get rewardMessage => _rewardMessage;
  int get currentStreak => _currentStreak;
  int get longestStreak => _longestStreak;
  int get todayCompleted => _todayCompleted.clamp(0, _studySessionsPerDay);
  int get weekCompleted => _weekCompleted.clamp(0, weeklyTarget);
  
  double get dailyProgress => (todayCompleted / _studySessionsPerDay).clamp(0.0, 1.0);
  double get weeklyProgress => (weekCompleted / weeklyTarget).clamp(0.0, 1.0);

  // Setters with persistence
  void setStudySessionsPerDay(int value) {
    _studySessionsPerDay = value;
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
  void setDaysPerWeek(int value) {
    _daysPerWeek = value;
    _updateProgressAfterGoalChange();
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
    await prefs.setInt('sessionDurationMinutes', _sessionDurationMinutes);
    await prefs.setInt('notificationTimeHour', _notificationTime.hour);
    await prefs.setInt('notificationTimeMinute', _notificationTime.minute);
    await prefs.setBool('breakReminders', _breakReminders);
    await prefs.setInt('breakDurationMinutes', _breakDurationMinutes);
    await prefs.setInt('daysPerWeek', _daysPerWeek);
    await prefs.setString('motivationalMessage', _motivationalMessage);
    await prefs.setString('rewardMessage', _rewardMessage);
    await prefs.setInt('todayCompleted', _todayCompleted);
    await prefs.setInt('weekCompleted', _weekCompleted);
    await prefs.setInt('currentStreak', _currentStreak);
    await prefs.setInt('longestStreak', _longestStreak);
  }
  
  Future<void> loadFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _studySessionsPerDay = prefs.getInt('studySessionsPerDay') ?? 3;
    _sessionDurationMinutes = prefs.getInt('sessionDurationMinutes') ?? 25;
    int hour = prefs.getInt('notificationTimeHour') ?? 20;
    int minute = prefs.getInt('notificationTimeMinute') ?? 0;
    _notificationTime = TimeOfDay(hour: hour, minute: minute);
    _breakReminders = prefs.getBool('breakReminders') ?? true;
    _breakDurationMinutes = prefs.getInt('breakDurationMinutes') ?? 10;
    _daysPerWeek = prefs.getInt('daysPerWeek') ?? 7;
    _motivationalMessage = prefs.getString('motivationalMessage') ?? 'Stay focused and achieve your goals!';
    _rewardMessage = prefs.getString('rewardMessage') ?? 'Great job! Keep up the excellent work!';
    _todayCompleted = prefs.getInt('todayCompleted') ?? 0;
    _weekCompleted = prefs.getInt('weekCompleted') ?? 0;
    _currentStreak = prefs.getInt('currentStreak') ?? 0;
    _longestStreak = prefs.getInt('longestStreak') ?? 0;
  }
  
  void addCourseGoal(Goal goal) {
    _courseGoals.add(goal);
  }
  
  void removeCourseGoal(int index) {
    if (index >= 0 && index < _courseGoals.length) {
      _courseGoals.removeAt(index);
    }
  }
  
  void updateCourseGoal(int index, Goal goal) {
    if (index >= 0 && index < _courseGoals.length) {
      _courseGoals[index] = goal;
    }
  }
  
  void completeSession() {
    bool wasAlreadyComplete = _todayCompleted >= _studySessionsPerDay;
    
    if (!wasAlreadyComplete) {
      _todayCompleted++;
      _weekCompleted++;
      
      // Check if daily goal is now complete
      if (_todayCompleted >= _studySessionsPerDay) {
        _currentStreak++;
        if (_currentStreak > _longestStreak) {
          _longestStreak = _currentStreak;
        }
        
        // Show completion notification
        _showDailyGoalCompletedNotification();
      }
    } else {
      // User already completed daily goal - show message
      _showAlreadyCompletedNotification();
    }
    
    // Save progress
    _saveToPreferences();
  }
  
  void _showDailyGoalCompletedNotification() {
    // Import the global notification service
    final notificationService = GlobalNotificationService();
    notificationService.showDailyGoalCompletedDialog(_currentStreak);
  }
  
  void _showAlreadyCompletedNotification() {
    final notificationService = GlobalNotificationService();
    notificationService.showAlreadyCompletedDialog(_studySessionsPerDay);
  }
  
  // Helper method to reset progress when daily goal changes
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
  }
  
  void resetWeekly() {
    _weekCompleted = 0;
  }
}

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  final GoalsService _goalsService = GoalsService();
  final TextEditingController _sessionsController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();
  final TextEditingController _rewardController = TextEditingController();
  final TextEditingController _daysPerWeekController = TextEditingController();
  late TabController _tabController;
  
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
    _motivationController.text = _goalsService.motivationalMessage;
    _rewardController.text = _goalsService.rewardMessage;
    _daysPerWeekController.text = _goalsService.daysPerWeek.toString();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _sessionsController.dispose();
    _motivationController.dispose();
    _rewardController.dispose();
    _daysPerWeekController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _goalsService.notificationTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF2A7DE1),
              secondary: const Color(0xFF2BD46E),
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
              background: Colors.white,
              onBackground: Colors.black87,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteTextColor: Colors.black87,
              hourMinuteColor: Colors.grey.shade100,
              dayPeriodTextColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white; // Selected AM/PM text color
                }
                return Colors.black87; // Unselected AM/PM text color
              }),
              dayPeriodColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const Color(0xFF00838F); // Selected AM/PM background color
                }
                return Colors.grey.shade100; // Unselected AM/PM background color
              }),
              dialHandColor: const Color(0xFF00838F),
              dialBackgroundColor: Colors.grey.shade50,
              dialTextColor: Colors.black87,
              entryModeIconColor: const Color(0xFF00838F),
              helpTextStyle: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              elevation: 8,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF00838F),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
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

  void _saveGoals() {
    // Update motivation and reward messages from controllers
    _goalsService.setMotivationalMessage(_motivationController.text);
    _goalsService.setRewardMessage(_rewardController.text);
    
    // Play haptic feedback
    HapticFeedback.heavyImpact();
    
    // Show success message
    _showSaveSuccessDialog();
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
                    'Goals Saved! 🎯',
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
          indicatorColor: Color(0xFF00838F),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Daily Goals'),
            Tab(text: 'Courses'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyGoalsTab(),
          _buildCoursesTab(),
          _buildProgressTab(),
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
                  style: TextStyle(
                    color: const Color(0xFF00838F),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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
                    Icon(Icons.access_time, color: const Color(0xFF00838F)),
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
            title: 'Break Reminders (Pomodoro Style)',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Enable Break Reminders',
                      style: TextStyle(color: Colors.black87),
                    ),
                    Switch(
                      value: _goalsService.breakReminders,
                      onChanged: (value) {
                        _goalsService.setBreakReminders(value);
                        setState(() {});
                      },
                      activeColor: const Color(0xFF00838F),
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
          
          // Weekly Target
          _buildSettingCard(
            icon: Icons.calendar_view_week,
            title: 'Weekly Goals Configuration',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Days per week
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Days per week:',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8),
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
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onChanged: (value) {
                              int daysPerWeek = int.tryParse(value) ?? _goalsService.daysPerWeek;
                              _goalsService.setDaysPerWeek(daysPerWeek);
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Auto-calculation display
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
                  child: Column(
                    children: [
                      Row(
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
                            _calculateDisplayTarget(),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _getCalculationDisplay(),
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCalculationDescription(),
                        style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 11,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Motivation Message
          _buildSettingCard(
            icon: Icons.psychology,
            title: 'Motivational Message',
            child: TextField(
              controller: _motivationController,
              maxLines: 2,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                hintText: 'Enter your motivational message...',
                hintStyle: TextStyle(color: Colors.black54),
              ),
              onChanged: (value) {
                _goalsService.setMotivationalMessage(value);
              },
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Reward Message
          _buildSettingCard(
            icon: Icons.emoji_events,
            title: 'Reward Message',
            child: TextField(
              controller: _rewardController,
              maxLines: 2,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyanAccent),
                ),
                hintText: 'Enter your reward message...',
                hintStyle: TextStyle(color: Colors.black54),
              ),
              onChanged: (value) {
                _goalsService.setRewardMessage(value);
              },
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Save Button
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
              onPressed: _saveGoals,
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
                    'Save Goals',
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
                  '${_goalsService.todayCompleted}/${_goalsService.studySessionsPerDay}',
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
            '${_goalsService.todayCompleted} of ${_goalsService.studySessionsPerDay} sessions completed',
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
          
          // Motivational Message
          Container(
            width: double.infinity,
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
              onPressed: () {
                _goalsService.completeSession();
                setState(() {});
                HapticFeedback.heavyImpact();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_goalsService.rewardMessage),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                  ),
                );
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
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Complete Session',
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
                  '${_goalsService.todayCompleted}/${_goalsService.studySessionsPerDay}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Progress bar styled
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.6), width: 1.2),
                boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 12,
                  child: Stack(children: [
                    Container(color: Colors.white70),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: _goalsService.dailyProgress.clamp(0.0, 1.0)),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)]),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ),
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
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
                  '${goal.target} ${goal.type == GoalType.custom && goal.customTypeName != null ? goal.customTypeName : goal.type.unit}',
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
        color: Colors.white,
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
            // Progress bar styled with gradient
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blueGrey.withOpacity(0.6), width: 1.2),
                boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.18), blurRadius: 6, offset: const Offset(0, 2))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  height: 12,
                  child: Stack(children: [
                    Container(color: Colors.white70),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOut,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)]),
                            ),
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ),
            ),
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

  String _calculateDisplayTarget() {
    final weeklyTarget = _goalsService.weeklyTarget;
    return '$weeklyTarget sessions';
  }

  String _getCalculationDisplay() {
    final dailySessions = _goalsService.studySessionsPerDay;
    final daysPerWeek = _goalsService.daysPerWeek;
    return '$dailySessions × $daysPerWeek';
  }

  String _getCalculationDescription() {
    return 'Auto-calculated from daily sessions × days per week';
  }

  void _showAddCourseDialog() {
    GoalType selectedType = GoalType.practiceProblems;
    String selectedCourse = 'Mathematics';
    int targetValue = 20;
    String customTypeName = '';
    
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => BackdropFilter(
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
                          items: CoursePriority.values.map((subject) {
                            return DropdownMenuItem(
                              value: subject.displayName,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                child: Row(
                                  children: [
                                    Text(
                                      subject.emoji,
                                      style: const TextStyle(fontSize: 18),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      subject.displayName,
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
                            return CoursePriority.values.map((subject) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Row(
                                    children: [
                                      Text(
                                        subject.emoji,
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        subject.displayName,
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
                                child: Text(
                                  type.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
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
                                  child: Text(
                                    type.displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }).toList();
                          },
                          onChanged: (value) {
                            if (value != null) {
                              selectedType = value;
                              setDialogState(() {});
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  
                  // Custom Goal Type Name (only show if Custom is selected)
                  if (selectedType == GoalType.custom) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Custom Goal Type Name:', 
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
                          initialValue: customTypeName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText: 'e.g., "Exercises", "Chapters"...',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                          ),
                          onChanged: (value) {
                            customTypeName = value;
                          },
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 16),
                  
                  // Target Value
                  Text(
                    'Target (${selectedType == GoalType.custom && customTypeName.isNotEmpty ? customTypeName : selectedType.unit}):', 
                    style: const TextStyle(
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
                        initialValue: targetValue.toString(),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        onChanged: (value) {
                          targetValue = int.tryParse(value) ?? 20;
                        },
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.black54,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text('Cancel'),
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
                                type: selectedType,
                                target: targetValue,
                                course: selectedCourse,
                                customTypeName: selectedType == GoalType.custom ? customTypeName : null,
                              );
                              _goalsService.addCourseGoal(newGoal);
                              setState(() {});
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
                              'Add Goal',
                              style: TextStyle(
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
        ),
      ),
    );
  }

  IconData _getCourseIcon(String course) {
    switch (course.toLowerCase()) {
      case 'mathematics':
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
      default:
        return Icons.school;
    }
  }
}

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Data Models
class OverallProgress {
  final int completed;
  final int inProgress;
  final int locked;

  OverallProgress({
    required this.completed,
    required this.inProgress,
    required this.locked,
  });

  factory OverallProgress.fromJson(Map<String, dynamic> json) {
    return OverallProgress(
      completed: json['completed'],
      inProgress: json['inProgress'],
      locked: json['locked'],
    );
  }
}

class Achievement {
  final int id;
  final String icon;
  final String title;
  final String subtitle;
  final double progress;
  final bool isCompleted;
  final String target;

  Achievement({
    required this.id,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.progress,
    required this.isCompleted,
    required this.target,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      icon: json['icon'],
      title: json['title'],
      subtitle: json['subtitle'],
      progress: json['progress'].toDouble(),
      isCompleted: json['isCompleted'],
      target: json['target'],
    );
  }
}

class AchievementCategory {
  final String title;
  final List<Achievement> achievements;

  AchievementCategory({required this.title, required this.achievements});

  factory AchievementCategory.fromJson(Map<String, dynamic> json) {
    return AchievementCategory(
      title: json['title'],
      achievements: (json['achievements'] as List)
          .map((achievement) => Achievement.fromJson(achievement))
          .toList(),
    );
  }
}

class AchievementData {
  final OverallProgress overallProgress;
  final List<AchievementCategory> categories;

  AchievementData({required this.overallProgress, required this.categories});

  factory AchievementData.fromJson(Map<String, dynamic> json) {
    return AchievementData(
      overallProgress: OverallProgress.fromJson(json['overallProgress']),
      categories: (json['categories'] as List)
          .map((category) => AchievementCategory.fromJson(category))
          .toList(),
    );
  }
}

// API Service
class AchievementService {
  static const String _baseUrl = 'https://mock-api.net/api/app2';

  static Future<AchievementData> fetchAchievements() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/achievements'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AchievementData.fromJson(data);
      } else {
        throw Exception('Failed to load achievements: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching achievements: $e');
    }
  }
}

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  AchievementData? _achievementData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final data = await AchievementService.fetchAchievements();

      setState(() {
        _achievementData = data;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildWhiteCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildAchievementCategory(AchievementCategory category) {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...category.achievements.map(
            (achievement) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildAchievementItem(achievement),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'access_time':
        return Icons.access_time;
      case 'schedule':
        return Icons.schedule;
      case 'timer':
        return Icons.timer;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'whatshot':
        return Icons.whatshot;
      case 'emoji_events':
        return Icons.emoji_events;
      case 'menu_book':
        return Icons.menu_book;
      case 'school':
        return Icons.school;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }

  Widget _buildAchievementItem(Achievement achievement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: achievement.isCompleted
            ? Colors.cyan.withOpacity(0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: achievement.isCompleted
              ? Colors.cyan.withOpacity(0.3)
              : Colors.grey.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: achievement.isCompleted
                        ? [Colors.cyan, Colors.blue]
                        : [Colors.grey[400]!, Colors.grey[500]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  _getIconFromString(achievement.icon),
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            achievement.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (achievement.isCompleted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Completed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      achievement.target,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    '${(achievement.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: achievement.isCompleted
                          ? Colors.cyan
                          : Colors.grey[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: achievement.progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: achievement.isCompleted
                            ? [Colors.cyan, Colors.blue]
                            : [Colors.grey[400]!, Colors.grey[500]!],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Achievements 🏆',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_error != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadAchievements,
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan),
            ),
            SizedBox(height: 16),
            Text(
              'Loading achievements...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Failed to load achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadAchievements,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_achievementData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Overall Progress Card
              _buildWhiteCard(
                child: Column(
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildProgressStat(
                          label: 'Completed',
                          value: _achievementData!.overallProgress.completed
                              .toString(),
                          icon: Icons.emoji_events,
                          color: Colors.green,
                        ),
                        _buildProgressStat(
                          label: 'In Progress',
                          value: _achievementData!.overallProgress.inProgress
                              .toString(),
                          icon: Icons.access_time,
                          color: Colors.orange,
                        ),
                        _buildProgressStat(
                          label: 'Locked',
                          value: _achievementData!.overallProgress.locked
                              .toString(),
                          icon: Icons.lock_outline,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Achievement Categories
              ..._achievementData!.categories.map(
                (category) => _buildAchievementCategory(category),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

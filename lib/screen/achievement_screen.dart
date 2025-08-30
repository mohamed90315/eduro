import 'package:flutter/material.dart';

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

    _animationController.forward();
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

  Widget _buildAchievementCategory({
    required String title,
    required List<Map<String, dynamic>> achievements,
  }) {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          ...achievements.map(
            (achievement) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: _buildAchievementItem(
                icon: achievement['icon'],
                title: achievement['title'],
                subtitle: achievement['subtitle'],
                progress: achievement['progress'],
                isCompleted: achievement['isCompleted'],
                target: achievement['target'],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double progress,
    required bool isCompleted,
    required String target,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.cyan.withOpacity(0.05) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
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
                    colors: isCompleted
                        ? [Colors.cyan, Colors.blue]
                        : [Colors.grey[400]!, Colors.grey[500]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
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
                            title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (isCompleted)
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
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      target,
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
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isCompleted ? Colors.cyan : Colors.grey[700],
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
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isCompleted
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
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FadeTransition(
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
                            value: '12',
                            icon: Icons.emoji_events,
                            color: Colors.green,
                          ),
                          _buildProgressStat(
                            label: 'In Progress',
                            value: '5',
                            icon: Icons.access_time,
                            color: Colors.orange,
                          ),
                          _buildProgressStat(
                            label: 'Locked',
                            value: '8',
                            icon: Icons.lock_outline,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Study Achievements
                _buildAchievementCategory(
                  title: 'Study Hours',
                  achievements: [
                    {
                      'icon': Icons.access_time,
                      'title': 'First Study Session',
                      'subtitle': 'Complete your first study session',
                      'progress': 1.0,
                      'isCompleted': true,
                      'target': 'Target: 1 hour',
                    },
                    {
                      'icon': Icons.schedule,
                      'title': 'Study Marathon',
                      'subtitle': 'Study for 10 hours total',
                      'progress': 0.7,
                      'isCompleted': false,
                      'target': 'Target: 10 hours (7/10)',
                    },
                    {
                      'icon': Icons.timer,
                      'title': 'Century Club',
                      'subtitle': 'Reach 100 hours of study time',
                      'progress': 0.24,
                      'isCompleted': false,
                      'target': 'Target: 100 hours (24/100)',
                    },
                  ],
                ),

                // Streak Achievements
                _buildAchievementCategory(
                  title: 'Study Streaks',
                  achievements: [
                    {
                      'icon': Icons.local_fire_department,
                      'title': 'Getting Started',
                      'subtitle': 'Maintain a 3-day study streak',
                      'progress': 1.0,
                      'isCompleted': true,
                      'target': 'Target: 3 days',
                    },
                    {
                      'icon': Icons.whatshot,
                      'title': 'Week Warrior',
                      'subtitle': 'Maintain a 7-day study streak',
                      'progress': 1.0,
                      'isCompleted': true,
                      'target': 'Target: 7 days',
                    },
                    {
                      'icon': Icons.emoji_events,
                      'title': 'Streak Master',
                      'subtitle': 'Maintain a 30-day study streak',
                      'progress': 0.23,
                      'isCompleted': false,
                      'target': 'Target: 30 days (7/30)',
                    },
                  ],
                ),

                // Course Achievements
                _buildAchievementCategory(
                  title: 'Course Completion',
                  achievements: [
                    {
                      'icon': Icons.menu_book,
                      'title': 'First Course',
                      'subtitle': 'Complete your first course',
                      'progress': 1.0,
                      'isCompleted': true,
                      'target': 'Target: 1 course',
                    },
                    {
                      'icon': Icons.school,
                      'title': 'Knowledge Seeker',
                      'subtitle': 'Complete 5 different courses',
                      'progress': 0.6,
                      'isCompleted': false,
                      'target': 'Target: 5 courses (3/5)',
                    },
                    {
                      'icon': Icons.auto_awesome,
                      'title': 'Course Master',
                      'subtitle': 'Complete 10 different courses',
                      'progress': 0.3,
                      'isCompleted': false,
                      'target': 'Target: 10 courses (3/10)',
                    },
                  ],
                ),
              ],
            ),
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

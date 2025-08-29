import 'package:flutter/material.dart';
import 'Pomodoro.dart';
import 'flashcard.dart';
import 'goals.dart';
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0; // Home tab is selected (index 0)

  void _onNavTapped(int index) {
    // Don't navigate if already on the same tab
    if (index == _selectedIndex) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Handle navigation based on index
    switch (index) {
      case 0: // Home
        // Already on dashboard screen
        break;
      case 1: // Course
        // Navigate to course screen (placeholder for now)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Course feature coming soon!'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
        // Reset to current tab since we're not navigating
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 2: // Cards
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FlashcardScreen()),
        );
        break;
      case 3: // Quiz
        // Navigate to quiz screen (placeholder for now)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quiz feature coming soon!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        // Reset to current tab since we're not navigating
        setState(() {
          _selectedIndex = 0;
        });
        break;
      case 4: // Profile
        // Navigate to profile screen (placeholder for now)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile feature coming soon!'),
            backgroundColor: Colors.purple,
            duration: Duration(seconds: 2),
          ),
        );
        // Reset to current tab since we're not navigating
        setState(() {
          _selectedIndex = 0;
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Welcome back ',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                "Let's make progress today.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 30),

              // Weekly Goal Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Weekly Goal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              '8 study sessions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.track_changes_outlined,
                            size: 24,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Progress Bar
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: 0.62,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '62% completed • 3 days left',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Grid Items
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.2,
                  children: [
                    _buildGridItem(
                      icon: Icons.map_outlined,
                      title: 'Roadmap',
                      subtitle: 'Plan subjects and topics',
                      onTap: () {},
                    ),
                    _buildGridItem(
                      icon: Icons.edit_outlined,
                      title: 'Notes',
                      subtitle: 'Write and summarize',
                      onTap: () {},
                    ),
                    _buildGridItem(
                      icon: Icons.style_outlined,
                      title: 'Flashcards',
                      subtitle: 'Practice with SRS',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FlashcardScreen(),
                          ),
                        );
                      },
                    ),
                    _buildGridItem(
                      icon: Icons.quiz_outlined,
                      title: 'Quiz',
                      subtitle: 'MCQ / T/F / Short',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Streak Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Streak',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Row(
                          children: [
                            Text(
                              '5 days ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text('🔥', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Keep it going for a badge',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.emoji_events_outlined,
                        size: 24,
                        color: Colors.amber,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Bottom Grid
              Row(
                children: [
                  Expanded(
                    child: _buildBottomGridItem(
                      icon: Icons.flag_outlined,
                      title: 'Goals',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GoalsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBottomGridItem(
                      icon: Icons.timer_outlined,
                      title: 'Pomodoro',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PomodoroScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: _buildBottomGridItem(
                      icon: Icons.import_export_outlined,
                      title: 'Import/Export',
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildBottomGridItem(
                      icon: Icons.leaderboard_outlined,
                      title: 'Leaderboard',
                      onTap: () {},
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // View Progress Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'View Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white,
        indicatorColor: Colors.cyan.withOpacity(0.2),
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onNavTapped,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home, color: Colors.black), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.menu_book, color: Colors.black), label: 'Course'),
          NavigationDestination(icon: Icon(Icons.layers, color: Colors.black), label: 'Cards'),
          NavigationDestination(icon: Icon(Icons.quiz, color: Colors.black), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.person, color: Colors.black), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildGridItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 24,
              color: Colors.black87,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomGridItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
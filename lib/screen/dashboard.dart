import 'package:eduro/screen/import_export_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import the Pages
import 'todo_list_page.dart';
import 'leaderboard.dart';
import 'pomodoro.dart';
// import 'todo2.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    DashboardHome(),
    PlaceholderPage(title: 'Course'),
    PlaceholderPage(title: 'Cards'),
    PlaceholderPage(title: 'Quiz'),
    PlaceholderPage(title: 'Profile'),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
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
}

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    // dynamic progress value (example)
    final double progress = 0.62; // 62%
    final int totalDays = 7;
    final int daysPassed = (totalDays * progress).floor();
    final int daysLeft = totalDays - daysPassed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // Removed "Dashboard" title and logout icon
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome text
            Text(
              'Welcome back 👋',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: Colors.black),
            ),
            const SizedBox(height: 4),
            Text(
              "Let's make progress today.",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.black87),
            ),
            const SizedBox(height: 16),

            // Weekly goal card
            Card(
              elevation: 4,
              shadowColor: Colors.cyanAccent.withOpacity(0.6),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Weekly Goal',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        )),
                    const SizedBox(height: 8),
                    const Text('8 study sessions',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 8),

                    // Gradient progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Stack(
                        children: [
                          Container(
                            height: 12,
                            color: Colors.black12,
                          ),
                          Container(
                            height: 12,
                            width: MediaQuery.of(context).size.width * progress - 64,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.blue, Colors.green],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),
                    Text(
                      "${(progress * 100).toStringAsFixed(0)}% completed • $daysLeft days left",
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Grid buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDashboardButton(context, Icons.route, 'Roadmap'),
                _buildDashboardButton(context, Icons.notes, 'Notes'),
                _buildDashboardButton(context, Icons.layers, 'Flashcards'),
                _buildDashboardButton(context, Icons.quiz, 'Quiz'),
              ],
            ),
            const SizedBox(height: 16),

            // Streak card
            Card(
              elevation: 4,
              shadowColor: Colors.cyanAccent.withOpacity(0.6),
              color: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: const [
                    Icon(Icons.local_fire_department, color: Colors.black, size: 32),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('5 days 🔥',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          SizedBox(height: 4),
                          Text('Keep it going for a badge',
                              style: TextStyle(color: Colors.black87)),
                        ],
                      ),
                    ),
                    Text("🏆", style: TextStyle(fontSize: 28)), // Gold cup emoji
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // More buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildDashboardButton(context, Icons.flag, 'Goals'),
                _buildDashboardButton(context, Icons.timer, 'Pomodoro',page: const PomodoroScreen()),
                _buildDashboardButton(
                  context,
                  Icons.checklist, // Changed icon
                  'To-Do List',
                  page: const TodoPage(),
                ),
                _buildDashboardButton(
                    context,
                    Icons.leaderboard,
                    'Leaderboard',
                    page: const LeaderboardPage()),
              ],
            ),
            const SizedBox(height: 20),

            // View Progress Button
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.cyanAccent, Colors.greenAccent],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 1,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                          const PlaceholderPage(title: 'View Progress')),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('View Progress',
                        style: TextStyle(color: Colors.black, fontSize: 16)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, IconData icon, String title,
      {Widget? page}) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => page ?? PlaceholderPage(title: title),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 3,
        shadowColor: Colors.cyanAccent.withOpacity(0.4),
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: Colors.black),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black)),
        ],
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(title, style: const TextStyle(color: Colors.black))),
      body: Center(
        child: Text('This is the $title page',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.black)),
      ),
    );
  }
}

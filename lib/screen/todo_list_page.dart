import 'package:flutter/material.dart';
// import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

/// Root App
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "🔥 To-Do App",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const TodoPage(),
    );
  }
}

/// Main To-Do Page
class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<Map<String, dynamic>> _weeklyTasks = [
    {"title": "Finish Flutter project", "done": false},
    {"title": "Review AI notes", "done": true},
    {"title": "Read robotics paper", "done": false},
    {"title": "Work on CV", "done": false},
    {"title": "Plan weekend trip 🗺️", "done": false},
    {"title": "Organize GitHub repos 💻", "done": true},
    {"title": "Team meeting preparation 📝", "done": false},
    {"title": "Research YOLO object detection 🖼️", "done": false},
    {"title": "Buy groceries 🛒", "done": false},
    {"title": "Call parents 📞", "done": true},
  ];

  List<Map<String, dynamic>> _dailyTasks = [
    {"title": "Workout 30 min 🏋️", "done": false},
    {"title": "Morning meditation 🧘", "done": false},
    {"title": "Check emails 📧", "done": false},
    {"title": "Read 1 chapter of book 📚", "done": false},
    {"title": "Practice coding problems 💻", "done": false},
    {"title": "Drink 2L water 💧", "done": false},
    {"title": "Evening walk 🚶", "done": false},
  ];

  String _viewMode = "Daily"; // "Daily" or "Weekly"
  String _previousViewMode = "Weekly";
  bool _showCompleted = true;
  bool _isFirstLoad = true;

  List<Map<String, dynamic>> get _currentTasks =>
      _viewMode == "Weekly" ? _weeklyTasks : _dailyTasks;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('weeklyTasks', jsonEncode(_weeklyTasks));
    prefs.setString('dailyTasks', jsonEncode(_dailyTasks));
    prefs.setString('showCompleted', jsonEncode(_showCompleted));
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final weekly = prefs.getString('weeklyTasks');
    final daily = prefs.getString('dailyTasks');
    final show = prefs.getString("showCompleted");

    if (weekly != null) {
      setState(() {
        _weeklyTasks =
        List<Map<String, dynamic>>.from(jsonDecode(weekly));
      });
    }
    if (daily != null) {
      setState(() {
        _dailyTasks =
        List<Map<String, dynamic>>.from(jsonDecode(daily));
      });
    }
    if (show != null) {
      setState(() {
        _showCompleted = jsonDecode(show);
      });
      _isFirstLoad = false;
    }
  }

  Future<void> _onToggle(Map<String, dynamic> task) async {
    if (task["__animating"] == true) return; // prevent double taps

    setState(() => task["__animating"] = true);

    await Future.delayed(const Duration(milliseconds: 280));

    setState(() {
      task["done"] = !(task["done"] ?? false);
      task.remove("__animating");
      _reorderTasks();
    });
    _saveData();
  }

  void _reorderTasks() {
    final pending = _currentTasks.where((t) => !(t["done"] ?? false)).toList();
    final done = _currentTasks.where((t) => t["done"] ?? false).toList();
    _currentTasks
      ..clear()
      ..addAll(pending)
      ..addAll(done);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _currentTasks.where((t) => t["done"] == true).length;
    final progress =
    _currentTasks.isEmpty ? 0.0 : completed / _currentTasks.length;

    final currentKey = ValueKey(_viewMode);
    final modeChanged = _previousViewMode != _viewMode;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "🔥 To-Do List",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Toggle buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _previousViewMode = _viewMode;
                        _viewMode = "Daily";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _viewMode == "Daily"
                            ? const Color(0xFF2BD46E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.18),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Daily",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _viewMode == "Daily"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _previousViewMode = _viewMode;
                        _viewMode = "Weekly";
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: _viewMode == "Weekly"
                            ? const Color(0xFF2A7DE1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.18),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          "Weekly",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _viewMode == "Weekly"
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress header
            Text(
              "$_viewMode Progress",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),

            // Progress bar
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.blueGrey.withOpacity(0.6),
                  width: 1.2,
                ),
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
                child: Container(
                  height: 12,
                  child: Stack(
                    children: [
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
            ),

            const SizedBox(height: 16),

            // Show/Hide Completed
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(
                    _showCompleted ? Icons.visibility_off : Icons.visibility,
                    color: Colors.black87,
                  ),
                  label: Text(
                    _showCompleted ? "Hide Completed" : "Show All",
                    style: const TextStyle(color: Colors.black87),
                  ),
                  onPressed: () {
                    setState(() {
                      _showCompleted = !_showCompleted;
                    });
                    _saveData();
                  },
                ),
              ],
            ),

            // Task list
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final vx = details.primaryVelocity ?? 0.0;
                  if (vx < -200) {
                    setState(() {
                      _previousViewMode = _viewMode;
                      _viewMode = "Weekly";
                    });
                  } else if (vx > 200) {
                    setState(() {
                      _previousViewMode = _viewMode;
                      _viewMode = "Daily";
                    });
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 420),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final isIncoming = child.key == currentKey;
                    String keyStr = '';
                    final k = child.key;
                    if (k is ValueKey) keyStr = k.value.toString();
                    final childIsDaily = keyStr.startsWith('Daily');
                    final enterOffset =
                    childIsDaily ? const Offset(-1, 0) : const Offset(1, 0);
                    final exitOffset =
                    childIsDaily ? const Offset(-1, 0) : const Offset(1, 0);

                    if (!modeChanged) return child;

                    if (isIncoming) {
                      final slideIn = animation.drive(
                        Tween<Offset>(begin: enterOffset, end: Offset.zero)
                            .chain(CurveTween(curve: Curves.easeInOut)),
                      );
                      return SlideTransition(
                        position: slideIn,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    } else {
                      final reversed = ReverseAnimation(animation);
                      final slideOut = reversed.drive(
                        Tween<Offset>(begin: Offset.zero, end: exitOffset)
                            .chain(CurveTween(curve: Curves.easeInOut)),
                      );
                      return SlideTransition(
                        position: slideOut,
                        child: FadeTransition(opacity: reversed, child: child),
                      );
                    }
                  },
                  child: AnimatedListWrapper(
                    key: ValueKey(_viewMode),
                    tasks: _currentTasks,
                    showCompleted: _showCompleted,
                    onToggle: (task) => _onToggle(task),
                    skipAnimation: _isFirstLoad,
                    onLongPress: (index, task) =>
                        _showEditDeleteDialog(index, task),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Add CTA
            GestureDetector(
              onTap: _showAddTaskDialog,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.18),
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "➕  Add New Task",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Add $_viewMode Task",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            hintText: "Enter task",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              shadowColor: Colors.cyanAccent.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _currentTasks.add(
                    {"title": controller.text.trim(), "done": false},
                  );
                  _reorderTasks();
                });
                _saveData();
                Navigator.pop(context);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showEditDeleteDialog(int index, Map<String, dynamic> task) {
    final controller = TextEditingController(text: task["title"]);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          "Edit $_viewMode Task",
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black87),
          decoration: const InputDecoration(
            hintText: "Update task",
            hintStyle: TextStyle(color: Colors.black54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _currentTasks.removeAt(index);
              });
              _saveData();
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.black87)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 3,
              shadowColor: Colors.cyanAccent.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _currentTasks[index]["title"] = controller.text.trim();
                });
                _saveData();
                Navigator.pop(context);
              }
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for visibility animation
class _VisibilitySwitcher extends StatelessWidget {
  final bool visible;
  final Widget child;
  final Duration duration;
  final bool skipAnimation;

  const _VisibilitySwitcher({
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
    this.skipAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    if (skipAnimation) {
      return visible ? child : const SizedBox.shrink();
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (w, anim) {
        return SizeTransition(
          sizeFactor: anim,
          axisAlignment: -1.0,
          child: FadeTransition(opacity: anim, child: w),
        );
      },
      child: visible
          ? KeyedSubtree(key: const ValueKey('shown'), child: child)
          : const SizedBox(key: ValueKey('hidden'), height: 0),
    );
  }
}

/// Task list builder
class AnimatedListWrapper extends StatelessWidget {
  final List<Map<String, dynamic>> tasks;
  final bool showCompleted;
  final bool skipAnimation;
  final Function(Map<String, dynamic>) onToggle;
  final Function(int, Map<String, dynamic>) onLongPress;

  const AnimatedListWrapper({
    super.key,
    required this.tasks,
    required this.showCompleted,
    required this.onToggle,
    required this.onLongPress,
    this.skipAnimation = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        itemCount: tasks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final isDone = task["done"] ?? false;
          final isAnimating = task["__animating"] ?? false;

          final tile = AnimatedOpacity(
              duration: const Duration(milliseconds: 280),
              opacity: isAnimating ? 0.0 : 1.0,
              child: AnimatedSize(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                  child: GestureDetector(
                      key: ValueKey(task["title"] + index.toString()),
                      onTap: () => onToggle(task),
                      onLongPress: () => onLongPress(index, task),
                      child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyanAccent.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: isDone,
                            activeColor: Colors.blue,
                            onChanged: (val) => onToggle(task),
                          ),
                          Expanded(
                            child: Text(
                              task["title"],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: isDone ? Colors.black54 : Colors.black87,
                                decoration: isDone
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ),
          ),
          );

          final visible = showCompleted || !isDone;

          return _VisibilitySwitcher(visible: visible, child: tile,skipAnimation: skipAnimation,);
        },
    );
  }
}

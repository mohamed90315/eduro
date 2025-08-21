import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

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
  final List<Map<String, dynamic>> _weeklyTasks = [
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

  final List<Map<String, dynamic>> _dailyTasks = [
    {"title": "Workout 30 min 🏋️", "done": false},
    {"title": "Morning meditation 🧘", "done": false},
    {"title": "Check emails 📧", "done": false},
    {"title": "Read 1 chapter of book 📚", "done": false},
    {"title": "Practice coding problems 💻", "done": false},
    {"title": "Drink 2L water 💧", "done": false},
    {"title": "Evening walk 🚶", "done": false},
  ];

  String _viewMode = "Weekly"; // "Daily" or "Weekly"
  String _previousViewMode = "Weekly";
  bool _showCompleted = true;

  List<Map<String, dynamic>> get _currentTasks =>
      _viewMode == "Weekly" ? _weeklyTasks : _dailyTasks;

  Future<void> _onToggle(Map<String, dynamic> task) async {
    if (task["__animating"] == true) return; // prevent double taps

    setState(() => task["__animating"] = true);

    await Future.delayed(const Duration(milliseconds: 280));

    setState(() {
      task["done"] = !(task["done"] ?? false);
      task.remove("__animating");
      _reorderTasks();
    });
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
                            color: Colors.cyanAccent.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
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
                            color: Colors.cyanAccent.withOpacity(0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
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
                    color: Colors.cyanAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
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
                      color: Colors.cyanAccent.withOpacity(0.45),
                      blurRadius: 16,
                      spreadRadius: 1,
                      offset: const Offset(0, 6),
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
              shadowColor: Colors.cyanAccent.withOpacity(0.4),
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
              shadowColor: Colors.cyanAccent.withOpacity(0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _currentTasks[index]["title"] = controller.text.trim();
                });
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

  const _VisibilitySwitcher({
    required this.visible,
    required this.child,
    this.duration = const Duration(milliseconds: 260),
  });

  @override
  Widget build(BuildContext context) {
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
  final Function(Map<String, dynamic>) onToggle;
  final Function(int, Map<String, dynamic>) onLongPress;

  const AnimatedListWrapper({
    super.key,
    required this.tasks,
    required this.showCompleted,
    required this.onToggle,
    required this.onLongPress,
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
                      color: Colors.cyanAccent.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
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

        return _VisibilitySwitcher(visible: visible, child: tile);
      },
    );
  }
}

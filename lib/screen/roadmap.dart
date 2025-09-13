import 'dart:math' as math;
import 'package:flutter/material.dart';

enum TaskCategory { exam, study, assignment, project, other }
enum RoadmapView { monthly, weekly }

class RoadmapPage extends StatefulWidget {
  const RoadmapPage({super.key});

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  // --- Layout constants (do not change)
  static const double _monthWidth = 140;
  static const double _laneHeight = 64;
  static const double _barHeight = 22;
  static const double _gridTopPadding = 8;
  static const double _gridSidePadding = 12;
  static const Radius _barRadius = Radius.circular(999);

  RoadmapView _currentView = RoadmapView.monthly;

  final _months = const [
    'JAN 2025',
    'FEB 2025',
    'MAR 2025',
    'APR 2025',
    'MAY 2025',
    'JUN 2025',
    'JUL 2025',
  ];

  // Study roadmap tasks (monthly)
  // ------------------------
// Inside _RoadmapPageState
// ------------------------

// Updated monthly tasks
  // Monthly tasks
  final _tasks = <RoadmapTask>[
    RoadmapTask("Math Revision – Algebra", lane: 0, start: 0.0, duration: 1.0, category: TaskCategory.study, subject: "Math", requirements: "Study chapters 1-3", dueDate: "15 March 2025",),
    RoadmapTask("Physics Lab Prep", lane: 0, start: 1.2, duration: 0.8, category: TaskCategory.assignment, subject: "Physics", requirements: "Complete lab assignment 2", dueDate: "18 March 2025",),
    RoadmapTask("Midterm Exams", lane: 1, start: 2.0, duration: 1.0, category: TaskCategory.exam, subject: "General", requirements: "Prepare for all subjects", dueDate: "20 March 2025"),
    RoadmapTask("Research Paper Writing", lane: 1, start: 3.2, duration: 2.0, category: TaskCategory.project, subject: "English", requirements: "Write full draft", dueDate: "30 March 2025"),
    RoadmapTask("Group Study Sessions", lane: 2, start: 1.8, duration: 1.2, category: TaskCategory.study, subject: "Math", requirements: "Review problem sets", dueDate: "22 March 2025"),
    RoadmapTask("AI Course Assignments", lane: 2, start: 4.5, duration: 1.0, category: TaskCategory.assignment, subject: "Computer Science", requirements: "Complete assignment 1", dueDate: "5 April 2025"),
    RoadmapTask("Final Project Presentation", lane: 3, start: 6.0, duration: 0.8, category: TaskCategory.exam, subject: "Computer Science", requirements: "Prepare slides and demo", dueDate: "15 April 2025"),
    RoadmapTask("English Essay Draft", lane: 3, start: 5.0, duration: 1.0, category: TaskCategory.assignment, subject: "English", requirements: "Draft essay on topic X", dueDate: "12 April 2025"),
    RoadmapTask("Chemistry Lab Report", lane: 4, start: 2.5, duration: 1.5, category: TaskCategory.assignment, subject: "Chemistry", requirements: "Submit lab report 3", dueDate: "25 March 2025"),
    RoadmapTask("Extra Credit Project", lane: 4, start: 5.0, duration: 1.5, category: TaskCategory.project, subject: "History", requirements: "Complete extra credit assignment", dueDate: "10 April 2025"),
    RoadmapTask("History Reading", lane: 5, start: 0.5, duration: 1.0, category: TaskCategory.study, subject: "History", requirements: "Read chapters 1-2", dueDate: "16 March 2025"),
    RoadmapTask("Computer Science Hackathon", lane: 5, start: 3.5, duration: 2.0, category: TaskCategory.project, subject: "Computer Science", requirements: "Participate in hackathon", dueDate: "28 March 2025"),
  ];

// Weekly tasks
  final _weeklyTasks = <RoadmapTask>[
    RoadmapTask("Math Revision – Algebra", lane: 0, start: 0.0, duration: 1.0, category: TaskCategory.study, subject: "Math", requirements: "Study chapters 1-3", dueDate: "15 March 2025"),
    RoadmapTask("Physics Lab Prep", lane: 0, start: 1.0, duration: 1.0, category: TaskCategory.assignment, subject: "Physics", requirements: "Complete lab assignment 2", dueDate: "18 March 2025"),
    RoadmapTask("Midweek Quiz", lane: 1, start: 2.0, duration: 1.0, category: TaskCategory.exam, subject: "General", requirements: "Prepare for quiz", dueDate: "19 March 2025"),
    RoadmapTask("Research Outline", lane: 1, start: 3.0, duration: 1.5, category: TaskCategory.project, subject: "English", requirements: "Prepare research outline", dueDate: "25 March 2025"),
    RoadmapTask("Group Study", lane: 2, start: 4.0, duration: 1.0, category: TaskCategory.study, subject: "Math", requirements: "Solve problems together", dueDate: "21 March 2025"),
    RoadmapTask("Project Review", lane: 2, start: 5.0, duration: 1.0, category: TaskCategory.assignment, subject: "Computer Science", requirements: "Review project progress", dueDate: "23 March 2025"),
    RoadmapTask("English Essay Draft", lane: 3, start: 1.0, duration: 1.0, category: TaskCategory.assignment, subject: "English", requirements: "Draft essay on topic X", dueDate: "12 April 2025"),
    RoadmapTask("Chemistry Lab Report", lane: 3, start: 3.0, duration: 1.5, category: TaskCategory.assignment, subject: "Chemistry", requirements: "Submit lab report 3", dueDate: "25 March 2025"),
    RoadmapTask("History Reading", lane: 4, start: 0.5, duration: 1.0, category: TaskCategory.study, subject: "History", requirements: "Read chapters 1-2", dueDate: "16 March 2025"),
    RoadmapTask("CS Mini Hackathon", lane: 5, start: 4.0, duration: 2.0, category: TaskCategory.project, subject: "Computer Science", requirements: "Participate in mini hackathon", dueDate: "28 March 2025"),
  ];

  // controllers
  late final ScrollController _gridH = ScrollController();
  late final ScrollController _headerH = ScrollController();
  bool _syncing = false;

  double get _totalWidth =>
      (_currentView == RoadmapView.monthly
          ? _months.length
          : _weekdaysWithDates.length) *
          _monthWidth +
          _gridSidePadding * 2;

  int get _lanes {
    final tasks = _currentView == RoadmapView.monthly ? _tasks : _weeklyTasks;
    return (tasks.map((t) => t.lane).fold<int>(0, (m, v) => math.max(m, v)) + 1);
  }

  List<RoadmapTask> get _activeTasks =>
      _currentView == RoadmapView.monthly ? _tasks : _weeklyTasks;

  List<String> get _activeLabels =>
      _currentView == RoadmapView.monthly ? _months : _weekdaysWithDates;

  // toggle button state
  List<bool> _selectedToggle = [true, false]; // Monthly selected by default
  bool _isWeeklyView = false;

  // === Generate current week (Sun → Sat with dates) ===
  List<String> get _weekdaysWithDates {
    final now = DateTime.now();
    // start from Sunday
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    const weekdayNames = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];
    return List.generate(7, (i) {
      final day = startOfWeek.add(Duration(days: i));
      return "${weekdayNames[i]} ${day.day}";
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _gridH.addListener(_syncHeaderToGrid);
      _headerH.addListener(_syncGridToHeader);
    });
  }

  @override
  void dispose() {
    // safe removal (no-op if not attached)
    try {
      _gridH.removeListener(_syncHeaderToGrid);
    } catch (_) {}
    try {
      _headerH.removeListener(_syncGridToHeader);
    } catch (_) {}
    _gridH.dispose();
    _headerH.dispose();
    super.dispose();
  }

  void _syncHeaderToGrid() {
    if (_syncing) return;
    if (!_gridH.hasClients || !_headerH.hasClients) return;
    _syncing = true;
    try {
      _headerH.jumpTo(_gridH.offset);
    } catch (_) {}
    // CRITICAL: rebuild so scrub bar reads new offset
    if (mounted) setState(() {});
    _syncing = false;
  }

  void _syncGridToHeader() {
    if (_syncing) return;
    if (!_gridH.hasClients || !_headerH.hasClients) return;
    _syncing = true;
    try {
      _gridH.jumpTo(_headerH.offset);
    } catch (_) {}
    // rebuild to update scrub bar too
    if (mounted) setState(() {});
    _syncing = false;
  }

  void _scrollByUnits(int units) {
    final delta = units * _monthWidth;
    final viewW = MediaQuery.of(context).size.width;
    final maxOff = (_totalWidth - viewW).clamp(0.0, double.infinity);
    final current = _gridH.hasClients ? _gridH.offset : 0.0;
    final target = (current + delta).clamp(0.0, maxOff);
    if (_gridH.hasClients) {
      try {
        _gridH.animateTo(target,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      } catch (_) {}
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_gridH.hasClients) {
          try {
            _gridH.animateTo(target,
                duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
          } catch (_) {}
        }
      });
    }
  }

  void _jumpToFraction(double leftFrac) {
    final viewW = MediaQuery.of(context).size.width;
    final maxOff = (_totalWidth - viewW).clamp(0.0, double.infinity);
    final newOff = (leftFrac * (_totalWidth - viewW)).clamp(0.0, maxOff);

    if (_gridH.hasClients) {
      try {
        // animate so the movement is smooth and grid listener fires
        _gridH.animateTo(newOff,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      } catch (_) {}
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_gridH.hasClients) {
          try {
            _gridH.animateTo(newOff,
                duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
          } catch (_) {}
        }
      });
    }
  }

  late List<double> _laneHeights; // dynamic lane heights per lane

  void _computeLaneHeights() {
    final tasks = _activeTasks;
    _laneHeights = List.filled(_lanes, _laneHeight); // default

    final textStyle = const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
    );

    final tp = TextPainter(
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    for (final task in tasks) {
      tp.text = TextSpan(text: task.title, style: textStyle);
      tp.layout(maxWidth: task.duration * _monthWidth - 16); // horizontal padding
      final neededHeight = tp.height + 8; // vertical padding
      if (neededHeight > _laneHeights[task.lane]) {
        _laneHeights[task.lane] = neededHeight;
      }
    }
  }

  void _showTaskDialog(BuildContext context, RoadmapTask t) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                t.title,
                style: TextStyle(
                  decoration: t.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
              content: const Text("Details about the task..."),
              actionsPadding: const EdgeInsets.only(right: 12, bottom: 8), // ✅ push to bottom-right
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: const Text("Close"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        t.completed ? Colors.grey[300] : const Color(0xFF00838F),
                        foregroundColor: Colors.black,
                      ),
                      icon: Icon(
                        t.completed ? Icons.refresh : Icons.check_circle,
                      ),
                      label: Text(
                        t.completed ? "Mark as Ongoing" : "Mark as Done",
                      ),
                      onPressed: () {
                        setDialogState(() {
                          t.completed = !t.completed;
                        });
                        setState(() {}); // refresh roadmap
                      },
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    _computeLaneHeights();
    final viewW = MediaQuery.of(context).size.width;
    final maxOffset = (_totalWidth - viewW).clamp(0.0, double.infinity);
    final gridOffset = _gridH.hasClients ? _gridH.offset : 0.0;
    final leftFrac = maxOffset == 0 ? 0.0 : (gridOffset / maxOffset);
    final visibleFrac =
    (_totalWidth == 0) ? 1.0 : (viewW / _totalWidth).clamp(0.05, 1.0);
    final completedCount = _tasks.where((t) => t.completed).length;
    final ongoingCount = _tasks.length - completedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(left: 1), // <-- adjust this value
          child: Text('Roadmap  🗓️'),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 16, 15, 10),
            child: ToggleButtons(
              isSelected: _selectedToggle,
              onPressed: (index) {
                setState(() {
                  for (int i = 0; i < _selectedToggle.length; i++) {
                    _selectedToggle[i] = i == index;
                  }
                  _currentView =
                  index == 0 ? RoadmapView.monthly : RoadmapView.weekly;
                });
              },
              borderRadius: BorderRadius.circular(8),
              borderWidth: 0,
              renderBorder: false,
              selectedColor: Colors.white,
              color: Colors.black,
              fillColor: const Color(0xFF00838F),
              constraints: const BoxConstraints(
                minHeight: 32,
                minWidth: 80,
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    "Monthly",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    "Weekly",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // === Top Navigator
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.chevron_left,
                  onTap: () => _scrollByUnits(-1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ScrubBar(
                    leftFraction: leftFrac,
                    visibleFraction: visibleFrac,
                    onDragToFraction: _jumpToFraction,
                  ),
                ),
                const SizedBox(width: 10),
                _CircleIconButton(
                  icon: Icons.chevron_right,
                  onTap: () => _scrollByUnits(1),
                ),
              ],
            ),
          ),

          // === Header (months or weekdays+dates)
          SizedBox(
            height: 40,
            child: SingleChildScrollView(
              controller: _headerH,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: CustomPaint(
                size: Size(_totalWidth, 40),
                painter: _MonthsHeaderPainter(
                  months: _activeLabels,
                  monthWidth: _monthWidth,
                  sidePadding: _gridSidePadding,
                ),
              ),
            ),
          ),

          Divider(height: 1, thickness: 1, color: Colors.grey.shade300),

          // === Grid + tasks
          Expanded(
            child: SingleChildScrollView(
              controller: _gridH,
              scrollDirection: Axis.horizontal,
              physics: const ClampingScrollPhysics(),
              child: SizedBox(
                width: _totalWidth,
                child: Stack(
                  children: [
                    CustomPaint(
                      size: Size(
                          _totalWidth,
                          _laneHeights.fold(0.0, (a, b) => a + b) +
                              _gridTopPadding),
                      painter: _GridPainter(
                        months: _activeLabels.length,
                        monthWidth: _monthWidth,
                        laneHeights: _laneHeights,
                        topPadding: _gridTopPadding,
                        sidePadding: _gridSidePadding,
                        barHeight: _barHeight,
                      ),
                    ),
                    for (final task in _activeTasks) _buildTask(context, task),
                  ],
                ),
              ),
            ),
          ),

          // === Key Table at the Bottom
          // === Key Table at the Bottom
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 18),
                    const SizedBox(width: 4),
                    Text("Completed: $completedCount"),
                  ],
                ),
                const SizedBox(width: 20),
                Row(
                  children: [
                    const Icon(Icons.remove_circle, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text("Ongoing: $ongoingCount"),
                  ],
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  double _computeLaneTop(int lane) {
    double top = _gridTopPadding;
    for (int i = 0; i < lane; i++) {
      top += _laneHeights[i];
    }
    return top;
  }

  Widget _buildTask(BuildContext context, RoadmapTask t) {
    final left = _gridSidePadding + t.start * _monthWidth;
    final width = math.max(8.0, t.duration * _monthWidth);
    final laneTop = _computeLaneTop(t.lane);
    final top = laneTop + (_laneHeights[t.lane] - _barHeight) / 2;

    Color barColor;
    switch (t.category) {
      case TaskCategory.exam:
        barColor = Colors.redAccent;
        break;
      case TaskCategory.study:
        barColor = Colors.blueAccent;
        break;
      case TaskCategory.assignment:
        barColor = Colors.green;
        break;
      case TaskCategory.project:
        barColor = Colors.purple;
        break;
      default:
        barColor = Colors.grey;
    }

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: StatefulBuilder( // allows toggling inside dialog
                builder: (context, setDialogState) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Colors.blue],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 10),
                        )
                      ],
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(3),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.book, size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(t.subject, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  t.requirements,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today,
                                  size: 18, color: Colors.black54),
                              const SizedBox(width: 6),
                              Text(t.dueDate, style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                          const SizedBox(height: 36),

                          // ✅ Toggle Button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: t.completed ? Colors.grey[300] : Color(0xFF00838F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                icon: Icon(
                                  t.completed ? Icons.refresh : Icons.check_circle,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  t.completed ? "Mark as Ongoing" : "Mark as Done",
                                ),
                                onPressed: () {
                                  t.completed = !t.completed;
                                  setDialogState(() {}); // refresh this dialog
                                  setState(() {});       // refresh roadmap bars (optional but useful)
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      elevation: 3,
                                      shadowColor: Colors.cyanAccent.withOpacity(
                                          0.6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () async {
                                      Navigator.pop(context);
                                    },
                                    // icon: const Icon(Icons.cancel),
                                    label: const Text("Close"),
                                  ),
                              ),
                              // TextButton(
                              //   onPressed: () => Navigator.of(context).pop(),
                              //   style: TextButton.styleFrom(
                              //     foregroundColor: Colors.black,
                              //   ),
                              //   child: const Text("Close"),
                              // ),

                            ],
                          ),
                          //
                          // const SizedBox(height: 8),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () => Navigator.of(context).pop(),
                          //     child: const Text("Close"),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );

        },

        child: Container(
          constraints: BoxConstraints(minWidth: width, maxWidth: width),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: t.completed ? barColor.withValues(alpha: 0.1) : barColor, // dim if completed
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    // decoration: t.completed
                    //     ? TextDecoration.lineThrough   // <-- strikethrough
                    //     : TextDecoration.none,
                    // decorationThickness: 2, // makes it bolder
                  ),
                  textAlign: TextAlign.center,
                  softWrap: true,
                ),
              ),
              if (t.completed) ...[
                const SizedBox(width: 6),
                const Icon(Icons.check_circle, size: 14, color: Colors.white),
              ],
            ],
          ),
        ),
      ),
    );
  }


}
// ===================
// RoadmapTask model
// ===================
class RoadmapTask {
  final String title;
  final int lane;
  final double start;
  final double duration;
  final TaskCategory category;
  final String subject;
  final String requirements;
  final String dueDate;
  bool completed;

  RoadmapTask(
      this.title, {
        required this.lane,
        required this.start,
        required this.duration,
        this.category = TaskCategory.other,
        this.subject = "General",
        this.requirements = "",
        this.dueDate = "",
        this.completed = false, // <-- default false
      });
}


// ===================================================================
// Painters & UI bits
// ===================================================================

class _GridPainter extends CustomPainter {
  final int months;
  final double monthWidth;
  final List<double> laneHeights; // dynamic lane heights
  final double topPadding;
  final double sidePadding;
  final double barHeight; // <-- add this

  _GridPainter({
    required this.months,
    required this.laneHeights,
    required this.topPadding,
    required this.sidePadding,
    required this.barHeight, // <-- add this
    double? monthWidth,
  }) : monthWidth = monthWidth ?? 140;

  @override
  void paint(Canvas canvas, Size size) {
    final baselinePaint = Paint()
      ..color = const Color(0xFFDBDEE5)
      ..strokeWidth = 1;

    double laneTop = topPadding;

    for (int i = 0; i < laneHeights.length; i++) {
      // Compute the vertical center of the bar inside this lane
      final lineY = laneTop + laneHeights[i] / 2;

      canvas.drawLine(
        Offset(sidePadding, lineY),
        Offset(size.width - sidePadding, lineY),
        baselinePaint,
      );

      // move to next lane
      laneTop += laneHeights[i];
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter old) =>
      old.months != months ||
          old.laneHeights != laneHeights ||
          old.topPadding != topPadding ||
          old.sidePadding != sidePadding ||
          old.barHeight != barHeight; // <-- include barHeight
}

class _MonthsHeaderPainter extends CustomPainter {
  final List<String> months;
  final double monthWidth;
  final double sidePadding;

  _MonthsHeaderPainter({
    required this.months,
    required this.monthWidth,
    required this.sidePadding,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final textStyle = const TextStyle(
      fontSize: 12.5,
      fontWeight: FontWeight.w700,
      color: Color(0xFF222733),
      letterSpacing: 0.3,
    );
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final linePaint = Paint()
      ..color = Colors.grey.shade400
      ..strokeWidth = 1;

    for (int i = 0; i < months.length; i++) {
      final left = sidePadding + i * monthWidth;
      final center = left + monthWidth / 2;

      // Draw text
      textPainter.text = TextSpan(text: months[i], style: textStyle);
      textPainter.layout(maxWidth: monthWidth);
      textPainter.paint(
        canvas,
        Offset(center - textPainter.width / 2, 10),
      );

      // Draw vertical separator line (skip last label)
      if (i < months.length - 1) {
        final lineX = left + monthWidth;
        canvas.drawLine(
          Offset(lineX, 8),
          Offset(lineX, size.height - 12),
          linePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MonthsHeaderPainter old) =>
      old.months != months ||
          old.monthWidth != monthWidth ||
          old.sidePadding != sidePadding;
}


class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.grey.shade200,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20),
        ),
      ),
    );
  }
}

class _ScrubBar extends StatefulWidget {
  final double leftFraction;
  final double visibleFraction;
  final ValueChanged<double> onDragToFraction;

  const _ScrubBar({
    required this.leftFraction,
    required this.visibleFraction,
    required this.onDragToFraction,
    super.key,
  });

  @override
  State<_ScrubBar> createState() => _ScrubBarState();
}

class _ScrubBarState extends State<_ScrubBar> {
  double? _dragStartX;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final trackR = BorderRadius.circular(8);
        final trackW = c.maxWidth;
        final h = 14.0;

        final handleW = math.max(28.0, widget.visibleFraction * trackW);
        final leftPx = (widget.leftFraction * (trackW - handleW)).clamp(0.0, trackW - handleW);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => _dragStartX = d.localPosition.dx - leftPx,
          onHorizontalDragUpdate: (d) {
            final desiredLeft = (d.localPosition.dx - (_dragStartX ?? 0));
            final frac = (desiredLeft / (trackW - handleW)).clamp(0.0, 1.0);
            widget.onDragToFraction(frac);
          },
          onHorizontalDragEnd: (_) => _dragStartX = null,
          child: Container(
            height: 16, // thinner scrollbar
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Stack(
              children: [
                // Track
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    height: h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: trackR,
                    ),
                  ),
                ),
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeOut,
                  left: leftPx,
                  width: handleW,
                  top: (22 - h) / 2,
                  bottom: (22 - h) / 2,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.blue, Colors.green],
                      ),
                      borderRadius: BorderRadius.circular(h / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 2,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'dart:convert';
import 'dart:math';
import 'dart:ui'; // For blur effect
import 'package:eduro/screen/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For haptics
import 'package:http/http.dart' as http;

const String mockApiUrl = "https://mock-api.net/api/jassermedhat/questions";

// Modified InfoCard for consistent height
// Modified InfoCard for responsive design
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.cyanAccent.withOpacity(0.2),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withOpacity(0.1),
                    color.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add this widget for the course name header
class _CourseNameCard extends StatelessWidget {
  final String courseName;

  const _CourseNameCard({required this.courseName});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.quiz,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Flutter Development Assessment',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 📋 Reusable quiz detail card
class _QuizDetailsCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _QuizDetailsCard({
    required this.title,
    required this.value,
    required this.icon,
    this.color = Colors.blueAccent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(fontSize: 14, color: Colors.black54)),
            ],
          ),
        ],
      ),
    );
  }
}

/// Modified Quiz Intro Card
class _QuizIntroCard extends StatelessWidget {
  final int questionCount;
  final int totalTime;
  final bool isGraded;

  const _QuizIntroCard({
    required this.questionCount,
    required this.totalTime,
    required this.isGraded,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = totalTime ~/ 60;
    final seconds = totalTime % 60;
    final timePerQuestion = totalTime ~/ questionCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            // Gradient icon without box
            ShaderMask(
              shaderCallback: (Rect bounds) {
                return const LinearGradient(
                  colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                ).createShader(bounds);
              },
              child: const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Quiz Instructions:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          _buildBullet("Each question has $timePerQuestion seconds to answer"),
          _buildBullet(
              "Total quiz time is ${minutes > 0 ? '$minutes minute${minutes > 1 ? 's' : ''} ' : ''}${seconds > 0 ? 'and $seconds second${seconds > 1 ? 's' : ''}' : ''}"),
          _buildBullet("Select the best answer for each question"),
          _buildBullet("The quiz will auto-submit when time runs out"),
          if (isGraded)
            _buildBullet("You'll receive your grade immediately after submission"),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(fontSize: 18, color: Color(0xFF00838F))),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class Question {
  final String question;
  final List<String> options;
  final int answerIndex;

  Question({
    required this.question,
    required this.options,
    required this.answerIndex,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    List<String> options =
    (json['options'] as List).map((e) => e.toString()).toList();
    int answerIndex = json['answerIndex'] as int;

    // Randomize the options while keeping correct index
    final correctAnswer = options[answerIndex];
    options.shuffle(Random());
    final newAnswerIndex = options.indexOf(correctAnswer);

    return Question(
      question: json['question'] as String,
      options: options,
      answerIndex: newAnswerIndex,
    );
  }
}

class _CourseInfoCard extends StatelessWidget {
  final String courseName;
  final int questionCount;
  final int totalTime;
  final bool isGraded;

  const _CourseInfoCard({
    required this.courseName,
    required this.questionCount,
    required this.totalTime,
    required this.isGraded,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = totalTime ~/ 60;
    final seconds = totalTime % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(courseName,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfo("Questions", "$questionCount"),
              _buildInfo("Time", "${minutes}m ${seconds}s"),
              _buildInfo("Grading", isGraded ? "Yes" : "No"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(String title, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        Text(title,
            style: const TextStyle(fontSize: 14, color: Colors.black54)),
      ],
    );
  }
}


class _QuizPageState extends State<QuizPage> with TickerProviderStateMixin {
  List<Question> _questions = [];
  final List<int?> _selectedAnswers = [];
  int _totalTime = 0;
  bool _quizStarted = false;
  bool _loading = true;
  String? _error;
  String _courseName = "Flutter Development Exam";
  bool _isGraded = true; // toggle if you want grading or just score


  late AnimationController _introController;
  late Animation<double> _introOpacity;
  late Animation<Offset> _introOffset;
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();

    // Intro animation for whole page
    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _introOpacity =
        CurvedAnimation(parent: _introController, curve: Curves.easeOut);
    _introOffset = Tween<Offset>(
      begin: const Offset(0, 0.045),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _introController, curve: Curves.easeOut));

    _timerController = AnimationController(vsync: this, duration: Duration.zero);

    _fetchQuestions();
  }

  @override
  void dispose() {
    _introController.dispose();
    _timerController.dispose();
    super.dispose();
  }
  Widget _buildScoreItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
  Future<void> _fetchQuestions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await http.get(Uri.parse(mockApiUrl));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as List;
        _questions = data.map((e) => Question.fromJson(e)).toList();
      } else {
        throw Exception("HTTP ${res.statusCode}");
      }
    } catch (_) {
      // Fallback questions if API fails
      _questions = [
        Question(
          question: "What is the renderer engine used in Flutter?",
          options: ["Skia", "OpenGL", "WebKit", "Vulkan"]..shuffle(Random()),
          answerIndex: 0,
        ),
        Question(
          question: "Which language is Flutter mainly written in?",
          options: ["Dart", "JavaScript", "Kotlin", "Swift"]..shuffle(Random()),
          answerIndex: 0,
        ),
        Question(
          question: "Flutter is developed by which company?",
          options: ["Google", "Facebook", "Microsoft", "Apple"]..shuffle(Random()),
          answerIndex: 0,
        ),
      ];
      _error = "Could not load from mock API. Using local sample questions.";
    }

    _selectedAnswers
      ..clear()
      ..addAll(List<int?>.filled(_questions.length, null));

    _totalTime = _questions.length * 15; // 15 seconds per question
    _timerController.duration = Duration(seconds: _totalTime);
    _timerController.reset();

    setState(() => _loading = false);
    _introController.forward();
  }

  String _getGrade(double accuracy) {
    if (accuracy >= 90) return "A+";
    if (accuracy >= 80) return "A";
    if (accuracy >= 70) return "B";
    if (accuracy >= 60) return "C";
    if (accuracy >= 50) return "D";
    return "F";
  }

  void _startQuiz() {
    if (_questions.isEmpty) return;
    setState(() => _quizStarted = true);

    _timerController.forward(from: 0);
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _submitQuiz(auto: true);
      }
    });
  }

  void _submitQuiz({bool auto = false}) {
    _timerController.stop();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    final correctCount = List.generate(_questions.length, (i) {
      return _selectedAnswers[i] == _questions[i].answerIndex ? 1 : 0;
    }).reduce((a, b) => a + b);

    final accuracy =
    _questions.isEmpty ? 0 : (correctCount / _questions.length) * 100;

    // Determine grade
    String grade = '';
    Color gradeColor = Colors.black;
    if (_isGraded) {
      if (accuracy >= 90) {
        grade = "A+";
        gradeColor = Colors.green.shade700;
      } else if (accuracy >= 80) {
        grade = "A";
        gradeColor = Colors.green;
      } else if (accuracy >= 70) {
        grade = "B";
        gradeColor = Colors.lightGreen;
      } else if (accuracy >= 60) {
        grade = "C";
        gradeColor = Colors.orange;
      } else if (accuracy >= 50) {
        grade = "D";
        gradeColor = Colors.deepOrange;
      } else {
        grade = "F";
        gradeColor = Colors.red;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
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
                        colors: [
                          Colors.blue.withOpacity(0.2),
                          Colors.green.withOpacity(0.2)
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      accuracy >= 80
                          ? Icons.emoji_events
                          : accuracy >= 60
                          ? Icons.thumb_up
                          : Icons.sentiment_neutral,
                      color: accuracy >= 80
                          ? Colors.amber
                          : accuracy >= 60
                          ? Colors.blue
                          : Colors.grey,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Quiz Complete! 🎉',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored $correctCount out of ${_questions.length}!',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  if (_isGraded) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Grade: $grade',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: gradeColor),
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Score breakdown
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildScoreItem(
                          "Correct",
                          correctCount.toString(),
                          Colors.green,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        _buildScoreItem(
                          "Incorrect",
                          (_questions.length - correctCount).toString(),
                          Colors.red,
                        ),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey[300],
                        ),
                        _buildScoreItem(
                          "Total",
                          _questions.length.toString(),
                          Color((0xFF00838F)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Responsive Buttons
                  LayoutBuilder(
                    builder: (context, constraints) {
                      // Stack buttons vertically on small screens
                      if (constraints.maxWidth < 300) {
                        return Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00838F),
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _fetchQuestions();
                                  setState(() => _quizStarted = false);
                                },
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Retry",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 3,
                                  shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                                        (Route<dynamic> route) => false,
                                  );
                                },
                                icon: const Icon(Icons.dashboard, size: 20),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    "Dashboard",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      // Horizontal layout for larger screens
                      return Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF00838F),
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  _fetchQuestions();
                                  setState(() => _quizStarted = false);
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.refresh, size: 20),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        "Retry",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black87,
                                  elevation: 3,
                                  shadowColor: Colors.cyanAccent.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: Colors.grey[300]!),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(builder: (context) => DashboardScreen()),
                                        (Route<dynamic> route) => false,
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.dashboard, size: 20),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        "Dashboard",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: FadeTransition(
            opacity: _introOpacity,
            child: SlideTransition(
              position: _introOffset,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const Text('  Quiz 📝',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87)),
                  const SizedBox(height: 12),

                  // Only show timer when quiz has started
                  if (_quizStarted) ...[
                    AnimatedBuilder(
                      animation: _timerController,
                      builder: (context, _) {
                        final progress = 1.0 - _timerController.value;
                        final remaining = (_totalTime *
                            (1 - _timerController.value))
                            .ceil();
                        final minutes = remaining ~/ 60;
                        final secs = remaining % 60;
                        final timeText =
                            '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
                        return _TimerFillCard(
                            progress: progress, timeText: timeText);
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (!_quizStarted) ...[
                    // Course name card
                    _CourseNameCard(courseName: _courseName),

                    // Info cards row
                    Row(
                      children: [
                        _InfoCard(
                          icon: Icons.quiz_outlined,
                          title: "${_questions.length} Questions",
                          subtitle: "Quick & Easy",
                          color: Color(0xFF00838F),
                        ),
                        const SizedBox(width: 12),
                        _InfoCard(
                          icon: Icons.timer,
                          title: "${_totalTime ~/ 60}m ${_totalTime % 60}s",
                          subtitle: "Time Limit",
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 12),
                        _InfoCard(
                          icon: Icons.emoji_events,
                          title: _isGraded ? "Graded" : "Practice",
                          subtitle: _isGraded ? "Get Results" : "No Grade",
                          color: Colors.green,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _QuizIntroCard(
                      questionCount: _questions.length,
                      totalTime: _totalTime,
                      isGraded: _isGraded,
                    ),

                    const SizedBox(height: 10),

                    Center(
                      child: GradientButton(
                        onPressed: _startQuiz,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.play_arrow, color: Colors.white, size: 24),
                            SizedBox(width: 8),
                            Text(
                              "Start Quiz",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],

                  if (_quizStarted) ...[
                    for (int q = 0; q < _questions.length; q++)
                      _AnimatedQuestionCard(
                          question: _questions[q],
                          qIndex: q,
                          onAnswer: (a) {
                            setState(() {
                              _selectedAnswers[q] = a;
                            });
                          },
                          selectedIndex: _selectedAnswers[q]),
                    const SizedBox(height: 20),

                    // Submit button with same style as Start button
                    Center(
                      child: GradientButton(
                        onPressed: () => _submitQuiz(),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Submit Quiz",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedQuestionCard extends StatelessWidget {
  final Question question;
  final int qIndex;
  final Function(int) onAnswer;
  final int? selectedIndex;

  const _AnimatedQuestionCard({
    required this.question,
    required this.qIndex,
    required this.onAnswer,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0.9, end: 1.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFEFEFEFE),
                  borderRadius: BorderRadius.circular(16.0),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.cyanAccent.withOpacity(0.2),
                        blurRadius: 2,
                        spreadRadius: 0.5,
                        offset: const Offset(0, 4)),
                    const BoxShadow(color: Colors.black12, blurRadius: 1.0),
                  ],
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                Padding(
                padding: const EdgeInsets.all(14.0),
                    child: Text("Q${qIndex + 1}: ${question.question}",
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87))),
                      for (int i = 0; i < question.options.length; i++)
                        _AnimatedAnswerTile(
                          text: question.options[i],
                          isSelected: selectedIndex == i,
                          onTap: () => onAnswer(i),
                        )
                    ],
                ),
            ),
        ),
    );
  }
}

class _AnimatedAnswerTile extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedAnswerTile(
      {required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          height: 54,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE0F2F1) : Colors.white,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color:
              isSelected ? const Color(0xFF00838F) : Colors.grey.shade200,
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 1.0),
            ],
          ),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Text(
            text,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color:
                isSelected ? const Color(0xFF00838F) : Colors.black87),
          ),
        ),
      ),
    );
  }
}

/// 🔥 Timer card
class _TimerFillCard extends StatelessWidget {
  final double progress;
  final String timeText;
  const _TimerFillCard({required this.progress, required this.timeText});

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
    );

    return SizedBox(
      height: 70,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withOpacity(0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),
          FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                gradient: gradient,
                borderRadius: BorderRadius.circular(16.0),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Outline
                        Text(
                          'Time Left',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()
                              ..style = PaintingStyle.stroke
                              ..strokeWidth = 2
                              ..color = const Color(0xFF00838F),
                          ),
                        ),
                        // Fill
                        const Text(
                          'Time Left',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Stack(
                    children: [
                      // Outline
                      Text(
                        timeText,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..style = PaintingStyle.stroke
                            ..strokeWidth = 2
                            ..color = const Color(0xFF00838F),
                        ),
                      ),
                      // Fill
                      Text(
                        timeText,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

/// Gradient button
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    const gradient = LinearGradient(
      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
    );

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onPressed,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
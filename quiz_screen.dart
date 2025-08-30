import 'package:flutter/material.dart';
import 'dart:async';
import 'notes_screen.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 3;
  int _timeLeft = 60;
  Timer? _timer;
  bool _quizStarted = false;
  Object animal = {};
  final List<int?> _selectedAnswers = [null, null, null];

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _timeLeft = 60;
    });
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // prevent stacking
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        timer.cancel();
        _submitQuiz(auto: true);
      }
    });
  }

  void _submitQuiz({bool auto = false}) {
    _timer?.cancel();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(auto ? "Time's up!" : "Quiz Submitted"),
        content: Text(
          auto
              ? "The quiz was submitted automatically."
              : "Your answers have been submitted.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // --------------------- Title ---------------------
                Row(
                  children: const [
                    Text(
                      '📝 Quiz',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // --------------------- Time Card ---------------------
                Container(
                  height: 70,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2A7DE1), Color(0xFF2BD46E)],
                    ),
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
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Time Left',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // darker
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          _formatTime(_timeLeft),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87, // darker
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // --------------------- Start Quiz Button ---------------------
                if (!_quizStarted)
                  Center(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                      ),
                      child: const Text(
                        "Start Quiz",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),

                if (_quizStarted) ...[
                  // --------------------- Question 1 ---------------------
                  _buildQuestionCard(
                    "Q1: What is the renderer engine used in Flutter?",
                    0,
                    ["A: Skia", "B: OpenGL", "C: WebKit", "D: Vulkan"],
                  ),

                  // --------------------- Question 2 ---------------------
                  _buildQuestionCard(
                    "Q2: Which language is Flutter mainly written in?",
                    1,
                    ["A: Dart", "B: JavaScript", "C: Kotlin", "D: Swift"],
                  ),

                  // --------------------- Question 3 ---------------------
                  _buildQuestionCard(
                    "Q3: Flutter is developed by which company?",
                    2,
                    ["A: Google", "B: Facebook", "C: Microsoft", "D: Apple"],
                  ),

                  // --------------------- Submit ---------------------
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => _submitQuiz(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2196F3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            "Submit",
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),

      // --------------------- New Bottom Navbar ---------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (int index) {
          _timer?.cancel(); // kill timer on nav
          setState(() {
            _currentIndex = index;
          });

          if (index == 0) {}
          if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const NotesPage()),
            );
          }

          if (index == 3) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const QuizScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_outlined),
            label: 'Course',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_outlined),
            label: 'Notes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help_outline),
            label: 'Quiz',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String question, int qIndex, List<String> answers) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: _boxStyle(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _questionText(question),
            for (int i = 0; i < answers.length; i++)
              _buildAnswer(answers[i], qIndex, i),
          ],
        ),
      ),
    );
  }

  BoxDecoration _boxStyle() => BoxDecoration(
    color: const Color(0xFEFEFEFE),
    borderRadius: BorderRadius.circular(16.0),
    border: Border.all(
      color: const Color.fromARGB(255, 243, 244, 245),
      width: 0.5,
    ),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1.0)],
  );

  Widget _questionText(String text) => Padding(
    padding: const EdgeInsets.all(14.0),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    ),
  );

  Widget _buildAnswer(String text, int questionIndex, int answerIndex) {
    final isSelected = _selectedAnswers[questionIndex] == answerIndex;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAnswers[questionIndex] = answerIndex;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue[100] : const Color(0xFEFEFEFE),
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected
                  ? Colors.blue
                  : const Color.fromARGB(255, 243, 244, 245),
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 1.0),
            ],
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.blue : Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

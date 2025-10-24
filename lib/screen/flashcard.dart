import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard.dart';
import 'package:http/http.dart' as http;

final String api = "https://mock-api.net/api/Flutter1/Flashcards_Questions";

class Flashcard {
  final String question;
  final String answer;
  final String category;

  Flashcard({
    required this.question,
    required this.answer,
    required this.category,
  });

  static Future<List<Flashcard>> fetchFlashcardsQA() async {
    final response = await http.get(Uri.parse(api));
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList.map((json) {
        return Flashcard(
          question: json['question'] as String,
          answer: json['answer'] as String,
          category: json['category'] as String,
        );
      }).toList();
    } else {
      throw Exception('Failed to load flashcards');
    }
  }
}

class FlashcardService {
  static final FlashcardService _instance = FlashcardService._internal();
  factory FlashcardService() => _instance;
  FlashcardService._internal();

  List<Flashcard> _flashcards = [];

  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _isShuffled = false;
  List<Flashcard> _shuffledCards = [];
  bool _hasCompletedRound = false;

  // Getters
  List<Flashcard> get flashcards => _isShuffled ? _shuffledCards : _flashcards;
  Flashcard? get currentCard => flashcards.isNotEmpty ? flashcards[_currentIndex] : null;
  int get currentIndex => _currentIndex;
  int get totalCards => flashcards.length;
  int get correctAnswers => _correctAnswers;
  int get totalAnswered => _totalAnswered;
  double get accuracy => _totalAnswered > 0 ? _correctAnswers / _totalAnswered : 0.0;
  bool get isShuffled => _isShuffled;
  bool get hasCompletedRound => _hasCompletedRound;

  // Method to load flashcards asynchronously
  Future<void> loadFlashcards() async {
    _flashcards = await Flashcard.fetchFlashcardsQA();
  }

  void nextCard() {
    if (flashcards.isEmpty) return;
    _currentIndex = (_currentIndex + 1) % flashcards.length;
    if (_currentIndex >= flashcards.length) {
      _currentIndex = 0;
    }
  }

  void previousCard() {
    if (flashcards.isEmpty) return;
    _currentIndex = (_currentIndex - 1 + flashcards.length) % flashcards.length;
    if (_currentIndex < 0) {
      _currentIndex = flashcards.length - 1;
    }
  }

  void markCorrect() {
    _correctAnswers++;
    _totalAnswered++;
    checkForCompletion();
  }

  void markIncorrect() {
    _totalAnswered++;
    checkForCompletion();
  }

  void shuffle() {
    if (!_isShuffled) {
      _shuffledCards = List.from(_flashcards)..shuffle();
      _isShuffled = true;
    } else {
      _isShuffled = false;
    }
  }

  void resetStats() {
    _correctAnswers = 0;
    _totalAnswered = 0;
    _hasCompletedRound = false;
  }

  void resetToFirst() {
    _currentIndex = 0;
    _hasCompletedRound = false;
  }

  void resetAll() {
    _currentIndex = 0;
    _correctAnswers = 0;
    _totalAnswered = 0;
    _hasCompletedRound = false;
    _isShuffled = false;
    _shuffledCards.clear();
  }

  void validateState() {
    print('Validating state: currentIndex=$_currentIndex, totalAnswered=$_totalAnswered, totalCards=${flashcards.length}, hasCompletedRound=$_hasCompletedRound');

    if (flashcards.isEmpty) {
      print('No flashcards loaded, resetting state');
      _currentIndex = 0;
      _correctAnswers = 0;
      _totalAnswered = 0;
      _hasCompletedRound = false;
      return;
    }

    if (_totalAnswered >= flashcards.length && _hasCompletedRound) {
      print('Completed round detected - resetting all');
      resetAll();
      return;
    }

    if (_currentIndex >= flashcards.length) {
      print('CurrentIndex $_currentIndex out of bounds, resetting to 0');
      _currentIndex = 0;
    }
    if (_currentIndex < 0) {
      print('CurrentIndex $_currentIndex negative, resetting to 0');
      _currentIndex = 0;
    }

    if (_totalAnswered > flashcards.length) {
      print('TotalAnswered $_totalAnswered exceeds limit, capping at ${flashcards.length}');
      _totalAnswered = flashcards.length;
    }

    if (_correctAnswers > _totalAnswered) {
      print('CorrectAnswers $_correctAnswers exceeds totalAnswered $_totalAnswered, capping');
      _correctAnswers = _totalAnswered;
    }

    print('State after validation: currentIndex=$_currentIndex, totalAnswered=$_totalAnswered');
  }

  void checkForCompletion() {
    if (_totalAnswered >= flashcards.length && !_hasCompletedRound) {
      _hasCompletedRound = true;
      print('Marking round as completed');
    }
  }
}

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> with TickerProviderStateMixin {
  final FlashcardService _flashcardService = FlashcardService();
  bool _isShowingAnswer = false;
  late AnimationController _flipController;
  late AnimationController _slideController;
  late Animation<double> _flipAnimation;
  late Animation<Offset> _slideAnimation;
  int _selectedIndex = 2;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _loadFlashcards();
    _slideController.forward();
  }

  Future<void> _loadFlashcards() async {
    try {
      await _flashcardService.loadFlashcards();
      _flashcardService.validateState();

      print('FlashCard State after loading: ${_flashcardService.currentIndex + 1}/${_flashcardService.totalCards} (totalAnswered=${_flashcardService.totalAnswered}, hasCompletedRound=${_flashcardService.hasCompletedRound})');

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error loading flashcards: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load flashcards: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _flipController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _showAnswer() {
    setState(() {
      _isShowingAnswer = true;
    });
    _flipController.forward();
  }

  void _hideAnswer() {
    _flipController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isShowingAnswer = false;
        });
      }
    });
  }

  void _nextCard() {
    _slideController.reset();
    _hideAnswer();
    _flashcardService.nextCard();
    _slideController.forward();
    setState(() {});
  }

  void _nextCardWithCompletionCheck() {
    if (_flashcardService.totalAnswered == _flashcardService.totalCards) {
      _showCompletionDialog();
    } else {
      _nextCard();
    }
  }

  void _previousCard() {
    _slideController.reset();
    _hideAnswer();
    _flashcardService.previousCard();
    _slideController.forward();
    setState(() {});
  }

  void _markCorrect() {
    _flashcardService.markCorrect();

    if (_flashcardService.totalAnswered == _flashcardService.totalCards) {
      _showCompletionDialog();
    } else {
      _nextCard();
    }
  }

  void _markIncorrect() {
    _flashcardService.markIncorrect();

    if (_flashcardService.totalAnswered == _flashcardService.totalCards) {
      _showCompletionDialog();
    } else {
      _nextCard();
    }
  }

  void _shuffleCards() {
    _hideAnswer();
    _flashcardService.shuffle();
    setState(() {});
  }

  void _showCompletionDialog() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.alert);

    showDialog(
        context: context,
        barrierDismissible: false,
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
                      Icons.emoji_events,
                      color: Colors.amber,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Round Complete! 🎉',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You scored ${_flashcardService.correctAnswers} out of ${_flashcardService.totalCards}!',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Accuracy: ${(_flashcardService.accuracy * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                      children: [
                  Expanded(
                  child: TextButton(
                  onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
                );
                },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black54,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Exit',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                  child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.blueAccent, Colors.greenAccent],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _flashcardService.resetAll();
                        setState(() {});
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
                        'Play Again',
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
          );
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    if (_flashcardService.totalCards == 0) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: const Text(
            'Loading Flashcards...',
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Loading flashcards...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Flexible(
              child: Text(
                'Flashcards',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: isSmallScreen ? 18 : 20,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '🧠',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 12,
                  vertical: 6
              ),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_flashcardService.currentIndex + 1}/${_flashcardService.totalCards}',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: isSmallScreen ? 12 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          // Stats Row
                          _buildResponsiveStatsRow(isSmallScreen),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Progress Indicator
                          _buildProgressIndicator(isSmallScreen),

                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Main Card
                          Container(
                            height: constraints.maxHeight * 0.4,
                            constraints: BoxConstraints(
                              minHeight: 250,
                              maxHeight: isSmallScreen ? 350 : 400,
                            ),
                            child: SlideTransition(
                              position: _slideAnimation,
                              child: _buildFlashcard(isSmallScreen),
                            ),
                          ),
                        ],
                      ),

                      Column(
                        children: [
                          SizedBox(height: isSmallScreen ? 20 : 30),

                          // Control Buttons
                          _buildResponsiveControlButtons(isSmallScreen, screenWidth),

                          SizedBox(height: isSmallScreen ? 16 : 20),

                          // Navigation Buttons
                          _buildNavigationButtons(isSmallScreen),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildResponsiveStatsRow(bool isSmallScreen) {
    if (isSmallScreen) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          _buildStatCard(
            'Accuracy',
            '${(_flashcardService.accuracy * 100).toInt()}%',
            Icons.track_changes,
            Colors.greenAccent,
            isSmallScreen: true,
          ),
          _buildStatCard(
            'Correct',
            '${_flashcardService.correctAnswers}',
            Icons.check_circle_outline,
            Colors.green,
            isSmallScreen: true,
          ),
          _buildStatCard(
            'Total',
            '${_flashcardService.totalAnswered}',
            Icons.quiz_outlined,
            Colors.blue,
            isSmallScreen: true,
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: _buildStatCard(
            'Accuracy',
            '${(_flashcardService.accuracy * 100).toInt()}%',
            Icons.track_changes,
            Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Correct',
            '${_flashcardService.correctAnswers}',
            Icons.check_circle_outline,
            Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Total',
            '${_flashcardService.totalAnswered}',
            Icons.quiz_outlined,
            Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {bool isSmallScreen = false}) {
    return Container(
      width: isSmallScreen ? 100 : null,
      padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 12 : 16,
          vertical: isSmallScreen ? 8 : 12
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.2), blurRadius: 7, offset: const Offset(0, 3))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmallScreen ? 18 : 20),
          SizedBox(height: isSmallScreen ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isSmallScreen) {
    double progress = _flashcardService.totalCards > 0
        ? (_flashcardService.currentIndex + 1) / _flashcardService.totalCards
        : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            Flexible(
              child: Text(
                _flashcardService.currentCard?.category ?? 'Loading...',
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.blue, Colors.green],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFlashcard(bool isSmallScreen) {
    return Center(
      child: GestureDetector(
        onTap: _isShowingAnswer ? _hideAnswer : _showAnswer,
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            final isShowingFront = _flipAnimation.value < 0.5;
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * math.pi),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.cyanAccent.withOpacity(0.3), blurRadius: 7, offset: const Offset(0, 3))],
                ),
                child: Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 16.0 : 24.0),
                  child: isShowingFront
                      ? _buildQuestionSide(isSmallScreen)
                      : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildAnswerSide(isSmallScreen),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionSide(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.help_outline,
          size: isSmallScreen ? 36 : 48,
          color: Colors.cyanAccent.withOpacity(0.6),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              _flashcardService.currentCard?.question ?? 'Loading flashcards...',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: 8
          ),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Tap to reveal answer',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSide(bool isSmallScreen) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: isSmallScreen ? 36 : 48,
          color: Colors.green.withOpacity(0.6),
        ),
        SizedBox(height: isSmallScreen ? 16 : 20),
        Flexible(
          child: SingleChildScrollView(
            child: Text(
              _flashcardService.currentCard?.answer ?? 'Loading...',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.black87,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        SizedBox(height: isSmallScreen ? 20 : 30),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Flexible(
                child: _buildAnswerButton(
                  'Got it wrong 😞',
                  Colors.red,
                  Colors.redAccent,
                  _markIncorrect,
                  isSmallScreen,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _buildAnswerButton(
                  'Got it right! 🎉',
                  Colors.green,
                  Colors.greenAccent,
                  _markCorrect,
                  isSmallScreen,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton(String text, Color color1, Color color2, VoidCallback onPressed, bool isSmallScreen) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: isSmallScreen ? 120 : 150,
        minWidth: isSmallScreen ? 100 : 120,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color2, color1]),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: color1.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 16,
            vertical: isSmallScreen ? 6 : 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveControlButtons(bool isSmallScreen, double screenWidth) {
    if (screenWidth < 400) {
      // Stack buttons vertically on very small screens
      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildControlButton(
                  icon: _flashcardService.isShuffled ? Icons.sort : Icons.shuffle,
                  label: _flashcardService.isShuffled ? 'Unshuffle' : 'Shuffle',
                  onPressed: _shuffleCards,
                  gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
                  isSmallScreen: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildControlButton(
                  icon: Icons.refresh,
                  label: 'Reset',
                  onPressed: () {
                    _flashcardService.resetStats();
                    setState(() {});
                  },
                  gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
                  isSmallScreen: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _buildControlButton(
              icon: _isShowingAnswer ? Icons.visibility_off : Icons.visibility,
              label: _isShowingAnswer ? 'Hide Answer' : 'Show Answer',
              onPressed: _isShowingAnswer ? _hideAnswer : _showAnswer,
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
              isSmallScreen: true,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Flexible(
          child: _buildControlButton(
            icon: _flashcardService.isShuffled ? Icons.sort : Icons.shuffle,
            label: _flashcardService.isShuffled ? 'Unshuffle' : 'Shuffle',
            onPressed: _shuffleCards,
            gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _buildControlButton(
            icon: Icons.refresh,
            label: 'Reset Stats',
            onPressed: () {
              _flashcardService.resetStats();
              setState(() {});
            },
            gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _buildControlButton(
            icon: _isShowingAnswer ? Icons.visibility_off : Icons.visibility,
            label: _isShowingAnswer ? 'Hide Answer' : 'Show Answer',
            onPressed: _isShowingAnswer ? _hideAnswer : _showAnswer,
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
    bool isSmallScreen = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.4),
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 8 : 16,
            vertical: isSmallScreen ? 8 : 12,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: isSmallScreen ? 16 : 20, color: Colors.white),
            SizedBox(height: isSmallScreen ? 2 : 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: isSmallScreen ? 9 : 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons(bool isSmallScreen) {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_back_ios,
            label: 'Previous',
            onPressed: _previousCard,
            gradient: const LinearGradient(colors: [Colors.blueGrey, Colors.blueAccent]),
            isSmallScreen: isSmallScreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_forward_ios,
            label: 'Next',
            onPressed: _nextCardWithCompletionCheck,
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
            isSmallScreen: isSmallScreen,
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
    required bool isSmallScreen,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.4),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 12 : 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.white),
              SizedBox(width: isSmallScreen ? 4 : 8),
            ],
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              SizedBox(width: isSmallScreen ? 4 : 8),
              Icon(icon, size: isSmallScreen ? 14 : 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}
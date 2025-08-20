import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Flashcard {
  final String question;
  final String answer;
  final String category;

  Flashcard({
    required this.question,
    required this.answer,
    required this.category,
  });
}

class FlashcardService {
  static final FlashcardService _instance = FlashcardService._internal();
  factory FlashcardService() => _instance;
  FlashcardService._internal();

  List<Flashcard> _flashcards = [
    Flashcard(
      question: "What is Flutter?",
      answer: "Flutter is Google's open-source UI software development kit used to develop applications for Android, iOS, Linux, Mac, Windows, and the web from a single codebase.",
      category: "Technology",
    ),
    Flashcard(
      question: "What is the capital of Japan?",
      answer: "Tokyo is the capital and most populous city of Japan. It serves as the country's political, economic, and cultural center.",
      category: "Geography",
    ),
    Flashcard(
      question: "What is photosynthesis?",
      answer: "Photosynthesis is the process by which green plants and some other organisms use sunlight to synthesize foods from carbon dioxide and water, typically producing oxygen as a byproduct.",
      category: "Science",
    ),
    Flashcard(
      question: "Who wrote Romeo and Juliet?",
      answer: "William Shakespeare wrote Romeo and Juliet around 1594-1596. It is one of his most famous tragedies and tells the story of two young star-crossed lovers.",
      category: "Literature",
    ),
    Flashcard(
      question: "What is the Pythagorean theorem?",
      answer: "The Pythagorean theorem states that in a right triangle, the square of the hypotenuse (the side opposite the right angle) is equal to the sum of the squares of the other two sides: a² + b² = c²",
      category: "Mathematics",
    ),
  ];

  int _currentIndex = 0;
  int _correctAnswers = 0;
  int _totalAnswered = 0;
  bool _isShuffled = false;
  List<Flashcard> _shuffledCards = [];
  bool _hasCompletedRound = false;

  // Getters
  List<Flashcard> get flashcards => _isShuffled ? _shuffledCards : _flashcards;
  Flashcard get currentCard => flashcards[_currentIndex];
  int get currentIndex => _currentIndex;
  int get totalCards => flashcards.length;
  int get correctAnswers => _correctAnswers;
  int get totalAnswered => _totalAnswered;
  double get accuracy => _totalAnswered > 0 ? _correctAnswers / _totalAnswered : 0.0;
  bool get isShuffled => _isShuffled;

  void nextCard() {
    _currentIndex = (_currentIndex + 1) % flashcards.length;
    // Additional safety check
    if (_currentIndex >= flashcards.length) {
      _currentIndex = 0;
    }
  }

  bool get hasCompletedRound => _hasCompletedRound;

  void previousCard() {
    _currentIndex = (_currentIndex - 1 + flashcards.length) % flashcards.length;
    // Additional safety check
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
    // Don't reset _currentIndex when shuffling - maintain current progress
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
    
    // If user completed all cards and comes back, reset everything
    if (_totalAnswered >= flashcards.length && _hasCompletedRound) {
      print('Completed round detected - resetting all');
      resetAll();
      return;
    }
    
    // Ensure currentIndex is within valid bounds
    if (_currentIndex >= flashcards.length) {
      print('CurrentIndex $_currentIndex out of bounds, resetting to 0');
      _currentIndex = 0;
    }
    if (_currentIndex < 0) {
      print('CurrentIndex $_currentIndex negative, resetting to 0');
      _currentIndex = 0;
    }
    
    // Ensure totalAnswered doesn't exceed total cards
    if (_totalAnswered > flashcards.length) {
      print('TotalAnswered $_totalAnswered exceeds limit, capping at ${flashcards.length}');
      _totalAnswered = flashcards.length;
    }
    
    // Ensure correctAnswers doesn't exceed totalAnswered
    if (_correctAnswers > _totalAnswered) {
      print('CorrectAnswers $_correctAnswers exceeds totalAnswered $_totalAnswered, capping');
      _correctAnswers = _totalAnswered;
    }
    
    print('State after validation: currentIndex=$_currentIndex, totalAnswered=$_totalAnswered');
  }

  // Method to check if we should mark completion
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
    
    // Validate and fix any corrupted state when returning to the screen
    _flashcardService.validateState();
    
    // Debug: Print current state
    print('FlashCard State at initState: ${_flashcardService.currentIndex + 1}/${_flashcardService.totalCards} (totalAnswered=${_flashcardService.totalAnswered}, hasCompletedRound=${_flashcardService.hasCompletedRound})');
    
    _slideController.forward();
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
    // Check if we've answered all questions
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
    
    // Check completion after marking the answer
    if (_flashcardService.totalAnswered == _flashcardService.totalCards) {
      _showCompletionDialog();
    } else {
      _nextCard();
    }
  }

  void _markIncorrect() {
    _flashcardService.markIncorrect();
    
    // Check completion after marking the answer
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
    // Play haptic feedback
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
                  // Icon and title
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
                  
                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop(); // Exit flashcard screen
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            const Text(
              'Flashcards',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '🧠',
              style: TextStyle(fontSize: 20),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_flashcardService.currentIndex + 1}/${_flashcardService.totalCards}',
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Stats Row
              _buildStatsRow(),
              
              const SizedBox(height: 20),
              
              // Progress Indicator
              _buildProgressIndicator(),
              
              const SizedBox(height: 30),
              
              // Main Card
              Expanded(
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _buildFlashcard(),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Control Buttons
              _buildControlButtons(),
              
              const SizedBox(height: 20),
              
              // Navigation Buttons
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatCard(
          'Accuracy',
          '${(_flashcardService.accuracy * 100).toInt()}%',
          Icons.track_changes,
          Colors.greenAccent,
        ),
        _buildStatCard(
          'Correct',
          '${_flashcardService.correctAnswers}',
          Icons.check_circle_outline,
          Colors.green,
        ),
        _buildStatCard(
          'Total',
          '${_flashcardService.totalAnswered}',
          Icons.quiz_outlined,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.6),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    double progress = (_flashcardService.currentIndex + 1) / _flashcardService.totalCards;
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _flashcardService.currentCard.category,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                fontWeight: FontWeight.w600,
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

  Widget _buildFlashcard() {
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
                constraints: const BoxConstraints(
                  minHeight: 300,
                  maxHeight: 400,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyanAccent.withOpacity(0.6),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: isShowingFront
                      ? _buildQuestionSide()
                      : Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()..rotateY(math.pi),
                          child: _buildAnswerSide(),
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuestionSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.help_outline,
          size: 48,
          color: Colors.cyanAccent.withOpacity(0.6),
        ),
        const SizedBox(height: 20),
        Text(
          _flashcardService.currentCard.question,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Tap to reveal answer',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerSide() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.lightbulb_outline,
          size: 48,
          color: Colors.green.withOpacity(0.6),
        ),
        const SizedBox(height: 20),
        Text(
          _flashcardService.currentCard.answer,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnswerButton(
              'Got it wrong 😞',
              Colors.red,
              Colors.redAccent,
              _markIncorrect,
            ),
            _buildAnswerButton(
              'Got it right! 🎉',
              Colors.green,
              Colors.greenAccent,
              _markCorrect,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerButton(String text, Color color1, Color color2, VoidCallback onPressed) {
    return Container(
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildControlButton(
          icon: _flashcardService.isShuffled ? Icons.sort : Icons.shuffle,
          label: _flashcardService.isShuffled ? 'Unshuffle' : 'Shuffle',
          onPressed: _shuffleCards,
          gradient: const LinearGradient(colors: [Colors.purple, Colors.purpleAccent]),
        ),
        _buildControlButton(
          icon: Icons.refresh,
          label: 'Reset Stats',
          onPressed: () {
            _flashcardService.resetStats();
            setState(() {});
          },
          gradient: const LinearGradient(colors: [Colors.orange, Colors.orangeAccent]),
        ),
        _buildControlButton(
          icon: _isShowingAnswer ? Icons.visibility_off : Icons.visibility,
          label: _isShowingAnswer ? 'Hide Answer' : 'Show Answer',
          onPressed: _isShowingAnswer ? _hideAnswer : _showAnswer,
          gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Gradient gradient,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_back_ios,
            label: 'Previous',
            onPressed: _previousCard,
            gradient: const LinearGradient(colors: [Colors.blueGrey, Colors.blueAccent]),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildNavButton(
            icon: Icons.arrow_forward_ios,
            label: 'Next',
            onPressed: _nextCardWithCompletionCheck,
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.greenAccent]),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

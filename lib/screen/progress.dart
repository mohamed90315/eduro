import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // Sample data for demonstration
  final List<List<int>> heatmapData = _generateHeatmapData();
  final List<SubjectData> subjectData = [
    SubjectData('Mathematics', 75, const Color(0xFF2A7DE1)),
    SubjectData('Physics', 60, const Color(0xFF2BD46E)),
    SubjectData('Chemistry', 85, const Color(0xFFFF6B9D)),
    SubjectData('Biology', 40, const Color(0xFFFFA726)),
    SubjectData('English', 90, const Color(0xFF9C27B0)),
  ];

  // Sample data for syllabus completed chart
  final List<ChartData> syllabusData = [
    ChartData('Tue', 20),
    ChartData('Wed', 35),
    ChartData('Thu', 55),
    ChartData('Fri', 45),
    ChartData('Sat', 65),
    ChartData('Sun', 80),
  ];

  // Hover state for syllabus chart
  int? hoveredIndex;
  Offset? hoverPosition;

  static List<List<int>> _generateHeatmapData() {
    // Generate sample heatmap data for the last 12 weeks
    List<List<int>> data = [];
    for (int week = 0; week < 12; week++) {
      List<int> weekData = [];
      for (int day = 0; day < 7; day++) {
        // Random study intensity (0-4)
        weekData.add((week * 7 + day) % 5);
      }
      data.add(weekData);
    }
    return data;
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

  Widget _buildSyllabusChart() {
    return _buildWhiteCard(
      child: GestureDetector(
        onTap: () {
          // Clear tooltip when tapping outside chart area
          setState(() {
            hoveredIndex = null;
            hoverPosition = null;
          });
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Syllabus Completed',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            Stack(
              children: [
                GestureDetector(
                  onTapDown: (details) {
                    final RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    final localPosition = renderBox.globalToLocal(
                      details.globalPosition,
                    );
                    _handleChartHover(localPosition);
                  },
                  child: MouseRegion(
                    onHover: (event) {
                      final RenderBox renderBox =
                          context.findRenderObject() as RenderBox;
                      final localPosition = renderBox.globalToLocal(
                        event.position,
                      );
                      _handleChartHover(localPosition);
                    },
                    onExit: (event) {
                      setState(() {
                        hoveredIndex = null;
                        hoverPosition = null;
                      });
                    },
                    child: Container(
                      height: 200,
                      child: CustomPaint(
                        size: Size.infinite,
                        painter: AreaChartPainter(syllabusData, hoveredIndex),
                      ),
                    ),
                  ),
                ),
                if (hoveredIndex != null && hoverPosition != null)
                  Positioned(
                    left: (hoverPosition!.dx - 50).clamp(
                      24.0, // Account for card padding
                      MediaQuery.of(context).size.width -
                          124, // Card padding + tooltip width
                    ),
                    top: (hoverPosition!.dy - 80).clamp(
                      60.0, // Below title area
                      200.0, // Within chart height
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            syllabusData[hoveredIndex!].day,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${syllabusData[hoveredIndex!].value.toInt()}%',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Days labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: syllabusData
                  .map(
                    (data) => Text(
                      data.day,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChartHover(Offset localPosition) {
    // Calculate which data point is being hovered
    const double chartHeight = 200;
    const double chartPadding = 24; // Account for card padding
    const double titleHeight = 60; // Account for title and spacing

    // Adjust position for card padding and title
    final adjustedX = localPosition.dx - chartPadding;
    final adjustedY = localPosition.dy - titleHeight;

    if (adjustedX < 0 || adjustedY < 0 || adjustedY > chartHeight) {
      setState(() {
        hoveredIndex = null;
        hoverPosition = null;
      });
      return;
    }

    // Get available width for chart (account for card padding on both sides)
    final screenWidth = MediaQuery.of(context).size.width;
    final chartWidth =
        screenWidth - (chartPadding * 2) - 48; // 48 for additional margins
    final stepX = chartWidth / (syllabusData.length - 1);

    // Find the closest data point
    int? closestIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < syllabusData.length; i++) {
      final pointX = i * stepX;
      final distance = (adjustedX - pointX).abs();

      if (distance < minDistance) {
        minDistance = distance;
        closestIndex = i;
      }
    }

    // Show hover for any point within a reasonable distance
    if (closestIndex != null && minDistance < stepX * 0.8) {
      // Increased tolerance
      final selectedIndex = closestIndex;
      setState(() {
        hoveredIndex = selectedIndex;
        // Use the original cursor position but ensure it stays within bounds
        hoverPosition = Offset(
          localPosition.dx.clamp(
            50.0,
            screenWidth - 50.0,
          ), // Keep tooltip within screen
          localPosition.dy.clamp(
            80.0,
            300.0,
          ), // Keep within reasonable vertical bounds
        );
      });
    } else {
      setState(() {
        hoveredIndex = null;
        hoverPosition = null;
      });
    }
  }

  Widget _buildHeatmapCalendar() {
    final weekDays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Study Consistency',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your daily study habits over the last 12 weeks',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),

          // Week day labels
          Row(
            children: [
              const SizedBox(width: 40), // Space for month labels
              ...weekDays.map(
                (day) => Expanded(
                  child: Center(
                    child: Text(
                      day,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Heatmap grid
          Column(
            children: List.generate(heatmapData.length, (weekIndex) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  children: [
                    // Month label (show only for first week of each month)
                    SizedBox(
                      width: 40,
                      child: weekIndex % 4 == 0
                          ? Text(
                              _getMonthName(weekIndex ~/ 4),
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey[600],
                              ),
                            )
                          : null,
                    ),
                    // Heatmap squares
                    ...heatmapData[weekIndex].map(
                      (intensity) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(1),
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: _getHeatmapColor(intensity),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Less',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getHeatmapColor(index),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                'More',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getHeatmapColor(int intensity) {
    switch (intensity) {
      case 0:
        return Colors.grey[200]!;
      case 1:
        return Colors.cyan[100]!;
      case 2:
        return Colors.cyan[300]!;
      case 3:
        return Colors.cyan[500]!;
      case 4:
        return Colors.cyan[700]!;
      default:
        return Colors.grey[200]!;
    }
  }

  String _getMonthName(int monthIndex) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final currentMonth = DateTime.now().month - 1;
    final targetMonth = (currentMonth - (2 - monthIndex)) % 12;
    return months[targetMonth < 0 ? targetMonth + 12 : targetMonth];
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildWhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Accuracy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 80,
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: LineChartPainter(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildWhiteCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak Days',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text(
                      '5',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.orange, Colors.red],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Keep studying daily',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectBreakdown() {
    return _buildWhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subject Progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your progress breakdown by subject',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          // Pie chart representation
          Center(
            child: SizedBox(
              height: 200,
              width: 200,
              child: Stack(
                children: [
                  // Background circle
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                  ),
                  // Pie segments
                  ...subjectData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final subject = entry.value;
                    return _buildPieSegment(subject, index);
                  }),
                  // Center circle
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${_calculateOverallProgress()}%',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            'Overall',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subject list
          ...subjectData.map((subject) => _buildSubjectItem(subject)),
        ],
      ),
    );
  }

  Widget _buildPieSegment(SubjectData subject, int index) {
    final totalProgress = subjectData.fold<double>(
      0,
      (sum, s) => sum + s.progress,
    );
    final percentage = subject.progress / totalProgress;
    final startAngle =
        subjectData
            .take(index)
            .fold<double>(0, (sum, s) => sum + (s.progress / totalProgress)) *
        2 *
        3.14159;
    final sweepAngle = percentage * 2 * 3.14159;

    return CustomPaint(
      size: const Size(200, 200),
      painter: PieSegmentPainter(
        color: subject.color,
        startAngle: startAngle,
        sweepAngle: sweepAngle,
      ),
    );
  }

  Widget _buildSubjectItem(SubjectData subject) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: subject.color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: subject.progress / 100,
                          child: Container(
                            decoration: BoxDecoration(
                              color: subject.color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${subject.progress}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _calculateOverallProgress() {
    if (subjectData.isEmpty) return 0;
    final total = subjectData.fold<double>(
      0,
      (sum, subject) => sum + subject.progress,
    );
    return (total / subjectData.length).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          'Progress & Stats 📈',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Syllabus completed chart
            _buildSyllabusChart(),

            // Stats row (Accuracy and Streak Days)
            _buildStatsRow(),

            // Heatmap calendar
            _buildHeatmapCalendar(),

            // Subject breakdown
            _buildSubjectBreakdown(),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final String day;
  final double value;

  ChartData(this.day, this.value);
}

class SubjectData {
  final String name;
  final double progress;
  final Color color;

  SubjectData(this.name, this.progress, this.color);
}

class AreaChartPainter extends CustomPainter {
  final List<ChartData> data;
  final int? hoveredIndex;

  AreaChartPainter(this.data, [this.hoveredIndex]);

  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines first (background)
    _drawGridLines(canvas, size);

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2A7DE1).withOpacity(0.8),
          const Color(0xFF2BD46E).withOpacity(0.3),
          const Color(0xFF2BD46E).withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = const Color(0xFF2A7DE1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();
    final linePath = Path();

    final stepX = size.width / (data.length - 1);
    final maxValue = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    // Start from bottom left
    path.moveTo(0, size.height);
    linePath.moveTo(0, size.height - (data[0].value / maxValue) * size.height);

    // Create smooth curve using quadratic bezier curves
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].value / maxValue) * size.height;

      if (i == 0) {
        path.lineTo(x, y);
        linePath.moveTo(x, y);
      } else if (i == 1) {
        // First curve point
        final prevX = (i - 1) * stepX;
        final prevY =
            size.height - (data[i - 1].value / maxValue) * size.height;
        final controlX = (prevX + x) / 2;

        path.quadraticBezierTo(controlX, prevY, x, y);
        linePath.quadraticBezierTo(controlX, prevY, x, y);
      } else {
        // Smooth curve between points
        final prevX = (i - 1) * stepX;
        final prevY =
            size.height - (data[i - 1].value / maxValue) * size.height;
        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;

        path.quadraticBezierTo(controlX, controlY, x, y);
        linePath.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    // Close the area path
    path.lineTo(size.width, size.height);
    path.close();

    // Draw area
    canvas.drawPath(path, paint);

    // Draw line
    canvas.drawPath(linePath, linePaint);

    // Draw dots (no hover effects, consistent size)
    final dotPaint = Paint()
      ..color = const Color(0xFF2A7DE1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - (data[i].value / maxValue) * size.height;

      // Draw consistent dot size regardless of hover state
      canvas.drawCircle(Offset(x, y), 4.0, dotPaint);

      // Draw white center
      canvas.drawCircle(Offset(x, y), 2.0, Paint()..color = Colors.white);
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw vertical grid lines
    final stepX = size.width / (data.length - 1);
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw horizontal grid lines
    for (int i = 0; i <= 3; i++) {
      final y = (size.height / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Sample accuracy data points (matching syllabus trend)
    final accuracyData = [65.0, 70.0, 78.0, 75.0, 82.0, 88.0];
    final maxValue = 100.0; // Percentage
    final stepX = size.width / (accuracyData.length - 1);

    // Create gradient for line
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [const Color(0xFF2A7DE1), const Color(0xFF2BD46E)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    // Start from first point
    final firstY = size.height - (accuracyData[0] / maxValue) * size.height;
    path.moveTo(0, firstY);

    // Create smooth curve using quadratic bezier curves (same as syllabus chart)
    for (int i = 1; i < accuracyData.length; i++) {
      final x = i * stepX;
      final y = size.height - (accuracyData[i] / maxValue) * size.height;

      if (i == 1) {
        // First curve point
        final prevX = (i - 1) * stepX;
        final prevY =
            size.height - (accuracyData[i - 1] / maxValue) * size.height;
        final controlX = (prevX + x) / 2;

        path.quadraticBezierTo(controlX, prevY, x, y);
      } else {
        // Smooth curve between points
        final prevX = (i - 1) * stepX;
        final prevY =
            size.height - (accuracyData[i - 1] / maxValue) * size.height;
        final controlX = (prevX + x) / 2;
        final controlY = (prevY + y) / 2;

        path.quadraticBezierTo(controlX, controlY, x, y);
      }
    }

    canvas.drawPath(path, linePaint);

    // Draw dots
    final dotPaint = Paint()
      ..color = const Color(0xFF2A7DE1)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < accuracyData.length; i++) {
      final x = i * stepX;
      final y = size.height - (accuracyData[i] / maxValue) * size.height;

      canvas.drawCircle(Offset(x, y), 3.0, dotPaint);

      // Draw white center
      canvas.drawCircle(Offset(x, y), 1.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class PieSegmentPainter extends CustomPainter {
  final Color color;
  final double startAngle;
  final double sweepAngle;

  PieSegmentPainter({
    required this.color,
    required this.startAngle,
    required this.sweepAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10; // Leave some margin

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

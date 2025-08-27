import 'package:flutter/material.dart';

class CourseDetailsPage extends StatelessWidget {
  final String title;
  final double progress;

  const CourseDetailsPage({
    super.key,
    required this.title,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title), // course name in the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Course: $title",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text("Progress: ${(progress * 100).toStringAsFixed(0)}%"),
            const SizedBox(height: 40),

            // Placeholder for more details (to be implemented later)
            const Text(
              "More details about this course will be shown here...",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

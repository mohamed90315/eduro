import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screen/auth/login_screen.dart';
import 'screen/dashboard.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateBasedOnAuth(BuildContext context, {bool replace = false}) {
    final user = FirebaseAuth.instance.currentUser;
    final destination =
    user != null ? const DashboardScreen() : const LoginScreen();

    final route = MaterialPageRoute(builder: (_) => destination);
    if (replace) {
      Navigator.pushReplacement(context, route);
    } else {
      Navigator.push(context, route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Skip button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => _navigateBasedOnAuth(context, replace: true),
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ),
              ),
              // Content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Illustration
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        'assets/images/onboarding.png',
                        width: 260,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Master Your Study',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Roadmap',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Map out your academic journey, set smart goals, and track your progress seamlessly to stay on track and achieve success.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Indicator
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 5,
                    backgroundColor: Color(0xFF00838F),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Get Started Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _navigateBasedOnAuth(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00838F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.cyanAccent.withOpacity(0.3),
                    elevation: 6,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}

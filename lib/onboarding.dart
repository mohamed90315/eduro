import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screen/auth/login_screen.dart';
import 'screen/dashboard.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              // Skip button at the top right
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    // If the user is already signed in (persisted), take them
                    // directly to the dashboard. Otherwise go to the login screen.
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                      return;
                    }
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),

              // Main content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/onboarding.png',
                      width: 260,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Master Your Study',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Roadmap',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        'Map out your academic journey, set smart goals, and track your progress seamlessly to stay on track and achieve success.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Page indicator (single dot)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Get Started button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DashboardScreen(),
                        ),
                      );
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

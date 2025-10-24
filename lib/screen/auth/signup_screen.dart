import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _loading = false;
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;
  bool _confirmError = false;
  String _nameErrorText = '';
  String _emailErrorText = '';
  String _passwordErrorText = '';
  String _confirmErrorText = '';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint, bool error, String errorText) {
    return InputDecoration(
      hintText: hint,
      errorText: error ? errorText : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error ? Colors.red : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: error ? Colors.red : Colors.blue),
      ),
    );
  }

  Future<void> _signUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirm = _confirmController.text.trim();

    setState(() {
      _nameError = name.isEmpty;
      _emailError = email.isEmpty;
      _passwordError = password.isEmpty;
      _confirmError = confirm.isEmpty;
      _nameErrorText = name.isEmpty ? 'Please enter your full name' : '';
      _emailErrorText = email.isEmpty ? 'Please enter your email' : '';
      _passwordErrorText = password.isEmpty ? 'Please enter your password' : '';
      _confirmErrorText = confirm.isEmpty ? 'Please confirm your password' : '';
    });

    if (_nameError || _emailError || _passwordError || _confirmError) return;

    if (password.length < 6) {
      setState(() {
        _passwordError = true;
        _passwordErrorText = 'Password must be at least 6 characters';
      });
      return;
    }

    if (password != confirm) {
      setState(() {
        _passwordError = true;
        _confirmError = true;
        _passwordErrorText = 'Passwords do not match';
        _confirmErrorText = 'Passwords do not match';
      });
      return;
    }

    setState(() => _loading = true);
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;

      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'displayName': name,
          'email': user.email,
          'photoUrl': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        try {
          await user.updateDisplayName(name);
        } catch (_) {}
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Sign up failed')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 80),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Sign up to get started',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Full Name
              const Text('Full Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: _inputDecoration(
                    'Enter your full name', _nameError, _nameErrorText),
                onChanged: (value) {
                  if (_nameError && value.isNotEmpty) {
                    setState(() {
                      _nameError = false;
                      _nameErrorText = '';
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Email
              const Text('Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                decoration: _inputDecoration(
                    'your@email.com', _emailError, _emailErrorText),
                onChanged: (value) {
                  if (_emailError && value.isNotEmpty) {
                    setState(() {
                      _emailError = false;
                      _emailErrorText = '';
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Password
              const Text('Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(
                    '********', _passwordError, _passwordErrorText),
                onChanged: (value) {
                  if (_passwordError && value.isNotEmpty) {
                    setState(() {
                      _passwordError = false;
                      _passwordErrorText = '';
                    });
                  }
                },
              ),
              const SizedBox(height: 20),

              // Confirm Password
              const Text('Confirm Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmController,
                obscureText: true,
                decoration: _inputDecoration(
                    '********', _confirmError, _confirmErrorText),
                onChanged: (value) {
                  if (_confirmError && value.isNotEmpty) {
                    setState(() {
                      _confirmError = false;
                      _confirmErrorText = '';
                    });
                  }
                },
              ),
              const SizedBox(height: 30),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00838F),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Colors.cyanAccent.withOpacity(0.3),
                    elevation: 6,
                  ),
                  child: _loading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Switch to Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(color: Color(0xFF00838F)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Divider
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Google Sign In
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Add Google sign-in logic here
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/google_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Continue with Google',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

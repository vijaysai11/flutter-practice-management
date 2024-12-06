import 'package:flutter/material.dart';
import 'package:practice_management/screens/home_screen.dart';
import 'package:practice_management/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _loginMessage = '';
  bool _isLoading = false;

  Future<void> _performMicrosoftLogin() async {
    setState(() {
      _isLoading = true;
      _loginMessage = 'Signing in...';
    });

    try {
      final authService = MicrosoftAuthService();
      final token = await authService.login();

      if (token != null) {
        // Navigate to home if login is successful
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const MyHomePage(title: 'Practice Management'),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _loginMessage = 'Login Failed. Please try again.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loginMessage = 'An error occurred during login: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF005EA6),
              Color(0xFF0078D4),
              Color(0xFF00A4EF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Microsoft logo or a custom image
            Container(
  color: Colors.transparent, // Ensure no background color
  child: Image.asset(
    'assets/images/images.png',
    width: 120,
    height: 120,
  ),

),
              const SizedBox(height: 40),
              const Text(
                'Sign in with Microsoft',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                  : ElevatedButton(
                      onPressed: _performMicrosoftLogin,
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.white, // Button color
                        // onPrimary: Colors.black, // Text color
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Login with Microsoft',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Text(
                _loginMessage,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

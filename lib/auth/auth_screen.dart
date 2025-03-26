import 'package:flutter/material.dart';
import 'login_form.dart';
import 'register_form.dart';
import '../theme/theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    elevation: 8,
                    shadowColor: Colors.black45,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppTheme.lightest.withOpacity(0.7),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppTheme.light,
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.restaurant_menu,
                              size: 60,
                              color: AppTheme.darkest,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            _isLogin ? 'Welcome Back!' : 'Create Account',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkest,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _isLogin ? const LoginForm() : const RegisterForm(),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed: _toggleAuthMode,
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.darker,
                            ),
                            child: Text(
                              _isLogin
                                  ? 'New user? Create an account'
                                  : 'Already have an account? Log in',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
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
        ),
      ),
    );
  }
}

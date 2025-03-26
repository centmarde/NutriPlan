import 'package:flutter/material.dart';
import '../router/routes.dart';
import '../theme/theme.dart';
import '../services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  final AuthService _authService = AuthService();
  String? _errorMessage;
  double _passwordStrength = 0;
  String _passwordStrengthText = 'Enter a password';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  void _checkPasswordStrength() {
    String password = _passwordController.text;
    double strength = 0;

    if (password.isEmpty) {
      _passwordStrengthText = 'Enter a password';
      _passwordStrengthColor = Colors.grey;
      strength = 0;
    } else {
      if (password.length < 6) {
        _passwordStrengthText = 'Too short';
        _passwordStrengthColor = Colors.red;
        strength = 0.2;
      } else {
        // Check for mixture of character types
        if (password.contains(RegExp(r'[A-Z]'))) strength += 0.2;
        if (password.contains(RegExp(r'[a-z]'))) strength += 0.2;
        if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
        if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')))
          strength += 0.2;
        if (password.length > 8) strength += 0.2;

        // Set text and color based on strength
        if (strength < 0.4) {
          _passwordStrengthText = 'Weak';
          _passwordStrengthColor = Colors.red;
        } else if (strength < 0.7) {
          _passwordStrengthText = 'Medium';
          _passwordStrengthColor = Colors.orange;
        } else {
          _passwordStrengthText = 'Strong';
          _passwordStrengthColor = Colors.green;
        }
      }
    }

    setState(() {
      _passwordStrength = strength;
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use the simplified registration method without fullName
      await _authService.registerUser(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to home screen after successful registration
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      setState(() {
        _errorMessage = _getFirebaseErrorMessage(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getFirebaseErrorMessage(String error) {
    if (error.contains('email-already-in-use')) {
      return 'The email address is already in use.';
    } else if (error.contains('invalid-email')) {
      return 'The email address is badly formatted.';
    } else if (error.contains('weak-password')) {
      return 'The password is too weak.';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled.';
    }
    return 'An error occurred. Please try again.';
  }

  @override
  void dispose() {
    _passwordController.removeListener(_checkPasswordStrength);
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            decoration: _buildInputDecoration('Email', Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            decoration: _buildPasswordInputDecoration(
              'Password',
              Icons.lock,
              _passwordVisible,
              () {
                setState(() {
                  _passwordVisible = !_passwordVisible;
                });
              },
            ),
            obscureText: !_passwordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 4),
          // Password strength indicator
          LinearProgressIndicator(
            value: _passwordStrength,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
            minHeight: 5,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
            child: Text(
              _passwordStrengthText,
              style: TextStyle(color: _passwordStrengthColor, fontSize: 12),
            ),
          ),
          TextFormField(
            controller: _confirmPasswordController,
            decoration: _buildPasswordInputDecoration(
              'Confirm Password',
              Icons.lock_outline,
              _confirmPasswordVisible,
              () {
                setState(() {
                  _confirmPasswordVisible = !_confirmPasswordVisible;
                });
              },
            ),
            obscureText: !_confirmPasswordVisible,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.darker,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 3,
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'REGISTER',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.darker),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.light),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.darkest, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppTheme.darker),
      fillColor: AppTheme.lightest.withOpacity(0.3),
      filled: true,
    );
  }

  InputDecoration _buildPasswordInputDecoration(
    String label,
    IconData icon,
    bool isVisible,
    VoidCallback toggleVisibility,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.darker),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.light),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.light),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.darkest, width: 2),
      ),
      prefixIcon: Icon(icon, color: AppTheme.darker),
      suffixIcon: IconButton(
        icon: Icon(
          isVisible ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.darker,
        ),
        onPressed: toggleVisibility,
      ),
      fillColor: AppTheme.lightest.withOpacity(0.3),
      filled: true,
    );
  }
}

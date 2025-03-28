import 'package:flutter/material.dart';
import '../router/routes.dart';
import '../theme/theme.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or icon with enhanced styling
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppTheme.lightest,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                        spreadRadius: 1,
                      ),
                    ],
                    border: Border.all(color: AppTheme.light, width: 3),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    size: 80,
                    color: AppTheme.darkest,
                  ),
                ),
                const SizedBox(height: 40),
                // App Title
                Text('DailyBite', style: AppTheme.headingStyle),
                const SizedBox(height: 20),
                // App description
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    'Your personal nutrition assistant for healthier meal planning',
                    textAlign: TextAlign.center,
                    style: AppTheme.subheadingStyle,
                  ),
                ),
                const SizedBox(height: 60),
                // Action buttons with improved styling
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.auth);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lightest,
                    foregroundColor: AppTheme.darkest,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Learn More functionality coming soon!'),
                        backgroundColor: AppTheme.darker,
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.lightest,
                  ),
                  child: const Text(
                    'Learn More',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

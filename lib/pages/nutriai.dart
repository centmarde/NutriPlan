import 'package:flutter/material.dart';
import '../layout/layout.dart';
import '../common/navbar.dart';
import '../theme/theme.dart';
import '../router/routes.dart'; // Add this import

class AIScreen extends StatefulWidget {
  const AIScreen({Key? key}) : super(key: key);

  @override
  State<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Nutrition AI',
      initialTabIndex: NavBarItems.ai,
      currentRoute: AppRoutes.nutriai, // Changed to use AppRoutes directly
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Nutrition Assistant',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightest,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.smart_toy,
                            size: 64,
                            color: AppTheme.darker,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Ask me anything about nutrition',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Get personalized meal recommendations, nutritional advice, and more',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Ask a question...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send, color: AppTheme.darker),
                          onPressed: () {
                            // TODO: Implement AI query functionality
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

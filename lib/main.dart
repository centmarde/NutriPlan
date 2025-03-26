import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:io';
import 'router/app_router.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    stderr.writeln('===== FIREBASE INITIALIZATION =====');
    stderr.writeln('Firebase successfully initialized');
    stderr.writeln('==================================');
  } catch (e) {
    stderr.writeln('===== FIREBASE INITIALIZATION ERROR =====');
    stderr.writeln(e.toString());
    stderr.writeln('=======================================');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPlan',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppTheme.darkest),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: AppRouter.generateRoute,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        // Add global error handling for the app
        return ErrorHandler(child: child ?? const SizedBox());
      },
    );
  }
}

class ErrorHandler extends StatelessWidget {
  final Widget child;

  const ErrorHandler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: Colors.white, child: child);
  }
}

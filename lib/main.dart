import 'package:flutter/material.dart';
import 'router/index.dart';
import 'auth/auth_screen.dart'; // Add explicit import for AuthScreen

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NutriPlan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Change initialRoute to the root route
      initialRoute: AppRoutes.root,
      onGenerateRoute: AppRouter.generateRoute,
      // Add a fallback route in case the route generation fails
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder:
              (_) =>
                  const Scaffold(body: Center(child: Text('Route not found'))),
        );
      },
    );
  }
}

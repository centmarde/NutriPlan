import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';
import '../landing/landing_screen.dart'; // Add import for the landing page
import 'routes.dart';
import 'dart:io'; // Add import for stderr

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    // Add debug prints for route generation
    stderr.writeln('==== Router Debug ====');
    stderr.writeln('Settings: $settings');
    stderr.writeln('Route name: ${settings.name}');
    stderr.writeln('Arguments: ${settings.arguments}');

    // Add null safety for route name
    final routeName = settings.name ?? AppRoutes.auth;
    stderr.writeln('Using route name: $routeName');

    switch (routeName) {
      case AppRoutes.root:
        stderr.writeln('Navigating to Landing screen');
        return MaterialPageRoute(builder: (_) => const LandingScreen());
      case AppRoutes.auth:
        stderr.writeln('Navigating to Auth screen');
        return MaterialPageRoute(builder: (_) => const AuthScreen());
      case AppRoutes.home:
        stderr.writeln('Navigating to Home screen');
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      // Add more routes as needed
      default:
        stderr.writeln('⚠️ Warning: No route defined for $routeName');
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text('No route defined for $routeName')),
              ),
        );
    }
  }
}

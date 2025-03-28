import 'package:flutter/material.dart';
import '../auth/auth_screen.dart';
import '../home/home_screen.dart';
import '../landing/landing_screen.dart';
import '../pages/schedule.dart';
import '../pages/nutriai.dart'; // Fixed case sensitivity in import path
import '../pages/planner.dart'; // Add import for planner screen
import '../pages/profiles.dart'; // Add import for profiles screen
import 'routes.dart';
import 'router_guard.dart';
import 'auth_route_guards.dart';
import 'dart:io';

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

    // Check if route needs protection or redirection
    Widget pageWidget;
    bool isProtected = RouterGuard.isProtectedRoute(routeName);
    bool isPublic = RouterGuard.isPublicRoute(routeName);

    switch (routeName) {
      case AppRoutes.root:
        stderr.writeln('Navigating to Landing screen');
        pageWidget = const LandingScreen();
        break;
      case AppRoutes.auth:
        stderr.writeln('Navigating to Auth screen');
        pageWidget = const AuthScreen();
        break;
      case AppRoutes.home:
        stderr.writeln('Navigating to Home screen');
        pageWidget = const HomeScreen();
        break;
      case AppRoutes.schedule:
        stderr.writeln('Navigating to Schedule screen');
        pageWidget = const ScheduleScreen();
        break;
      case AppRoutes.nutriai: // Add case for AI route
        stderr.writeln('Navigating to AI screen');
        pageWidget = const AIScreen();
        break;
      case AppRoutes.planner: // Add case for planner route
        stderr.writeln('Navigating to Planner screen');
        pageWidget = const PlannerScreen();
        break;
      case AppRoutes.profiles: // Add case for profiles route
        stderr.writeln('Navigating to Profiles screen');
        pageWidget = const ProfilesScreen();
        break;
      // Add more routes as needed
      default:
        stderr.writeln('⚠️ Warning: No route defined for $routeName');
        pageWidget = Scaffold(
          body: Center(child: Text('No route defined for $routeName')),
        );
        break;
    }

    // Apply protection as needed
    if (isProtected) {
      stderr.writeln('Applying protection to route: $routeName');
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) => ProtectedRoute(
              redirectRoute: AppRoutes.auth,
              child: pageWidget,
            ),
      );
    } else if (isPublic) {
      stderr.writeln('Applying public guard to route: $routeName');
      return MaterialPageRoute(
        settings: settings,
        builder:
            (_) =>
                PublicRoute(redirectRoute: AppRoutes.home, child: pageWidget),
      );
    } else {
      // For routes that aren't specifically protected or public
      return MaterialPageRoute(settings: settings, builder: (_) => pageWidget);
    }
  }
}

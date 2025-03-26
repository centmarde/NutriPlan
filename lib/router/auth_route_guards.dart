import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'routes.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;
  final String redirectRoute;

  const ProtectedRoute({
    Key? key,
    required this.child,
    this.redirectRoute = AppRoutes.auth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<bool>(
      stream: authService.authStateChanges.map((user) => user != null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isAuthenticated = snapshot.data ?? false;

        if (!isAuthenticated) {
          // User is not authenticated, redirect to public route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(redirectRoute);
          });
          // Return loading while redirecting
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}

class PublicRoute extends StatelessWidget {
  final Widget child;
  final String redirectRoute;

  const PublicRoute({
    Key? key,
    required this.child,
    this.redirectRoute = AppRoutes.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return StreamBuilder<bool>(
      stream: authService.authStateChanges.map((user) => user != null),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final bool isAuthenticated = snapshot.data ?? false;

        if (isAuthenticated) {
          // User is authenticated, redirect to protected route
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacementNamed(redirectRoute);
          });
          // Return loading while redirecting
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // User is not authenticated, show the public content
        return child;
      },
    );
  }
}

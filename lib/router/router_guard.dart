import 'routes.dart';
import '../services/auth_service.dart';
import 'dart:io'; // Add import for stderr

class RouterGuard {
  static final AuthService _authService = AuthService();

  // Determine initial route based on authentication status
  static Future<String> determineInitialRoute() async {
    stderr.writeln('==== RouterGuard Debug ====');
    stderr.writeln('Determining initial route');
    stderr.writeln('Timestamp: ${DateTime.now()}');

    final bool isAuthenticated = _authService.currentUser != null;
    stderr.writeln('User authenticated: $isAuthenticated');

    // Return appropriate initial route based on auth state
    final route = isAuthenticated ? AppRoutes.home : AppRoutes.auth;
    stderr.writeln('Selected initial route: $route');
    stderr.writeln('Initial Route Location: $route');
    return route;
  }

  // Check if route should be protected
  static bool isProtectedRoute(String routeName) {
    return RouteType.protectedRoutes.contains(routeName);
  }

  // Check if route is public only
  static bool isPublicRoute(String routeName) {
    return RouteType.publicRoutes.contains(routeName);
  }

  // Determine if user can access a route
  static bool canNavigateToRoute(String routeName) {
    final bool isAuthenticated = _authService.currentUser != null;

    if (isProtectedRoute(routeName) && !isAuthenticated) {
      stderr.writeln('Access denied: Protected route requires authentication');
      return false;
    }

    if (isPublicRoute(routeName) && isAuthenticated) {
      stderr.writeln(
        'Access denied: Public route not accessible when authenticated',
      );
      return false;
    }

    return true;
  }

  // Get redirect route based on current authentication state
  static String getRedirectRoute() {
    final bool isAuthenticated = _authService.currentUser != null;
    return isAuthenticated ? AppRoutes.home : AppRoutes.auth;
  }
}

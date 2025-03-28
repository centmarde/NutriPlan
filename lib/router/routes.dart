class AppRoutes {
  static const String root = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String schedule = '/schedule';
  static const String nutriai = '/ai';
  static const String planner = '/planner';
  static const String profiles = '/profiles'; // Add profiles route
  // Add more routes as needed
}

// Add route categories for protected/public routes
class RouteType {
  static const publicRoutes = [AppRoutes.root, AppRoutes.auth];
  static const protectedRoutes = [
    AppRoutes.home,
    AppRoutes.settings,
    AppRoutes.schedule,
    AppRoutes.nutriai,
    AppRoutes.planner,
    AppRoutes.profiles, // Add profiles to protected routes
  ];
}

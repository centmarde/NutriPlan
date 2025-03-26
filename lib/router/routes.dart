class AppRoutes {
  static const String root = '/';
  static const String auth = '/auth';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';
  // Add more routes as needed
}

// Add route categories for protected/public routes
class RouteType {
  static const publicRoutes = [AppRoutes.root, AppRoutes.auth];
  static const protectedRoutes = [
    AppRoutes.home,
    AppRoutes.profile,
    AppRoutes.settings,
  ];
}

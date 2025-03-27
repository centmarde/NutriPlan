import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../theme/theme.dart';
import '../router/routes.dart';

// Define constants for tab indices
class NavBarItems {
  static const int ai = 0;
  static const int planner = 1;
  static const int home = 2;
  static const int schedule = 3;
  static const int profile = 4;

  // Map indices to route paths
  static String getRouteForIndex(int index) {
    switch (index) {
      case ai:
        return '/ai';
      case planner:
        return AppRoutes.planner;
      case home:
        return AppRoutes.home;
      case schedule:
        return '/schedule';
      case profile:
        return AppRoutes.profile;
      default:
        return AppRoutes.home;
    }
  }

  // Get display names for each tab
  static String getDisplayNameForIndex(int index) {
    switch (index) {
      case ai:
        return 'AI';
      case planner:
        return 'Planner';
      case home:
        return 'Home';
      case schedule:
        return 'Schedule';
      case profile:
        return 'Profile';
      default:
        return '';
    }
  }

  // Map route paths to indices - add this new method
  static int getIndexForRoute(String route) {
    switch (route) {
      case AppRoutes.nutriai: // Use constant from AppRoutes
        return ai;
      case AppRoutes.planner:
        return planner;
      case AppRoutes.home:
        return home;
      case AppRoutes.schedule:
        return schedule;
      case AppRoutes.profile:
        return profile;
      default:
        return home;
    }
  }
}

class CustomNavBar extends StatefulWidget {
  final int activeIndex;
  final Function(int) onTap;

  const CustomNavBar({Key? key, required this.activeIndex, required this.onTap})
    : super(key: key);

  @override
  State<CustomNavBar> createState() => _CustomNavBarState();
}

class _CustomNavBarState extends State<CustomNavBar> {
  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
      activeIcons: const [
        Icon(Icons.smart_toy, color: Colors.white, size: 24),
        Icon(Icons.calendar_today, color: Colors.white, size: 24),
        Icon(Icons.home, color: Colors.white, size: 24),
        Icon(Icons.schedule, color: Colors.white, size: 24),
        Icon(Icons.person, color: Colors.white, size: 24),
      ],
      inactiveIcons: const [
        Text(
          "AI",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Planner",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Home",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Schedule",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Profile",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
      color: Colors.white,
      circleColor: AppTheme.darker,
      height: 60,
      circleWidth: 60,
      activeIndex: widget.activeIndex,
      onTap: widget.onTap,
      padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0),
      cornerRadius: const BorderRadius.only(
        topLeft: Radius.circular(8),
        topRight: Radius.circular(8),
      ),
      shadowColor: AppTheme.darkest.withOpacity(0.3),
      elevation: 10,
    );
  }
}

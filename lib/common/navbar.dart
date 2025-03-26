import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import '../theme/theme.dart';
import '../router/routes.dart';

// Define constants for tab indices
class NavBarItems {
  static const int home = 0;
  static const int meals = 1;
  static const int progress = 2;
  static const int shop = 3;
  static const int profile = 4;

  // Map indices to route paths
  static String getRouteForIndex(int index) {
    switch (index) {
      case home:
        return AppRoutes.home;
      case meals:
        return '/meals'; // Add this route to AppRoutes if needed
      case progress:
        return '/progress'; // Add this route to AppRoutes if needed
      case shop:
        return '/shop'; // Add this route to AppRoutes if needed
      case profile:
        return AppRoutes.profile;
      default:
        return AppRoutes.home;
    }
  }

  // Get display names for each tab
  static String getDisplayNameForIndex(int index) {
    switch (index) {
      case home:
        return 'Home';
      case meals:
        return 'Meals';
      case progress:
        return 'Progress';
      case shop:
        return 'Shop';
      case profile:
        return 'Profile';
      default:
        return '';
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
        Icon(Icons.home, color: Colors.white, size: 24),
        Icon(Icons.restaurant, color: Colors.white, size: 24),
        Icon(Icons.bar_chart, color: Colors.white, size: 24),
        Icon(Icons.shopping_cart, color: Colors.white, size: 24),
        Icon(Icons.person, color: Colors.white, size: 24),
      ],
      inactiveIcons: const [
        Text(
          "Home",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Meals",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Progress",
          style: TextStyle(
            color: AppTheme.darkest,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "Shop",
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

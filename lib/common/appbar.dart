import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../router/routes.dart';
import '../common/navbar.dart';
import '../services/auth_service.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final String? currentRoute;

  const CustomAppBar({
    Key? key,
    this.title = 'NutriPlan',
    this.actions,
    this.currentRoute,
  }) : super(key: key);

  Widget _buildRouteIndicator() {
    if (currentRoute == null) return const SizedBox();

    String displayRoute = '';

    // First try to get the display name from NavBarItems if it's a navbar route
    for (int i = 0; i < 5; i++) {
      if (currentRoute == NavBarItems.getRouteForIndex(i)) {
        displayRoute = NavBarItems.getDisplayNameForIndex(i);
        break;
      }
    }

    // If we didn't find a match, use our existing switch
    if (displayRoute.isEmpty) {
      switch (currentRoute) {
        case AppRoutes.home:
          displayRoute = 'Home';
          break;
        case AppRoutes.profiles:
          displayRoute = 'Profiles';
          break;
        case AppRoutes.settings:
          displayRoute = 'Settings';
          break;
        case AppRoutes.auth:
          displayRoute = 'Login';
          break;
        default:
          displayRoute = currentRoute!.replaceAll('/', '');
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        displayRoute,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create a new actions list that includes our route indicator
    final List<Widget> updatedActions = [
      _buildRouteIndicator(),
      ...(actions ?? []),
      // Add logout button to the actions area where it belongs
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () => _showLogoutConfirmationDialog(context),
        tooltip: 'Log out',
      ),
    ];

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: updatedActions,
      // Use a proper back button when navigation is possible
      leading:
          Navigator.canPop(context)
              ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              )
              : null,
      flexibleSpace: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
      ),
      elevation: 4,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Log Out'),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop(); // Close dialog
                  try {
                    final authService = AuthService();
                    await authService.signOut();

                    // Navigate to login screen and clear back stack
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        '/', // Replace with your actual login route
                        (route) => false,
                      );
                    }
                  } catch (e) {
                    // Show error message
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error signing out: $e')),
                      );
                    }
                  }
                },
                child: const Text('Log Out'),
              ),
            ],
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

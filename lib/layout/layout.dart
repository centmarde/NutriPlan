import 'package:flutter/material.dart';
import '../common/appbar.dart';
import '../common/navbar.dart';
import '../theme/theme.dart';

class AppLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;
  final bool showAppBar;
  final bool showNavBar;
  final int initialTabIndex;
  final String? currentRoute;

  const AppLayout({
    Key? key,
    required this.child,
    this.title = 'DailyBite',
    this.actions,
    this.showAppBar = true,
    this.showNavBar = true,
    this.initialTabIndex = 0,
    this.currentRoute,
  }) : super(key: key);

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  late int _activeIndex;
  late String _currentRoute;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialTabIndex;
    // Initialize the route - either from props or derived from the active tab index
    _currentRoute =
        widget.currentRoute ?? NavBarItems.getRouteForIndex(_activeIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.showAppBar
              ? CustomAppBar(
                title: widget.title,
                actions: widget.actions,
                currentRoute: _currentRoute,
              )
              : null,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.lightest],
          ),
        ),
        child: widget.child,
      ),
      bottomNavigationBar:
          widget.showNavBar
              ? CustomNavBar(
                activeIndex: _activeIndex,
                onTap: (index) {
                  // Only navigate if selecting a different tab
                  if (index != _activeIndex) {
                    // Get the route path for the selected tab
                    final String routePath = NavBarItems.getRouteForIndex(
                      index,
                    );

                    // Navigate to the new route using pushReplacementNamed
                    // This replaces the current page in the navigation stack
                    Navigator.of(context).pushReplacementNamed(routePath);

                    // Update local state
                    setState(() {
                      _activeIndex = index;
                      _currentRoute = routePath;
                    });
                  }
                },
              )
              : null,
    );
  }
}

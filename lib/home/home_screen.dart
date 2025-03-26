import 'package:flutter/material.dart';
import '../theme/theme.dart';
import '../layout/layout.dart';
import 'swiper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppLayout(
      title: 'NutriPlan',
      initialTabIndex: 2, // Home tab is selected
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [const Expanded(child: MealSwiper())],
      ),
    );
  }
}

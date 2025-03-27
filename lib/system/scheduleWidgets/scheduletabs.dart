import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

enum ScheduleFilter { all, today, week, month }

class ScheduleTabs extends StatefulWidget {
  final ScheduleFilter activeFilter;
  final Function(ScheduleFilter) onFilterChanged;

  const ScheduleTabs({
    Key? key,
    required this.activeFilter,
    required this.onFilterChanged,
  }) : super(key: key);

  @override
  State<ScheduleTabs> createState() => _ScheduleTabsState();
}

class _ScheduleTabsState extends State<ScheduleTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.activeFilter.index,
    );

    _tabController.addListener(() {
      if (_tabController.indexIsChanging ||
          _tabController.animation!.value == _tabController.index) {
        widget.onFilterChanged(ScheduleFilter.values[_tabController.index]);
      }
    });
  }

  @override
  void didUpdateWidget(ScheduleTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeFilter.index != _tabController.index) {
      _tabController.animateTo(widget.activeFilter.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Theme.of(context).primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Theme.of(context).primaryColor,
        indicatorWeight: 3,
        labelStyle: const TextStyle(fontWeight: FontWeight.bold),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Today'),
          Tab(text: 'This Week'),
          Tab(text: 'This Month'),
        ],
      ),
    );
  }
}

// Helper function to filter meals based on selected tab
List<QueryDocumentSnapshot> filterMealsBySchedule(
  List<QueryDocumentSnapshot> meals,
  ScheduleFilter filter,
) {
  if (filter == ScheduleFilter.all) {
    return meals;
  }

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  final startOfMonth = DateTime(now.year, now.month, 1);

  return meals.where((meal) {
    final mealData = meal.data() as Map<String, dynamic>;
    if (mealData['scheduledAt'] == null) return false;

    final scheduledDate = (mealData['scheduledAt'] as Timestamp).toDate();

    switch (filter) {
      case ScheduleFilter.today:
        final mealDate = DateTime(
          scheduledDate.year,
          scheduledDate.month,
          scheduledDate.day,
        );
        return mealDate.isAtSameMomentAs(today);

      case ScheduleFilter.week:
        return scheduledDate.isAfter(
              startOfWeek.subtract(const Duration(seconds: 1)),
            ) &&
            scheduledDate.isBefore(startOfWeek.add(const Duration(days: 7)));

      case ScheduleFilter.month:
        return scheduledDate.isAfter(
              startOfMonth.subtract(const Duration(seconds: 1)),
            ) &&
            scheduledDate.isBefore(DateTime(now.year, now.month + 1, 0));

      default:
        return true;
    }
  }).toList();
}

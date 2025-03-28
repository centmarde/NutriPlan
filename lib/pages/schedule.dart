import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../common/navbar.dart';
import '../theme/theme.dart';
import '../layout/layout.dart';
import '../services/auth_service.dart';
import '../system/scheduleWidgets/scheduleview.dart';
import '../system/scheduleWidgets/scheduletabs.dart';
import '../system/scheduleWidgets/schedulesearch.dart';
import '../system/scheduler/view_notif.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Stream<QuerySnapshot> _mealsStream;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isProcessing = false;
  final MealNotificationScheduler _notificationScheduler =
      MealNotificationScheduler();

  // Filter and search state
  ScheduleFilter _activeFilter = ScheduleFilter.all;
  String _searchQuery = '';
  List<QueryDocumentSnapshot> _allMeals = [];
  List<QueryDocumentSnapshot> _filteredMeals = [];

  @override
  void initState() {
    super.initState();
    _initMealsStream();
    _notificationScheduler.scheduleMealNotifications();
  }

  Future<void> _initMealsStream() async {
    try {
      final user = _authService.currentUser;
      if (user != null) {
        setState(() {
          _mealsStream =
              FirebaseFirestore.instance
                  .collection('meals')
                  .where('userId', isEqualTo: user.uid)
                  .where('isScheduled', isEqualTo: true)
                  .orderBy('scheduledAt', descending: false)
                  .snapshots();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              'You need to be logged in to view your scheduled meals';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading scheduled meals: ${e.toString()}';
        _isLoading = false;
      });
      print('Error in _initMealsStream: $e');
    }
  }

  void _handleFilterChange(ScheduleFilter filter) {
    setState(() {
      _activeFilter = filter;
      _applyFilters();
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _clearSearch() {
    setState(() {
      _searchQuery = '';
      _applyFilters();
    });
  }

  void _applyFilters() {
    // First filter by tab (schedule period)
    var tabFiltered = filterMealsBySchedule(_allMeals, _activeFilter);

    // Then filter by search query
    _filteredMeals = filterMealsBySearch(tabFiltered, _searchQuery);
  }

  Future<void> _deleteMeal(String documentId) async {
    print('DEBUG: _deleteMeal called with document ID: $documentId');
    if (documentId.isEmpty) {
      print('DEBUG: Attempted to delete with empty document ID');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Simple direct deletion approach
      await _firestore.collection('meals').doc(documentId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Meal deleted successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('DEBUG: Error deleting meal: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete meal: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _rescheduleMeal(String mealId, DateTime newScheduledTime) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      await _firestore.collection('meals').doc(mealId).update({
        'scheduledAt': Timestamp.fromDate(newScheduledTime),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal rescheduled successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error rescheduling meal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reschedule meal'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Schedule your Meal',
      initialTabIndex: NavBarItems.schedule,
      currentRoute: NavBarItems.getRouteForIndex(NavBarItems.schedule),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Search bar
                ScheduleSearch(
                  onSearch: _handleSearch,
                  onClear: _clearSearch,
                  initialSearchText: _searchQuery,
                ),

                // Tabs for filtering
                ScheduleTabs(
                  activeFilter: _activeFilter,
                  onFilterChanged: _handleFilterChange,
                ),

                // Expanded area for the content
                Expanded(child: _buildContent()),
              ],
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initMealsStream,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _mealsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState();
        }

        // Store all meals and apply filters
        _allMeals = snapshot.data!.docs;

        // Log document IDs and internal meal IDs to verify
        for (var meal in _allMeals) {
          final data = meal.data() as Map<String, dynamic>;
          final internalId = data['mealId'] as String?;
          print(
            'DEBUG: Meal document ID: ${meal.id}, Internal mealId: $internalId',
          );
        }

        _applyFilters();

        // Show empty search results message if needed
        if (_filteredMeals.isEmpty) {
          return _buildNoResultsState();
        }

        // Pass the filtered meals to the ScheduleView widget
        return ScheduleView(
          meals: _filteredMeals,
          onDelete: _deleteMeal,
          onReschedule: _rescheduleMeal,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today, size: 72, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No scheduled meals found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Save meals and schedule them to see them here',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to search or discover page
              Navigator.of(context).pushNamed('/home');
            },
            child: const Text('Find Meals'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            'No matching meals found',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              _activeFilter != ScheduleFilter.all
                  ? 'Try changing the time filter or search term'
                  : 'Try modifying your search term',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              setState(() {
                _activeFilter = ScheduleFilter.all;
                _searchQuery = '';
                _applyFilters();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
          ),
        ],
      ),
    );
  }
}

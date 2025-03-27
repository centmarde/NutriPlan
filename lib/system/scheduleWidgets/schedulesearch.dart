import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleSearch extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;
  final String initialSearchText;

  const ScheduleSearch({
    Key? key,
    required this.onSearch,
    required this.onClear,
    this.initialSearchText = '',
  }) : super(key: key);

  @override
  State<ScheduleSearch> createState() => _ScheduleSearchState();
}

class _ScheduleSearchState extends State<ScheduleSearch> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchText);
    _showClearButton = widget.initialSearchText.isNotEmpty;

    _searchController.addListener(() {
      setState(() {
        _showClearButton = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onClear();
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.grey.shade200,
              ),
              child: TextField(
                controller: _searchController,
                focusNode: _focusNode,
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  hintText: 'Search scheduled meals...',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 8, left: 16),
                  prefixIcon: Icon(Icons.search, color: Colors.grey.shade600),
                  suffixIcon:
                      _showClearButton
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: _clearSearch,
                          )
                          : null,
                ),
                onChanged: widget.onSearch,
                textInputAction: TextInputAction.search,
                onSubmitted: widget.onSearch,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to filter meals by search query
List<QueryDocumentSnapshot> filterMealsBySearch(
  List<QueryDocumentSnapshot> meals,
  String searchQuery,
) {
  if (searchQuery.isEmpty) {
    return meals;
  }

  final query = searchQuery.toLowerCase();

  return meals.where((meal) {
    final mealData = meal.data() as Map<String, dynamic>;

    // Search in name, category, and area
    final name = (mealData['name'] ?? '').toString().toLowerCase();
    final category = (mealData['category'] ?? '').toString().toLowerCase();
    final area = (mealData['area'] ?? '').toString().toLowerCase();

    // Search in ingredients
    bool matchesIngredients = false;
    if (mealData['ingredients'] != null && mealData['ingredients'] is Map) {
      final ingredients = mealData['ingredients'] as Map;
      matchesIngredients = ingredients.keys.any(
        (key) => key.toString().toLowerCase().contains(query),
      );
    }

    return name.contains(query) ||
        category.contains(query) ||
        area.contains(query) ||
        matchesIngredients;
  }).toList();
}

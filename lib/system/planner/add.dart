import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:nutriplan/theme/theme.dart';

class AddMealDialog extends StatefulWidget {
  final String userId;
  final DateTime selectedDate;

  const AddMealDialog({
    Key? key,
    required this.userId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<AddMealDialog> createState() => _AddMealDialogState();
}

class _AddMealDialogState extends State<AddMealDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _searchController = TextEditingController();

  DateTime _scheduledDateTime = DateTime.now();
  bool _isSearching = false;
  List<dynamic> _searchResults = [];
  Map<String, dynamic>? _selectedMeal;

  @override
  void initState() {
    super.initState();
    _scheduledDateTime = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      DateTime.now().hour,
      DateTime.now().minute,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchMeals(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://www.themealdb.com/api/json/v1/1/search.php?s=$query',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _searchResults = data['meals'] ?? [];
          _isSearching = false;
        });
      } else {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    } catch (e) {
      print('Error searching meals: $e');
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
    }
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final mealData = {
        'userId': widget.userId,
        'name': _nameController.text.trim(),
        'scheduledAt': Timestamp.fromDate(_scheduledDateTime),
        'createdAt': Timestamp.now(),
      };

      // Add additional data if a meal was selected from the search
      if (_selectedMeal != null) {
        mealData.addAll({
          'description': _selectedMeal!['strMeal'] ?? '',
          'category': _selectedMeal!['strCategory'],
          'area': _selectedMeal!['strArea'],
          'instructions': _selectedMeal!['strInstructions'],
          'imageUrl': _selectedMeal!['strMealThumb'],
          'externalId': _selectedMeal!['idMeal'],
        });
      }

      await FirebaseFirestore.instance.collection('meals').add(mealData);
      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      print('Error saving meal: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save meal')));
    }
  }

  void _selectMeal(dynamic meal) {
    setState(() {
      _selectedMeal = meal;
      _nameController.text = meal['strMeal'] ?? '';
    });
  }

  Future<void> _pickDateTime() async {
    // Show time picker
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledDateTime),
    );

    if (timeOfDay != null) {
      setState(() {
        _scheduledDateTime = DateTime(
          _scheduledDateTime.year,
          _scheduledDateTime.month,
          _scheduledDateTime.day,
          timeOfDay.hour,
          timeOfDay.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 0, // Minimalist design - reduced shadow
      insetPadding: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.05,
        vertical: MediaQuery.of(context).size.height * 0.02,
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
          minHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Minimalist header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'New Meal',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkest,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.darkest),
                      onPressed: () => Navigator.of(context).pop(),
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Minimalist search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search for meals',
                    labelStyle: TextStyle(color: AppTheme.darker),
                    hintText: 'e.g., Pasta, Salad',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon:
                        _isSearching
                            ? Padding(
                              padding: const EdgeInsets.all(12),
                              child: SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.darkest,
                                  ),
                                ),
                              ),
                            )
                            : Icon(Icons.search, color: AppTheme.darker),
                    filled: false,
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.light, width: 1),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.darkest, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) {
                    if (value.length >= 2) {
                      _searchMeals(value);
                    } else if (value.isEmpty) {
                      setState(() {
                        _searchResults = [];
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Minimalist search results
                if (!_isSearching && _searchResults.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      shrinkWrap: false,
                      itemCount: _searchResults.length,
                      separatorBuilder:
                          (context, index) => Divider(
                            color: AppTheme.lightest,
                            height: 1,
                            thickness: 1,
                          ),
                      itemBuilder: (context, index) {
                        final meal = _searchResults[index];
                        return InkWell(
                          onTap: () => _selectMeal(meal),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child:
                                      meal['strMealThumb'] != null
                                          ? Image.network(
                                            meal['strMealThumb'],
                                            width: 50,
                                            height: 50,
                                            fit: BoxFit.cover,
                                            errorBuilder: (
                                              context,
                                              error,
                                              stackTrace,
                                            ) {
                                              return Container(
                                                width: 50,
                                                height: 50,
                                                color: AppTheme.lightest,
                                                child: Icon(
                                                  Icons.restaurant,
                                                  color: AppTheme.darkest,
                                                  size: 24,
                                                ),
                                              );
                                            },
                                          )
                                          : Container(
                                            width: 50,
                                            height: 50,
                                            color: AppTheme.lightest,
                                            child: Icon(
                                              Icons.restaurant,
                                              color: AppTheme.darkest,
                                              size: 24,
                                            ),
                                          ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        meal['strMeal'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        meal['strCategory'] ?? '',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 20),

                // Selected meal - minimalist design
                if (_selectedMeal != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppTheme.lightest, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                          ),
                          child: Image.network(
                            _selectedMeal!['strMealThumb'] ?? '',
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 180,
                                color: AppTheme.lightest,
                                child: Icon(
                                  Icons.restaurant,
                                  size: 50,
                                  color: AppTheme.darkest,
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _selectedMeal!['strMeal'] ?? 'Unknown',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: AppTheme.darkest,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                children: [
                                  if (_selectedMeal!['strCategory'] != null)
                                    Chip(
                                      label: Text(
                                        _selectedMeal!['strCategory'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.darkest,
                                        ),
                                      ),
                                      backgroundColor: AppTheme.lightest,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  if (_selectedMeal!['strArea'] != null)
                                    Chip(
                                      label: Text(
                                        _selectedMeal!['strArea'],
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.darker,
                                        ),
                                      ),
                                      backgroundColor: AppTheme.lightest,
                                      padding: EdgeInsets.zero,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Meal name field - minimalist design
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Meal Name',
                    labelStyle: TextStyle(color: AppTheme.darker),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.light),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppTheme.darkest, width: 2),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a meal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Time picker - minimalist design
                InkWell(
                  onTap: _pickDateTime,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppTheme.light)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.access_time, color: AppTheme.darker),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Scheduled Time',
                              style: TextStyle(
                                color: AppTheme.darker,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              DateFormat('h:mm a').format(_scheduledDateTime),
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: AppTheme.darkest,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(Icons.edit, size: 16, color: AppTheme.darker),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Save button - minimalist design
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveMeal,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.darkest,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      'Add to Meal Plan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

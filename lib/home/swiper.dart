import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';

class Meal {
  final String id;
  final String name;
  final String imageUrl;
  final String? category;
  final String? area;
  final String? instructions;
  final Map<String, String?> ingredients;

  Meal({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.category,
    this.area,
    this.instructions,
    required this.ingredients,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measurements
    Map<String, String?> ingredients = {};
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measure = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients[ingredient] = measure;
      }
    }

    return Meal(
      id: json['idMeal'],
      name: json['strMeal'],
      imageUrl: json['strMealThumb'],
      category: json['strCategory'],
      area: json['strArea'],
      instructions: json['strInstructions'],
      ingredients: ingredients,
    );
  }
}

class MealService {
  static Future<Meal> getRandomMeal() async {
    try {
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/random.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Meal.fromJson(data['meals'][0]);
      } else {
        throw Exception('Failed to load meal');
      }
    } catch (e) {
      throw Exception('Error fetching meal: $e');
    }
  }
}

class MealSwiper extends StatefulWidget {
  const MealSwiper({Key? key}) : super(key: key);

  @override
  State<MealSwiper> createState() => _MealSwiperState();
}

class _MealSwiperState extends State<MealSwiper> {
  final CardSwiperController _swiperController = CardSwiperController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  List<Meal> _meals = [];
  bool _isLoading = true;
  bool _isProgrammaticSwipe = false; // Add this flag

  @override
  void initState() {
    super.initState();
    _loadInitialMeals();
  }

  Future<void> _loadInitialMeals() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load 3 initial meals to have some cards ready
      final meals = await Future.wait([
        MealService.getRandomMeal(),
        MealService.getRandomMeal(),
        MealService.getRandomMeal(),
      ]);

      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading meals: $e')));
      }
    }
  }

  Future<void> _fetchNewMeal() async {
    try {
      final meal = await MealService.getRandomMeal();
      if (mounted) {
        setState(() {
          _meals.add(meal);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading new meal: $e')));
      }
    }
  }

  Future<void> _confirmAndSaveMeal(Meal meal) async {
    // Check if the user is authenticated first
    final user = _authService.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to be logged in to save meals'),
          ),
        );
      }
      return;
    }

    // Show confirmation dialog
    bool? shouldSave = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder:
          (dialogContext) => AlertDialog(
            title: const Text('Save Meal'),
            content: Text(
              'Do you want to save "${meal.name}" to your collection?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  // Close the dialog first
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );

    // Handle case where dialog is dismissed
    if (shouldSave == null) shouldSave = false;

    // If user confirmed, save the meal
    if (shouldSave && mounted) {
      await _saveMealToFirestore(meal);
    }
  }

  Future<void> _saveMealToFirestore(Meal meal) async {
    try {
      // Check if user is authenticated
      final user = _authService.currentUser;
      if (user == null) {
        return; // Already checked in confirmation dialog
      }

      // Clear any existing snackbars
      ScaffoldMessenger.of(context).clearSnackBars();

      // Check if this meal is already saved by the user
      final existingMeals =
          await _firestore
              .collection('meals')
              .where('userId', isEqualTo: user.uid)
              .where('mealId', isEqualTo: meal.id)
              .get();

      if (existingMeals.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${meal.name} is already in your collection'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
        return; // Skip saving if already exists
      }

      // Save the meal to Firestore
      await _firestore.collection('meals').add({
        'userId': user.uid,
        'mealId': meal.id,
        'name': meal.name,
        'imageUrl': meal.imageUrl,
        'category': meal.category,
        'area': meal.area,
        'instructions': meal.instructions,
        'ingredients': meal.ingredients.map((k, v) => MapEntry(k, v ?? '')),
        'savedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${meal.name} saved to your collection!'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving meal: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
      print('Error saving meal: $e');
    }
  }

  void _showMealDetails(Meal meal) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(meal.name),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  meal.category != null
                      ? Text('Category: ${meal.category}')
                      : const SizedBox(),
                  meal.area != null
                      ? Text('Cuisine: ${meal.area}')
                      : const SizedBox(),
                  const SizedBox(height: 16),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...meal.ingredients.entries
                      .map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text('• ${entry.key}: ${entry.value ?? ""}'),
                        ),
                      )
                      .toList(),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(meal.instructions ?? 'No instructions available'),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  Widget _buildMealCard(Meal meal) {
    return InkWell(
      onTap: () => _showMealDetails(meal),
      borderRadius: BorderRadius.circular(15),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  meal.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value:
                            loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 50),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (meal.category != null)
                    Text(
                      '${meal.category} • ${meal.area ?? ""}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_meals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load meals'),
            ElevatedButton(
              onPressed: _loadInitialMeals,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: CardSwiper(
              controller: _swiperController,
              cardsCount: _meals.length,
              cardBuilder:
                  (context, index, percentThresholdX, percentThresholdY) =>
                      _buildMealCard(_meals[index]),
              onSwipe: (previousIndex, currentIndex, direction) {
                // Only save meal when swiped right manually (not programmatically)
                if (direction == CardSwiperDirection.right &&
                    previousIndex < _meals.length &&
                    !_isProgrammaticSwipe) {
                  _confirmAndSaveMeal(_meals[previousIndex]);
                }

                // Reset the flag after handling the swipe
                _isProgrammaticSwipe = false;

                // Fetch a new meal when swiped
                _fetchNewMeal();
                return true;
              },
              padding: const EdgeInsets.all(24.0),
            ),
          ),
          // Swipe indicators
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left swipe indicator
                InkWell(
                  onTap: () {
                    if (_meals.isNotEmpty) {
                      _isProgrammaticSwipe = true; // Set flag before swiping
                      _swiperController.swipe(CardSwiperDirection.left);
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(Icons.close, color: Colors.red[300], size: 28),
                        const SizedBox(height: 4),
                        const Text('Ignore', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: MediaQuery.of(context).size.width * 0.2),
                // Right swipe indicator
                InkWell(
                  onTap: () {
                    if (_meals.isNotEmpty) {
                      // Get current top card index
                      int currentIndex = _meals.length - 1;
                      if (currentIndex < _meals.length) {
                        _confirmAndSaveMeal(_meals[currentIndex]);
                        // Set flag before swiping to prevent duplicate save action
                        _isProgrammaticSwipe = true;
                        _swiperController.swipe(CardSwiperDirection.right);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(30),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          color: Colors.green[300],
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        const Text('Save', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

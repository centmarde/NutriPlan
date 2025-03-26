import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

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
  List<Meal> _meals = [];
  bool _isLoading = true;

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
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Stack(
        children: [
          Column(
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
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.visibility, color: Colors.black87),
                onPressed: () => _showMealDetails(meal),
              ),
            ),
          ),
        ],
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
                // Fetch a new meal when swiped
                _fetchNewMeal();
                return true;
              },
              padding: const EdgeInsets.all(24.0),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _swiperController.swipe(CardSwiperDirection.left);
                  _fetchNewMeal();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.red,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  _swiperController.swipe(CardSwiperDirection.right);
                  _fetchNewMeal();
                },
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(20),
                  backgroundColor: Colors.green,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

class MealData {
  final String name;
  final String image;
  final String instructions;
  final String category;
  final String area;
  final List<String> ingredients;
  final List<String> measures;

  MealData({
    required this.name,
    required this.image,
    required this.instructions,
    required this.category,
    required this.area,
    required this.ingredients,
    required this.measures,
  });

  factory MealData.fromJson(Map<String, dynamic> json) {
    List<String> ingredients = [];
    List<String> measures = [];

    // Extract ingredients and measures
    for (int i = 1; i <= 20; i++) {
      String ingredient = json['strIngredient$i'] ?? '';
      String measure = json['strMeasure$i'] ?? '';

      if (ingredient.isNotEmpty && ingredient != 'null') {
        ingredients.add(ingredient);
        measures.add(measure.isNotEmpty ? measure : '-');
      }
    }

    return MealData(
      name: json['strMeal'] ?? 'Unknown',
      image: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? 'No instructions available',
      category: json['strCategory'] ?? 'Unknown',
      area: json['strArea'] ?? 'Unknown',
      ingredients: ingredients,
      measures: measures,
    );
  }
}

class MealExtractor {
  // Extract only the first two meal names enclosed in double asterisks
  static List<String> extractMealNames(String aiResponse) {
    print("DEBUG: Starting meal name extraction from response");
    print(
      "DEBUG: Response text: ${aiResponse.substring(0, min(100, aiResponse.length))}...",
    );

    final regExp = RegExp(r'\*\*([^*]+)\*\*');
    final matches = regExp.allMatches(aiResponse);

    // Get all matches as a list
    final allMatches =
        matches.map((match) => match.group(1)?.trim() ?? '').toList();
    print(
      "DEBUG: Found ${allMatches.length} meal names in asterisks: $allMatches",
    );

    // Return only the first two matches (or fewer if there aren't two)
    final result = allMatches.take(2).toList();
    print("DEBUG: Returning first ${result.length} meal names: $result");

    return result;
  }

  // Fetch meal data from TheMealDB API
  static Future<List<MealData>> fetchMealData(List<String> mealNames) async {
    print("DEBUG: Starting API fetch for meal names: $mealNames");
    List<MealData> meals = [];

    for (String name in mealNames) {
      try {
        final url =
            'https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(name)}';
        print("DEBUG: Fetching from URL: $url");

        final response = await http.get(Uri.parse(url));

        print("DEBUG: API response status code: ${response.statusCode}");

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          print("DEBUG: Received data with meals: ${data['meals'] != null}");

          if (data['meals'] != null && data['meals'].isNotEmpty) {
            print(
              "DEBUG: Found meal data for '$name': ${data['meals'][0]['strMeal']}",
            );
            meals.add(MealData.fromJson(data['meals'][0]));
          } else {
            print("DEBUG: No meal found for '$name'");
          }
        } else {
          print(
            "DEBUG: Failed to get data for '$name', status: ${response.statusCode}",
          );
        }
      } catch (e) {
        print("DEBUG ERROR: Error fetching meal data for '$name': $e");
      }
    }

    print("DEBUG: Final meals list contains ${meals.length} meals");
    return meals;
  }
}

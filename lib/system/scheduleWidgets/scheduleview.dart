import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'scheduleedit.dart';
import 'deleteschedule.dart';

class ScheduleView extends StatelessWidget {
  final List<QueryDocumentSnapshot> meals;
  final Function(String) onDelete;
  final Function(String, DateTime) onReschedule;

  const ScheduleView({
    Key? key,
    required this.meals,
    required this.onDelete,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: meals.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, index) {
        final meal = meals[index].data() as Map<String, dynamic>;
        return MealCard(
          meal: meal,
          mealId: meals[index].id,
          onDelete: onDelete,
          onReschedule: onReschedule,
        );
      },
    );
  }
}

class MealCard extends StatelessWidget {
  final Map<String, dynamic> meal;
  final String mealId; // This is the Firestore document ID
  final Function(String) onDelete;
  final Function(String, DateTime) onReschedule;

  const MealCard({
    Key? key,
    required this.meal,
    required this.mealId,
    required this.onDelete,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the internal meal ID if available
    String? internalMealId = meal['mealId'] as String?;

    String formattedDate = '';
    if (meal['scheduledAt'] != null) {
      DateTime scheduledTime = (meal['scheduledAt'] as Timestamp).toDate();
      formattedDate = DateFormat('MMMM d, y - h:mm a').format(scheduledTime);
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stack to overlay actions on the image
          Stack(
            children: [
              // Image container
              InkWell(
                onTap: () => _showMealDetails(context, meal),
                child: SizedBox(
                  width: double.infinity,
                  height: 200,
                  child:
                      meal['imageUrl'] != null
                          ? Image.network(
                            meal['imageUrl'],
                            fit: BoxFit.cover,
                            errorBuilder:
                                (ctx, error, _) => const Center(
                                  child: Icon(Icons.broken_image, size: 60),
                                ),
                            loadingBuilder: (ctx, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(child: CircularProgressIndicator());
                            },
                          )
                          : Center(child: Icon(Icons.no_food, size: 60)),
                ),
              ),

              // Action buttons overlay at the top right
              Positioned(
                top: 8,
                right: 8,
                child: Row(
                  children: [
                    // Edit button
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 18,
                      child: IconButton(
                        icon: Icon(Icons.edit, size: 18, color: Colors.blue),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () {
                          showScheduleEditDialog(
                            context: context,
                            mealId: mealId,
                            meal: meal,
                            onReschedule: onReschedule,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Delete button
                    CircleAvatar(
                      backgroundColor: Colors.white.withOpacity(0.8),
                      radius: 18,
                      child: IconButton(
                        icon: Icon(Icons.delete, size: 18, color: Colors.red),
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => _showDeleteConfirmation(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Meal details section - make this tappable too
          InkWell(
            onTap: () => _showMealDetails(context, meal),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal['name'] ?? 'Unnamed Meal',
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${meal['category'] ?? 'No Category'} • ${meal['area'] ?? 'No Area'}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  if (formattedDate.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Scheduled for: $formattedDate',
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMealDetails(BuildContext context, Map<String, dynamic> meal) {
    showDialog(
      context: context,
      builder:
          (dialogContext) => Dialog(
            insetPadding: EdgeInsets.all(16),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Image
                  if (meal['imageUrl'] != null)
                    Image.network(
                      meal['imageUrl'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal['name'] ?? 'Unnamed Meal',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),

                          // Category and Area
                          Row(
                            children: [
                              Chip(
                                label: Text(meal['category'] ?? 'No Category'),
                                backgroundColor: Colors.amber[100],
                              ),
                              const SizedBox(width: 8),
                              Chip(
                                label: Text(meal['area'] ?? 'No Area'),
                                backgroundColor: Colors.blue[100],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Ingredients Section
                          Text(
                            'Ingredients:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          if (meal['ingredients'] != null)
                            ..._buildIngredientsList(
                              context,
                              meal['ingredients'],
                            ),

                          const SizedBox(height: 16),

                          // Instructions Section
                          Text(
                            'Instructions:',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            meal['instructions'] ??
                                'No instructions available.',
                          ),

                          const SizedBox(height: 16),

                          // Schedule Information
                          if (meal['scheduledAt'] != null) ...[
                            Text(
                              'Schedule Info:',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Scheduled for: ${DateFormat('MMMM d, y - h:mm a').format((meal['scheduledAt'] as Timestamp).toDate())}',
                              style: TextStyle(color: Colors.blue[700]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Action buttons - now only showing a Close button
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          icon: Icon(Icons.close),
                          label: Text('CLOSE'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    // Get the internal meal ID if available
    String? internalMealId = meal['mealId'] as String?;

    // Use a simplified approach that doesn't rely on complex context chains
    // to show multiple sequential dialogs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDeleteMealDialog(
            context: context,
            documentId: mealId, // Firestore document ID
            mealData: meal,
            internalMealId: internalMealId, // Internal meal ID (might be null)
          )
          .then((wasDeleted) {
            if (wasDeleted) {
              // Call the callback to update UI if deletion was successful
              onDelete(mealId);
            } else {
              print('DEBUG: Meal was not deleted, no callback triggered');
            }
          })
          .catchError((error) {
            print('DEBUG: Error in delete flow: $error');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error while deleting: $error'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          });
    });
  }

  List<Widget> _buildIngredientsList(
    BuildContext context,
    Map<String, dynamic> ingredients,
  ) {
    List<Widget> ingredientWidgets = [];

    ingredients.forEach((ingredient, measure) {
      if (ingredient.isNotEmpty && measure.isNotEmpty) {
        ingredientWidgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text('$ingredient: $measure')),
              ],
            ),
          ),
        );
      }
    });

    return ingredientWidgets.isEmpty
        ? [Text('No ingredients listed.')]
        : ingredientWidgets;
  }
}

import 'package:flutter/material.dart';
import '../layout/layout.dart';
import '../router/routes.dart';
import '../common/navbar.dart'; // Add import for NavBarItems

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({Key? key}) : super(key: key);

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Meal Planner',
      currentRoute: AppRoutes.planner,
      initialTabIndex: NavBarItems.planner, // Set the correct initial tab index
      actions: [
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () {
            // Calendar action
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Calendar view coming soon')),
            );
          },
        ),
      ],
      child: Stack(
        children: [
          Column(
            children: [
              // Days of week selector
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: daysOfWeek.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDay = index;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color:
                              _selectedDay == index
                                  ? Theme.of(context).primaryColor
                                  : Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            daysOfWeek[index],
                            style: TextStyle(
                              color:
                                  _selectedDay == index
                                      ? Colors.white
                                      : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Meal plan content
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildMealCard('Breakfast', 'Add breakfast items'),
                    _buildMealCard('Lunch', 'Add lunch items'),
                    _buildMealCard('Dinner', 'Add dinner items'),
                    _buildMealCard('Snacks', 'Add snacks'),
                  ],
                ),
              ),
            ],
          ),

          // Floating Action Button positioned at the bottom right
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                // Action to add new meal or item
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Add new meal item feature coming soon'),
                  ),
                );
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String title, String placeholder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Edit functionality
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(placeholder, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Item'),
                onPressed: () {
                  // Action to add item to this meal
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

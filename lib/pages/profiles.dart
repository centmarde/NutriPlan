import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../layout/layout.dart';
import '../system/scheduler/view_notif.dart';

// Define NavBarItems enum
enum NavBarItems { home, profiles, settings }

class ProfilesScreen extends StatefulWidget {
  const ProfilesScreen({Key? key}) : super(key: key);

  @override
  State<ProfilesScreen> createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  final MealNotificationScheduler _notificationScheduler =
      MealNotificationScheduler();

  // User data
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  // Form controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  List<String> _dietaryPreferences = ['Balanced'];
  List<String> _allergies = ['None'];

  final List<String> _availableDiets = [
    'Balanced',
    'Vegetarian',
    'Vegan',
    'Keto',
    'Paleo',
    'Low-carb',
    'Low-fat',
    'High-protein',
    'Gluten-free',
    'Dairy-free',
  ];

  final List<String> _availableAllergies = [
    'None',
    'Nuts',
    'Dairy',
    'Eggs',
    'Gluten',
    'Soy',
    'Seafood',
    'Shellfish',
    'Wheat',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _notificationScheduler.scheduleMealNotifications();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await _authService.getUserData();

      if (userData != null) {
        setState(() {
          _userData = userData;
          _emailController.text =
              _authService.currentUser?.email ?? "test@gmail.com";
          _fullNameController.text = userData['fullName'] ?? "";
          _ageController.text = userData['age']?.toString() ?? "30";
          _weightController.text = userData['weight']?.toString() ?? "70";
          _heightController.text = userData['height']?.toString() ?? "175";

          if (userData['dietaryPreferences'] != null) {
            _dietaryPreferences = List<String>.from(
              userData['dietaryPreferences'],
            );
          }

          if (userData['allergies'] != null) {
            _allergies = List<String>.from(userData['allergies']);
          }
        });
      } else {
        // Default values if no user data
        _emailController.text = "test@gmail.com";
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Show loading indicator
        setState(() {
          _isLoading = true;
        });

        // Get the current user ID
        final userId = _authService.currentUser?.uid;
        if (userId == null) {
          throw Exception('User not logged in');
        }

        // Create updated profile data
        final updatedData = {
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'age': int.tryParse(_ageController.text) ?? 0,
          'weight': double.tryParse(_weightController.text) ?? 0,
          'height': double.tryParse(_heightController.text) ?? 0,
          'dietaryPreferences': _dietaryPreferences,
          'allergies': _allergies,
          'updatedAt': DateTime.now().toIso8601String(),
        };

        // Save to Firestore using the AuthService
        await _authService.updateUserData(updatedData);

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating profile: ${e.toString()}')),
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      title: 'Profile Settings',
      initialTabIndex: 4,
      actions: [
        IconButton(icon: const Icon(Icons.save), onPressed: _saveProfile),
      ],
      child:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildProfileForm(context),
    );
  }

  Widget _buildProfileForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User Icon
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 60,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            _buildSectionHeader('Personal Information'),
            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              readOnly: true, // Email shouldn't be editable
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Physical Details Section
            _buildSectionHeader('Physical Details'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.cake),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.fitness_center),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _heightController,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.height),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            // Dietary Preferences Section
            _buildSectionHeader('Dietary Preferences'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  _availableDiets.map((diet) {
                    final isSelected = _dietaryPreferences.contains(diet);
                    return FilterChip(
                      label: Text(diet),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _dietaryPreferences.add(diet);
                          } else {
                            _dietaryPreferences.remove(diet);
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 24),

            // Allergies Section
            _buildSectionHeader('Allergies'),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children:
                  _availableAllergies.map((allergy) {
                    final isSelected = _allergies.contains(allergy);
                    return FilterChip(
                      label: Text(allergy),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            if (allergy == 'None') {
                              _allergies = ['None'];
                            } else {
                              _allergies.remove('None');
                              _allergies.add(allergy);
                            }
                          } else {
                            _allergies.remove(allergy);
                            if (_allergies.isEmpty) {
                              _allergies = ['None'];
                            }
                          }
                        });
                      },
                      backgroundColor: Colors.grey.shade200,
                      selectedColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.2),
                      checkmarkColor: Theme.of(context).primaryColor,
                    );
                  }).toList(),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Divider(
            color: Theme.of(context).primaryColor.withOpacity(0.5),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}

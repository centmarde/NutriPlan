import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Shows a delete confirmation dialog and handles the meal deletion process
Future<bool> showDeleteMealDialog({
  required BuildContext context,
  required String documentId,
  required Map<String, dynamic> mealData,
  String? internalMealId,
}) async {
  // Use the correct document ID for deletion (the Firestore document ID)
  String documentIdToDelete = documentId;

  // Show confirmation dialog
  bool? confirmDelete;
  try {
    confirmDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder:
          (dialogContext) => AlertDialog(
            title: Text('Delete Meal'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to completely delete this meal?',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  mealData['name'] ?? 'Unnamed Meal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                // Show internal meal ID for debugging
                if (internalMealId != null) ...[
                  SizedBox(height: 4),
                  Text(
                    'Meal ID: $internalMealId',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
                if (mealData['scheduledAt'] != null) ...[
                  SizedBox(height: 8),
                  Text(
                    'Scheduled for: ${DateFormat('MMMM d, y - h:mm a').format((mealData['scheduledAt'] as Timestamp).toDate())}',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
                SizedBox(height: 16),
                Text(
                  'This action cannot be undone. The meal will be permanently deleted.',
                  style: TextStyle(
                    color: Colors.red[700],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: Text('DELETE'),
              ),
            ],
          ),
    );
  } catch (e) {
    print('DEBUG: Error showing confirmation dialog: $e');
    return false;
  }

  // If user didn't confirm deletion, return false
  if (confirmDelete != true) {
    return false;
  }

  // Delete directly without showing another dialog that requires context
  try {
    // Permanently delete the meal from Firestore using the correct document ID
    await FirebaseFirestore.instance
        .collection('meals')
        .doc(documentIdToDelete)
        .delete();

    // Only show success message if context is still available
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }

    return true;
  } catch (e) {
    // Only show error message if context is still available
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete meal: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }

    return false;
  }
}

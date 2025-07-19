import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'food_item.dart';

class FirebaseService {
  static final DatabaseReference _database = FirebaseDatabase.instance.ref();

  // Database references
  static DatabaseReference get foodItemsRef => _database.child('food_items');
  static DatabaseReference get wasteItemsRef => _database.child('waste_items');

  // Add a new food item to Realtime Database
  static Future<void> addFoodItem(FoodItem item) async {
    try {
      final newItemRef = foodItemsRef.push();
      await newItemRef.set({
        'name': item.name,
        'expiryDate': item.expiryDate?.toIso8601String(),
        'location': item.location,
        'isFavorite': item.isFavorite,
        'nutritionInfo': item.nutritionInfo,
        'recipeInfo': item.recipeInfo,
        'allergyInfo': item.allergyInfo,
        'spoilageInfo': item.spoilageInfo,
        'nutritionValues': item.nutritionValues,
        'imageBytes': item.imageBytes != null
            ? base64Encode(item.imageBytes!)
            : null,
        'createdAt': ServerValue.timestamp,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error adding food item: $e');
      rethrow;
    }
  }

  // Get all food items from Realtime Database
  static Future<List<FoodItem>> getFoodItems() async {
    try {
      final snapshot = await foodItemsRef.get();

      if (snapshot.value == null) {
        return [];
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      final List<FoodItem> items = [];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final itemData = Map<String, dynamic>.from(value);
          items.add(
            FoodItem(
              name: itemData['name'] ?? '',
              expiryDate: itemData['expiryDate'] != null
                  ? DateTime.parse(itemData['expiryDate'])
                  : null,
              location: itemData['location'] ?? '',
              isFavorite: itemData['isFavorite'] ?? false,
              nutritionInfo: itemData['nutritionInfo'],
              recipeInfo: itemData['recipeInfo'],
              allergyInfo: itemData['allergyInfo'],
              spoilageInfo: itemData['spoilageInfo'],
              nutritionValues: itemData['nutritionValues'] != null
                  ? Map<String, double>.from(itemData['nutritionValues'])
                  : null,
              imageBytes: itemData['imageBytes'] != null
                  ? base64Decode(itemData['imageBytes'])
                  : null,
              createdAt: itemData['createdAt'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(itemData['createdAt'])
                  : null,
            ),
          );
        }
      });

      // Sort by creation time (newest first)
      items.sort(
        (a, b) => (b.createdAt ?? DateTime.now()).compareTo(
          a.createdAt ?? DateTime.now(),
        ),
      );
      return items;
    } catch (e) {
      print('Error getting food items: $e');
      return [];
    }
  }

  // Update a food item in Realtime Database
  static Future<void> updateFoodItem(String itemId, FoodItem item) async {
    try {
      await foodItemsRef.child(itemId).update({
        'name': item.name,
        'expiryDate': item.expiryDate?.toIso8601String(),
        'location': item.location,
        'isFavorite': item.isFavorite,
        'nutritionInfo': item.nutritionInfo,
        'recipeInfo': item.recipeInfo,
        'allergyInfo': item.allergyInfo,
        'spoilageInfo': item.spoilageInfo,
        'nutritionValues': item.nutritionValues,
        'imageBytes': item.imageBytes != null
            ? base64Encode(item.imageBytes!)
            : null,
        'updatedAt': ServerValue.timestamp,
      });
    } catch (e) {
      print('Error updating food item: $e');
      rethrow;
    }
  }

  // Delete a food item from Realtime Database
  static Future<void> deleteFoodItem(String itemId) async {
    try {
      await foodItemsRef.child(itemId).remove();
    } catch (e) {
      print('Error deleting food item: $e');
      rethrow;
    }
  }

  // Delete a food item from the list by finding it in the database
  static Future<void> deleteFoodItemFromList(FoodItem item) async {
    try {
      // Get all items to find the matching one
      final snapshot = await foodItemsRef.get();

      if (snapshot.value == null) {
        print('No items found in database');
        return;
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;

      // Find the item that matches the one to delete
      String? itemIdToDelete;
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final itemData = Map<String, dynamic>.from(value);
          if (itemData['name'] == item.name &&
              itemData['location'] == item.location &&
              itemData['expiryDate'] == item.expiryDate?.toIso8601String()) {
            itemIdToDelete = key.toString();
          }
        }
      });

      if (itemIdToDelete != null) {
        await foodItemsRef.child(itemIdToDelete!).remove();
        print('Successfully deleted item: $itemIdToDelete');
      } else {
        print('Item not found in database for deletion');
      }
    } catch (e) {
      print('Error deleting food item from list: $e');
      rethrow;
    }
  }

  // Add item to waste management
  static Future<void> addToWaste(FoodItem item) async {
    try {
      final newWasteRef = wasteItemsRef.push();
      await newWasteRef.set({
        'name': item.name,
        'expiryDate': item.expiryDate?.toIso8601String(),
        'location': item.location,
        'addedToWasteAt': ServerValue.timestamp,
        'reason': 'Expired',
      });
    } catch (e) {
      print('Error adding to waste: $e');
      rethrow;
    }
  }

  // Get waste items
  static Future<List<Map<String, dynamic>>> getWasteItems() async {
    try {
      final snapshot = await wasteItemsRef.get();

      if (snapshot.value == null) {
        return [];
      }

      final Map<dynamic, dynamic> data =
          snapshot.value as Map<dynamic, dynamic>;
      final List<Map<String, dynamic>> items = [];

      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          final itemData = Map<String, dynamic>.from(value);
          items.add({
            'id': key,
            'name': itemData['name'] ?? '',
            'expiryDate': itemData['expiryDate'] != null
                ? DateTime.parse(itemData['expiryDate'])
                : null,
            'location': itemData['location'] ?? '',
            'addedToWasteAt': itemData['addedToWasteAt'],
            'reason': itemData['reason'] ?? 'Expired',
          });
        }
      });

      return items;
    } catch (e) {
      print('Error getting waste items: $e');
      return [];
    }
  }

  // Get food items expiring soon (within 3 days)
  static Future<List<FoodItem>> getExpiringSoonItems() async {
    try {
      final allItems = await getFoodItems();
      final now = DateTime.now();
      final threeDaysFromNow = now.add(Duration(days: 3));

      return allItems.where((item) {
        if (item.expiryDate == null) return false;
        return item.expiryDate!.isAfter(now) &&
            item.expiryDate!.isBefore(threeDaysFromNow);
      }).toList();
    } catch (e) {
      print('Error getting expiring soon items: $e');
      return [];
    }
  }

  // Get expired items
  static Future<List<FoodItem>> getExpiredItems() async {
    try {
      final allItems = await getFoodItems();
      final now = DateTime.now();

      return allItems.where((item) {
        if (item.expiryDate == null) return false;
        return item.expiryDate!.isBefore(now);
      }).toList();
    } catch (e) {
      print('Error getting expired items: $e');
      return [];
    }
  }

  // Search food items by name
  static Future<List<FoodItem>> searchFoodItems(String query) async {
    try {
      final allItems = await getFoodItems();
      final lowercaseQuery = query.toLowerCase();

      return allItems.where((item) {
        return item.name.toLowerCase().contains(lowercaseQuery);
      }).toList();
    } catch (e) {
      print('Error searching food items: $e');
      return [];
    }
  }
}

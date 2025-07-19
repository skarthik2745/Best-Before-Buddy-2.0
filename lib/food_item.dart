import 'dart:typed_data';

class FoodItem {
  final String name;
  final DateTime? expiryDate;
  final Uint8List? imageBytes;
  final String? nutritionInfo;
  final String? recipeInfo;
  final String? allergyInfo;
  final String? spoilageInfo;
  final Map<String, double>? nutritionValues;
  final bool isFavorite;
  final String location;
  final DateTime? createdAt;

  FoodItem({
    required this.name,
    this.expiryDate,
    this.imageBytes,
    this.nutritionInfo,
    this.recipeInfo,
    this.allergyInfo,
    this.spoilageInfo,
    this.nutritionValues,
    this.isFavorite = false,
    required this.location,
    this.createdAt,
  });

  // Create a copy of this item with updated favorite status
  FoodItem copyWith({
    String? name,
    DateTime? expiryDate,
    Uint8List? imageBytes,
    String? nutritionInfo,
    String? recipeInfo,
    String? allergyInfo,
    String? spoilageInfo,
    Map<String, double>? nutritionValues,
    bool? isFavorite,
    String? location,
    DateTime? createdAt,
  }) {
    return FoodItem(
      name: name ?? this.name,
      expiryDate: expiryDate ?? this.expiryDate,
      imageBytes: imageBytes ?? this.imageBytes,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      recipeInfo: recipeInfo ?? this.recipeInfo,
      allergyInfo: allergyInfo ?? this.allergyInfo,
      spoilageInfo: spoilageInfo ?? this.spoilageInfo,
      nutritionValues: nutritionValues ?? this.nutritionValues,
      isFavorite: isFavorite ?? this.isFavorite,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

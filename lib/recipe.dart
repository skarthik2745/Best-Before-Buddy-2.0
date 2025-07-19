import 'package:hive/hive.dart';

part 'recipe.g.dart';

@HiveType(typeId: 1)
class Recipe extends HiveObject {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final String description;
  @HiveField(2)
  final List<String> ingredients;
  @HiveField(3)
  final List<String> instructions;
  @HiveField(4)
  final String cookingTime;
  @HiveField(5)
  final String difficulty;
  @HiveField(6)
  final int servings;
  @HiveField(7)
  final String? nutritionalBenefits;
  @HiveField(8)
  final String foodName; // The food item this recipe is for
  @HiveField(9)
  bool isFavorite; // Can be toggled

  Recipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.difficulty,
    required this.servings,
    this.nutritionalBenefits,
    required this.foodName,
    this.isFavorite = false,
  });

  // Create a copy with updated favorite status
  Recipe copyWith({bool? isFavorite}) {
    return Recipe(
      title: title,
      description: description,
      ingredients: ingredients,
      instructions: instructions,
      cookingTime: cookingTime,
      difficulty: difficulty,
      servings: servings,
      nutritionalBenefits: nutritionalBenefits,
      foodName: foodName,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

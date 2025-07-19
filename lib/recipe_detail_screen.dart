import 'package:flutter/material.dart';
import 'food_item.dart';
import 'food_api_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  final FoodItem foodItem;
  final Function(FoodItem) onFavoriteToggle;

  const RecipeDetailScreen({
    Key? key,
    required this.foodItem,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  List<Map<String, dynamic>>? _recipes;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    try {
      final recipes = await FoodApiService.getRecipeInfo(widget.foodItem.name);
      setState(() {
        _recipes = recipes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading recipes: $e')));
    }
  }

  void _toggleFavorite() {
    final updatedItem = widget.foodItem.copyWith(
      isFavorite: !widget.foodItem.isFavorite,
    );
    widget.onFavoriteToggle(updatedItem);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.foodItem.name} Recipes'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              widget.foodItem.isFavorite
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: widget.foodItem.isFavorite ? Colors.red : Colors.white,
            ),
            onPressed: _toggleFavorite,
            tooltip: widget.foodItem.isFavorite
                ? 'Remove from favorites'
                : 'Add to favorites',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading recipes...'),
                ],
              ),
            )
          : _recipes == null || _recipes!.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No recipes found',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try adding this food item to get recipe suggestions',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _recipes!.length,
              itemBuilder: (context, index) {
                final recipe = _recipes![index];
                return Card(
                  margin: EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                recipe['title'] ?? 'Recipe ${index + 1}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                recipe['difficulty'] ?? 'Easy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        if (recipe['description'] != null) ...[
                          Text(
                            recipe['description'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 12),
                        ],
                        Row(
                          children: [
                            Icon(Icons.timer, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('${recipe['cookingTime'] ?? 'N/A'} min'),
                            SizedBox(width: 16),
                            Icon(Icons.people, size: 16, color: Colors.grey),
                            SizedBox(width: 4),
                            Text('${recipe['servings'] ?? 'N/A'} servings'),
                          ],
                        ),
                        SizedBox(height: 12),
                        if (recipe['ingredients'] != null) ...[
                          Text(
                            'Ingredients:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...(recipe['ingredients'] as List)
                              .map(
                                (ingredient) => Padding(
                                  padding: EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 6,
                                        color: Colors.green.shade600,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(ingredient.toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                          SizedBox(height: 12),
                        ],
                        // Show instructions/steps
                        if (recipe['steps'] != null) ...[
                          Text(
                            'Instructions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...(recipe['steps'] as List)
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(entry.value.toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ] else if (recipe['instructions'] != null) ...[
                          Text(
                            'Instructions:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          ...(recipe['instructions'] is List
                                  ? (recipe['instructions'] as List)
                                  : [recipe['instructions']])
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade600,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${entry.key + 1}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(entry.value.toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                              .toList(),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

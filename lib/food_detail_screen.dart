import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'food_item.dart';
import 'food_api_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final FoodItem foodItem;

  const FoodDetailScreen({Key? key, required this.foodItem}) : super(key: key);

  @override
  _FoodDetailScreenState createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _foodInfo;
  bool _isLoading = true;
  Map<String, dynamic>? _selectedRecipe;
  Set<String> _likedRecipes = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFoodInfo();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFoodInfo() async {
    try {
      final foodInfo = await FoodApiService.getComprehensiveFoodInfo(
        widget.foodItem.name,
      );
      setState(() {
        _foodInfo = foodInfo;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading food information: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = _foodInfo?['recipes'] ?? [];
    final likedCount = _likedRecipes.length;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade700, Colors.pink.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          title: Text(
            widget.foodItem.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
          ),
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade700, Colors.pink.shade400],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: LinearGradient(
                    colors: [Colors.pink.shade300, Colors.orange.shade300],
                  ),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.restaurant_menu), text: 'Nutrition'),
                  Tab(
                    icon: Icon(Icons.book),
                    text: 'Recipes ($likedCount/${recipes.length})',
                  ),
                  Tab(icon: Icon(Icons.warning), text: 'Allergens'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              child: TabBarView(
                key: ValueKey(_tabController.index),
                controller: _tabController,
                children: [
                  _buildNutritionTab(),
                  _buildRecipesTab(),
                  _buildAllergensTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildNutritionTab() {
    final nutrition = _foodInfo?['nutrition'];

    if (nutrition == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nutrition information not available',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nutrition Chart
          Container(
            height: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                Text(
                  'Nutrition Breakdown (per 100g)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: [
                        PieChartSectionData(
                          value: nutrition['protein'] ?? 0,
                          title:
                              'Protein\n${(nutrition['protein'] ?? 0).toStringAsFixed(1)}g',
                          color: Colors.blue,
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: nutrition['carbs'] ?? 0,
                          title:
                              'Carbs\n${(nutrition['carbs'] ?? 0).toStringAsFixed(1)}g',
                          color: Colors.orange,
                          radius: 80,
                        ),
                        PieChartSectionData(
                          value: nutrition['fat'] ?? 0,
                          title:
                              'Fat\n${(nutrition['fat'] ?? 0).toStringAsFixed(1)}g',
                          color: Colors.red,
                          radius: 80,
                        ),
                      ],
                      centerSpaceRadius: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),

          // Detailed Nutrition Info
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detailed Nutrition',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildNutritionRow(
                  'Calories',
                  '${(nutrition['calories'] ?? 0).toStringAsFixed(1)} kcal',
                  Colors.amber,
                ),
                _buildNutritionRow(
                  'Protein',
                  '${(nutrition['protein'] ?? 0).toStringAsFixed(1)}g',
                  Colors.blue,
                ),
                _buildNutritionRow(
                  'Carbohydrates',
                  '${(nutrition['carbs'] ?? 0).toStringAsFixed(1)}g',
                  Colors.orange,
                ),
                _buildNutritionRow(
                  'Fat',
                  '${(nutrition['fat'] ?? 0).toStringAsFixed(1)}g',
                  Colors.red,
                ),
                _buildNutritionRow(
                  'Fiber',
                  '${(nutrition['fiber'] ?? 0).toStringAsFixed(1)}g',
                  Colors.green,
                ),
                _buildNutritionRow(
                  'Sugar',
                  '${(nutrition['sugar'] ?? 0).toStringAsFixed(1)}g',
                  Colors.pink,
                ),
                _buildNutritionRow(
                  'Sodium',
                  '${(nutrition['sodium'] ?? 0).toStringAsFixed(1)}mg',
                  Colors.purple,
                ),
                SizedBox(height: 16),
                if ((nutrition['vitamins'] != null &&
                        nutrition['vitamins'].isNotEmpty) ||
                    (nutrition['minerals'] != null &&
                        nutrition['minerals'].isNotEmpty)) ...[
                  Divider(),
                  Text(
                    'Micronutrients',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (nutrition['vitamins'] != null &&
                      nutrition['vitamins'].isNotEmpty) ...[
                    Text(
                      'Vitamins:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: List<Widget>.from(
                        (nutrition['vitamins'] as List).map(
                          (v) => Chip(label: Text(v)),
                        ),
                      ),
                    ),
                  ],
                  if (nutrition['minerals'] != null &&
                      nutrition['minerals'].isNotEmpty) ...[
                    SizedBox(height: 8),
                    Text(
                      'Minerals:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Wrap(
                      spacing: 8,
                      children: List<Widget>.from(
                        (nutrition['minerals'] as List).map(
                          (m) => Chip(label: Text(m)),
                        ),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              SizedBox(width: 12),
              Text(label, style: TextStyle(fontSize: 16)),
            ],
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipesTab() {
    final recipes = _foodInfo?['recipes'];
    if (recipes == null || recipes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No recipes found', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    final likedRecipes = recipes
        .where((r) => _likedRecipes.contains(r['title']))
        .toList();
    final unlikedRecipes = recipes
        .where((r) => !_likedRecipes.contains(r['title']))
        .toList();

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 500),
      child: ListView(
        key: ValueKey(_likedRecipes.length),
        padding: EdgeInsets.all(16),
        children: [
          if (likedRecipes.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pink.shade100, Colors.purple.shade100],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Liked Recipes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade700,
                ),
              ),
            ),
            SizedBox(height: 8),
            ...likedRecipes
                .map((recipe) => _buildRecipeCard(recipe, isLiked: true))
                .toList(),
            Divider(height: 32),
          ],
          ...unlikedRecipes
              .map((recipe) => _buildRecipeCard(recipe, isLiked: false))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildRecipeCard(Map recipe, {required bool isLiked}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.95, end: 1),
      duration: Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) {
        return Transform.scale(scale: scale, child: child);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showRecipeDetail(recipe['title']),
          child: Card(
            margin: EdgeInsets.only(bottom: 16),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            shadowColor: Colors.pink.shade100,
            color: Colors.white,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: isLiked
                        ? Colors.pink.shade100
                        : Colors.grey.shade100,
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            recipe['title'],
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (isLiked) {
                                _likedRecipes.remove(recipe['title']);
                              } else {
                                _likedRecipes.add(recipe['title']);
                              }
                            });
                          },
                          child: AnimatedSwitcher(
                            duration: Duration(milliseconds: 300),
                            transitionBuilder: (child, anim) =>
                                ScaleTransition(scale: anim, child: child),
                            child: Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              key: ValueKey(isLiked),
                              color: isLiked ? Colors.pink : Colors.grey,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    if (recipe['description'] != null)
                      Text(
                        recipe['description'],
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 16, color: Colors.orange),
                        SizedBox(width: 4),
                        Text('${recipe['cookingTime'] ?? 'N/A'} min'),
                        SizedBox(width: 16),
                        Icon(Icons.people, size: 16, color: Colors.purple),
                        SizedBox(width: 4),
                        Text('${recipe['servings'] ?? 'N/A'} servings'),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap to view recipe details',
                      style: TextStyle(
                        color: Colors.green.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllergensTab() {
    final allergens = _foodInfo?['allergens'];
    final allergyDetails = _foodInfo?['allergyDetails'];

    if (allergens == null || allergens.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'No common allergens detected',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'This food appears to be allergen-free',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Pie chart for allergen distribution
    final allergenCounts = <String, int>{};
    for (var allergen in allergens) {
      allergenCounts[allergen] = (allergenCounts[allergen] ?? 0) + 1;
    }
    final totalAllergens = allergens.length;
    final chartSections = allergenCounts.entries
        .map(
          (entry) => PieChartSectionData(
            value: entry.value.toDouble(),
            title: entry.key,
            color:
                Colors.primaries[entry.key.hashCode % Colors.primaries.length],
            radius: 60,
          ),
        )
        .toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 220,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
            ),
            child: Column(
              children: [
                Text(
                  'Allergen Distribution',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 12),
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sections: chartSections,
                      centerSpaceRadius: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600),
                    SizedBox(width: 8),
                    Text(
                      'Allergen Warning',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  'This food contains the following allergens:',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          ...allergens
              .map(
                (allergen) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  color: Colors.red.shade50,
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red.shade600),
                    title: Text(
                      allergen.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                    subtitle: Text('May cause allergic reactions'),
                  ),
                ),
              )
              .toList(),
          if (allergyDetails != null && allergyDetails.isNotEmpty) ...[
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.yellow.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detailed Allergy Info',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(allergyDetails),
                ],
              ),
            ),
          ],
          SizedBox(height: 24),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Important Note',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'This information is for general guidance only. Always check food labels and consult with healthcare professionals if you have food allergies.',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRecipeDetail(String recipeTitle) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Loading recipe...'),
        content: CircularProgressIndicator(),
      ),
    );

    try {
      final recipe = await FoodApiService.getDetailedRecipe(recipeTitle);
      Navigator.pop(context); // Close loading dialog

      if (recipe != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(recipe['title'] ?? recipeTitle),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (recipe['description'] != null) ...[
                    Text(
                      'Description:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(recipe['description']),
                    SizedBox(height: 16),
                  ],
                  Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (recipe['ingredients'] != null)
                    ...(recipe['ingredients'] as List)
                        .map(
                          (ingredient) => Text(
                            '• ${ingredient['amount']} ${ingredient['unit']} ${ingredient['name']}',
                          ),
                        )
                        .toList()
                  else
                    Text('No ingredients available'),
                  SizedBox(height: 16),
                  Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  if (recipe['instructions'] != null &&
                      (recipe['instructions'] as List).isNotEmpty) ...[
                    Text(
                      'Cooking Steps:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 4),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (recipe['instructions'] as List)
                          .asMap()
                          .entries
                          .map(
                            (entry) => Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 2.0,
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.key + 1}. ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Expanded(child: Text(entry.value)),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ] else ...[
                    Text('No instructions available'),
                  ],
                  if (recipe['tips'] != null &&
                      (recipe['tips'] as List).isNotEmpty) ...[
                    SizedBox(height: 16),
                    Text(
                      'Cooking Tips:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...(recipe['tips'] as List)
                        .map((tip) => Text('• $tip'))
                        .toList(),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading recipe details: $e')),
      );
    }
  }
}

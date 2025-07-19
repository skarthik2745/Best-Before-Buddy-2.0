import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'food_item.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_ml_kit/google_ml_kit.dart';
import 'camera_scanner_screen.dart';
import 'food_api_service.dart';
import 'food_detail_screen.dart';
import 'recipe_detail_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:simple_web_camera/simple_web_camera.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_service.dart';
import 'database_status_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyDqBUYQsxzy_c4CW7G8qb3GUQRIUgc0geE",
        authDomain: "food-expiry--db.firebaseapp.com",
        databaseURL: "https://food-expiry--db-default-rtdb.firebaseio.com",
        projectId: "food-expiry--db",
        storageBucket: "food-expiry--db.appspot.com",
        messagingSenderId: "439141650636",
        appId: "1:439141650636:web:76ba01de82c906af797269",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(SmartFoodApp());
}

class SmartFoodApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Food Nutrition & Scanner AI',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 8,
            shadowColor: Colors.black26,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 12,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
      home: FrontPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FrontPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade700,
              Colors.green.shade900,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 24,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/apple logo.jpg',
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Best Before Buddy',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                          letterSpacing: 1.2,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Your smart companion for tracking food freshness, expiry, and healthy choices.',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.green.shade700,
                          height: 1.4,
                          fontFamily: 'Montserrat',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      _FeatureCard(
                        icon: Icons.camera_alt,
                        title: 'Smart Scanning',
                        description:
                            'AI-powered food detection & expiry scanning',
                        color: Colors.blue.shade600,
                      ),
                      _FeatureCard(
                        icon: Icons.mic,
                        title: 'Voice Input',
                        description: 'Speak to add food items instantly',
                        color: Colors.purple.shade600,
                      ),
                      _FeatureCard(
                        icon: Icons.health_and_safety,
                        title: 'Nutrition Analysis',
                        description: 'Detailed nutrition & allergy information',
                        color: Colors.green.shade600,
                      ),
                      _FeatureCard(
                        icon: Icons.notifications_active,
                        title: 'Smart Reminders',
                        description: 'Expiry alerts & consumption tracking',
                        color: Colors.orange.shade600,
                      ),
                      SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder:
                                    (context, animation, secondaryAnimation) =>
                                        MainAppScaffold(),
                                transitionsBuilder:
                                    (
                                      context,
                                      animation,
                                      secondaryAnimation,
                                      child,
                                    ) {
                                      return FadeTransition(
                                        opacity: animation,
                                        child: child,
                                      );
                                    },
                                transitionDuration: Duration(milliseconds: 800),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            textStyle: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 12,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.arrow_forward, size: 24),
                              SizedBox(width: 12),
                              Text('Get Started'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String text;
  const FeatureTile({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.all(8),
            child: Icon(icon, color: Colors.green.shade700, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16, color: Colors.green.shade900),
            ),
          ),
        ],
      ),
    );
  }
}

class MainAppScaffold extends StatefulWidget {
  @override
  State<MainAppScaffold> createState() => _MainAppScaffoldState();
}

class _MainAppScaffoldState extends State<MainAppScaffold>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  List<FoodItem> _foodItems = [];
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _speechEnabled = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showAssistantChat = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _initSpeech();
    _loadFoodItemsFromFirebase();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  Future<void> _loadFoodItemsFromFirebase() async {
    try {
      final items = await FirebaseService.getFoodItems();
      if (mounted) {
        setState(() {
          _foodItems = items;
        });
      }
    } catch (e) {
      print('Error loading food items from Firebase: $e');
    }
  }

  void _addFoodItem(FoodItem item) async {
    setState(() {
      _foodItems.add(item);
    });

    // Save to Firebase
    try {
      await FirebaseService.addFoodItem(item);
    } catch (e) {
      print('Error saving to Firebase: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving to database: $e')));
    }

    Future<Map<String, dynamic>?> fetchWithRetry(
      String name, {
      int retries = 1,
    }) async {
      for (int attempt = 0; attempt <= retries; attempt++) {
        try {
          final foodInfo = await FoodApiService.getComprehensiveFoodInfo(name);
          if (foodInfo['nutrition'] != null ||
              (foodInfo['recipes'] != null && foodInfo['recipes'].isNotEmpty) ||
              (foodInfo['allergens'] != null &&
                  foodInfo['allergens'].isNotEmpty)) {
            return foodInfo;
          }
        } catch (e) {
          if (attempt == retries) rethrow;
        }
      }
      return null;
    }

    try {
      final foodInfo = await fetchWithRetry(item.name, retries: 1);
      if (foodInfo == null) throw Exception('No data from Gemini API');

      // Create updated food item with API data
      final updatedItem = FoodItem(
        name: item.name,
        expiryDate: item.expiryDate,
        imageBytes: item.imageBytes,
        nutritionInfo:
            (foodInfo['nutrition'] != null && foodInfo['nutrition'].isNotEmpty)
            ? 'Calories: \\${foodInfo['nutrition']['calories']?.toStringAsFixed(1)} kcal\n'
              'Protein: \\${foodInfo['nutrition']['protein']?.toStringAsFixed(1)}g\n'
              'Carbs: \\${foodInfo['nutrition']['carbs']?.toStringAsFixed(1)}g\n'
              'Fat: \\${foodInfo['nutrition']['fat']?.toStringAsFixed(1)}g\n'
              'Fiber: \\${foodInfo['nutrition']['fiber']?.toStringAsFixed(1)}g\n'
              'Sugar: \\${foodInfo['nutrition']['sugar']?.toStringAsFixed(1)}g\n'
              'Sodium: \\${foodInfo['nutrition']['sodium']?.toStringAsFixed(1)}mg'
            : 'No nutrition data available',
        recipeInfo:
            foodInfo['recipes'] != null && foodInfo['recipes'].isNotEmpty
            ? 'Found \\${foodInfo['recipes'].length} recipes for \\${item.name}'
            : null,
        allergyInfo:
            (foodInfo['allergens'] != null && foodInfo['allergens'].isNotEmpty)
            ? 'Contains: \\${foodInfo['allergens'].join(', ')}'
            : 'No allergy data available',
        nutritionValues: foodInfo['nutrition'] != null
            ? {
                'calories': foodInfo['nutrition']['calories'] ?? 0.0,
                'protein': foodInfo['nutrition']['protein'] ?? 0.0,
                'carbs': foodInfo['nutrition']['carbs'] ?? 0.0,
                'fat': foodInfo['nutrition']['fat'] ?? 0.0,
                'fiber': foodInfo['nutrition']['fiber'] ?? 0.0,
                'sugar': foodInfo['nutrition']['sugar'] ?? 0.0,
                'sodium': foodInfo['nutrition']['sodium'] ?? 0.0,
              }
            : null,
        location: item.location ?? 'Unknown',
      );

      setState(() {
        final idx = _foodItems.indexWhere(
          (f) => f.name == item.name && f.expiryDate == item.expiryDate,
        );
        if (idx != -1) {
          _foodItems[idx] = updatedItem;
        } else if (_foodItems.isNotEmpty) {
          _foodItems[_foodItems.length - 1] = updatedItem;
        }
      });
    } catch (e) {
      print('Error fetching food information: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading food information: $e')),
      );
    }
  }

  void _updateFoodItem(int index, FoodItem item) async {
    setState(() {
      _foodItems[index] = item;
    });

    // Update in Firebase (you'll need to store document IDs for this to work properly)
    // For now, we'll just add the updated item
    try {
      await FirebaseService.addFoodItem(item);
    } catch (e) {
      print('Error updating in Firebase: $e');
    }
  }

  void _toggleFavorite(FoodItem item) {
    final updatedItem = item.copyWith(isFavorite: !item.isFavorite);
    final index = _foodItems.indexWhere((f) => f.name == item.name);
    if (index != -1) {
      setState(() {
        _foodItems[index] = updatedItem;
      });
    }
  }

  // Test API connection
  void _testApiConnection() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Testing API Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing Gemini API connection...'),
          ],
        ),
      ),
    );

    try {
      final isWorking = await FoodApiService.testApiConnection();
      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('API Test Result'),
          content: Text(
            isWorking
                ? '✅ Gemini API is working correctly!\n\nYou can now use all features including:\n• Food scanning\n• Nutrition analysis\n• Recipe generation\n• Allergen detection'
                : '❌ API connection failed.\n\nPlease check your internet connection and try again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('API test error: $e')));
    }
  }

  // Test Firebase Database connection
  void _testDatabaseConnection() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Testing Database Connection'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Testing Firebase Database connection...'),
          ],
        ),
      ),
    );

    try {
      // Test 1: Try to add a test item
      final testItem = FoodItem(
        name: 'Test Food Item',
        expiryDate: DateTime.now().add(Duration(days: 7)),
        location: 'Test Location',
      );

      await FirebaseService.addFoodItem(testItem);

      // Test 2: Try to retrieve items
      final items = await FirebaseService.getFoodItems();

      Navigator.pop(context); // Close loading dialog

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Database Test Result'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Firebase Database is working correctly!'),
              SizedBox(height: 16),
              Text('Test Results:'),
              Text('• Write operation: ✅ Success'),
              Text('• Read operation: ✅ Success'),
              Text('• Total items in database: ${items.length}'),
              SizedBox(height: 8),
              Text(
                'Your food items will now be saved to the cloud!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Database Test Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ Database connection failed.'),
              SizedBox(height: 8),
              Text('Error: $e'),
              SizedBox(height: 16),
              Text('Please check:'),
              Text('• Internet connection'),
              Text('• Firebase configuration'),
              Text('• Database rules'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // Enhanced Gemini API call with image analysis
  Future<FoodItem> _fetchGeminiInfo(FoodItem item) async {
    final apiKey = "AIzaSyDa4RWPw66dkX3sXqpQdFoIrGLWx825X9U";
    final model = "gemini-2.5-flash";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
    );

    // If we have an image, send it to Gemini for food detection
    final prompt = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  """
Food name: ${item.name}

Provide:
1. A nutritional breakdown (macros, vitamins, minerals).
2. One or two simple healthy recipe ideas.
3. Suitability for children, diabetics, and pregnant women.
4. Allergy analysis and age-based risk.
5. Vitamin and mineral deficiencies for the user based on food database.
6. If the food is spoiled or has visible damage, describe the risk and how to use it safely.
              """,
            },
            if (item.imageBytes != null)
              {
                "inlineData": {
                  "mimeType": "image/jpeg",
                  "data": base64Encode(item.imageBytes!),
                },
              },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;
        // Improved parsing
        String? recipe, nutrition, allergy, spoilage;
        final recipeMatch = RegExp(
          r'(?:Recipe|Recipes|Healthy recipe ideas)[\s\S]*?(?=(Nutrition|Nutritional breakdown|Allergy|Allerg|Spoilage|Risk|$))',
          caseSensitive: false,
        ).firstMatch(text);
        final nutritionMatch = RegExp(
          r'(?:Nutrition|Nutritional breakdown)[\s\S]*?(?=(Recipe|Healthy recipe ideas|Allergy|Allerg|Spoilage|Risk|$))',
          caseSensitive: false,
        ).firstMatch(text);
        final allergyMatch = RegExp(
          r'(?:Allergy|Allergy analysis|Allerg|Allergy risk)[\s\S]*?(?=(Recipe|Healthy recipe ideas|Nutrition|Nutritional breakdown|Spoilage|Risk|$))',
          caseSensitive: false,
        ).firstMatch(text);
        final spoilageMatch = RegExp(
          r'(?:Spoilage|Risk|Spoiled|Physical damage)[\s\S]*?(?=(Recipe|Healthy recipe ideas|Nutrition|Nutritional breakdown|Allergy|Allerg|$))',
          caseSensitive: false,
        ).firstMatch(text);
        recipe = recipeMatch != null ? recipeMatch.group(0)?.trim() : null;
        nutrition = nutritionMatch != null
            ? nutritionMatch.group(0)?.trim()
            : null;
        allergy = allergyMatch != null ? allergyMatch.group(0)?.trim() : null;
        spoilage = spoilageMatch != null
            ? spoilageMatch.group(0)?.trim()
            : null;
        // Fallback: if all are null, show raw text in recipe
        if ([
          recipe,
          nutrition,
          allergy,
          spoilage,
        ].every((s) => s == null || s.isEmpty)) {
          recipe = text;
        }
        return FoodItem(
          name: item.name,
          expiryDate: item.expiryDate,
          imageBytes: item.imageBytes,
          recipeInfo: recipe,
          nutritionInfo: nutrition,
          allergyInfo: allergy,
          spoilageInfo: spoilage,
          location: item.location ?? 'Unknown',
        );
      } else {
        return item;
      }
    } catch (e) {
      return item;
    }
  }

  // Function to detect food name from image using Gemini
  Future<String?> _detectFoodFromImage(Uint8List imageBytes) async {
    final apiKey = "AIzaSyDa4RWPw66dkX3sXqpQdFoIrGLWx825X9U";
    final model = "gemini-2.5-flash";
    final url = Uri.parse(
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey",
    );

    final prompt = {
      "contents": [
        {
          "parts": [
            {
              "text":
                  "What food item is shown in this image? Respond with only the food name, nothing else.",
            },
            {
              "inlineData": {
                "mimeType": "image/jpeg",
                "data": base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return decoded['candidates'][0]['content']['parts'][0]['text']
            as String;
      }
    } catch (e) {
      print('Error detecting food: $e');
    }
    return null;
  }

  // Function to extract expiry date from image using OCR
  Future<DateTime?> _extractExpiryDateFromImage(XFile pickedFile) async {
    try {
      final inputImage = InputImage.fromFilePath(pickedFile.path);
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Look for date patterns in the recognized text
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.toLowerCase();
          // Look for expiry date patterns
          if (text.contains('expiry') ||
              text.contains('exp') ||
              text.contains('best before') ||
              text.contains('use by')) {
            // Extract date from the text
            final dateMatch = RegExp(
              r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
            ).firstMatch(text);
            if (dateMatch != null) {
              final day = int.parse(dateMatch.group(1)!);
              final month = int.parse(dateMatch.group(2)!);
              final year = int.parse(dateMatch.group(3)!);
              return DateTime(year, month, day);
            }
          }
        }
      }
      textRecognizer.close();
    } catch (e) {
      print('Error extracting expiry date: $e');
    }
    return null;
  }

  // Function to extract expiry date from image bytes using OCR
  Future<DateTime?> _extractExpiryDateFromImageBytes(
    Uint8List imageBytes,
  ) async {
    try {
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata: InputImageMetadata(
          size: Size(640, 480),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.bgra8888,
          bytesPerRow: 640 * 4,
        ),
      );
      final textRecognizer = GoogleMlKit.vision.textRecognizer();
      final RecognizedText recognizedText = await textRecognizer.processImage(
        inputImage,
      );

      // Look for date patterns in the recognized text
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          final text = line.text.toLowerCase();
          // Look for expiry date patterns
          if (text.contains('expiry') ||
              text.contains('exp') ||
              text.contains('best before') ||
              text.contains('use by')) {
            // Extract date from the text
            final dateMatch = RegExp(
              r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})',
            ).firstMatch(text);
            if (dateMatch != null) {
              final day = int.parse(dateMatch.group(1)!);
              final month = int.parse(dateMatch.group(2)!);
              final year = int.parse(dateMatch.group(3)!);
              return DateTime(year, month, day);
            }
          }
        }
      }
      textRecognizer.close();
    } catch (e) {
      print('Error extracting expiry date: $e');
    }
    return null;
  }

  // Enhanced function to parse voice input with recipe prediction
  Future<Map<String, dynamic>?> _parseVoiceInput(String voiceText) async {
    try {
      final text = voiceText.toLowerCase();
      String? foodName;
      DateTime? expiryDate;
      String? recipeSuggestion;
      String? nutritionInfo;

      // Enhanced food name extraction with more comprehensive keywords
      final foodKeywords = [
        // Fruits
        'apple',
        'banana',
        'orange',
        'strawberry',
        'blueberry',
        'raspberry',
        'grape',
        'pear',
        'peach',
        'plum',
        'cherry',
        'mango',
        'pineapple',
        'kiwi',
        'lemon',
        'lime',
        // Vegetables
        'tomato',
        'potato',
        'carrot',
        'lettuce',
        'spinach',
        'onion',
        'garlic',
        'broccoli',
        'cauliflower',
        'cucumber',
        'bell pepper',
        'mushroom',
        'zucchini',
        'eggplant',
        'corn',
        'peas',
        // Dairy
        'milk',
        'cheese',
        'yogurt',
        'butter',
        'cream',
        'sour cream',
        'cottage cheese',
        'cream cheese',
        // Meat & Fish
        'chicken',
        'beef',
        'pork',
        'lamb',
        'fish',
        'salmon',
        'tuna',
        'shrimp',
        'turkey',
        'duck',
        // Grains
        'bread',
        'rice',
        'pasta',
        'flour',
        'oatmeal',
        'cereal',
        'quinoa',
        'barley',
        'wheat',
        // Nuts & Seeds
        'almond',
        'walnut',
        'peanut',
        'cashew',
        'sunflower seed',
        'chia seed',
        'flax seed',
        // Beverages
        'juice', 'water', 'coffee', 'tea', 'soda', 'beer', 'wine',
        // Processed Foods
        'pizza',
        'burger',
        'sandwich',
        'salad',
        'soup',
        'stew',
        'curry',
        'pasta sauce',
        'ketchup',
        'mustard',
        'mayonnaise',
        // Snacks
        'cookies',
        'chocolate',
        'ice cream',
        'chips',
        'popcorn',
        'nuts',
        'crackers',
        // Cooking Ingredients
        'oil',
        'sugar',
        'salt',
        'pepper',
        'herbs',
        'spices',
        'vinegar',
        'soy sauce',
        'honey',
        'maple syrup',
        // Eggs
        'eggs', 'egg',
      ];

      // Find food name by looking for food keywords
      for (String keyword in foodKeywords) {
        if (text.contains(keyword)) {
          foodName =
              keyword.substring(0, 1).toUpperCase() + keyword.substring(1);
          break;
        }
      }

      // If no food keyword found, try to extract first meaningful word
      if (foodName == null) {
        final words = text.split(' ');
        for (String word in words) {
          if (word.length > 2 && !word.contains(RegExp(r'\d'))) {
            foodName = word.substring(0, 1).toUpperCase() + word.substring(1);
            break;
          }
        }
      }

      // Extract expiry date with more patterns
      final datePatterns = [
        // "12th June 2025" or "12 June 2025" format
        RegExp(
          r'(\d{1,2})(?:st|nd|rd|th)?\s+(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{4})',
          caseSensitive: false,
        ),
        // "12/06/2025" or "12-06-2025" format
        RegExp(r'(\d{1,2})[/-](\d{1,2})[/-](\d{2,4})'),
        // "June 12th 2025" or "June 12 2025" format
        RegExp(
          r'(january|february|march|april|may|june|july|august|september|october|november|december)\s+(\d{1,2})(?:st|nd|rd|th)?\s+(\d{4})',
          caseSensitive: false,
        ),
        // "2025-06-12" format
        RegExp(r'(\d{4})[/-](\d{1,2})[/-](\d{1,2})'),
        // Relative dates
        RegExp(r'(today|tomorrow|next week|next month)', caseSensitive: false),
      ];

      for (final pattern in datePatterns) {
        final match = pattern.firstMatch(text);
        if (match != null) {
          try {
            if (pattern == datePatterns[4]) {
              // Relative dates
              final relativeDate = match.group(1)!.toLowerCase();
              switch (relativeDate) {
                case 'today':
                  expiryDate = DateTime.now();
                  break;
                case 'tomorrow':
                  expiryDate = DateTime.now().add(Duration(days: 1));
                  break;
                case 'next week':
                  expiryDate = DateTime.now().add(Duration(days: 7));
                  break;
                case 'next month':
                  expiryDate = DateTime.now().add(Duration(days: 30));
                  break;
              }
            } else if (pattern == datePatterns[0] ||
                pattern == datePatterns[2]) {
              // Month name format
              final months = [
                'january',
                'february',
                'march',
                'april',
                'may',
                'june',
                'july',
                'august',
                'september',
                'october',
                'november',
                'december',
              ];
              if (pattern == datePatterns[0]) {
                // "12th June 2025" or "12 June 2025" format
                final day = int.parse(match.group(1)!);
                final monthName = match.group(2)!.toLowerCase();
                final year = int.parse(match.group(3)!);
                final month = months.indexOf(monthName) + 1;
                expiryDate = DateTime(year, month, day);
              } else {
                // "June 12th 2025" or "June 12 2025" format
                final monthName = match.group(1)!.toLowerCase();
                final day = int.parse(match.group(2)!);
                final year = int.parse(match.group(3)!);
                final month = months.indexOf(monthName) + 1;
                expiryDate = DateTime(year, month, day);
              }
            } else {
              // Numeric format
              if (pattern == datePatterns[1]) {
                // "12/06/2025" format
                final day = int.parse(match.group(1)!);
                final month = int.parse(match.group(2)!);
                final year = int.parse(match.group(3)!);
                expiryDate = DateTime(year, month, day);
              } else {
                // "2025-06-12" format
                final year = int.parse(match.group(1)!);
                final month = int.parse(match.group(2)!);
                final day = int.parse(match.group(3)!);
                expiryDate = DateTime(year, month, day);
              }
            }
            break;
          } catch (e) {
            print('Error parsing date: $e');
            continue;
          }
        }
      }

      // If food name is found, get recipe suggestions and nutrition info
      if (foodName != null) {
        try {
          final foodInfo = await FoodApiService.getComprehensiveFoodInfo(
            foodName,
          );

          // Extract recipe suggestion
          if (foodInfo['recipes'] != null && foodInfo['recipes'].isNotEmpty) {
            final recipe = foodInfo['recipes'][0];
            recipeSuggestion =
                'Quick Recipe: ${recipe['title'] ?? 'Delicious $foodName recipe'}';
          }

          // Extract nutrition info
          if (foodInfo['nutrition'] != null) {
            final nutrition = foodInfo['nutrition'];
            nutritionInfo =
                'Calories: ${nutrition['calories']?.toStringAsFixed(1)} kcal | Protein: ${nutrition['protein']?.toStringAsFixed(1)}g | Carbs: ${nutrition['carbs']?.toStringAsFixed(1)}g';
          }
        } catch (e) {
          print('Error fetching food info for voice input: $e');
        }
      }

      return {
        'foodName': foodName,
        'expiryDate': expiryDate,
        'recipeSuggestion': recipeSuggestion,
        'nutritionInfo': nutritionInfo,
      };
    } catch (e) {
      print('Error parsing voice input: $e');
      return null;
    }
  }

  // Function to handle voice recipe commands
  Future<void> _handleVoiceRecipeCommand(String voiceText) async {
    final text = voiceText.toLowerCase();

    // Check for recipe-related commands
    if (text.contains('recipe') ||
        text.contains('cook') ||
        text.contains('make')) {
      // Extract food name from recipe command
      String? foodName;
      final foodKeywords = [
        'apple',
        'banana',
        'chicken',
        'beef',
        'fish',
        'rice',
        'pasta',
        'tomato',
        'potato',
        'carrot',
        'lettuce',
        'spinach',
        'onion',
        'garlic',
        'milk',
        'cheese',
        'yogurt',
        'eggs',
        'bread',
        'butter',
        'oil',
        'sugar',
        'salt',
        'flour',
        'sauce',
        'juice',
        'coffee',
        'tea',
        'cereal',
        'cookies',
        'chocolate',
        'ice cream',
        'pizza',
        'burger',
        'sandwich',
        'salad',
        'soup',
        'strawberry',
        'blueberry',
        'grape',
        'pear',
        'peach',
        'mango',
        'pineapple',
        'kiwi',
        'lemon',
        'lime',
        'broccoli',
        'cauliflower',
        'cucumber',
        'bell pepper',
        'mushroom',
        'zucchini',
        'eggplant',
        'corn',
        'peas',
        'pork',
        'lamb',
        'salmon',
        'tuna',
        'shrimp',
        'turkey',
        'duck',
        'oatmeal',
        'quinoa',
        'barley',
        'wheat',
        'almond',
        'walnut',
        'peanut',
        'cashew',
        'sunflower seed',
        'chia seed',
        'flax seed',
        'soda',
        'beer',
        'wine',
        'stew',
        'curry',
        'pasta sauce',
        'ketchup',
        'mustard',
        'mayonnaise',
        'chips',
        'popcorn',
        'nuts',
        'crackers',
        'pepper',
        'herbs',
        'spices',
        'vinegar',
        'soy sauce',
        'honey',
        'maple syrup',
      ];

      for (String keyword in foodKeywords) {
        if (text.contains(keyword)) {
          foodName =
              keyword.substring(0, 1).toUpperCase() + keyword.substring(1);
          break;
        }
      }

      if (foodName != null) {
        // Show recipe suggestions for the detected food
        _showVoiceRecipeSuggestions(foodName);
      } else {
        // Show general recipe suggestions
        _showVoiceRecipeSuggestions('general');
      }
    }
  }

  // Function to show recipe suggestions from voice command
  void _showVoiceRecipeSuggestions(String foodName) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Recipe Suggestions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding recipes for $foodName...'),
          ],
        ),
      ),
    );

    try {
      final foodInfo = await FoodApiService.getComprehensiveFoodInfo(foodName);
      Navigator.pop(context); // Close loading dialog

      if (foodInfo['recipes'] != null && foodInfo['recipes'].isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Recipes for $foodName'),
            content: Container(
              width: double.maxFinite,
              height: 300,
              child: ListView.builder(
                itemCount: foodInfo['recipes'].length,
                itemBuilder: (context, index) {
                  final recipe = foodInfo['recipes'][index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.restaurant,
                        color: Colors.orange.shade600,
                      ),
                      title: Text(recipe['title'] ?? 'Recipe ${index + 1}'),
                      subtitle: Text(
                        recipe['description'] ?? 'Delicious recipe',
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        // Create a temporary food item to show recipe details
                        final tempItem = FoodItem(
                          name: foodName,
                          recipeInfo:
                              'Recipe: ${recipe['title']}\n${recipe['description'] ?? ''}',
                          location: 'Unknown',
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeDetailScreen(
                              foodItem: tempItem,
                              onFavoriteToggle: (item) {
                                // Handle favorite toggle for temp item
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
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
      } else {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No recipes found for $foodName'),
            backgroundColor: Colors.orange.shade600,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching recipes: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    }
  }

  // Get nutrition information for a food item
  Future<String?> _getNutritionInfo(String foodName) async {
    try {
      final nutritionData = await FoodApiService.getNutritionInfo(foodName);
      if (nutritionData != null) {
        return 'Calories: ${nutritionData['calories']?.toStringAsFixed(1)} kcal\n' +
            'Protein: ${nutritionData['protein']?.toStringAsFixed(1)}g\n' +
            'Carbs: ${nutritionData['carbs']?.toStringAsFixed(1)}g\n' +
            'Fat: ${nutritionData['fat']?.toStringAsFixed(1)}g\n' +
            'Fiber: ${nutritionData['fiber']?.toStringAsFixed(1)}g\n' +
            'Sugar: ${nutritionData['sugar']?.toStringAsFixed(1)}g\n' +
            'Sodium: ${nutritionData['sodium']?.toStringAsFixed(1)}mg';
      }
    } catch (e) {
      print('Error getting nutrition info: $e');
    }
    return null;
  }

  // Get allergy information for a food item
  Future<String?> _getAllergyInfo(String foodName) async {
    try {
      final allergens = await FoodApiService.getAllergenInfo(foodName);
      if (allergens != null && allergens.isNotEmpty) {
        return 'Contains: ${allergens.join(', ')}';
      }
    } catch (e) {
      print('Error getting allergy info: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardPage(
        foodItems: _foodItems,
        addFoodItem: _addFoodItem,
        toggleFavorite: _toggleFavorite,
      ),
      InventoryPage(foodItems: _foodItems),
      AIRecipePage(foodItems: _foodItems),
      NutritionPage(foodItems: _foodItems),
      AllergyPage(foodItems: _foodItems),
      WasteManagementPage(foodItems: _foodItems),
    ];
    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(opacity: _fadeAnimation, child: pages[_selectedIndex]),
          if (_showAssistantChat)
            Center(
              child: SizedBox(
                width: 370,
                child: Material(
                  elevation: 8,
                  borderRadius: BorderRadius.circular(24),
                  child: FoodAssistantChat(
                    onClose: () => setState(() => _showAssistantChat = false),
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "test_database",
            onPressed: _testDatabaseConnection,
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            tooltip: 'Test Database Connection',
            child: Icon(Icons.storage),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "test_api",
            onPressed: _testApiConnection,
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            tooltip: 'Test API Connection',
            child: Icon(Icons.bug_report),
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: "chat_assistant",
            backgroundColor: Colors.green.shade600,
            child: Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              setState(() => _showAssistantChat = !_showAssistantChat);
            },
            tooltip: 'Smart Food Assistant',
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.grey.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: Colors.green.shade700,
          unselectedItemColor: Colors.grey.shade600,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_rounded),
              label: 'Inventory',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_rounded),
              label: 'Recipes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              label: 'Nutrition',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning_amber_rounded),
              label: 'Allergies',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.recycling_rounded),
              label: 'Waste',
            ),
          ],
        ),
      ),
    );
  }
}

// --- Dashboard Page ---
class DashboardPage extends StatelessWidget {
  final List<FoodItem> foodItems;
  final Function(FoodItem) addFoodItem;
  final Function(FoodItem) toggleFavorite;
  const DashboardPage({
    required this.foodItems,
    required this.addFoodItem,
    required this.toggleFavorite,
  });

  void _showScanDialog(BuildContext context) async {
    if (kIsWeb) {
      // Use web camera widget
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SimpleWebCameraPage(
            appBarTitle: "Scan Food Item",
            centerTitle: true,
          ),
        ),
      );
      if (result is String && result.isNotEmpty) {
        Uint8List imageBytes = base64Decode(result);
        // Auto-detect food name using Gemini API
        String? foodName = await FoodApiService.detectFoodNameFromImage(
          imageBytes,
        );
        if (foodName == null || foodName == 'Unknown' || foodName.isEmpty) {
          // Fallback to manual entry if detection fails
          foodName = await _promptForName(context);
        }
        // Prompt for expiry and location only
        DateTime? expiry = await _promptForExpiry(context);
        String? selectedLocation;
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Storage Location'),
            content: _LocationInput(onChanged: (loc) => selectedLocation = loc),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedLocation != null &&
                      selectedLocation!.trim().isNotEmpty) {
                    Navigator.pop(context);
                  }
                },
                child: Text('OK'),
              ),
            ],
          ),
        );
        if (foodName != null &&
            expiry != null &&
            selectedLocation != null &&
            selectedLocation!.trim().isNotEmpty) {
          final foodItem = FoodItem(
            name: foodName,
            expiryDate: expiry,
            imageBytes: imageBytes,
            location: selectedLocation!,
          );
          addFoodItem(foodItem);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added $foodName to inventory!'),
              backgroundColor: Colors.green.shade600,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      // Use your existing CameraScannerScreen for mobile
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('No camera available')));
        return;
      }
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CameraScannerScreen(
            camera: cameras.first,
            onFoodDetected: (foodName, imageBytes) async {
              // Show loading dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Text('Analyzing Image...'),
                  content: Row(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text('Detecting food and expiry date...'),
                    ],
                  ),
                ),
              );
              final state = context
                  .findAncestorStateOfType<_MainAppScaffoldState>();
              if (state != null) {
                final expiryDate = await state._extractExpiryDateFromImageBytes(
                  imageBytes,
                );
                Navigator.pop(context);
                final confirmedName = await _promptForName(
                  context,
                  initialValue: foodName,
                );
                final confirmedExpiry = await _promptForExpiry(
                  context,
                  initialDate: expiryDate,
                );
                if (confirmedName != null && confirmedExpiry != null) {
                  String? selectedLocation;
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Confirm Details'),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Food: $foodName'),
                          SizedBox(height: 8),
                          Text(
                            'Expiry: ${expiryDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
                          ),
                          SizedBox(height: 8),
                          _LocationInput(
                            onChanged: (loc) => selectedLocation = loc,
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (selectedLocation != null &&
                                selectedLocation!.trim().isNotEmpty) {
                              Navigator.pop(context);
                            }
                          },
                          child: Text('Add'),
                        ),
                      ],
                    ),
                  );
                  if (selectedLocation != null &&
                      selectedLocation!.trim().isNotEmpty) {
                    final foodItem = FoodItem(
                      name: confirmedName,
                      expiryDate: confirmedExpiry,
                      imageBytes: imageBytes,
                      location: selectedLocation!,
                    );
                    addFoodItem(foodItem);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added $confirmedName to inventory!'),
                        backgroundColor: Colors.green.shade600,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            },
          ),
        ),
      );
    }
  }

  void _showManualEntryDialog(BuildContext context) async {
    final name = await _promptForName(context);
    final expiry = await _promptForExpiry(context);
    String? selectedLocation;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Location'),
        content: _LocationInput(onChanged: (loc) => selectedLocation = loc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedLocation != null &&
                  selectedLocation!.trim().isNotEmpty) {
                Navigator.pop(context);
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
    if (name != null &&
        expiry != null &&
        selectedLocation != null &&
        selectedLocation!.trim().isNotEmpty) {
      final foodItem = FoodItem(
        name: name,
        expiryDate: expiry,
        location: selectedLocation!,
      );
      addFoodItem(foodItem);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $name to inventory!'),
          backgroundColor: Colors.green.shade600,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _showSimpleRecipeDetails(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.restaurant_menu_rounded, color: Colors.purple.shade600),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recipe for ${item.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageBytes != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(item.imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple.shade50, Colors.purple.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.purple.shade200, width: 1),
                ),
                child: Text(
                  item.recipeInfo ??
                      'No recipe information available. Check the Recipes tab for detailed recipes.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: Colors.purple.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Recipe added to favorites!'),
                  backgroundColor: Colors.purple.shade600,
                ),
              );
            },
            icon: Icon(Icons.favorite_border_rounded),
            label: Text('Favorite'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showVoiceInputDialog(BuildContext context) async {
    final state = context.findAncestorStateOfType<_MainAppScaffoldState>();
    if (state == null || !state._speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    String recognizedText = '';
    bool isListening = false;
    Map<String, dynamic>? parsedData;
    String? selectedLocation; // <-- fix scope here

    showDialog(
      context: context,
      builder: (context) => LayoutBuilder(
        builder: (context, constraints) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.mic, color: Colors.purple.shade600),
                SizedBox(width: 12),
                Text('Voice Input'),
              ],
            ),
            content: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: constraints.maxHeight * 0.9,
                maxWidth: 500,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Say something like:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('"Banana expiry date 12 June 2025"'),
                          Text('"Milk expires on 15/12/2024"'),
                          Text('"Apple best before 2024-12-20"'),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    // Recognition status
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isListening
                            ? Colors.green.shade50
                            : Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isListening
                              ? Colors.green.shade200
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isListening ? Icons.mic : Icons.mic_off,
                            color: isListening
                                ? Colors.green.shade600
                                : Colors.grey.shade600,
                          ),
                          SizedBox(width: 8),
                          Text(
                            isListening ? 'Listening...' : 'Not listening',
                            style: TextStyle(
                              color: isListening
                                  ? Colors.green.shade700
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    // Recognized text
                    if (recognizedText.isNotEmpty) ...[
                      Text(
                        'Recognized Text:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Text(
                          recognizedText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    // Parsed results
                    if (parsedData != null) ...[
                      Text(
                        'Parsed Results:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food: ${parsedData!['foodName'] ?? 'Not detected'}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (parsedData!['expiryDate'] != null) ...[
                              SizedBox(height: 4),
                              Text(
                                'Expiry: ${parsedData!['expiryDate'].toString().split(' ')[0]}',
                                style: TextStyle(color: Colors.green.shade700),
                              ),
                            ],
                            if (parsedData!['nutritionInfo'] != null) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.blue.shade200,
                                  ),
                                ),
                                child: Text(
                                  parsedData!['nutritionInfo']!
                                      .replaceAll('\n', ' ')
                                      .replaceAll('\\n', ' '),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ),
                            ],
                            if (parsedData!['recipeSuggestion'] != null) ...[
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.restaurant,
                                      size: 16,
                                      color: Colors.orange.shade700,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        parsedData!['recipeSuggestion']!
                                            .replaceAll('\n', ' ')
                                            .replaceAll('\\n', ' '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.orange.shade800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(height: 16),
                    ],
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!isListening) {
                              setDialogState(() => isListening = true);
                              await state._speechToText.listen(
                                onResult: (result) {
                                  setDialogState(() {
                                    recognizedText = result.recognizedWords;
                                  });
                                },
                              );
                            } else {
                              setDialogState(() => isListening = false);
                              await state._speechToText.stop();
                              // Parse the recognized text
                              if (recognizedText.isNotEmpty) {
                                final parsed = await state._parseVoiceInput(
                                  recognizedText,
                                );
                                setDialogState(() {
                                  parsedData = parsed;
                                });
                              }
                            }
                          },
                          icon: Icon(isListening ? Icons.stop : Icons.mic),
                          label: Text(isListening ? 'Stop' : 'Listen'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isListening
                                ? Colors.red.shade600
                                : Colors.purple.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              recognizedText = '';
                              parsedData = null;
                            });
                          },
                          icon: Icon(Icons.clear),
                          label: Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade600,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    _LocationInput(onChanged: (loc) => selectedLocation = loc),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (parsedData != null &&
                      parsedData!['foodName'] != null &&
                      selectedLocation != null &&
                      selectedLocation!.trim().isNotEmpty) {
                    Navigator.pop(context);
                    final String foodName = parsedData!['foodName'] as String;
                    final DateTime expiry =
                        parsedData!['expiryDate'] as DateTime? ??
                        DateTime.now().add(Duration(days: 7));
                    final foodItem = FoodItem(
                      name: foodName,
                      expiryDate: expiry,
                      location: selectedLocation!,
                    );
                    addFoodItem(foodItem);
                    final isExpired = expiry.isBefore(DateTime.now());
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isExpired
                              ? 'Added $foodName to inventory and Waste Management (expired)!'
                              : 'Added $foodName to inventory!',
                        ),
                        backgroundColor: isExpired
                            ? Colors.red.shade600
                            : Colors.green.shade600,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please speak clearly and try again'),
                        backgroundColor: Colors.orange.shade600,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade600,
                  foregroundColor: Colors.white,
                ),
                child: Text('Add to Inventory'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<String?> _promptForName(
    BuildContext context, {
    String? initialValue,
  }) async {
    String? foodName = initialValue;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Food Name'),
        content: TextField(
          autofocus: true,
          decoration: InputDecoration(labelText: 'Enter food name'),
          controller: TextEditingController(text: initialValue),
          onChanged: (val) => foodName = val,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
    return foodName;
  }

  static Future<DateTime?> _promptForExpiry(
    BuildContext context, {
    DateTime? initialDate,
  }) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
  }

  void _showRecipeDetails(BuildContext context, FoodItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailScreen(
          foodItem: item,
          onFavoriteToggle: toggleFavorite,
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, FoodItem item) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (item.imageBytes != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(
                        item.imageBytes!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Icon(
                      Icons.fastfood,
                      size: 60,
                      color: Colors.green.shade700,
                    ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              if (item.expiryDate != null)
                Text(
                  'Expiry: ${item.expiryDate!.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              SizedBox(height: 16),
              if (item.nutritionInfo != null && item.nutritionInfo!.isNotEmpty)
                _InfoCard(
                  icon: Icons.health_and_safety,
                  color: Colors.green.shade700,
                  title: 'Nutrition',
                  content: item.nutritionInfo!
                      .replaceAll('\n', ' ')
                      .replaceAll('\\n', ' '),
                ),
              if (item.recipeInfo != null && item.recipeInfo!.isNotEmpty)
                _InfoCard(
                  icon: Icons.restaurant_menu,
                  color: Colors.orange.shade700,
                  title: 'Recipe',
                  content: item.recipeInfo!
                      .replaceAll('\n', ' ')
                      .replaceAll('\\n', ' '),
                ),
              if (item.allergyInfo != null && item.allergyInfo!.isNotEmpty)
                _InfoCard(
                  icon: Icons.warning,
                  color: Colors.red.shade700,
                  title: 'Allergy',
                  content: item.allergyInfo!
                      .replaceAll('\n', ' ')
                      .replaceAll('\\n', ' '),
                ),
              if (item.spoilageInfo != null && item.spoilageInfo!.isNotEmpty)
                _InfoCard(
                  icon: Icons.error_outline,
                  color: Colors.red.shade400,
                  title: 'Spoilage',
                  content: item.spoilageInfo!
                      .replaceAll('\n', ' ')
                      .replaceAll('\\n', ' '),
                ),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FoodDetailScreen(foodItem: item),
                      ),
                    );
                  },
                  icon: Icon(Icons.info_outline),
                  label: Text('View Detailed Information'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final expiringSoon = foodItems
        .where(
          (item) =>
              item.expiryDate != null &&
              item.expiryDate!.isBefore(DateTime.now().add(Duration(days: 3))),
        )
        .toList();
    final totalItems = foodItems.length;
    final expiringCount = expiringSoon.length;
    final favorites = foodItems.where((item) => item.isFavorite).toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade50, Colors.white, Colors.green.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.green.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.dashboard_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Food Tracker',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                'Smart nutrition management',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        _StatCard(
                          icon: Icons.inventory_2_rounded,
                          title: 'Total Items',
                          value: totalItems.toString(),
                          color: Colors.white,
                          bgColor: Colors.white.withOpacity(0.2),
                        ),
                        SizedBox(width: 12),
                        _StatCard(
                          icon: Icons.warning_rounded,
                          title: 'Expiring Soon',
                          value: expiringCount.toString(),
                          color: Colors.orange.shade100,
                          bgColor: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Database Status Section
              DatabaseStatusWidget(),
              SizedBox(height: 24),

              // Input Methods Section
              Text(
                'Add Food Item',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InputMethodCard(
                      icon: Icons.camera_alt_rounded,
                      title: 'Scan',
                      subtitle: 'AI Detection',
                      color: Colors.blue.shade600,
                      onTap: () => _showScanDialog(context),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _InputMethodCard(
                      icon: Icons.edit_rounded,
                      title: 'Manual',
                      subtitle: 'Type Entry',
                      color: Colors.green.shade600,
                      onTap: () => _showManualEntryDialog(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InputMethodCard(
                      icon: Icons.mic_rounded,
                      title: 'Voice',
                      subtitle: 'Speak Input',
                      color: Colors.purple.shade600,
                      onTap: () => _showVoiceInputDialog(context),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Favorites Section
              if (favorites.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(Icons.favorite, color: Colors.red.shade600, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'Favorites',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...favorites.map(
                  (item) => _FavoriteItemCard(
                    item: item,
                    onTap: () => _showItemDetails(context, item),
                    onRecipeTap: () => _showSimpleRecipeDetails(context, item),
                    onFavoriteToggle: () => toggleFavorite(item),
                  ),
                ),
                SizedBox(height: 32),
              ],

              // Expiring Soon Section
              if (expiringSoon.isNotEmpty) ...[
                Row(
                  children: [
                    Icon(
                      Icons.warning_rounded,
                      color: Colors.orange.shade600,
                      size: 28,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Expiring Soon',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                ...expiringSoon.map(
                  (item) => _ExpiringItemCard(
                    item: item,
                    onTap: () => _showItemDetails(context, item),
                  ),
                ),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green.shade600,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'All Good!',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'No food items expiring soon',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color bgColor;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputMethodCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _InputMethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.2), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpiringItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _ExpiringItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange.shade50, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: item.imageBytes != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    item.imageBytes!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade600,
                  size: 24,
                ),
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.orange.shade800,
          ),
        ),
        subtitle: Text(
          'Expires: ${item.expiryDate?.toLocal().toString().split(' ')[0] ?? 'N/A'}',
          style: TextStyle(fontSize: 14, color: Colors.orange.shade700),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.orange.shade600,
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}

// --- Inventory Page ---
class InventoryPage extends StatefulWidget {
  final List<FoodItem> foodItems;
  const InventoryPage({required this.foodItems});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  String _searchQuery = '';
  String _sortBy = 'name';

  List<FoodItem> get filteredItems {
    var items = widget.foodItems
        .where(
          (item) =>
              item.name.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    switch (_sortBy) {
      case 'name':
        items.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'expiry':
        items.sort((a, b) {
          if (a.expiryDate == null && b.expiryDate == null) return 0;
          if (a.expiryDate == null) return 1;
          if (b.expiryDate == null) return -1;
          return a.expiryDate!.compareTo(b.expiryDate!);
        });
        break;
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white, Colors.blue.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.shade200,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.inventory_2_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Food Inventory',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${widget.foodItems.length} items in stock',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: 'Search food items...',
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.blue.shade600,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Sort Options
                  Row(
                    children: [
                      Text(
                        'Sort by: ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      _SortChip(
                        label: 'Name',
                        value: 'name',
                        selected: _sortBy == 'name',
                        onTap: () => setState(() => _sortBy = 'name'),
                      ),
                      SizedBox(width: 8),
                      _SortChip(
                        label: 'Expiry',
                        value: 'expiry',
                        selected: _sortBy == 'expiry',
                        onTap: () => setState(() => _sortBy = 'expiry'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Food Items List
            Expanded(
              child: filteredItems.isEmpty
                  ? _EmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return _FoodItemCard(
                          item: item,
                          onTap: () => _showItemDetails(context, item),
                          onEdit: () => _showEditDialog(context, item),
                          onDelete: () => _confirmDelete(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemDetails(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          'Food Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (item.imageBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  item.imageBytes!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            SizedBox(height: 16),
            Text(
              'Name: ${item.name}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Expiry: ${item.expiryDate?.toLocal().toString().split(' ')[0] ?? 'Not set'}',
            ),
            SizedBox(height: 8),
            Text(
              'Food Item',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            if (item.nutritionInfo != null) ...[
              SizedBox(height: 16),
              Text(
                'Nutrition Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.nutritionInfo!
                    .replaceAll('\n', ' ')
                    .replaceAll('\\n', ' '),
              ),
            ],
            if (item.allergyInfo != null) ...[
              SizedBox(height: 16),
              Text(
                'Allergy Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                item.allergyInfo!.replaceAll('\n', ' ').replaceAll('\\n', ' '),
              ),
            ],
          ],
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

  void _showEditDialog(BuildContext context, FoodItem item) async {
    String name = item.name;
    DateTime expiry = item.expiryDate ?? DateTime.now();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Food Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: name),
              decoration: InputDecoration(labelText: 'Name'),
              onChanged: (val) => name = val,
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.calendar_today),
              label: Text('Pick Expiry Date'),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: expiry,
                  firstDate: DateTime.now().subtract(Duration(days: 1)),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) expiry = picked;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, {'name': name, 'expiry': expiry}),
            child: Text('Save'),
          ),
        ],
      ),
    );
    if (result != null) {
      setState(() {
        final index = widget.foodItems.indexOf(item);
        if (index != -1) {
          widget.foodItems[index] = item.copyWith(
            name: result['name'],
            expiryDate: result['expiry'],
          );
        }
      });
    }
  }

  void _confirmDelete(BuildContext context, FoodItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Food Item'),
        content: Text('Are you sure you want to delete ${item.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        widget.foodItems.remove(item);
      });

      // Delete from Firebase database
      try {
        await FirebaseService.deleteFoodItemFromList(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} deleted from database'),
            backgroundColor: Colors.green.shade600,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        print('Error deleting from database: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting from database: $e'),
            backgroundColor: Colors.red.shade600,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? Colors.blue.shade600
                : Colors.white.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.blue.shade600 : Colors.white,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _FoodItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _FoodItemCard({
    required this.item,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isExpiringSoon =
        item.expiryDate != null &&
        item.expiryDate!.isBefore(DateTime.now().add(Duration(days: 3)));
    final isExpired =
        item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color statusColor = Colors.green.shade600;

    if (isExpired) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      statusColor = Colors.red.shade600;
    } else if (isExpiringSoon) {
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
      statusColor = Colors.orange.shade600;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey.shade100,
                  ),
                  child: item.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            item.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.fastfood_rounded,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                ),
                SizedBox(width: 16),

                // Food Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Location: ' +
                            (item.location.isNotEmpty
                                ? item.location
                                : 'Unknown'),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Food Item',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isExpired
                                      ? Icons.warning_rounded
                                      : isExpiringSoon
                                      ? Icons.schedule_rounded
                                      : Icons.check_circle_rounded,
                                  size: 16,
                                  color: statusColor,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  isExpired
                                      ? 'Expired'
                                      : isExpiringSoon
                                      ? 'Expiring Soon'
                                      : 'Good',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.expiryDate != null) ...[
                            SizedBox(width: 8),
                            Text(
                              'Expires: ${item.expiryDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Edit and Delete Icons
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue.shade400),
                      tooltip: 'Edit',
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red.shade400),
                      tooltip: 'Delete',
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              size: 64,
              color: Colors.blue.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Food Items',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first food item to get started',
            style: TextStyle(fontSize: 16, color: Colors.blue.shade600),
          ),
        ],
      ),
    );
  }
}

// Helper widget for info cards
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String content;
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.content,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    content,
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- AI Recipe Page ---
class AIRecipePage extends StatefulWidget {
  final List<FoodItem> foodItems;
  const AIRecipePage({required this.foodItems});

  @override
  State<AIRecipePage> createState() => _AIRecipePageState();
}

class _AIRecipePageState extends State<AIRecipePage> {
  Map<String, List<Map<String, dynamic>>> _recipeCache = {};
  Map<String, bool> _loadingStates = {};
  Set<String> _favoriteRecipes = {};
  bool _showFavoritesOnly = false; // Add this state

  @override
  void initState() {
    super.initState();
    _loadRecipesForAllItems();
  }

  @override
  void didUpdateWidget(covariant AIRecipePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.foodItems != oldWidget.foodItems) {
      _loadRecipesForAllItems();
    }
  }

  Future<void> _loadRecipesForAllItems() async {
    for (var item in widget.foodItems) {
      if (!_recipeCache.containsKey(item.name)) {
        setState(() {
          _loadingStates[item.name] = true;
        });
        try {
          final recipes = await FoodApiService.getRecipeInfo(item.name);
          setState(() {
            _recipeCache[item.name] = recipes != null && recipes.length > 5
                ? recipes.sublist(0, 5)
                : (recipes ?? []);
            _loadingStates[item.name] = false;
          });
        } catch (e) {
          setState(() {
            _loadingStates[item.name] = false;
          });
        }
      }
    }
  }

  // Helper to build a unique key for a recipe
  String _recipeKey(String foodName, int recipeIndex) =>
      '$foodName-$recipeIndex';

  @override
  Widget build(BuildContext context) {
    final itemsWithRecipes = widget.foodItems
        .where(
          (item) =>
              _recipeCache[item.name]?.isNotEmpty == true ||
              _loadingStates[item.name] == true,
        )
        .toList();
    // Filter for favorites if needed
    final filteredItems = _showFavoritesOnly
        ? itemsWithRecipes.where((item) {
            final recipes = _recipeCache[item.name] ?? [];
            for (int i = 0; i < recipes.length; i++) {
              if (_favoriteRecipes.contains(_recipeKey(item.name, i))) {
                return true;
              }
            }
            return false;
          }).toList()
        : itemsWithRecipes;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.white, Colors.purple.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade600, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade200,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.restaurant_menu_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Recipe Suggestions',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${itemsWithRecipes.length} food items with recipes',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Add Favorites button here
                      SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _showFavoritesOnly
                              ? Colors.pink.shade400
                              : Colors.white,
                          foregroundColor: _showFavoritesOnly
                              ? Colors.white
                              : Colors.pink.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        icon: Icon(
                          _showFavoritesOnly
                              ? Icons.favorite
                              : Icons.favorite_border,
                        ),
                        label: Text(
                          _showFavoritesOnly ? 'Show All' : 'Favorites',
                        ),
                        onPressed: () {
                          setState(() {
                            _showFavoritesOnly = !_showFavoritesOnly;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      _RecipeStatCard(
                        icon: Icons.restaurant_rounded,
                        title: 'Food Items',
                        value: itemsWithRecipes.length.toString(),
                        color: Colors.white,
                        bgColor: Colors.white.withOpacity(0.2),
                      ),
                      SizedBox(width: 12),
                      _RecipeStatCard(
                        icon: Icons.menu_book_rounded,
                        title: 'Total Recipes',
                        value: _recipeCache.values
                            .fold<int>(
                              0,
                              (sum, recipes) => sum + recipes.length,
                            )
                            .toString(),
                        color: Colors.pink.shade100,
                        bgColor: Colors.pink.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Recipe List
            Expanded(
              child: filteredItems.isEmpty
                  ? _NoRecipesState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        final recipes = _recipeCache[item.name] ?? [];
                        final isLoading = _loadingStates[item.name] ?? false;
                        // If showing favorites only, filter recipes
                        final recipeIndices = _showFavoritesOnly
                            ? List.generate(recipes.length, (i) => i)
                                  .where(
                                    (i) => _favoriteRecipes.contains(
                                      _recipeKey(item.name, i),
                                    ),
                                  )
                                  .toList()
                            : List.generate(recipes.length, (i) => i);
                        return Card(
                          margin: EdgeInsets.only(bottom: 20),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.fastfood,
                                      color: Colors.purple.shade400,
                                      size: 28,
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.purple.shade700,
                                        ),
                                      ),
                                    ),
                                    if (isLoading)
                                      SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                if (recipes.isEmpty && !isLoading)
                                  Text(
                                    'No recipes found.',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                if (recipes.isNotEmpty &&
                                    recipeIndices.isNotEmpty)
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: recipeIndices.length > 5
                                        ? 5
                                        : recipeIndices.length,
                                    separatorBuilder: (context, i) => Divider(),
                                    itemBuilder: (context, idx) {
                                      final i = recipeIndices[idx];
                                      final recipe = recipes[i];
                                      return ListTile(
                                        leading: Icon(
                                          Icons.restaurant,
                                          color: Colors.orange.shade400,
                                        ),
                                        title: Text(
                                          recipe['title'] ?? 'Recipe ${i + 1}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            _favoriteRecipes.contains(
                                                  _recipeKey(item.name, i),
                                                )
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color:
                                                _favoriteRecipes.contains(
                                                  _recipeKey(item.name, i),
                                                )
                                                ? Colors.red
                                                : Colors.grey,
                                          ),
                                          tooltip:
                                              _favoriteRecipes.contains(
                                                _recipeKey(item.name, i),
                                              )
                                              ? 'Remove from favorites'
                                              : 'Add to favorites',
                                          onPressed: () {
                                            setState(() {
                                              final key = _recipeKey(
                                                item.name,
                                                i,
                                              );
                                              if (_favoriteRecipes.contains(
                                                key,
                                              )) {
                                                _favoriteRecipes.remove(key);
                                              } else {
                                                _favoriteRecipes.add(key);
                                              }
                                            });
                                          },
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (recipe['description'] !=
                                                null) ...[
                                              Text(recipe['description']),
                                              SizedBox(height: 6),
                                            ],
                                            if (recipe['ingredients'] !=
                                                null) ...[
                                              Text(
                                                'Ingredients:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                (recipe['ingredients'] as List)
                                                    .join(', '),
                                              ),
                                              SizedBox(height: 6),
                                            ],
                                            if (recipe['steps'] != null) ...[
                                              Text(
                                                'Cooking Procedure:',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              ...((recipe['steps'] as List)
                                                  .map<Widget>(
                                                    (s) => Text('- $s'),
                                                  )
                                                  .toList()),
                                              SizedBox(height: 6),
                                            ],
                                            if (recipe['cookingTime'] !=
                                                null) ...[
                                              Text(
                                                'Cooking Time: ${recipe['cookingTime']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 6),
                                            ],
                                            if (recipe['difficulty'] !=
                                                null) ...[
                                              Text(
                                                'Difficulty: ${recipe['difficulty']}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        onTap: () => _showRecipeDetails(
                                          context,
                                          item,
                                          recipes,
                                        ),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecipeDetails(
    BuildContext context,
    FoodItem item,
    List<Map<String, dynamic>> recipes,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.restaurant_menu_rounded, color: Colors.purple.shade600),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Recipes for ${item.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: recipes.length > 5 ? 5 : recipes.length,
            separatorBuilder: (context, i) => Divider(),
            itemBuilder: (context, i) {
              final recipe = recipes[i];
              return ListTile(
                leading: Icon(Icons.restaurant, color: Colors.orange.shade400),
                title: Text(
                  recipe['title'] ?? 'Recipe ${i + 1}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _favoriteRecipes.contains(_recipeKey(item.name, i))
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: _favoriteRecipes.contains(_recipeKey(item.name, i))
                        ? Colors.red
                        : Colors.grey,
                  ),
                  tooltip: _favoriteRecipes.contains(_recipeKey(item.name, i))
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  onPressed: () {
                    setState(() {
                      final key = _recipeKey(item.name, i);
                      if (_favoriteRecipes.contains(key)) {
                        _favoriteRecipes.remove(key);
                      } else {
                        _favoriteRecipes.add(key);
                      }
                    });
                  },
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (recipe['description'] != null) ...[
                      Text(recipe['description']),
                      SizedBox(height: 6),
                    ],
                    if (recipe['ingredients'] != null) ...[
                      Text(
                        'Ingredients:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text((recipe['ingredients'] as List).join(', ')),
                      SizedBox(height: 6),
                    ],
                    if (recipe['steps'] != null) ...[
                      Text(
                        'Cooking Procedure:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...((recipe['steps'] as List)
                          .map<Widget>((s) => Text('- $s'))
                          .toList()),
                      SizedBox(height: 6),
                    ],
                    if (recipe['cookingTime'] != null) ...[
                      Text(
                        'Cooking Time: ${recipe['cookingTime']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 6),
                    ],
                    if (recipe['difficulty'] != null) ...[
                      Text(
                        'Difficulty: ${recipe['difficulty']}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              );
            },
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
}

class _RecipeStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color bgColor;

  const _RecipeStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _RecipeCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Food Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.purple.shade50,
                      ),
                      child: item.imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                item.imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.restaurant_rounded,
                              size: 40,
                              color: Colors.purple.shade400,
                            ),
                    ),
                    SizedBox(width: 16),

                    // Recipe Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.purple.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.menu_book_rounded,
                                  size: 16,
                                  color: Colors.purple.shade600,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'AI Generated',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.purple.shade400,
                      size: 20,
                    ),
                  ],
                ),
                SizedBox(height: 16),

                // Recipe Preview
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.purple.shade100, width: 1),
                  ),
                  child: Text(
                    item.recipeInfo != null && item.recipeInfo!.length > 100
                        ? item.recipeInfo!.substring(0, 100) + '...'
                        : (item.recipeInfo ?? ''),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.purple.shade700,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoRecipesState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.purple.shade200, width: 2),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              size: 64,
              color: Colors.purple.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Recipes Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add food items to get AI recipe suggestions',
            style: TextStyle(fontSize: 16, color: Colors.purple.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Enhanced Nutrition Page ---
class NutritionPage extends StatelessWidget {
  final List<FoodItem> foodItems;
  const NutritionPage({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    final itemsWithNutrition = foodItems
        .where(
          (item) =>
              item.nutritionInfo != null && item.nutritionInfo!.isNotEmpty,
        )
        .toList();

    // Calculate nutrition statistics
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    int itemsWithValues = 0;

    for (var item in itemsWithNutrition) {
      if (item.nutritionValues != null) {
        totalCalories += item.nutritionValues!['calories'] ?? 0;
        totalProtein += item.nutritionValues!['protein'] ?? 0;
        totalCarbs += item.nutritionValues!['carbs'] ?? 0;
        totalFat += item.nutritionValues!['fat'] ?? 0;
        itemsWithValues++;
      }
    }

    final avgCalories = itemsWithValues > 0
        ? (totalCalories / itemsWithValues).round()
        : 0;
    final avgProtein = itemsWithValues > 0
        ? (totalProtein / itemsWithValues).roundToDouble()
        : 0.0;
    final avgCarbs = itemsWithValues > 0
        ? (totalCarbs / itemsWithValues).roundToDouble()
        : 0.0;
    final avgFat = itemsWithValues > 0
        ? (totalFat / itemsWithValues).roundToDouble()
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.teal.shade50, Colors.white, Colors.teal.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal.shade600, Colors.teal.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.teal.shade200,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nutrition Analysis',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                '${itemsWithNutrition.length} items analyzed',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Enhanced Nutrition Stats
                    Row(
                      children: [
                        _NutritionStatCard(
                          icon: Icons.monitor_heart_rounded,
                          title: 'Items Analyzed',
                          value: itemsWithNutrition.length.toString(),
                          color: Colors.white,
                          bgColor: Colors.white.withOpacity(0.2),
                        ),
                        SizedBox(width: 12),
                        _NutritionStatCard(
                          icon: Icons.local_fire_department_rounded,
                          title: 'Avg Calories',
                          value: avgCalories.toString(),
                          color: Colors.orange.shade100,
                          bgColor: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Enhanced Nutrition Overview
              if (itemsWithNutrition.isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.pie_chart_rounded,
                            color: Colors.teal.shade600,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Macro Distribution',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Macro breakdown cards
                      Row(
                        children: [
                          Expanded(
                            child: _MacroCard(
                              title: 'Protein',
                              value: '${avgProtein.toStringAsFixed(1)}g',
                              color: Colors.teal.shade400,
                              icon: Icons.fitness_center_rounded,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _MacroCard(
                              title: 'Carbs',
                              value: '${avgCarbs.toStringAsFixed(1)}g',
                              color: Colors.orange.shade400,
                              icon: Icons.grain_rounded,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _MacroCard(
                              title: 'Fat',
                              value: '${avgFat.toStringAsFixed(1)}g',
                              color: Colors.red.shade400,
                              icon: Icons.water_drop_rounded,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Pie Chart
                      Container(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: avgProtein > 0 ? avgProtein : 1,
                                title:
                                    'Protein\n${avgProtein.toStringAsFixed(1)}g',
                                color: Colors.teal.shade400,
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: avgCarbs > 0 ? avgCarbs : 1,
                                title: 'Carbs\n${avgCarbs.toStringAsFixed(1)}g',
                                color: Colors.orange.shade400,
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: avgFat > 0 ? avgFat : 1,
                                title: 'Fat\n${avgFat.toStringAsFixed(1)}g',
                                color: Colors.red.shade400,
                                radius: 60,
                                titleStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            centerSpaceRadius: 40,
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Enhanced Nutrition Items List
              if (itemsWithNutrition.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: itemsWithNutrition.length,
                  itemBuilder: (context, index) {
                    final item = itemsWithNutrition[index];
                    return _EnhancedNutritionCard(
                      item: item,
                      onTap: () => _showEnhancedNutritionDetails(context, item),
                    );
                  },
                )
              else
                _NoNutritionState(),
            ],
          ),
        ),
      ),
    );
  }

  void _showEnhancedNutritionDetails(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.monitor_heart_rounded, color: Colors.teal.shade600),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nutrition for ${item.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageBytes != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(item.imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 16),

              // Enhanced nutrition display
              if (item.nutritionValues != null) ...[
                // Macro breakdown
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.teal.shade50, Colors.teal.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.teal.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Macro Breakdown',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailMacroCard(
                              title: 'Calories',
                              value:
                                  '${item.nutritionValues!['calories']?.toStringAsFixed(1) ?? '0'} kcal',
                              color: Colors.orange.shade600,
                              icon: Icons.local_fire_department_rounded,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _DetailMacroCard(
                              title: 'Protein',
                              value:
                                  '${item.nutritionValues!['protein']?.toStringAsFixed(1) ?? '0'}g',
                              color: Colors.teal.shade600,
                              icon: Icons.fitness_center_rounded,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _DetailMacroCard(
                              title: 'Carbs',
                              value:
                                  '${item.nutritionValues!['carbs']?.toStringAsFixed(1) ?? '0'}g',
                              color: Colors.orange.shade600,
                              icon: Icons.grain_rounded,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _DetailMacroCard(
                              title: 'Fat',
                              value:
                                  '${item.nutritionValues!['fat']?.toStringAsFixed(1) ?? '0'}g',
                              color: Colors.red.shade600,
                              icon: Icons.water_drop_rounded,
                            ),
                          ),
                        ],
                      ),
                      if (item.nutritionValues!['fiber'] != null ||
                          item.nutritionValues!['sugar'] != null ||
                          item.nutritionValues!['sodium'] != null) ...[
                        SizedBox(height: 8),
                        Row(
                          children: [
                            if (item.nutritionValues!['fiber'] != null)
                              Expanded(
                                child: _DetailMacroCard(
                                  title: 'Fiber',
                                  value:
                                      '${item.nutritionValues!['fiber']?.toStringAsFixed(1) ?? '0'}g',
                                  color: Colors.green.shade600,
                                  icon: Icons.eco_rounded,
                                ),
                              ),
                            if (item.nutritionValues!['fiber'] != null &&
                                item.nutritionValues!['sugar'] != null)
                              SizedBox(width: 8),
                            if (item.nutritionValues!['sugar'] != null)
                              Expanded(
                                child: _DetailMacroCard(
                                  title: 'Sugar',
                                  value:
                                      '${item.nutritionValues!['sugar']?.toStringAsFixed(1) ?? '0'}g',
                                  color: Colors.pink.shade600,
                                  icon: Icons.cake_rounded,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Detailed nutrition info
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detailed Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      item.nutritionInfo!
                          .replaceAll('\n', ' ')
                          .replaceAll('\\n', ' '),
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _NutritionStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color bgColor;

  const _NutritionStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _MacroCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _DetailMacroCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _DetailMacroCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _EnhancedNutritionCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _EnhancedNutritionCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with image and name
                Row(
                  children: [
                    // Food Image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.teal.shade50,
                      ),
                      child: item.imageBytes != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.memory(
                                item.imageBytes!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.monitor_heart_rounded,
                              size: 40,
                              color: Colors.teal.shade400,
                            ),
                    ),
                    SizedBox(width: 16),

                    // Food name and status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.health_and_safety_rounded,
                                  size: 16,
                                  color: Colors.teal.shade600,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Nutrition Analyzed',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow Icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.teal.shade400,
                      size: 20,
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // Quick nutrition preview
                if (item.nutritionValues != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _QuickMacroCard(
                          title: 'Calories',
                          value:
                              '${item.nutritionValues!['calories']?.toStringAsFixed(0) ?? '0'}',
                          color: Colors.orange.shade600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _QuickMacroCard(
                          title: 'Protein',
                          value:
                              '${item.nutritionValues!['protein']?.toStringAsFixed(1) ?? '0'}g',
                          color: Colors.teal.shade600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _QuickMacroCard(
                          title: 'Carbs',
                          value:
                              '${item.nutritionValues!['carbs']?.toStringAsFixed(1) ?? '0'}g',
                          color: Colors.orange.shade600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: _QuickMacroCard(
                          title: 'Fat',
                          value:
                              '${item.nutritionValues!['fat']?.toStringAsFixed(1) ?? '0'}g',
                          color: Colors.red.shade600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                ],

                // Nutrition info preview
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.teal.shade200),
                  ),
                  child: Text(
                    item.nutritionInfo!.length > 120
                        ? '${item.nutritionInfo!.substring(0, 120)}...'
                        : item.nutritionInfo!
                              .replaceAll('\n', ' ')
                              .replaceAll('\\n', ' '),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.teal.shade700,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickMacroCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _QuickMacroCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 10, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _NutritionCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.teal.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.teal.shade50,
                  ),
                  child: item.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            item.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.monitor_heart_rounded,
                          size: 40,
                          color: Colors.teal.shade400,
                        ),
                ),
                SizedBox(width: 16),

                // Nutrition Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.health_and_safety_rounded,
                              size: 16,
                              color: Colors.teal.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Nutrition Analyzed',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.nutritionInfo!.length > 80
                            ? '${item.nutritionInfo!.substring(0, 80)}...'
                            : item.nutritionInfo!
                                  .replaceAll('\n', ' ')
                                  .replaceAll('\\n', ' '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.teal.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.teal.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoNutritionState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.teal.shade200, width: 2),
            ),
            child: Icon(
              Icons.bar_chart_rounded,
              size: 64,
              color: Colors.teal.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Nutrition Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add food items to get nutrition analysis',
            style: TextStyle(fontSize: 16, color: Colors.teal.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Allergy Page ---
class AllergyPage extends StatelessWidget {
  final List<FoodItem> foodItems;
  const AllergyPage({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    final itemsWithAllergies = foodItems
        .where(
          (item) => item.allergyInfo != null && item.allergyInfo!.isNotEmpty,
        )
        .toList();

    // Common allergens to check for
    final commonAllergens = [
      'peanuts',
      'tree nuts',
      'milk',
      'eggs',
      'soy',
      'wheat',
      'fish',
      'shellfish',
      'gluten',
      'lactose',
      'sulfites',
      'sesame',
      'mustard',
      'celery',
      'lupin',
      'molluscs',
      'crustaceans',
      'nuts',
      'dairy',
      'egg',
      'soybean',
      'wheat flour',
    ];

    // Group items by allergen
    Map<String, List<FoodItem>> allergenGroups = {};
    for (var allergen in commonAllergens) {
      final items = foodItems.where((item) {
        final allergyInfo = item.allergyInfo?.toLowerCase() ?? '';
        return allergyInfo.contains(allergen);
      }).toList();
      if (items.isNotEmpty) {
        allergenGroups[allergen] = items;
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.white, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header Section
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade600, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Allergy Analysis',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              Text(
                                '${itemsWithAllergies.length} items with allergy info',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Allergy Stats
                    Row(
                      children: [
                        _AllergyStatCard(
                          icon: Icons.warning_amber_rounded,
                          title: 'Allergy Items',
                          value: itemsWithAllergies.length.toString(),
                          color: Colors.white,
                          bgColor: Colors.white.withOpacity(0.2),
                        ),
                        SizedBox(width: 12),
                        _AllergyStatCard(
                          icon: Icons.category_rounded,
                          title: 'Allergen Types',
                          value: allergenGroups.length.toString(),
                          color: Colors.orange.shade100,
                          bgColor: Colors.orange.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Allergen Categories
              if (allergenGroups.isNotEmpty) ...[
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.1),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.category_rounded,
                            color: Colors.red.shade600,
                            size: 24,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Allergen Categories',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),

                      // Allergen category cards
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: allergenGroups.entries.map((entry) {
                          final allergen = entry.key;
                          final items = entry.value;
                          return _AllergenCategoryCard(
                            allergen: allergen,
                            itemCount: items.length,
                            items: items,
                            onTap: () =>
                                _showAllergenDetails(context, allergen, items),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],

              // Items with Allergy Info
              if (itemsWithAllergies.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.all(16),
                  itemCount: itemsWithAllergies.length,
                  itemBuilder: (context, index) {
                    final item = itemsWithAllergies[index];
                    return _AllergyCard(
                      item: item,
                      onTap: () => _showAllergyDetails(context, item),
                    );
                  },
                )
              else
                _NoAllergyState(),
            ],
          ),
        ),
      ),
    );
  }

  void _showAllergenDetails(
    BuildContext context,
    String allergen,
    List<FoodItem> items,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            SizedBox(width: 12),
            Text('$allergen Allergen'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: item.imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          item.imageBytes!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(Icons.fastfood, color: Colors.red.shade600),
                title: Text(item.name),
                subtitle: Text(item.allergyInfo ?? ''),
                onTap: () {
                  Navigator.pop(context);
                  _showAllergyDetails(context, item);
                },
              );
            },
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

  void _showAllergyDetails(BuildContext context, FoodItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade600),
            SizedBox(width: 12),
            Text('Allergy Info: ${item.name}'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageBytes != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(item.imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade50, Colors.red.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade200, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Allergy Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      item.allergyInfo!
                          .replaceAll('\n', ' ')
                          .replaceAll('\\n', ' '),
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AllergyStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color bgColor;

  const _AllergyStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergenCategoryCard extends StatelessWidget {
  final String allergen;
  final int itemCount;
  final List<FoodItem> items;
  final VoidCallback onTap;

  const _AllergenCategoryCard({
    required this.allergen,
    required this.itemCount,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.red.shade600,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              allergen.toUpperCase(),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              '$itemCount items',
              style: TextStyle(fontSize: 12, color: Colors.red.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class _AllergyCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _AllergyCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.red.shade50,
                  ),
                  child: item.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            item.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.warning_amber_rounded,
                          size: 40,
                          color: Colors.red.shade400,
                        ),
                ),
                SizedBox(width: 16),

                // Allergy Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              size: 16,
                              color: Colors.red.shade600,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Allergy Alert',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.allergyInfo!.length > 80
                            ? '${item.allergyInfo!.substring(0, 80)}...'
                            : item.allergyInfo!
                                  .replaceAll('\n', ' ')
                                  .replaceAll('\\n', ' '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.red.shade700,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.red.shade400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoAllergyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.red.shade200, width: 2),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 64,
              color: Colors.red.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Allergy Data',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add food items to get allergy analysis',
            style: TextStyle(fontSize: 16, color: Colors.red.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// --- Allergy/Spoilage Page ---
class AllergySpoilagePage extends StatelessWidget {
  final List<FoodItem> foodItems;
  const AllergySpoilagePage({required this.foodItems});

  @override
  Widget build(BuildContext context) {
    final itemsWithAlerts = foodItems
        .where(
          (item) =>
              (item.allergyInfo != null && item.allergyInfo!.isNotEmpty) ||
              (item.spoilageInfo != null && item.spoilageInfo!.isNotEmpty) ||
              (item.expiryDate != null &&
                  item.expiryDate!.isBefore(
                    DateTime.now().add(Duration(days: 3)),
                  )),
        )
        .toList();
    final itemsWithAlertsList = itemsWithAlerts;

    final expiredItems = foodItems
        .where(
          (item) =>
              item.expiryDate != null &&
              item.expiryDate!.isBefore(DateTime.now()),
        )
        .toList();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade50, Colors.white, Colors.red.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade600, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.shade200,
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safety Alerts',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                            Text(
                              '${itemsWithAlerts.length} items need attention',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Alert Stats
                  Row(
                    children: [
                      _AlertStatCard(
                        icon: Icons.warning_rounded,
                        title: 'Total Alerts',
                        value: itemsWithAlerts.length.toString(),
                        color: Colors.white,
                        bgColor: Colors.white.withOpacity(0.2),
                      ),
                      SizedBox(width: 12),
                      _AlertStatCard(
                        icon: Icons.error_rounded,
                        title: 'Expired',
                        value: expiredItems.length.toString(),
                        color: Colors.orange.shade100,
                        bgColor: Colors.orange.shade400,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Critical Alerts Section
            if (expiredItems.isNotEmpty) ...[
              Container(
                margin: EdgeInsets.all(16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade100, Colors.red.shade50],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.shade200, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_rounded,
                          color: Colors.red.shade600,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Critical Alerts',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      '${expiredItems.length} items have expired and should be discarded immediately.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Alerts List
            Expanded(
              child: itemsWithAlertsList.isEmpty
                  ? _NoAlertsState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16),
                      itemCount: itemsWithAlertsList.length,
                      itemBuilder: (context, index) {
                        final item = itemsWithAlertsList[index];
                        return _AlertCard(
                          item: item,
                          onTap: () => _showAlertDetails(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAlertDetails(BuildContext context, FoodItem item) {
    final isExpired =
        item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        item.expiryDate != null &&
        item.expiryDate!.isBefore(DateTime.now().add(Duration(days: 3)));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(
              isExpired ? Icons.error_rounded : Icons.warning_rounded,
              color: isExpired ? Colors.red.shade600 : Colors.orange.shade600,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Safety Alert for ${item.name}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.imageBytes != null)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.memory(item.imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              SizedBox(height: 16),

              // Expiry Alert
              if (isExpired || isExpiringSoon) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isExpired
                          ? [Colors.red.shade50, Colors.red.shade100]
                          : [Colors.orange.shade50, Colors.orange.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isExpired
                          ? Colors.red.shade200
                          : Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isExpired
                                ? Icons.error_rounded
                                : Icons.schedule_rounded,
                            color: isExpired
                                ? Colors.red.shade600
                                : Colors.orange.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            isExpired ? 'EXPIRED' : 'Expiring Soon',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isExpired
                                  ? Colors.red.shade600
                                  : Colors.orange.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        isExpired
                            ? 'This item expired on ${item.expiryDate!.toLocal().toString().split(' ')[0]}. Please discard immediately.'
                            : 'This item expires on ${item.expiryDate!.toLocal().toString().split(' ')[0]}. Use soon.',
                        style: TextStyle(
                          fontSize: 14,
                          color: isExpired
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Allergy Info
              if (item.allergyInfo != null && item.allergyInfo!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade50, Colors.purple.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.purple.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.purple.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Allergy Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.allergyInfo!
                            .replaceAll('\n', ' ')
                            .replaceAll('\\n', ' '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.purple.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
              ],

              // Spoilage Info
              if (item.spoilageInfo != null &&
                  item.spoilageInfo!.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.brown.shade50, Colors.brown.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.brown.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_rounded,
                            color: Colors.brown.shade600,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Spoilage Information',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.brown.shade600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        item.spoilageInfo!
                            .replaceAll('\n', ' ')
                            .replaceAll('\\n', ' '),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.brown.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _AlertStatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final Color bgColor;

  const _AlertStatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;

  const _AlertCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isExpired =
        item.expiryDate != null && item.expiryDate!.isBefore(DateTime.now());
    final isExpiringSoon =
        item.expiryDate != null &&
        item.expiryDate!.isBefore(DateTime.now().add(Duration(days: 3)));
    final hasAllergy = item.allergyInfo != null && item.allergyInfo!.isNotEmpty;
    final hasSpoilage =
        item.spoilageInfo != null && item.spoilageInfo!.isNotEmpty;

    Color cardColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color statusColor = Colors.green.shade600;
    String alertType = '';

    if (isExpired) {
      cardColor = Colors.red.shade50;
      borderColor = Colors.red.shade200;
      statusColor = Colors.red.shade600;
      alertType = 'Expired';
    } else if (isExpiringSoon) {
      cardColor = Colors.orange.shade50;
      borderColor = Colors.orange.shade200;
      statusColor = Colors.orange.shade600;
      alertType = 'Expiring Soon';
    } else if (hasAllergy) {
      cardColor = Colors.purple.shade50;
      borderColor = Colors.purple.shade200;
      statusColor = Colors.purple.shade600;
      alertType = 'Allergy Alert';
    } else if (hasSpoilage) {
      cardColor = Colors.brown.shade50;
      borderColor = Colors.brown.shade200;
      statusColor = Colors.brown.shade600;
      alertType = 'Spoilage Info';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                // Food Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: statusColor.withOpacity(0.1),
                  ),
                  child: item.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.memory(
                            item.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.warning_rounded,
                          size: 40,
                          color: statusColor,
                        ),
                ),
                SizedBox(width: 16),

                // Alert Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpired
                                  ? Icons.error_rounded
                                  : Icons.warning_rounded,
                              size: 16,
                              color: statusColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              alertType,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      if (item.expiryDate != null)
                        Text(
                          'Expires: ${item.expiryDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            fontSize: 14,
                            color: statusColor.withOpacity(0.8),
                          ),
                        ),
                    ],
                  ),
                ),

                // Arrow Icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: statusColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoAlertsState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.green.shade200, width: 2),
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 64,
              color: Colors.green.shade400,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'All Clear!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'No safety alerts at the moment',
            style: TextStyle(fontSize: 16, color: Colors.green.shade600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _FavoriteItemCard extends StatelessWidget {
  final FoodItem item;
  final VoidCallback onTap;
  final VoidCallback onRecipeTap;
  final VoidCallback onFavoriteToggle;

  const _FavoriteItemCard({
    required this.item,
    required this.onTap,
    required this.onRecipeTap,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              if (item.imageBytes != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(
                    item.imageBytes!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.fastfood,
                    color: Colors.green.shade700,
                    size: 30,
                  ),
                ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                    if (item.expiryDate != null) ...[
                      SizedBox(height: 4),
                      Text(
                        'Expires: ${item.expiryDate!.toLocal().toString().split(' ')[0]}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite, color: Colors.red, size: 24),
                    onPressed: onFavoriteToggle,
                    tooltip: 'Remove from favorites',
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.restaurant_menu,
                      color: Colors.orange.shade600,
                      size: 24,
                    ),
                    onPressed: onRecipeTap,
                    tooltip: 'View recipes',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Add at the top:
const List<String> kPredefinedLocations = [
  'Fridge',
  'Freezer',
  'Pantry',
  'Shelf',
  'Kitchen Cabinet',
  'Others',
];

class _LocationInput extends StatefulWidget {
  final void Function(String) onChanged;
  final String? initialValue;
  const _LocationInput({Key? key, required this.onChanged, this.initialValue})
    : super(key: key);
  @override
  State<_LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<_LocationInput> {
  String? _selected;
  String? _custom;
  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null &&
        kPredefinedLocations.contains(widget.initialValue)) {
      _selected = widget.initialValue;
    } else if (widget.initialValue != null) {
      _selected = 'Others';
      _custom = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          value: _selected,
          items: kPredefinedLocations
              .map((loc) => DropdownMenuItem(value: loc, child: Text(loc)))
              .toList(),
          onChanged: (val) {
            setState(() {
              _selected = val;
            });
            if (val != 'Others')
              widget.onChanged(val!);
            else if (_custom != null)
              widget.onChanged(_custom!);
          },
          decoration: InputDecoration(labelText: 'Storage Location'),
        ),
        if (_selected == 'Others')
          TextFormField(
            initialValue: _custom,
            decoration: InputDecoration(labelText: 'Custom Location'),
            onChanged: (val) {
              _custom = val;
              widget.onChanged(val);
            },
          ),
      ],
    );
  }
}

// --- Waste Management Page (COMPLETE REWRITE) ---
class WasteManagementPage extends StatefulWidget {
  final List<FoodItem> foodItems;
  const WasteManagementPage({required this.foodItems});

  @override
  State<WasteManagementPage> createState() => _WasteManagementPageState();
}

class _WasteManagementPageState extends State<WasteManagementPage>
    with TickerProviderStateMixin {
  late DateTime _weekStart;
  late int _totalStars;
  late int _starsThisWeek;
  late int _expiredThisWeek;
  late List<WeeklyStarHistory> _weeklyStarHistory;
  late AnimationController _starAnimController;
  late AnimationController _expiredAnimController;
  late Animation<int> _starAnim;
  late Animation<int> _expiredAnim;

  @override
  void initState() {
    super.initState();
    _weekStart = _getCurrentWeekStart();
    _totalStars = 0;
    _starsThisWeek = 0;
    _expiredThisWeek = _calcExpiredThisWeek();
    _weeklyStarHistory = [];
    _starAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _expiredAnimController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _starAnim = IntTween(
      begin: 0,
      end: _starsThisWeek,
    ).animate(_starAnimController);
    _expiredAnim = IntTween(
      begin: 0,
      end: _expiredThisWeek,
    ).animate(_expiredAnimController);
    WidgetsBinding.instance.addPostFrameCallback((_) => _evaluateWeek());
  }

  @override
  void dispose() {
    _starAnimController.dispose();
    _expiredAnimController.dispose();
    super.dispose();
  }

  DateTime _getCurrentWeekStart() {
    final now = DateTime.now();
    return now.subtract(Duration(days: now.weekday - 1)); // Monday as start
  }

  int _calcExpiredThisWeek() {
    final now = DateTime.now();
    final weekStart = _getCurrentWeekStart();
    final weekEnd = weekStart.add(Duration(days: 7));
    return widget.foodItems
        .where(
          (item) =>
              item.expiryDate != null &&
              item.expiryDate!.isAfter(weekStart) &&
              item.expiryDate!.isBefore(weekEnd) &&
              item.expiryDate!.isBefore(now),
        )
        .length;
  }

  Map<String, int> _categoryWasteData() {
    final Map<String, int> data = {
      'Fruits': 0,
      'Vegetables': 0,
      'Snacks': 0,
      'Dairy': 0,
      'Meat & Fish': 0,
      'Other': 0,
    };
    final weekStart = _getCurrentWeekStart();
    final weekEnd = weekStart.add(Duration(days: 7));
    for (var item in widget.foodItems) {
      if (item.expiryDate != null &&
          item.expiryDate!.isAfter(weekStart) &&
          item.expiryDate!.isBefore(weekEnd) &&
          item.expiryDate!.isBefore(DateTime.now())) {
        final name = item.name.toLowerCase();
        if (["apple", "banana", "orange", "berry", "fruit"].any(name.contains))
          data['Fruits'] = data['Fruits']! + 1;
        else if ([
          "lettuce",
          "spinach",
          "carrot",
          "broccoli",
          "vegetable",
        ].any(name.contains))
          data['Vegetables'] = data['Vegetables']! + 1;
        else if (["chips", "cookie", "snack", "chocolate"].any(name.contains))
          data['Snacks'] = data['Snacks']! + 1;
        else if (["milk", "cheese", "yogurt", "dairy"].any(name.contains))
          data['Dairy'] = data['Dairy']! + 1;
        else if (["meat", "fish", "chicken", "beef", "pork"].any(name.contains))
          data['Meat & Fish'] = data['Meat & Fish']! + 1;
        else
          data['Other'] = data['Other']! + 1;
      }
    }
    return data;
  }

  void _evaluateWeek() {
    final now = DateTime.now();
    if (now.difference(_weekStart).inDays >= 7) {
      // Weekly reset
      int expired = _calcExpiredThisWeek();
      int stars = 0;
      if (expired == 0)
        stars = 500;
      else if (expired == 1)
        stars = -50;
      else if (expired >= 2 && expired <= 5)
        stars = -150;
      else if (expired > 5)
        stars = -300;
      _totalStars = (_totalStars + stars).clamp(0, 999999);
      _starsThisWeek = stars;
      _expiredThisWeek = expired;
      _weeklyStarHistory.add(
        WeeklyStarHistory(
          weekStart: _weekStart,
          expiredCount: expired,
          starsEarned: stars,
          totalStars: _totalStars,
        ),
      );
      _weekStart = _getCurrentWeekStart();
      _starAnim = IntTween(
        begin: 0,
        end: _starsThisWeek,
      ).animate(_starAnimController);
      _expiredAnim = IntTween(
        begin: 0,
        end: _expiredThisWeek,
      ).animate(_expiredAnimController);
      _starAnimController.forward(from: 0);
      _expiredAnimController.forward(from: 0);
      setState(() {});
    }
  }

  String _motivation(int expired) {
    if (expired == 0) return '🎉 Amazing! No food wasted this week!';
    if (expired == 1)
      return '⚠ Oops! 1 item expired. Try to finish items before expiry!';
    if (expired <= 5)
      return '🔥 $expired items expired. Let\'s reduce waste next week!';
    return '🚨 More than 5 items expired! Time to organize better!';
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Fruits':
        return Colors.redAccent;
      case 'Vegetables':
        return Colors.green;
      case 'Snacks':
        return Colors.purple;
      case 'Dairy':
        return Colors.blue;
      case 'Meat & Fish':
        return Colors.brown;
      default:
        return Colors.grey;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Fruits':
        return Icons.apple;
      case 'Vegetables':
        return Icons.eco;
      case 'Snacks':
        return Icons.fastfood;
      case 'Dairy':
        return Icons.icecream;
      case 'Meat & Fish':
        return Icons.set_meal;
      default:
        return Icons.category;
    }
  }

  void _showStarHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.star_rounded, color: Colors.yellow.shade600, size: 28),
            SizedBox(width: 12),
            Text('Star History'),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: _weeklyStarHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No star history yet',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _weeklyStarHistory.length,
                  itemBuilder: (context, index) {
                    final history = _weeklyStarHistory[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          history.starsEarned >= 0
                              ? Icons.star
                              : Icons.star_border,
                          color: history.starsEarned >= 0
                              ? Colors.yellow.shade600
                              : Colors.grey,
                        ),
                        title: Text(
                          'Week of ${history.weekStart.day}/${history.weekStart.month}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${history.expiredCount} items expired',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: Text(
                          '${history.starsEarned >= 0 ? '+' : ''}${history.starsEarned} ⭐',
                          style: TextStyle(
                            color: history.starsEarned >= 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow.shade600,
              foregroundColor: Colors.white,
            ),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final catData = _categoryWasteData();
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- Waste Management Heading ---
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 22, horizontal: 8),
                  margin: EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Center(
                    child: Text(
                      'Waste Management',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                // Star Summary
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('⭐', style: TextStyle(fontSize: 28)),
                            AnimatedBuilder(
                              animation: _starAnim,
                              builder: (context, child) => Text(
                                '${_starAnim.value > 0 ? '+' : ''}${_starAnim.value}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                            Text(
                              'Stars This Week',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('🌟', style: TextStyle(fontSize: 28)),
                            AnimatedBuilder(
                              animation: _starAnim,
                              builder: (context, child) => Text(
                                '$_totalStars',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green.shade700,
                                ),
                              ),
                            ),
                            Text(
                              'Total Stars',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text('📅', style: TextStyle(fontSize: 28)),
                            AnimatedBuilder(
                              animation: _expiredAnim,
                              builder: (context, child) => Text(
                                '$_expiredThisWeek',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                            Text(
                              'Expired This Week',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Motivational Message
                Center(
                  child: Text(
                    _motivation(_expiredThisWeek),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ),
                SizedBox(height: 12),
                // Status Notification
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${_expiredThisWeek} items expired this week – Try to finish items early!',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.orange.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                // Pie Chart
                if (catData.values.any((v) => v > 0))
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pie_chart,
                                color: Colors.blue.shade400,
                                size: 24,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Expired Items by Category',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: catData.entries
                                    .where((e) => e.value > 0)
                                    .map(
                                      (e) => PieChartSectionData(
                                        value: e.value.toDouble(),
                                        title:
                                            '${e.key}\n${(e.value / (_expiredThisWeek == 0 ? 1 : _expiredThisWeek) * 100).toStringAsFixed(1)}%',
                                        color: _categoryColor(e.key),
                                        radius: 60,
                                        titleStyle: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                centerSpaceRadius: 40,
                                sectionsSpace: 2,
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: catData.keys
                                .map(
                                  (cat) => Row(
                                    children: [
                                      Icon(
                                        _categoryIcon(cat),
                                        color: _categoryColor(cat),
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(cat, style: TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 16),
                // View Star History Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () => _showStarHistoryDialog(context),
                    icon: Icon(
                      Icons.trending_up,
                      color: Colors.yellow.shade700,
                    ),
                    label: Text(
                      'View Star History',
                      style: TextStyle(color: Colors.yellow.shade700),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow.shade50,
                      foregroundColor: Colors.yellow.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class WeeklyStarHistory {
  final DateTime weekStart;
  final int expiredCount;
  final int starsEarned;
  final int totalStars;
  WeeklyStarHistory({
    required this.weekStart,
    required this.expiredCount,
    required this.starsEarned,
    required this.totalStars,
  });
}

class FoodAssistantChat extends StatefulWidget {
  final String welcomeMessage;
  final Color accentColor;
  final Color backgroundColor;
  final double width;
  final double height;
  final VoidCallback? onClose;
  const FoodAssistantChat({
    this.welcomeMessage =
        "Hi, I'm your Smart Food Assistant! Ask me anything about food expiry, recipes, nutrition, or safe storage tips.",
    this.accentColor = Colors.green,
    this.backgroundColor = Colors.white,
    this.width = 350,
    this.height = 500,
    this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<FoodAssistantChat> createState() => _FoodAssistantChatState();
}

class _FoodAssistantChatState extends State<FoodAssistantChat> {
  final List<_ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, false));
      _isLoading = true;
    });
    _controller.clear();
    await Future.delayed(Duration(milliseconds: 100));
    _scrollToBottom();
    final response = await FoodApiService.sendChatPrompt(text);
    setState(() {
      _isLoading = false;
      if (response != null && response.trim().isNotEmpty) {
        _messages.add(_ChatMessage(response.trim(), true));
      } else {
        _messages.add(
          _ChatMessage(
            "Sorry, I couldn't get a response. Please try again.",
            true,
          ),
        );
      }
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: widget.width,
          height: widget.height,
          constraints: BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: widget.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, color: widget.accentColor),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Smart Food Assistant",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: widget.accentColor,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => widget.onClose?.call(),
                      child: Icon(Icons.close, color: widget.accentColor),
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16),
                  itemCount: _messages.length + 1,
                  itemBuilder: (context, idx) {
                    if (idx == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          widget.welcomeMessage,
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 15,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                    final msg = _messages[idx - 1];
                    return Align(
                      alignment: msg.isAssistant
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        padding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: msg.isAssistant
                              ? widget.accentColor.withOpacity(0.12)
                              : widget.accentColor.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(color: Colors.black87, fontSize: 15),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_isLoading)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Assistant is typing...",
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _sendMessage,
                        textInputAction: TextInputAction.send,
                        decoration: InputDecoration(
                          hintText: "Type your question...",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: widget.accentColor),
                      onPressed: () => _sendMessage(_controller.text),
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
}

class _ChatMessage {
  final String text;
  final bool isAssistant;
  _ChatMessage(this.text, this.isAssistant);
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data'; // Added for Uint8List

class FoodApiService {
  // Gemini API configuration
  static const String _geminiApiKey = "AIzaSyDT5YXHy0q_8IkEVEdwXxVprrtqdSgElEY";
  static const String _geminiModel = "gemini-2.5-flash";
  static const String _geminiBaseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models";

  // Fetch nutrition information for a food item using Gemini
  static Future<Map<String, dynamic>?> getNutritionInfo(String foodName) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Analyze the nutritional content of $foodName and provide the following information in JSON format only:

{
  "calories": number,
  "protein": number,
  "carbs": number,
  "fat": number,
  "fiber": number,
  "sugar": number,
  "sodium": number,
  "vitamins": ["vitamin names"],
  "minerals": ["mineral names"]
}

Provide realistic values per 100g serving. If you cannot determine exact values, provide reasonable estimates based on similar foods.
""",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        // Try to extract JSON from the response
        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            final nutritionData = jsonDecode(jsonMatch.group(0)!);
            return {
              'calories': nutritionData['calories']?.toDouble() ?? 0.0,
              'protein': nutritionData['protein']?.toDouble() ?? 0.0,
              'carbs': nutritionData['carbs']?.toDouble() ?? 0.0,
              'fat': nutritionData['fat']?.toDouble() ?? 0.0,
              'fiber': nutritionData['fiber']?.toDouble() ?? 0.0,
              'sugar': nutritionData['sugar']?.toDouble() ?? 0.0,
              'sodium': nutritionData['sodium']?.toDouble() ?? 0.0,
              'vitamins': nutritionData['vitamins'] ?? [],
              'minerals': nutritionData['minerals'] ?? [],
            };
          }
        } catch (e) {
          print('Error parsing nutrition JSON: $e');
        }
      } else {
        print('Gemini API Error: Status ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Gemini API Error: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching nutrition info: $e');
    }
    return null;
  }

  // Fetch recipe information for a food item using Gemini
  static Future<List<Map<String, dynamic>>?> getRecipeInfo(
    String foodName,
  ) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Provide 5 simple and healthy recipes using $foodName. Return the response in JSON format only:

{
  \"recipes\": [
    {
      \"title\": \"Recipe name\",
      \"description\": \"Brief description\",
      \"ingredients\": [\"ingredient 1\", \"ingredient 2\"],
      \"steps\": [\"Step 1 instruction\", \"Step 2 instruction\"],
      \"cookingTime\": \"time in minutes\",
      \"difficulty\": \"easy/medium/hard\",
      \"servings\": number,
      \"nutritionalBenefits\": \"health benefits\"
    }
  ]
}

Each recipe must include a clear, step-by-step cooking procedure in the 'steps' array. Make the recipes practical and easy to follow.
""",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            final recipeData = jsonDecode(jsonMatch.group(0)!);
            return List<Map<String, dynamic>>.from(recipeData['recipes'] ?? []);
          }
        } catch (e) {
          print('Error parsing recipe JSON: $e');
        }
      } else {
        print('Gemini API Error: Status ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Gemini API Error: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching recipe info: $e');
    }
    return null;
  }

  // Fetch detailed recipe information using Gemini
  static Future<Map<String, dynamic>?> getDetailedRecipe(
    String recipeTitle,
  ) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Provide detailed information for the recipe: $recipeTitle

Return in JSON format:
{
  "title": "Recipe name",
  "description": "Detailed description",
  "ingredients": [
    {
      "name": "ingredient name",
      "amount": "quantity",
      "unit": "measurement unit"
    }
  ],
  "instructions": [
    "Step 1",
    "Step 2",
    "Step 3"
  ],
  "cookingTime": "time in minutes",
  "prepTime": "preparation time",
  "difficulty": "easy/medium/hard",
  "servings": number,
  "nutritionalInfo": "nutritional benefits",
  "tips": ["cooking tip 1", "cooking tip 2"]
}
""",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            return jsonDecode(jsonMatch.group(0)!);
          }
        } catch (e) {
          print('Error parsing detailed recipe JSON: $e');
        }
      } else {
        print('Gemini API Error: Status ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Gemini API Error: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching detailed recipe: $e');
    }
    return null;
  }

  // Fetch allergen information for a food item using Gemini
  static Future<List<String>?> getAllergenInfo(String foodName) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Analyze $foodName for potential allergens and food safety concerns. Return the response in JSON format only:

{
  "allergens": ["allergen1", "allergen2"],
  "safetyNotes": "safety information",
  "storageRecommendations": "how to store safely",
  "crossContaminationRisks": ["risk1", "risk2"]
}

Focus on common allergens like dairy, gluten, nuts, eggs, soy, fish, shellfish, and wheat.
""",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            final allergenData = jsonDecode(jsonMatch.group(0)!);
            return List<String>.from(allergenData['allergens'] ?? []);
          }
        } catch (e) {
          print('Error parsing allergen JSON: $e');
        }
      } else {
        print('Gemini API Error: Status ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Gemini API Error: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching allergen info: $e');
    }
    return null;
  }

  // Get comprehensive food information using Gemini
  static Future<Map<String, dynamic>> getComprehensiveFoodInfo(
    String foodName,
  ) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    """
Provide comprehensive information about $foodName including nutrition, recipes, and allergens. Return in JSON format only:

{
  "nutrition": {
    "calories": number,
    "protein": number,
    "carbs": number,
    "fat": number,
    "fiber": number,
    "sugar": number,
    "sodium": number,
    "vitamins": ["vitamin names"],
    "minerals": ["mineral names"]
  },
  "recipes": [
    {
      "title": "Recipe name",
      "description": "Brief description",
      "ingredients": ["ingredient 1", "ingredient 2"],
      "instructions": "Step by step instructions",
      "cookingTime": "time in minutes",
      "difficulty": "easy/medium/hard",
      "servings": number
    }
  ],
  "allergens": ["allergen1", "allergen2"],
  "healthBenefits": "health benefits description",
  "storageTips": "how to store properly",
  "safetyNotes": "safety information"
}

Provide realistic and practical information.
""",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;

        try {
          final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(text);
          if (jsonMatch != null) {
            final rawData = jsonDecode(jsonMatch.group(0)!);

            // Process nutrition data to ensure proper types
            Map<String, dynamic>? nutritionData;
            if (rawData['nutrition'] != null) {
              final nutrition = rawData['nutrition'] as Map<String, dynamic>;
              nutritionData = {
                'calories': _safeToDouble(nutrition['calories']),
                'protein': _safeToDouble(nutrition['protein']),
                'carbs': _safeToDouble(nutrition['carbs']),
                'fat': _safeToDouble(nutrition['fat']),
                'fiber': _safeToDouble(nutrition['fiber']),
                'sugar': _safeToDouble(nutrition['sugar']),
                'sodium': _safeToDouble(nutrition['sodium']),
                'vitamins': nutrition['vitamins'] ?? [],
                'minerals': nutrition['minerals'] ?? [],
              };
            }

            return {
              'nutrition': nutritionData,
              'recipes': rawData['recipes'] ?? [],
              'allergens': rawData['allergens'] ?? [],
              'healthBenefits': rawData['healthBenefits'] ?? '',
              'storageTips': rawData['storageTips'] ?? '',
              'safetyNotes': rawData['safetyNotes'] ?? '',
            };
          }
        } catch (e) {
          print('Error parsing comprehensive food info JSON: $e');
        }
      } else {
        print('Gemini API Error: Status ${response.statusCode}');
        print('Response: ${response.body}');
        throw Exception(
          'Gemini API Error: Status ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error fetching comprehensive food info: $e');
    }

    // Return empty structure if API fails
    return {
      'nutrition': null,
      'recipes': [],
      'allergens': [],
      'healthBenefits': '',
      'storageTips': '',
      'safetyNotes': '',
    };
  }

  // Detect food name from image using Gemini API
  static Future<String?> detectFoodNameFromImage(Uint8List imageBytes) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );
      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "What food item is shown in this image? Respond with only the food name, nothing else. If you cannot identify a food item, respond with 'Unknown'.",
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
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;
        return text.trim();
      }
    } catch (e) {
      print('Error calling Gemini API for food name: $e');
    }
    return null;
  }

  // Send a free-form chat prompt to Gemini and return the response as a string
  static Future<String?> sendChatPrompt(String prompt) async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );
      final body = {
        "contents": [
          {
            "parts": [
              {"text": prompt},
            ],
          },
        ],
      };
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String?;
        return text;
      } else {
        print('Gemini API Error: Status  {response.statusCode}');
        print('Response:  {response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending chat prompt: $e');
      return null;
    }
  }

  // Helper method to safely convert values to double
  static double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    if (value is String) {
      try {
        return double.parse(value);
      } catch (e) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Test method to verify Gemini API connection
  static Future<bool> testApiConnection() async {
    try {
      final url = Uri.parse(
        "$_geminiBaseUrl/$_geminiModel:generateContent?key=$_geminiApiKey",
      );

      final prompt = {
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Hello! Please respond with 'API is working' if you can see this message.",
              },
            ],
          },
        ],
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(prompt),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final text =
            decoded['candidates'][0]['content']['parts'][0]['text'] as String;
        print('Gemini API Test Response: $text');
        return true;
      } else {
        print('Gemini API Test Failed: Status ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Gemini API Test Error: $e');
      return false;
    }
  }
}

# API Setup Guide for Smart Food App

This app uses Google's Gemini API to fetch comprehensive nutrition, recipe, and allergen information for food items. The setup is now much simpler!

## Required API

### Google Gemini API

- **Website**: https://aistudio.google.com/app/apikey
- **Free Tier**: 15 requests per minute, 1500 requests per day
- **Setup**:
  1. Go to https://aistudio.google.com/app/apikey
  2. Sign in with your Google account
  3. Create a new API key
  4. The API key is already configured in the app!

## Configuration

The app is already configured with a Gemini API key. If you want to use your own key:

1. **Open** `lib/food_api_service.dart`
2. **Replace** the API key:
   ```dart
   static const String _geminiApiKey = "YOUR_GEMINI_API_KEY";
   ```

## Features Enabled

Once configured, your app will automatically fetch:

### Nutrition Information

- Calories, protein, carbs, fat breakdown
- Fiber, sugar, sodium content
- Vitamins and minerals
- Visual nutrition charts

### Recipe Information

- Multiple recipe suggestions per food item
- Detailed cooking instructions
- Ingredient lists with measurements
- Cooking tips and techniques
- Preparation and cooking times

### Allergen Information

- Common allergen detection
- Safety recommendations
- Storage tips
- Cross-contamination risks

## How It Works

The app uses Gemini AI to:

1. **Analyze food names** and provide comprehensive information
2. **Generate realistic nutrition data** based on food databases
3. **Create practical recipes** with clear instructions
4. **Identify potential allergens** and safety concerns
5. **Provide health benefits** and storage recommendations

## Testing

1. Add a food item to your inventory
2. The app will automatically fetch information from Gemini
3. View detailed information by tapping "View Detailed Information"
4. Navigate through Nutrition, Recipes, and Allergens tabs

## Benefits of Gemini API

- **No external dependencies** - Everything through one API
- **Intelligent responses** - Context-aware information
- **Comprehensive data** - Nutrition, recipes, and safety in one call
- **Reliable service** - Google's infrastructure
- **Easy setup** - Single API key configuration

## Troubleshooting

- **No data showing**: Check your internet connection
- **Limited requests**: Upgrade to paid Gemini plan for more requests
- **Slow loading**: Gemini may take a few seconds to generate responses

## Security Note

- Keep your API keys private
- Don't commit them to public repositories
- Consider using environment variables for production apps

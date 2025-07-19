import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _currencyKey = 'selected_currency';
  static const String _vendorCategoriesKey = 'vendor_categories';

  // Default vendor categories
  static const List<String> _defaultVendorCategories = [
    'Venue',
    'Catering',
    'Photography',
    'Videography',
    'Music/DJ',
    'Flowers',
    'Decoration',
    'Transportation',
    'Beauty/Makeup',
    'Attire/Clothing',
    'Entertainment',
  ];

  Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currencyKey) ?? '\$'; // Default to USD
  }

  Future<void> setCurrency(String currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_currencyKey, currency);
      if (!success) {
        throw Exception('Failed to save currency preference');
      }
    } catch (e) {
      print('Error in setCurrency: $e'); // Debug print
      rethrow;
    }
  }

  Future<List<String>> getVendorCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_vendorCategoriesKey);
    
    // If no custom categories are saved, return default categories
    if (categories == null || categories.isEmpty) {
      await setVendorCategories(_defaultVendorCategories);
      return List.from(_defaultVendorCategories);
    }
    
    return categories;
  }

  Future<void> setVendorCategories(List<String> categories) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setStringList(_vendorCategoriesKey, categories);
      if (!success) {
        throw Exception('Failed to save vendor categories preference');
      }
    } catch (e) {
      print('Error in setVendorCategories: $e'); // Debug print
      rethrow;
    }
  }

  Future<void> addVendorCategory(String category) async {
    final currentCategories = await getVendorCategories();
    if (!currentCategories.contains(category)) {
      currentCategories.add(category);
      await setVendorCategories(currentCategories);
    }
  }

  Future<void> removeVendorCategory(String category) async {
    final currentCategories = await getVendorCategories();
    currentCategories.remove(category);
    await setVendorCategories(currentCategories);
  }

  Future<void> resetToDefaults() async {
    await setCurrency('\$');
    await setVendorCategories(_defaultVendorCategories);
  }

  // Static method to get default categories for use in other classes
  static List<String> get defaultVendorCategories => List.from(_defaultVendorCategories);
}
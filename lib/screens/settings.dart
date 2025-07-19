import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/preferences_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  String _selectedCurrency = '\$';
  List<String> _vendorCategories = [];
  final TextEditingController _categoryController = TextEditingController();
  bool _isLoading = true;

  final List<Map<String, String>> _currencies = [
    {'symbol': '\$', 'name': 'US Dollar (USD)'},
    {'symbol': '€', 'name': 'Euro (EUR)'},
    {'symbol': '£', 'name': 'British Pound (GBP)'},
    {'symbol': '¥', 'name': 'Japanese Yen (JPY)'},
    {'symbol': '₹', 'name': 'Indian Rupee (INR)'},
    {'symbol': 'C\$', 'name': 'Canadian Dollar (CAD)'},
    {'symbol': 'A\$', 'name': 'Australian Dollar (AUD)'},
    {'symbol': '₽', 'name': 'Russian Ruble (RUB)'},
    {'symbol': '¥', 'name': 'Chinese Yuan (CNY)'},
    {'symbol': '₩', 'name': 'South Korean Won (KRW)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    try {
      print("Loading settings..."); // Debug print
      final currency = await _preferencesHelper.getCurrency();
      print("Loaded currency: $currency"); // Debug print
      final categories = await _preferencesHelper.getVendorCategories();
      print("Loaded categories: $categories"); // Debug print
      
      setState(() {
        _selectedCurrency = currency;
        _vendorCategories = List.from(categories);
        _isLoading = false;
      });
      print("Settings loaded successfully"); // Debug print
    } catch (e) {
      print("Error loading settings: $e"); // Debug print
      setState(() {
        _isLoading = false;
      });
      
      Fluttertoast.showToast(
        msg: "Error loading settings: ${e.toString()}",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Future<void> _saveCurrency(String currency) async {
    if (!mounted) return; // Check if widget is still mounted
    
    try {
      print("Attempting to save currency: $currency");
      
      // Test direct SharedPreferences access
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString('selected_currency', currency);
      print("SharedPreferences setString success: $success");
      
      if (mounted) {
        setState(() {
          _selectedCurrency = currency;
        });
        
        Fluttertoast.showToast(
          msg: "Currency updated to $currency",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.greenAccent,
          fontSize: 14.0,
        );
      }
    } catch (e) {
      print("Currency update error: $e");
      print("Error type: ${e.runtimeType}");
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Error: ${e.toString()}",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.redAccent,
          fontSize: 14.0,
        );
      }
    }
  }

  Future<void> _addVendorCategory() async {
    final category = _categoryController.text.trim();
    if (category.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter a category name",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: const Color(0xFF94A3B8),
        fontSize: 14.0,
      );
      return;
    }

    if (_vendorCategories.contains(category)) {
      Fluttertoast.showToast(
        msg: "Category '$category' already exists",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: const Color(0xFF94A3B8),
        fontSize: 14.0,
      );
      return;
    }

    try {
      final updatedCategories = [..._vendorCategories, category];
      await _preferencesHelper.setVendorCategories(updatedCategories);
      
      setState(() {
        _vendorCategories = updatedCategories;
        _categoryController.clear();
      });

      Fluttertoast.showToast(
        msg: "Category '$category' added successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error adding category: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Future<void> _removeVendorCategory(String category) async {
    try {
      final updatedCategories = _vendorCategories.where((c) => c != category).toList();
      await _preferencesHelper.setVendorCategories(updatedCategories);
      
      setState(() {
        _vendorCategories = updatedCategories;
      });

      Fluttertoast.showToast(
        msg: "Category '$category' removed successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error removing category: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Future<void> _resetToDefaults() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Reset to Defaults',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'This will reset currency to USD (\$) and vendor categories to default list. This action cannot be undone.',
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.deepPurple,
              ),
              child: const Text(
                'Reset',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        await _preferencesHelper.resetToDefaults();
        await _loadSettings();
        
        Fluttertoast.showToast(
          msg: "Settings reset to defaults successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.greenAccent,
          fontSize: 14.0,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error resetting settings: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.redAccent,
          fontSize: 14.0,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D1B2A),
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // Currency Settings Section
            _buildSectionCard(
              title: 'Currency Settings',
              icon: Icons.attach_money,
              children: [
                const Text(
                  'Select your preferred currency for budget tracking:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCurrency,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1E293B),
                      style: const TextStyle(color: Colors.white),
                      items: _currencies.map((currency) {
                        return DropdownMenuItem<String>(
                          value: currency['symbol'],
                          child: Text(
                            '${currency['symbol']} - ${currency['name']}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        print("Currency dropdown changed to: $newValue"); // Debug print
                        if (newValue != null && newValue != _selectedCurrency) {
                          _saveCurrency(newValue);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Vendor Categories Section
            _buildSectionCard(
              title: 'Vendor Categories',
              icon: Icons.category,
              children: [
                const Text(
                  'Manage your vendor categories:',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Add new category
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _categoryController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter new category',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _addVendorCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Categories list
                if (_vendorCategories.isNotEmpty) ...[
                  const Text(
                    'Current Categories:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...(_vendorCategories.map((category) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              category,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeVendorCategory(category),
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ),
                  )).toList()),
                ] else
                  const Text(
                    'No custom categories added yet.',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            // Reset Button
            Center(
              child: ElevatedButton(
                onPressed: _resetToDefaults,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Reset to Defaults'),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1E293B),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
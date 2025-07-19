import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/vendor.dart';
import '../services/database_helper.dart';
import '../services/preferences_helper.dart';

class AddVendorScreen extends StatefulWidget {
  const AddVendorScreen({super.key});

  @override
  State<AddVendorScreen> createState() => _AddVendorScreenState();
}

class _AddVendorScreenState extends State<AddVendorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategory;
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  List<String> _existingCategories = [];
  List<String> _availableCategories = [];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      // Load available categories from preferences
      final categories = await _preferencesHelper.getVendorCategories();
      
      // Load existing categories to check for uniqueness
      final weddingEvent = await _databaseHelper.getWeddingEvent();
      if (weddingEvent != null) {
        final vendors = await _databaseHelper.getVendorsByWeddingEvent(
          weddingEvent.id!,
        );
        setState(() {
          _availableCategories = categories;
          _existingCategories = vendors
              .map((vendor) => vendor.category)
              .toList();
        });
      } else {
        setState(() {
          _availableCategories = categories;
        });
      }
    } catch (e) {
      // Handle error silently, use default categories
      setState(() {
        _availableCategories = PreferencesHelper.defaultVendorCategories;
      });
    }
  }

  Future<void> _saveVendor() async {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      // Check if category already exists
      if (_existingCategories.contains(_selectedCategory)) {
        Fluttertoast.showToast(
          msg: "A vendor with category '$_selectedCategory' already exists",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 4,
          backgroundColor: const Color(0xFF1E293B),
          textColor: const Color(0xFF94A3B8),
          fontSize: 14.0,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current wedding event
        final weddingEvent = await _databaseHelper.getWeddingEvent();
        if (weddingEvent == null) {
          throw Exception('No wedding event found');
        }

        final vendor = Vendor(
          name: _nameController.text.trim(),
          contact: _contactController.text.trim(),
          category: _selectedCategory!,
          notes: _notesController.text.trim(),
          weddingEventId: weddingEvent.id!,
        );

        await _databaseHelper.insertVendor(vendor);

        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "Vendor added successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.greenAccent,
          fontSize: 14.0,
        );

        Navigator.of(context).pop();
      } catch (e) {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: "Error adding vendor: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.redAccent,
          fontSize: 14.0,
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } else if (_selectedCategory == null) {
      Fluttertoast.showToast(
        msg: "Please select a vendor category",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: const Color(0xFF94A3B8),
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Add Vendor',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Add a new vendor to your wedding',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Vendor Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.business, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the vendor name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.phone, color: Colors.white70),
                  hintText: '10-digit phone number',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter phone number';
                  }
                  if (value.length != 10) {
                    return 'Phone number must be exactly 10 digits';
                  }
                  if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                    return 'Phone number must contain only numbers';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.category, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF1E293B),
                items: _availableCategories.map((String category) {
                  final isUsed = _existingCategories.contains(category);
                  return DropdownMenuItem<String>(
                    value: category,
                    enabled: !isUsed,
                    child: Row(
                      children: [
                        Text(
                          category,
                          style: TextStyle(
                            color: isUsed ? Colors.grey : Colors.white,
                          ),
                        ),
                        if (isUsed) ...[
                          const SizedBox(width: 8),
                          const Text(
                            '(Already added)',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.note, color: Colors.white70),
                  hintText: 'Additional notes about this vendor',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                minLines: 2,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveVendor,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 8,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add Vendor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

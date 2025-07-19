import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/budget.dart';
import '../services/database_helper.dart';
import '../services/preferences_helper.dart';

class AddBudgetScreen extends StatefulWidget {
  const AddBudgetScreen({super.key});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _allocatedAmountController = TextEditingController();
  final _spentAmountController = TextEditingController();
  String _selectedCategory = BudgetCategory.venue;
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  List<String> _existingCategories = [];
  String _currency = '\$';

  @override
  void initState() {
    super.initState();
    _loadExistingCategories();
    _loadCurrency();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _allocatedAmountController.dispose();
    _spentAmountController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingCategories() async {
    try {
      final weddingEvent = await _databaseHelper.getWeddingEvent();
      if (weddingEvent != null) {
        final budgets = await _databaseHelper.getBudgetsByWeddingEvent(weddingEvent.id!);
        setState(() {
          _existingCategories = budgets.map((budget) => budget.category).toList();
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _loadCurrency() async {
    try {
      final currency = await _preferencesHelper.getCurrency();
      setState(() {
        _currency = currency;
      });
    } catch (e) {
      // Use default currency if loading fails
    }
  }

  Future<void> _saveBudget() async {
    if (_formKey.currentState!.validate()) {
      // Check if category already exists
      if (_existingCategories.contains(_selectedCategory)) {
        Fluttertoast.showToast(
          msg: "A budget for '$_selectedCategory' already exists",
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

        final budget = Budget(
          category: _selectedCategory,
          description: _descriptionController.text.trim(),
          allocatedAmount: double.parse(_allocatedAmountController.text.trim()),
          spentAmount: double.parse(_spentAmountController.text.trim().isEmpty ? '0' : _spentAmountController.text.trim()),
          weddingEventId: weddingEvent.id!,
        );

        await _databaseHelper.insertBudget(budget);

        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "Budget entry added successfully!",
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
          msg: "Error adding budget: $e",
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Add Budget Entry',
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
                'Add a new budget entry',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
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
                items: BudgetCategory.allCategories.map((String category) {
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
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
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
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.description, color: Colors.white70),
                  hintText: 'Brief description of this budget item',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _allocatedAmountController,
                decoration: InputDecoration(
                  labelText: 'Allocated Budget',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: Text(
                        _currency,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(15), // Limit total length to prevent overflow
                ],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter allocated budget';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'Please enter a valid amount';
                  }
                  if (amount > 999999999) {
                    return 'Amount too large (max 999,999,999)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _spentAmountController,
                decoration: InputDecoration(
                  labelText: 'Amount Spent (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 12, right: 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: 1.0,
                      child: Text(
                        _currency,
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ),
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  LengthLimitingTextInputFormatter(15), // Limit total length to prevent overflow
                ],
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    final amount = double.tryParse(value);
                    if (amount == null || amount < 0) {
                      return 'Please enter a valid amount';
                    }
                    if (amount > 999999999) {
                      return 'Amount too large (max 999,999,999)';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveBudget,
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
                        'Add Budget Entry',
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
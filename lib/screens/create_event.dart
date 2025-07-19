import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/wedding_event.dart';
import '../services/database_helper.dart';

class CreateEventScreen extends StatefulWidget {
  final WeddingEvent? existingEvent;
  
  const CreateEventScreen({super.key, this.existingEvent});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brideNameController = TextEditingController();
  final _groomNameController = TextEditingController();
  DateTime? _selectedDate;
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  bool get _isEditing => widget.existingEvent != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _brideNameController.text = widget.existingEvent!.brideName;
      _groomNameController.text = widget.existingEvent!.groomName;
      _selectedDate = widget.existingEvent!.weddingDate;
      print('Edit mode: Prefilling with ${widget.existingEvent!.brideName} & ${widget.existingEvent!.groomName}');
    } else {
      print('Create mode: Starting with empty form');
    }
  }

  @override
  void dispose() {
    _brideNameController.dispose();
    _groomNameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.deepPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        final event = WeddingEvent(
          id: _isEditing ? widget.existingEvent!.id : null,
          brideName: _brideNameController.text.trim(),
          groomName: _groomNameController.text.trim(),
          weddingDate: _selectedDate!,
          createdAt: _isEditing ? widget.existingEvent!.createdAt : null,
        );

        if (_isEditing) {
          await _databaseHelper.updateWeddingEvent(event);
        } else {
          await _databaseHelper.insertWeddingEvent(event);
        }

        if (!mounted) return;

        Fluttertoast.showToast(
          msg: _isEditing 
            ? "Wedding event updated successfully!" 
            : "Wedding event created successfully!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3,
          backgroundColor: const Color(0xFF1E293B),
          textColor: Colors.greenAccent,
          fontSize: 14.0,
        );

        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        if (!mounted) return;
        Fluttertoast.showToast(
          msg: "Error ${_isEditing ? 'updating' : 'creating'} event: $e",
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
    } else if (_selectedDate == null) {
      Fluttertoast.showToast(
        msg: "Please select a wedding date",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: const Color(0xFF94A3B8), // Light slate gray
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Wedding Event' : 'Create Wedding Event',
          style: const TextStyle(
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                _isEditing 
                  ? 'Update your wedding details'
                  : 'Let\'s start planning your special day!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: _brideNameController,
                decoration: InputDecoration(
                  labelText: 'Bride\'s Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the bride\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _groomNameController,
                decoration: InputDecoration(
                  labelText: 'Groom\'s Name',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person, color: Colors.white70),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the groom\'s name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select Wedding Date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null ? Colors.white70 : Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveEvent,
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
                    : Text(
                        _isEditing ? 'Update Event' : 'Create Event',
                        style: const TextStyle(
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
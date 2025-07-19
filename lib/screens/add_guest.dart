import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/guest.dart';
import '../services/database_helper.dart';

class AddGuestScreen extends StatefulWidget {
  const AddGuestScreen({super.key});

  @override
  State<AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<AddGuestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dietaryController = TextEditingController();
  String _selectedRSVPStatus = RSVPStatus.pending;
  String _selectedSide = GuestSide.bride;
  bool _isLoading = false;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dietaryController.dispose();
    super.dispose();
  }

  Future<void> _saveGuest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Get the current wedding event
        final weddingEvent = await _databaseHelper.getWeddingEvent();
        if (weddingEvent == null) {
          throw Exception('No wedding event found');
        }

        final guest = Guest(
          name: _nameController.text.trim(),
          email: '', // Empty email since we removed the field
          phone: _phoneController.text.trim(),
          rsvpStatus: _selectedRSVPStatus,
          side: _selectedSide,
          dietaryRestrictions: _dietaryController.text.trim(),
          weddingEventId: weddingEvent.id!,
        );

        await _databaseHelper.insertGuest(guest);

        if (!mounted) return;

        Fluttertoast.showToast(
          msg: "Guest added successfully!",
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
          msg: "Error adding guest: $e",
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
          'Add Guest',
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
                'Add a new guest to your wedding',
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
                  labelText: 'Guest Name',
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
                    return 'Please enter the guest name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
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
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedSide,
                decoration: InputDecoration(
                  labelText: 'Guest Side',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.people_alt,
                    color: Colors.white70,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF1E293B),
                items: GuestSide.allSides.map((String side) {
                  return DropdownMenuItem<String>(
                    value: side,
                    child: Text(
                      side,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedSide = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedRSVPStatus,
                decoration: InputDecoration(
                  labelText: 'RSVP Status',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.event_available,
                    color: Colors.white70,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                dropdownColor: const Color(0xFF1E293B),
                items: RSVPStatus.allStatuses.map((String status) {
                  return DropdownMenuItem<String>(
                    value: status,
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRSVPStatus = newValue!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _dietaryController,
                decoration: InputDecoration(
                  labelText: 'Dietary Restrictions (Optional)',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(
                    Icons.restaurant,
                    color: Colors.white70,
                  ),
                  hintText: 'Allergies, preferences, etc.',
                  hintStyle: const TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                minLines: 1,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveGuest,
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
                        'Add Guest',
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

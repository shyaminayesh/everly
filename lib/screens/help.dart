import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text(
          'Help',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 4,
        shadowColor: Colors.deepPurple.withOpacity(0.3),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              'Getting Started',
              [
                _buildFAQItem(
                  'How do I create my first wedding event?',
                  'Tap the "Create Event" button on the home screen. Fill in the couple names, wedding date, and venue details to get started.',
                ),
                _buildFAQItem(
                  'How do I add guests to my wedding?',
                  'Go to the Guest List tab and tap the "+" button. Enter guest details including name, phone, side (Bride/Groom), and dietary restrictions.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Managing Your Budget',
              [
                _buildFAQItem(
                  'How do I track my wedding expenses?',
                  'Use the Budget tab to create categories like "Venue", "Catering", "Photography". Set allocated amounts and update spent amounts as you make payments.',
                ),
                _buildFAQItem(
                  'What happens if I go over budget?',
                  'The app will show your budget items in red when you exceed the allocated amount, helping you track overspending.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Vendor Management',
              [
                _buildFAQItem(
                  'How do I add vendors?',
                  'Go to the Vendors tab and tap the "+" button. Add vendor details including name, category, contact information, and notes.',
                ),
                _buildFAQItem(
                  'Can I organize vendors by category?',
                  'Yes, when adding vendors you can assign them to categories like "Photography", "Catering", "Flowers", etc.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Guest List Features',
              [
                _buildFAQItem(
                  'How do I track RSVPs?',
                  'Edit any guest to update their RSVP status to "Attending", "Not Attending", or "Pending". The home screen shows an overview chart.',
                ),
                _buildFAQItem(
                  'Can I filter guests by side?',
                  'Yes, use the filter button in the Guest List to view all guests, just the bride\'s side, or just the groom\'s side.',
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Settings & Customization',
              [
                _buildFAQItem(
                  'How do I change the currency?',
                  'Go to Settings and select your preferred currency. This will update all budget displays throughout the app.',
                ),
                _buildFAQItem(
                  'Can I delete my wedding event?',
                  'Yes, but be careful! Go to the home screen and use the delete button on your wedding card. This action cannot be undone.',
                ),
              ],
            ),
            const SizedBox(height: 32),
            Center(
              child: Card(
                color: const Color(0xFF1E293B),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: Colors.deepPurple,
                        size: 48,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Need More Help?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Contact our support team for additional assistance with planning your special day.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...items,
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E293B),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconColor: Colors.deepPurple,
        collapsedIconColor: Colors.white70,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
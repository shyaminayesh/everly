import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/wedding_event.dart';
import '../models/vendor.dart';
import '../models/guest.dart';
import '../models/budget.dart';
import '../services/database_helper.dart';
import '../services/preferences_helper.dart';
import 'settings.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2; // Start with Home tab (middle)
  WeddingEvent? _weddingEvent;
  List<Vendor> _vendors = [];
  List<Guest> _guests = [];
  List<Guest> _filteredGuests = [];
  List<Budget> _budgets = [];
  String _guestFilter = 'All'; // 'All', 'Bride\'s Side', 'Groom\'s Side'
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final PreferencesHelper _preferencesHelper = PreferencesHelper();
  bool _isLoading = true;
  String _currency = '\$';

  String _formatCompactCurrency(double amount) {
    try {
      if (amount.isNaN || amount.isInfinite) {
        return '$_currency 0';
      }
      if (amount >= 10000) {
        return '$_currency${(amount / 1000).toStringAsFixed(0)}K';
      } else if (amount >= 1000) {
        return '$_currency${(amount / 1000).toStringAsFixed(1)}K';
      } else {
        return '$_currency${amount.toStringAsFixed(0)}';
      }
    } catch (e) {
      return '$_currency 0';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWeddingEvent();
    _loadCurrency();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload wedding event when returning from other screens
    _loadWeddingEvent();
  }

  Future<void> _loadWeddingEvent() async {
    try {
      final event = await _databaseHelper.getWeddingEvent();
      List<Vendor> vendors = [];
      List<Guest> guests = [];
      List<Budget> budgets = [];

      if (event != null) {
        vendors = await _databaseHelper.getVendorsByWeddingEvent(event.id!);
        guests = await _databaseHelper.getGuestsByWeddingEvent(event.id!);
        budgets = await _databaseHelper.getBudgetsByWeddingEvent(event.id!);
      }

      setState(() {
        _weddingEvent = event;
        _vendors = vendors;
        _guests = guests;
        _budgets = budgets;
        _applyGuestFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
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

  void _applyGuestFilter() {
    switch (_guestFilter) {
      case 'All':
        _filteredGuests = List.from(_guests);
        break;
      case "Bride's Side":
        _filteredGuests = _guests
            .where((guest) => guest.side == "Bride's Side")
            .toList();
        break;
      case "Groom's Side":
        _filteredGuests = _guests
            .where((guest) => guest.side == "Groom's Side")
            .toList();
        break;
      default:
        _filteredGuests = List.from(_guests);
    }
  }

  void _setGuestFilter(String filter) {
    setState(() {
      _guestFilter = filter;
      _applyGuestFilter();
    });
  }

  Future<void> _showDeleteConfirmation() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Wedding Event',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${_weddingEvent?.coupleNames}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteWeddingEvent();
    }
  }

  Future<void> _deleteWeddingEvent() async {
    try {
      await _databaseHelper.deleteWeddingEvent();

      setState(() {
        _weddingEvent = null;
      });

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Wedding event deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Error deleting event: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Future<void> _showDeleteVendorConfirmation(Vendor vendor) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Vendor',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${vendor.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteVendor(vendor);
    }
  }

  Future<void> _deleteVendor(Vendor vendor) async {
    try {
      await _databaseHelper.deleteVendor(vendor.id!);

      setState(() {
        _vendors.removeWhere((v) => v.id == vendor.id);
      });

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Vendor deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Error deleting vendor: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Widget _buildDisabledScreen(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2; // Navigate to Home tab
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: const Text(
                'Go to Home',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0: // Guest List
        return _weddingEvent == null
            ? _buildDisabledScreen(
                'Guest List',
                'Create a wedding event first to manage your guest list',
                Icons.people,
              )
            : _buildGuestsList();
      case 1: // Budget
        return _weddingEvent == null
            ? _buildDisabledScreen(
                'Budget',
                'Create a wedding event first to start planning your budget',
                Icons.attach_money,
              )
            : _buildBudgetList();
      case 2: // Home
        return _buildHomeContent();
      case 3: // Vendors
        return _weddingEvent == null
            ? _buildDisabledScreen(
                'Vendors',
                'Create a wedding event first to manage your vendor list',
                Icons.business,
              )
            : _buildVendorsList();
      case 4: // Settings
        return const SettingsScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildGuestsList() {
    if (_guests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people, size: 80, color: Colors.white54),
            SizedBox(height: 24),
            Text(
              'Add guests using the + button\nto keep track of them',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // RSVP Chart
        _buildRSVPChart(),
        // Guest count indicator
        if (_filteredGuests.length != _guests.length)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Showing ${_filteredGuests.length} of ${_guests.length} guests',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        // Guest list
        Expanded(
          child: _filteredGuests.isEmpty
              ? Center(
                  child: Text(
                    'No guests found for $_guestFilter',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredGuests.length,
                  itemBuilder: (context, index) {
                    final guest = _filteredGuests[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      color: const Color(0xFF1E293B),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getRSVPStatusColor(
                                            guest.rsvpStatus,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          guest.rsvpStatus,
                                          style: TextStyle(
                                            color: _getRSVPStatusColor(
                                              guest.rsvpStatus,
                                            ),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 4,
                                          vertical: 1,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getSideColor(
                                            guest.side,
                                          ).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Text(
                                          guest.side,
                                          style: TextStyle(
                                            color: _getSideColor(guest.side),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    guest.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.phone,
                                        color: Colors.white70,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          guest.phone,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (guest.dietaryRestrictions.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.restaurant,
                                          color: Colors.white70,
                                          size: 12,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            guest.dietaryRestrictions,
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 11,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    await Navigator.of(context).pushNamed(
                                      '/edit-guest',
                                      arguments: guest,
                                    );
                                    // Reload guests after returning from edit guest screen
                                    _loadWeddingEvent();
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white70,
                                      size: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                GestureDetector(
                                  onTap: () =>
                                      _showDeleteGuestConfirmation(guest),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.redAccent,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildRSVPChart() {
    final stats = _calculateRSVPStats();
    final total = stats.values.reduce((a, b) => a + b);

    if (total == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Circular Chart
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: RSVPChartPainter(stats, total),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$total',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Total',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem(
                'Attending',
                stats['Attending'] ?? 0,
                Colors.greenAccent,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                'Pending',
                stats['Pending'] ?? 0,
                Colors.orangeAccent,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                'Not Attending',
                stats['Not Attending'] ?? 0,
                Colors.redAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: $count',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBudgetList() {
    if (_budgets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.attach_money,
              size: 80,
              color: Colors.white54,
            ),
            SizedBox(height: 24),
            Text(
              'Add budget entries using the + button\nto track your wedding expenses',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Budget Chart
        _buildBudgetChart(),
        // Budget list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _budgets.length,
            itemBuilder: (context, index) {
              final budget = _budgets[index];
              return _buildBudgetCard(budget);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBudgetChart() {
    final totalAllocated = _budgets.fold<double>(0, (sum, budget) => sum + budget.allocatedAmount);
    final totalSpent = _budgets.fold<double>(0, (sum, budget) => sum + budget.spentAmount);
    final remaining = totalAllocated - totalSpent;
    
    if (totalAllocated == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Circular Chart
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(
              painter: BudgetChartPainter(totalSpent, totalAllocated),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formatCompactCurrency(totalAllocated),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Total Budget',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Legend
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBudgetLegendItem('Allocated', totalAllocated, Colors.blueAccent),
              const SizedBox(height: 8),
              _buildBudgetLegendItem('Spent', totalSpent, Colors.orangeAccent),
              const SizedBox(height: 8),
              _buildBudgetLegendItem('Remaining', remaining, remaining >= 0 ? Colors.greenAccent : Colors.redAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetLegendItem(String label, double amount, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${_formatCompactCurrency(amount)}',
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildBudgetCard(Budget budget) {
    final progressPercent = budget.allocatedAmount > 0 
        ? (budget.spentAmount / budget.allocatedAmount * 100).clamp(0, 100) 
        : 0.0;
    final remaining = budget.allocatedAmount - budget.spentAmount;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFF1E293B),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with category and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        budget.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (budget.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          budget.description,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () async {
                        await Navigator.of(context).pushNamed(
                          '/edit-budget',
                          arguments: budget,
                        );
                        _loadWeddingEvent();
                      },
                      icon: const Icon(
                        Icons.edit,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      onPressed: () => _showDeleteBudgetConfirmation(budget),
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Budget amounts
            Row(
              children: [
                Expanded(
                  child: _buildBudgetAmount(
                    'Allocated',
                    budget.allocatedAmount,
                    Colors.blueAccent,
                  ),
                ),
                Expanded(
                  child: _buildBudgetAmount(
                    'Spent',
                    budget.spentAmount,
                    budget.spentAmount > budget.allocatedAmount 
                        ? Colors.redAccent 
                        : Colors.orangeAccent,
                  ),
                ),
                Expanded(
                  child: _buildBudgetAmount(
                    'Remaining',
                    remaining,
                    remaining >= 0 ? Colors.greenAccent : Colors.redAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '${progressPercent.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: progressPercent > 100 ? Colors.redAccent : Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (progressPercent / 100).clamp(0.0, 1.0),
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progressPercent > 100 ? Colors.redAccent : Colors.greenAccent,
                  ),
                  minHeight: 8,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetAmount(String label, double amount, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatCompactCurrency(amount),
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Future<void> _showDeleteBudgetConfirmation(Budget budget) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Budget Entry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${budget.category}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteBudget(budget);
    }
  }

  Future<void> _deleteBudget(Budget budget) async {
    try {
      await _databaseHelper.deleteBudget(budget.id!);

      setState(() {
        _budgets.removeWhere((b) => b.id == budget.id);
      });

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Budget entry deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Error deleting budget entry: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Map<String, int> _calculateRSVPStats() {
    final stats = <String, int>{
      'Attending': 0,
      'Not Attending': 0,
      'Pending': 0,
    };

    for (final guest in _filteredGuests) {
      stats[guest.rsvpStatus] = (stats[guest.rsvpStatus] ?? 0) + 1;
    }

    return stats;
  }

  Color _getRSVPStatusColor(String status) {
    switch (status) {
      case 'Attending':
        return Colors.greenAccent;
      case 'Not Attending':
        return Colors.redAccent;
      case 'Pending':
      default:
        return Colors.orangeAccent;
    }
  }

  Color _getSideColor(String side) {
    switch (side) {
      case "Bride's Side":
        return Colors.pinkAccent;
      case "Groom's Side":
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }

  Future<void> _showDeleteGuestConfirmation(Guest guest) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Delete Guest',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${guest.name}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'Delete',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteGuest(guest);
    }
  }

  Future<void> _deleteGuest(Guest guest) async {
    try {
      await _databaseHelper.deleteGuest(guest.id!);

      setState(() {
        _guests.removeWhere((g) => g.id == guest.id);
        _applyGuestFilter();
      });

      if (!mounted) return;

      Fluttertoast.showToast(
        msg: "Guest deleted successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.greenAccent,
        fontSize: 14.0,
      );
    } catch (e) {
      if (!mounted) return;
      Fluttertoast.showToast(
        msg: "Error deleting guest: $e",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3,
        backgroundColor: const Color(0xFF1E293B),
        textColor: Colors.redAccent,
        fontSize: 14.0,
      );
    }
  }

  Widget _buildVendorsList() {
    if (_vendors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.white54),
            SizedBox(height: 24),
            Text(
              'Add vendors using the + button\nto manage your wedding vendors',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vendors.length,
      itemBuilder: (context, index) {
        final vendor = _vendors[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: const Color(0xFF1E293B),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              vendor.category,
                              style: const TextStyle(
                                color: Colors.deepPurple,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        vendor.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.phone,
                            color: Colors.white70,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              vendor.contact,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (vendor.notes.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.note,
                              color: Colors.white70,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                vendor.notes,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        await Navigator.of(
                          context,
                        ).pushNamed('/edit-vendor', arguments: vendor);
                        // Reload vendors after returning from edit vendor screen
                        _loadWeddingEvent();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white70,
                          size: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showDeleteVendorConfirmation(vendor),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.redAccent,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHomeContent() {
    return _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _weddingEvent == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Start Planning Your Wedding',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Material(
                  borderRadius: BorderRadius.circular(15),
                  elevation: 8,
                  shadowColor: Colors.deepPurple.withValues(alpha: 0.5),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15),
                    onTap: () {
                      Navigator.of(context).pushNamed('/create-event');
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Text(
                        'Create Event',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: () {
                  final daysUntilWedding = _weddingEvent!.weddingDate
                      .difference(DateTime.now())
                      .inDays;

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Main card content
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(15),
                              topRight: Radius.circular(15),
                            ),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4C1D95), // Dark purple
                                Color(0xFF6D28D9), // Medium purple
                              ],
                            ),
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                _weddingEvent!.coupleNames,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: Colors.white70,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_weddingEvent!.weddingDate.day}/${_weddingEvent!.weddingDate.month}/${_weddingEvent!.weddingDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  daysUntilWedding > 0
                                      ? '$daysUntilWedding days to go!'
                                      : daysUntilWedding == 0
                                      ? 'Today is the day! 🎉'
                                      : 'Wedding was ${-daysUntilWedding} days ago',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: daysUntilWedding >= 0
                                        ? Colors.greenAccent
                                        : Colors.white70,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Card footer with buttons
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF2D1B69,
                            ), // Dark purple footer
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(15),
                              bottomRight: Radius.circular(15),
                            ),
                            border: Border(
                              top: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamed(
                                    '/create-event',
                                    arguments: _weddingEvent,
                                  );
                                },
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                tooltip: 'Edit Wedding',
                                padding: const EdgeInsets.all(8),
                              ),
                              IconButton(
                                onPressed: () => _showDeleteConfirmation(),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                tooltip: 'Delete Wedding',
                                padding: const EdgeInsets.all(8),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }(),
              ),
              const SizedBox(height: 24),
              // Overview Charts Section
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      // Guest Overview Card
                      if (_guests.isNotEmpty) _buildHomeGuestOverview(),
                      const SizedBox(height: 16),
                      // Budget Overview Card
                      if (_budgets.isNotEmpty) _buildHomeBudgetOverview(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildHomeGuestOverview() {
    final stats = _calculateRSVPStats();
    final total = stats.values.reduce((a, b) => a + b);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: const Color(0xFF1E293B),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Guest Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = 0; // Switch to Guest List tab
                    });
                  },
                  child: const Text(
                    'View All',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0)
              Row(
                children: [
                  // Compact circular chart
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CustomPaint(
                      painter: RSVPChartPainter(stats, total),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '$total',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              'Total',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Compact legend
                  Expanded(
                    child: Column(
                      children: [
                        _buildCompactLegendItem(
                          'Attending',
                          stats['Attending'] ?? 0,
                          Colors.greenAccent,
                        ),
                        const SizedBox(height: 6),
                        _buildCompactLegendItem(
                          'Pending',
                          stats['Pending'] ?? 0,
                          Colors.orangeAccent,
                        ),
                        const SizedBox(height: 6),
                        _buildCompactLegendItem(
                          'Not Attending',
                          stats['Not Attending'] ?? 0,
                          Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            else
              const Center(
                child: Text(
                  'No guests added yet',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeBudgetOverview() {
    try {
      final totalAllocated = _budgets.fold<double>(
        0,
        (sum, budget) => sum + budget.allocatedAmount,
      );
      final totalSpent = _budgets.fold<double>(
        0,
        (sum, budget) => sum + budget.spentAmount,
      );
      final remaining = totalAllocated - totalSpent;

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        color: const Color(0xFF1E293B),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.attach_money, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Budget Overview',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = 1; // Switch to Budget tab
                      });
                    },
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (totalAllocated > 0)
                Row(
                  children: [
                    // Compact circular chart
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CustomPaint(
                        painter: BudgetChartPainter(totalSpent, totalAllocated),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formatCompactCurrency(totalAllocated),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Text(
                                'Budget',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),
                    // Compact legend
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompactBudgetLegendItem(
                            'Allocated',
                            totalAllocated,
                            Colors.blueAccent,
                          ),
                          const SizedBox(height: 6),
                          _buildCompactBudgetLegendItem(
                            'Spent',
                            totalSpent,
                            totalSpent > totalAllocated
                                ? Colors.redAccent
                                : Colors.orangeAccent,
                          ),
                          const SizedBox(height: 6),
                          _buildCompactBudgetLegendItem(
                            'Remaining',
                            remaining,
                            remaining >= 0
                                ? Colors.greenAccent
                                : Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Center(
                  child: Text(
                    'No budget entries added yet',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const SizedBox.shrink();
    }
  }

  Widget _buildCompactLegendItem(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $count',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCompactBudgetLegendItem(
    String label,
    double amount,
    Color color,
  ) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$label: ${_formatCompactCurrency(amount)}',
              style: const TextStyle(color: Colors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget>? _buildAppBarActions() {
    List<Widget> actions = [];

    // Add hamburger menu (only on Home screen)
    if (_currentIndex == 2) {
      actions.add(
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          tooltip: 'Menu',
          color: const Color(0xFF1E293B),
          onSelected: (String value) {
            // Handle menu item selection
            switch (value) {
              case 'settings':
                setState(() {
                  _currentIndex = 4; // Navigate to Settings tab
                });
                break;
              case 'help':
                Navigator.of(context).pushNamed('/help');
                break;
              case 'about':
                Navigator.of(context).pushNamed('/about-us');
                break;
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'settings',
              child: Row(
                children: [
                  Icon(Icons.settings, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text('Settings', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'help',
              child: Row(
                children: [
                  Icon(Icons.help_outline, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text('Help', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem<String>(
              value: 'about',
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 18),
                  SizedBox(width: 8),
                  Text('About Us', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (_weddingEvent == null) return actions.isEmpty ? null : actions;

    // Guest List filters
    if (_currentIndex == 0 && _guests.isNotEmpty) {
      actions.addAll([
        PopupMenuButton<String>(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          tooltip: 'Filter Guests',
          color: const Color(0xFF1E293B),
          onSelected: _setGuestFilter,
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'All',
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: _guestFilter == 'All'
                        ? Colors.deepPurple
                        : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'All Guests',
                    style: TextStyle(
                      color: _guestFilter == 'All'
                          ? Colors.deepPurple
                          : Colors.white,
                      fontWeight: _guestFilter == 'All'
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_guestFilter == 'All') ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.deepPurple, size: 16),
                  ],
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: "Bride's Side",
              child: Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: _guestFilter == "Bride's Side"
                        ? Colors.pinkAccent
                        : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Bride's Side",
                    style: TextStyle(
                      color: _guestFilter == "Bride's Side"
                          ? Colors.pinkAccent
                          : Colors.white,
                      fontWeight: _guestFilter == "Bride's Side"
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_guestFilter == "Bride's Side") ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.pinkAccent, size: 16),
                  ],
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: "Groom's Side",
              child: Row(
                children: [
                  Icon(
                    Icons.face,
                    color: _guestFilter == "Groom's Side"
                        ? Colors.blueAccent
                        : Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Groom's Side",
                    style: TextStyle(
                      color: _guestFilter == "Groom's Side"
                          ? Colors.blueAccent
                          : Colors.white,
                      fontWeight: _guestFilter == "Groom's Side"
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                  if (_guestFilter == "Groom's Side") ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Colors.blueAccent, size: 16),
                  ],
                ],
              ),
            ),
          ],
        ),
      ]);
    }

    // Add buttons for Guest List, Budget, and Vendors
    if (_currentIndex == 3 || _currentIndex == 0 || _currentIndex == 1) {
      actions.add(
        IconButton(
          onPressed: () async {
            if (_currentIndex == 3) {
              // Vendors tab
              await Navigator.of(context).pushNamed('/add-vendor');
              _loadWeddingEvent();
            } else if (_currentIndex == 0) {
              // Guest List tab
              await Navigator.of(context).pushNamed('/add-guest');
              _loadWeddingEvent();
            } else if (_currentIndex == 1) {
              // Budget tab
              await Navigator.of(context).pushNamed('/add-budget');
              _loadWeddingEvent();
            }
          },
          icon: const Icon(Icons.add, color: Colors.white, size: 24),
          tooltip: _currentIndex == 3
              ? 'Add Vendor'
              : _currentIndex == 0
              ? 'Add Guest'
              : 'Add Budget',
        ),
      );
    }

    return actions;
  }

  bool get _shouldShowBackgroundImage {
    // Only show background image when on Home tab and no wedding event exists
    return _currentIndex == 2 && _weddingEvent == null && !_isLoading;
  }

  String get _getAppBarTitle {
    switch (_currentIndex) {
      case 0:
        return 'Guest List';
      case 1:
        return 'Budget';
      case 2:
        return 'Home';
      case 3:
        return 'Vendors';
      case 4:
        return 'Settings';
      default:
        return 'Everly';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: Text(
          _getAppBarTitle,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 4,
        shadowColor: Colors.deepPurple.withValues(alpha: 0.3),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: _buildAppBarActions(),
      ),
      body: Container(
        decoration: _shouldShowBackgroundImage
            ? const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/home_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              )
            : null,
        child: Container(
          decoration: _shouldShowBackgroundImage
              ? BoxDecoration(color: Colors.black.withOpacity(0.4))
              : null,
          child: _buildCurrentScreen(),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedFontSize: 10,
        unselectedFontSize: 10,
        backgroundColor: const Color(0xFF1E293B),
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        elevation: 8,
        onTap: (index) {
          // Prevent navigation to Guest List (0), Budget (1), and Vendors (3) if no wedding event
          if ((index == 0 || index == 1 || index == 3) &&
              _weddingEvent == null) {
            Fluttertoast.showToast(
              msg: "Create a wedding event first to access this feature",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: const Color(0xFF1E293B),
              textColor: const Color(0xFF94A3B8), // Light slate gray
              fontSize: 14.0,
            );
            return;
          }

          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.people,
              color: _weddingEvent == null
                  ? Colors.grey.withOpacity(0.5)
                  : null,
            ),
            label: 'Guest List',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.attach_money,
              color: _weddingEvent == null
                  ? Colors.grey.withOpacity(0.5)
                  : null,
            ),
            label: 'Budget',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.business,
              color: _weddingEvent == null
                  ? Colors.grey.withOpacity(0.5)
                  : null,
            ),
            label: 'Vendors',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class RSVPChartPainter extends CustomPainter {
  final Map<String, int> stats;
  final int total;

  RSVPChartPainter(this.stats, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius, bgPaint);

    // Draw segments
    double startAngle = -90 * (3.14159 / 180); // Start from top

    final attending = stats['Attending'] ?? 0;
    final pending = stats['Pending'] ?? 0;
    final notAttending = stats['Not Attending'] ?? 0;

    // Attending segment (green)
    if (attending > 0) {
      final sweepAngle = (attending / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Pending segment (orange)
    if (pending > 0) {
      final sweepAngle = (pending / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = Colors.orangeAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }

    // Not Attending segment (red)
    if (notAttending > 0) {
      final sweepAngle = (notAttending / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = Colors.redAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class BudgetChartPainter extends CustomPainter {
  final double spentAmount;
  final double totalAmount;

  BudgetChartPainter(this.spentAmount, this.totalAmount);

  @override
  void paint(Canvas canvas, Size size) {
    if (totalAmount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;

    canvas.drawCircle(center, radius, bgPaint);

    // Spent amount segment
    if (spentAmount > 0) {
      final sweepAngle = (spentAmount / totalAmount * 2 * 3.14159).clamp(
        0.0,
        2 * 3.14159,
      );
      final paint = Paint()
        ..color = spentAmount > totalAmount
            ? Colors.redAccent
            : Colors.orangeAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -90 * (3.14159 / 180), // Start from top
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/wedding_event.dart';
import '../models/vendor.dart';
import '../models/guest.dart';
import '../models/budget.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'everly.db');
    return await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE wedding_events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brideName TEXT NOT NULL,
        groomName TEXT NOT NULL,
        weddingDate TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        contact TEXT NOT NULL,
        category TEXT NOT NULL,
        notes TEXT NOT NULL,
        weddingEventId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE guests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        rsvpStatus TEXT NOT NULL,
        side TEXT NOT NULL,
        dietaryRestrictions TEXT NOT NULL,
        weddingEventId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        allocatedAmount REAL NOT NULL,
        spentAmount REAL NOT NULL,
        weddingEventId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add vendors table for version 2
      await db.execute('''
        CREATE TABLE vendors(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          contact TEXT NOT NULL,
          category TEXT NOT NULL,
          notes TEXT NOT NULL,
          weddingEventId INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add guests table for version 3
      await db.execute('''
        CREATE TABLE guests(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT NOT NULL,
          phone TEXT NOT NULL,
          rsvpStatus TEXT NOT NULL,
          dietaryRestrictions TEXT NOT NULL,
          weddingEventId INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 4) {
      // Add side column to guests table for version 4
      await db.execute('''
        ALTER TABLE guests ADD COLUMN side TEXT NOT NULL DEFAULT "Bride's Side"
      ''');
    }
    if (oldVersion < 5) {
      // Add budgets table for version 5
      await db.execute('''
        CREATE TABLE budgets(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          category TEXT NOT NULL,
          description TEXT NOT NULL,
          allocatedAmount REAL NOT NULL,
          spentAmount REAL NOT NULL,
          weddingEventId INTEGER NOT NULL,
          createdAt TEXT NOT NULL,
          FOREIGN KEY (weddingEventId) REFERENCES wedding_events (id) ON DELETE CASCADE
        )
      ''');
    }
  }

  Future<int> insertWeddingEvent(WeddingEvent event) async {
    final db = await database;
    
    // First, delete any existing wedding event (single event only)
    await db.delete('wedding_events');
    
    return await db.insert('wedding_events', event.toMap());
  }

  Future<WeddingEvent?> getWeddingEvent() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wedding_events',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return WeddingEvent.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WeddingEvent>> getAllWeddingEvents() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wedding_events',
      limit: 1,
    );

    return List.generate(maps.length, (i) {
      return WeddingEvent.fromMap(maps[i]);
    });
  }

  Future<bool> hasWeddingEvent() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'wedding_events',
      limit: 1,
    );
    return maps.isNotEmpty;
  }

  Future<int> updateWeddingEvent(WeddingEvent event) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('wedding_events', limit: 1);
    
    if (maps.isNotEmpty) {
      return await db.update(
        'wedding_events',
        event.toMap(),
        where: 'id = ?',
        whereArgs: [maps.first['id']],
      );
    }
    return 0;
  }

  Future<int> deleteWeddingEvent() async {
    final db = await database;
    return await db.delete('wedding_events');
  }

  // Vendor operations
  Future<int> insertVendor(Vendor vendor) async {
    final db = await database;
    return await db.insert('vendors', vendor.toMap());
  }

  Future<List<Vendor>> getVendorsByWeddingEvent(int weddingEventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vendors',
      where: 'weddingEventId = ?',
      whereArgs: [weddingEventId],
      orderBy: 'category ASC, name ASC',
    );

    return List.generate(maps.length, (i) {
      return Vendor.fromMap(maps[i]);
    });
  }

  Future<Vendor?> getVendor(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'vendors',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Vendor.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateVendor(Vendor vendor) async {
    final db = await database;
    return await db.update(
      'vendors',
      vendor.toMap(),
      where: 'id = ?',
      whereArgs: [vendor.id],
    );
  }

  Future<int> deleteVendor(int id) async {
    final db = await database;
    return await db.delete(
      'vendors',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Guest operations
  Future<int> insertGuest(Guest guest) async {
    final db = await database;
    return await db.insert('guests', guest.toMap());
  }

  Future<List<Guest>> getGuestsByWeddingEvent(int weddingEventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guests',
      where: 'weddingEventId = ?',
      whereArgs: [weddingEventId],
      orderBy: 'name ASC',
    );

    return List.generate(maps.length, (i) {
      return Guest.fromMap(maps[i]);
    });
  }

  Future<Guest?> getGuest(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'guests',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Guest.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateGuest(Guest guest) async {
    final db = await database;
    return await db.update(
      'guests',
      guest.toMap(),
      where: 'id = ?',
      whereArgs: [guest.id],
    );
  }

  Future<int> deleteGuest(int id) async {
    final db = await database;
    return await db.delete(
      'guests',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Budget operations
  Future<int> insertBudget(Budget budget) async {
    final db = await database;
    return await db.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getBudgetsByWeddingEvent(int weddingEventId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'weddingEventId = ?',
      whereArgs: [weddingEventId],
      orderBy: 'category ASC',
    );

    return List.generate(maps.length, (i) {
      return Budget.fromMap(maps[i]);
    });
  }

  Future<Budget?> getBudget(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Budget.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateBudget(Budget budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget.toMap(),
      where: 'id = ?',
      whereArgs: [budget.id],
    );
  }

  Future<int> deleteBudget(int id) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<double> getTotalAllocatedBudget(int weddingEventId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(allocatedAmount) as total FROM budgets WHERE weddingEventId = ?',
      [weddingEventId],
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<double> getTotalSpentBudget(int weddingEventId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(spentAmount) as total FROM budgets WHERE weddingEventId = ?',
      [weddingEventId],
    );
    final total = result.first['total'];
    return total != null ? (total as num).toDouble() : 0.0;
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
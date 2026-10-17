import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/employee.dart';
import '../models/activity_log.dart';

/// Enterprise SQLite Database Service for NEXUS People.
/// Handles cross-platform database initialization, migrations, and seed data.
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  static Database? _database;
  static const String _dbName = 'nexus_people_enterprise.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Enable FFI for desktop (Windows, Linux, macOS) and test runners
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    String path;
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      try {
        final docDir = await getApplicationDocumentsDirectory();
        path = p.join(docDir.path, 'NexusPeople', _dbName);
        final dir = Directory(p.dirname(path));
        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }
      } catch (_) {
        path = inMemoryDatabasePath;
      }
    } else {
      final dbPath = await getDatabasesPath();
      path = p.join(dbPath, _dbName);
    }

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onOpen: (db) async {
        // Enforce foreign key constraints
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Create employees table with unique constraints
    await db.execute('''
      CREATE TABLE employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_id TEXT UNIQUE NOT NULL,
        full_name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        phone TEXT NOT NULL,
        department TEXT NOT NULL,
        designation TEXT NOT NULL,
        joining_date TEXT NOT NULL,
        employment_type TEXT NOT NULL,
        employment_status TEXT NOT NULL,
        location TEXT NOT NULL,
        avatar_color INTEGER NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Create activity logs table
    await db.execute('''
      CREATE TABLE activity_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        action_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Initial seed of realistic corporate employees
    await _seedEmployees(db);
  }

  /// Populates 10 realistic corporate employees across multiple departments
  Future<void> _seedEmployees(DatabaseExecutor db) async {
    final now = DateTime.now();
    final sampleEmployees = [
      Employee(
        employeeId: 'NEX-1001',
        fullName: 'Sarah Jenkins',
        email: 'sarah.jenkins@nexuscorp.com',
        phone: '+1 (415) 890-2341',
        department: 'Engineering',
        designation: 'VP of Engineering',
        joiningDate: DateTime(2022, 3, 15),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'San Francisco, CA',
        avatarColor: 0xFF4F46E5,
        notes: 'Leads 45+ distributed engineers. Architect of NEXUS cloud infrastructure.',
        createdAt: now.subtract(const Duration(days: 900)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1002',
        fullName: 'Marcus Vance',
        email: 'marcus.vance@nexuscorp.com',
        phone: '+1 (212) 554-7890',
        department: 'Product',
        designation: 'Lead Product Designer',
        joiningDate: DateTime(2022, 8, 1),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'New York, NY',
        avatarColor: 0xFF0891B2,
        notes: 'Spearheads enterprise design systems and MD executive presentations.',
        createdAt: now.subtract(const Duration(days: 750)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1003',
        fullName: 'Priya Sharma',
        email: 'priya.sharma@nexuscorp.com',
        phone: '+44 20 7946 0912',
        department: 'Human Resources',
        designation: 'Director of Talent & Culture',
        joiningDate: DateTime(2021, 11, 10),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'London, UK',
        avatarColor: 0xFFDB2777,
        notes: 'Oversees EMEA & APAC recruitment, retention strategies, and compliance.',
        createdAt: now.subtract(const Duration(days: 1000)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1004',
        fullName: 'David Chen',
        email: 'david.chen@nexuscorp.com',
        phone: '+65 6789 1234',
        department: 'Finance',
        designation: 'Senior Financial Controller',
        joiningDate: DateTime(2023, 1, 20),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'Singapore',
        avatarColor: 0xFF059669,
        notes: 'Manages fiscal runway, global audit readiness, and board reporting.',
        createdAt: now.subtract(const Duration(days: 600)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1005',
        fullName: 'Elena Rostova',
        email: 'elena.rostova@nexuscorp.com',
        phone: '+1 (646) 332-9018',
        department: 'Sales',
        designation: 'VP of Global Enterprise Sales',
        joiningDate: DateTime(2022, 5, 18),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'New York, NY',
        avatarColor: 0xFF7C3AED,
        notes: 'Generated \$24M in Net New ARR across Fortune 500 accounts.',
        createdAt: now.subtract(const Duration(days: 820)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1006',
        fullName: 'Alex Thompson',
        email: 'alex.thompson@nexuscorp.com',
        phone: '+1 (512) 402-9981',
        department: 'Engineering',
        designation: 'Principal DevOps Architect',
        joiningDate: DateTime(2023, 4, 10),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'Remote',
        avatarColor: 0xFF2563EB,
        notes: 'Maintains 99.99% multi-region Kubernetes uptime and SOC2 compliance.',
        createdAt: now.subtract(const Duration(days: 520)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1007',
        fullName: 'Aisha Patel',
        email: 'aisha.patel@nexuscorp.com',
        phone: '+44 20 8123 4567',
        department: 'Marketing',
        designation: 'Head of Growth Marketing',
        joiningDate: DateTime(2023, 9, 1),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'London, UK',
        avatarColor: 0xFFD97706,
        notes: 'Scaled inbound organic pipeline by 140% over the last 3 quarters.',
        createdAt: now.subtract(const Duration(days: 380)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1008',
        fullName: 'Carlos Gomez',
        email: 'carlos.gomez@nexuscorp.com',
        phone: '+1 (415) 762-1100',
        department: 'Operations',
        designation: 'Director of Business Operations',
        joiningDate: DateTime(2021, 6, 15),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'San Francisco, CA',
        avatarColor: 0xFF0891B2,
        notes: 'Streamlines vendor procurement, IT infrastructure, and facilities.',
        createdAt: now.subtract(const Duration(days: 1100)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1009',
        fullName: 'Zoe Martin',
        email: 'zoe.martin@nexuscorp.com',
        phone: '+1 (206) 912-8834',
        department: 'Engineering',
        designation: 'Staff Mobile Engineer',
        joiningDate: DateTime(2026, 8, 15),
        employmentType: 'Full-time',
        employmentStatus: 'Probation',
        location: 'Remote',
        avatarColor: 0xFF4F46E5,
        notes: 'Leading Flutter client application modernization for enterprise release.',
        createdAt: now.subtract(const Duration(days: 60)),
        updatedAt: now,
      ),
      Employee(
        employeeId: 'NEX-1010',
        fullName: 'Jonathan Reed',
        email: 'jonathan.reed@nexuscorp.com',
        phone: '+1 (212) 890-4411',
        department: 'Legal',
        designation: 'Senior Corporate Counsel',
        joiningDate: DateTime(2022, 10, 1),
        employmentType: 'Part-time',
        employmentStatus: 'On Leave',
        location: 'New York, NY',
        avatarColor: 0xFF64748B,
        notes: 'Sabbatical through Q4. IP, patent defense, and enterprise privacy lead.',
        createdAt: now.subtract(const Duration(days: 700)),
        updatedAt: now,
      ),
    ];

    final batch = db.batch();
    for (final emp in sampleEmployees) {
      batch.insert('employees', emp.toMap());
    }

    // Add initial activity logs
    final initialLogs = [
      ActivityLog(
        actionType: 'SYSTEM',
        title: 'NEXUS Database Seeded',
        description: 'Initialized 10 enterprise employee records across 8 departments.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ActivityLog(
        actionType: 'CREATE',
        title: 'New Hire Onboarded',
        description: 'Zoe Martin joined Engineering as Staff Mobile Engineer.',
        timestamp: now.subtract(const Duration(days: 2)),
      ),
      ActivityLog(
        actionType: 'UPDATE',
        title: 'Status Updated',
        description: 'Jonathan Reed (Legal) status marked as On Leave.',
        timestamp: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (final log in initialLogs) {
      batch.insert('activity_logs', log.toMap());
    }

    await batch.commit(noResult: true);
  }

  /// Resets database and re-seeds original corporate demo dataset
  Future<void> resetToSampleData() async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('employees');
      await txn.delete('activity_logs');
      await _seedEmployees(txn);
    });
  }

  /// Closes database connection safely
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}

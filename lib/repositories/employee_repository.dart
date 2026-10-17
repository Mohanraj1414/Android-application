import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/employee.dart';
import '../models/activity_log.dart';
import '../models/department.dart';
import '../models/dashboard_stats.dart';
import '../services/database_service.dart';

/// Clean repository pattern separating business logic from raw SQLite queries.
class EmployeeRepository {
  final DatabaseService _dbService;

  EmployeeRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db => _dbService.database;

  /// Fetches all employee records ordered by created_at descending
  Future<List<Employee>> getAllEmployees() async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      orderBy: 'id DESC',
    );
    return maps.map((map) => Employee.fromMap(map)).toList();
  }

  /// Fetches an employee by primary key id
  Future<Employee?> getEmployeeById(int id) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return Employee.fromMap(maps.first);
    }
    return null;
  }

  /// Checks if employeeId is already in use by another record
  Future<bool> isEmployeeIdTaken(String employeeId, {int? excludeId}) async {
    final db = await _db;
    String query = 'SELECT COUNT(*) as count FROM employees WHERE LOWER(employee_id) = ?';
    List<dynamic> args = [employeeId.trim().toLowerCase()];
    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Checks if email is already in use by another record
  Future<bool> isEmailTaken(String email, {int? excludeId}) async {
    final db = await _db;
    String query = 'SELECT COUNT(*) as count FROM employees WHERE LOWER(email) = ?';
    List<dynamic> args = [email.trim().toLowerCase()];
    if (excludeId != null) {
      query += ' AND id != ?';
      args.add(excludeId);
    }
    final result = await db.rawQuery(query, args);
    final count = Sqflite.firstIntValue(result) ?? 0;
    return count > 0;
  }

  /// Auto-generates the next sequential Employee ID, e.g. "NEX-1011"
  Future<String> generateNextEmployeeId() async {
    final db = await _db;
    final result = await db.rawQuery(
      'SELECT employee_id FROM employees ORDER BY id DESC LIMIT 20',
    );
    int highestNum = 1000;
    for (final row in result) {
      final empId = row['employee_id'] as String?;
      if (empId != null && empId.toUpperCase().startsWith('NEX-')) {
        final numPart = empId.substring(4);
        final parsed = int.tryParse(numPart);
        if (parsed != null && parsed > highestNum) {
          highestNum = parsed;
        }
      }
    }
    return 'NEX-${highestNum + 1}';
  }

  /// Inserts a new employee and logs the activity
  Future<int> insertEmployee(Employee employee) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final id = await txn.insert('employees', employee.toMap());
      await txn.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'CREATE',
          title: 'Employee Hired',
          description: '${employee.fullName} (${employee.employeeId}) onboarded to ${employee.department}.',
          timestamp: DateTime.now(),
        ).toMap(),
      );
      return id;
    });
  }

  /// Updates an existing employee and logs the activity
  Future<int> updateEmployee(Employee employee) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final count = await txn.update(
        'employees',
        employee.toMap(),
        where: 'id = ?',
        whereArgs: [employee.id],
      );
      await txn.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'UPDATE',
          title: 'Profile Updated',
          description: 'Updated record for ${employee.fullName} (${employee.employeeId}).',
          timestamp: DateTime.now(),
        ).toMap(),
      );
      return count;
    });
  }

  /// Deletes an employee and logs the activity
  Future<int> deleteEmployee(Employee employee) async {
    final db = await _db;
    return await db.transaction((txn) async {
      final count = await txn.delete(
        'employees',
        where: 'id = ?',
        whereArgs: [employee.id],
      );
      await txn.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'DELETE',
          title: 'Employee Offboarded',
          description: 'Removed ${employee.fullName} (${employee.employeeId}) from ${employee.department}.',
          timestamp: DateTime.now(),
        ).toMap(),
      );
      return count;
    });
  }

  /// Retrieves recent activity logs
  Future<List<ActivityLog>> getActivityLogs({int limit = 8}) async {
    final db = await _db;
    final List<Map<String, dynamic>> maps = await db.query(
      'activity_logs',
      orderBy: 'id DESC',
      limit: limit,
    );
    return maps.map((m) => ActivityLog.fromMap(m)).toList();
  }

  /// Resets database back to default demonstration records
  Future<void> resetToSampleData() async {
    await _dbService.resetToSampleData();
  }

  /// Computes real-time executive dashboard statistics from actual SQLite records
  Future<DashboardStats> getDashboardStats() async {
    final employees = await getAllEmployees();
    if (employees.isEmpty) {
      return DashboardStats.empty();
    }

    int activeCount = 0;
    int onLeaveCount = 0;
    int probationCount = 0;
    int terminatedCount = 0;
    int recentCount = 0;
    final now = DateTime.now();
    final ninetyDaysAgo = now.subtract(const Duration(days: 90));

    final Map<String, int> deptCounts = {};

    for (final emp in employees) {
      // Status counting
      switch (emp.employmentStatus.toLowerCase()) {
        case 'active':
          activeCount++;
          break;
        case 'on leave':
          onLeaveCount++;
          break;
        case 'probation':
          probationCount++;
          break;
        case 'terminated':
          terminatedCount++;
          break;
      }

      // Recently joined check (within last 90 days)
      if (emp.joiningDate.isAfter(ninetyDaysAgo)) {
        recentCount++;
      }

      // Department distribution
      deptCounts[emp.department] = (deptCounts[emp.department] ?? 0) + 1;
    }

    final double activeRatio =
        employees.isNotEmpty ? (activeCount / employees.length) * 100 : 0.0;

    // Build Monthly Workforce Growth trend based on actual joining dates
    // Generate data points for the past 6-8 months
    final List<MonthlyGrowthData> trend = [];
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    for (int i = 6; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

      // Cumulative employees who joined on or before target month end
      final cumulativeCount = employees
          .where((e) =>
              e.joiningDate.isBefore(nextMonth) &&
              e.employmentStatus.toLowerCase() != 'terminated')
          .length;

      trend.add(MonthlyGrowthData(
        label: monthNames[targetDate.month],
        year: targetDate.year,
        month: targetDate.month,
        count: cumulativeCount,
      ));
    }

    return DashboardStats(
      totalEmployees: employees.length,
      activeEmployees: activeCount,
      onLeaveEmployees: onLeaveCount,
      probationEmployees: probationCount,
      terminatedEmployees: terminatedCount,
      departmentCount: deptCounts.keys.length,
      recentlyJoinedCount: recentCount,
      activePercentage: activeRatio,
      departmentCounts: deptCounts,
      growthTrend: trend,
    );
  }

  /// Calculates departments with dynamic headcount and active status
  Future<List<Department>> getDepartments() async {
    final employees = await getAllEmployees();

    final deptMeta = {
      'Engineering': {
        'lead': 'Sarah Jenkins',
        'designation': 'VP of Engineering',
        'budget': '\$3.4M',
        'icon': Icons.code_rounded,
        'color': const Color(0xFF4F46E5),
      },
      'Product': {
        'lead': 'Marcus Vance',
        'designation': 'Lead Product Designer',
        'budget': '\$1.2M',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFF0891B2),
      },
      'Human Resources': {
        'lead': 'Priya Sharma',
        'designation': 'Director of Talent & Culture',
        'budget': '\$950K',
        'icon': Icons.people_outline_rounded,
        'color': const Color(0xFFDB2777),
      },
      'Finance': {
        'lead': 'David Chen',
        'designation': 'Senior Financial Controller',
        'budget': '\$1.1M',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF059669),
      },
      'Marketing': {
        'lead': 'Aisha Patel',
        'designation': 'Head of Growth Marketing',
        'budget': '\$1.8M',
        'icon': Icons.campaign_outlined,
        'color': const Color(0xFFD97706),
      },
      'Sales': {
        'lead': 'Elena Rostova',
        'designation': 'VP of Global Enterprise Sales',
        'budget': '\$2.6M',
        'icon': Icons.trending_up_rounded,
        'color': const Color(0xFF7C3AED),
      },
      'Operations': {
        'lead': 'Carlos Gomez',
        'designation': 'Director of Business Operations',
        'budget': '\$1.5M',
        'icon': Icons.domain_rounded,
        'color': const Color(0xFF0284C7),
      },
      'Legal': {
        'lead': 'Jonathan Reed',
        'designation': 'Senior Corporate Counsel',
        'budget': '\$800K',
        'icon': Icons.gavel_rounded,
        'color': const Color(0xFF64748B),
      },
    };

    final List<Department> list = [];
    deptMeta.forEach((name, meta) {
      final deptEmployees = employees.where((e) => e.department == name).toList();
      final activeEmployees =
          deptEmployees.where((e) => e.employmentStatus.toLowerCase() == 'active').length;

      list.add(Department(
        name: name,
        totalEmployees: deptEmployees.length,
        activeEmployees: activeEmployees,
        leadName: meta['lead'] as String,
        leadDesignation: meta['designation'] as String,
        budget: meta['budget'] as String,
        icon: meta['icon'] as IconData,
        color: meta['color'] as Color,
      ));
    });

    return list;
  }
}

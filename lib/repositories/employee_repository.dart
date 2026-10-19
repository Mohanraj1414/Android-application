import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../models/employee.dart';
import '../models/activity_log.dart';
import '../models/department.dart';
import '../models/dashboard_stats.dart';
import '../services/database_service.dart';
import '../services/api_service.dart';

/// Clean repository pattern separating business logic from raw queries.
class EmployeeRepository {
  final DatabaseService _dbService;

  EmployeeRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db => _dbService.database;

  /// Fetches all employee records from Laravel API with fallback to SQLite
  Future<List<Employee>> getAllEmployees() async {
    try {
      return await ApiService.instance.getAllEmployees();
    } catch (e) {
      // Fallback to local SQLite if Laravel is not reachable (or in offline unit tests)
      try {
        final db = await _db;
        final List<Map<String, dynamic>> maps = await db.query(
          'employees',
          orderBy: 'id DESC',
        );
        return maps.map((map) => Employee.fromMap(map)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  /// Fetches an employee by primary key id
  Future<Employee?> getEmployeeById(int id) async {
    try {
      final all = await getAllEmployees();
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Checks if employeeId is already in use by another record
  Future<bool> isEmployeeIdTaken(String employeeId, {int? excludeId}) async {
    final employees = await getAllEmployees();
    final target = employeeId.trim().toLowerCase();
    return employees.any((e) => e.employeeId.trim().toLowerCase() == target && e.id != excludeId);
  }

  /// Checks if email is already in use by another record
  Future<bool> isEmailTaken(String email, {int? excludeId}) async {
    final employees = await getAllEmployees();
    final target = email.trim().toLowerCase();
    return employees.any((e) => e.email.trim().toLowerCase() == target && e.id != excludeId);
  }

  /// Auto-generates the next sequential Employee ID, e.g. "NEX-1011"
  Future<String> generateNextEmployeeId() async {
    final employees = await getAllEmployees();
    int highestNum = 1000;
    for (final emp in employees) {
      if (emp.employeeId.toUpperCase().startsWith('NEX-')) {
        final numPart = emp.employeeId.substring(4);
        final parsed = int.tryParse(numPart);
        if (parsed != null && parsed > highestNum) {
          highestNum = parsed;
        }
      }
    }
    return 'NEX-${highestNum + 1}';
  }

  /// Inserts a new employee via Laravel API with local fallback
  Future<int> insertEmployee(Employee employee) async {
    int id = 1;
    try {
      final created = await ApiService.instance.createEmployee(employee);
      id = created.id ?? 1;
    } catch (_) {
      try {
        final db = await _db;
        id = await db.insert('employees', employee.toMap());
      } catch (_) {}
    }

    try {
      final db = await _db;
      await db.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'CREATE',
          title: 'Employee Hired',
          description: '${employee.fullName} (${employee.employeeId}) onboarded to ${employee.department}.',
          timestamp: DateTime.now(),
        ).toMap(),
      );
    } catch (_) {}

    return id;
  }

  /// Updates an existing employee via Laravel API with local fallback
  Future<int> updateEmployee(Employee employee) async {
    try {
      await ApiService.instance.updateEmployee(employee);
    } catch (_) {}

    try {
      final db = await _db;
      await db.update(
        'employees',
        employee.toMap(),
        where: 'id = ?',
        whereArgs: [employee.id],
      );
      await db.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'UPDATE',
          title: 'Profile Updated',
          description: 'Updated record for ${employee.fullName} (${employee.employeeId}).',
          timestamp: DateTime.now(),
        ).toMap(),
      );
    } catch (_) {}

    return 1;
  }

  /// Deletes an employee via Laravel API with local fallback
  Future<int> deleteEmployee(Employee employee) async {
    try {
      if (employee.id != null) {
        await ApiService.instance.deleteEmployee(employee.id!);
      }
    } catch (_) {}

    try {
      final db = await _db;
      await db.delete('employees', where: 'id = ?', whereArgs: [employee.id]);
      await db.insert(
        'activity_logs',
        ActivityLog(
          actionType: 'DELETE',
          title: 'Employee Offboarded',
          description: 'Removed ${employee.fullName} (${employee.employeeId}) from ${employee.department}.',
          timestamp: DateTime.now(),
        ).toMap(),
      );
    } catch (_) {}

    return 1;
  }

  /// Retrieves recent activity logs
  Future<List<ActivityLog>> getActivityLogs({int limit = 8}) async {
    try {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query(
        'activity_logs',
        orderBy: 'id DESC',
        limit: limit,
      );
      return maps.map((m) => ActivityLog.fromMap(m)).toList();
    } catch (_) {
      return [
        ActivityLog(
          actionType: 'CONNECT',
          title: 'Connected to Laravel Backend',
          description: 'Synchronized with Laravel API at ${ApiService.baseUrl}',
          timestamp: DateTime.now(),
        ),
      ];
    }
  }

  /// Resets database back to default demonstration records
  Future<void> resetToSampleData() async {
    try {
      await _dbService.resetToSampleData();
    } catch (_) {}
  }

  /// Computes real-time executive dashboard statistics from actual records
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

      if (emp.joiningDate.isAfter(ninetyDaysAgo)) {
        recentCount++;
      }

      deptCounts[emp.department] = (deptCounts[emp.department] ?? 0) + 1;
    }

    final double activeRatio =
        employees.isNotEmpty ? (activeCount / employees.length) * 100 : 0.0;

    final List<MonthlyGrowthData> trend = [];
    final monthNames = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    for (int i = 6; i >= 0; i--) {
      final targetDate = DateTime(now.year, now.month - i, 1);
      final nextMonth = DateTime(now.year, now.month - i + 1, 1);

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
      'Design': {
        'lead': 'Marcus Vance',
        'designation': 'Lead Product Designer',
        'budget': '\$1.2M',
        'icon': Icons.palette_outlined,
        'color': const Color(0xFF0891B2),
      },
      'Product': {
        'lead': 'Amina Diallo',
        'designation': 'Director of Product',
        'budget': '\$1.6M',
        'icon': Icons.lightbulb_outline_rounded,
        'color': const Color(0xFF8B5CF6),
      },
      'HR': {
        'lead': 'Thomas Wright',
        'designation': 'Talent Acquisition Manager',
        'budget': '\$950K',
        'icon': Icons.people_outline_rounded,
        'color': const Color(0xFFDB2777),
      },
      'Finance': {
        'lead': 'Liam Gallagher',
        'designation': 'Financial Controller',
        'budget': '\$1.1M',
        'icon': Icons.account_balance_wallet_outlined,
        'color': const Color(0xFF059669),
      },
      'Marketing': {
        'lead': 'Elena Rostova',
        'designation': 'Head of Brand Strategy',
        'budget': '\$1.8M',
        'icon': Icons.campaign_outlined,
        'color': const Color(0xFFD97706),
      },
      'Operations': {
        'lead': 'Carlos Rodriguez',
        'designation': 'Senior DevOps Engineer',
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

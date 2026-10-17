import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:flutter_application_1/models/employee.dart';
import 'package:flutter_application_1/repositories/employee_repository.dart';
import 'package:flutter_application_1/providers/employee_provider.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Employee Repository & Provider Integration Tests', () {
    late EmployeeRepository repository;
    late EmployeeProvider provider;

    setUp(() async {
      repository = EmployeeRepository();
      provider = EmployeeProvider(repository: repository);
      // Reset to clean seeded state
      await repository.resetToSampleData();
      await provider.loadData();
    });

    test('Initial database seeding has 10 sample employees', () async {
      expect(provider.allEmployees.length, 10);
      expect(provider.dashboardStats.totalEmployees, 10);
      expect(provider.dashboardStats.activeEmployees, 8);
      expect(provider.departments.length, 8);
    });

    test('CREATE: Adds new employee and updates all dashboard metrics', () async {
      final now = DateTime.now();
      final newEmp = Employee(
        employeeId: 'NEX-9999',
        fullName: 'Alexander Wright',
        email: 'alex.wright@nexuscorp.com',
        phone: '+1 (555) 019-9999',
        department: 'Engineering',
        designation: 'Senior Infrastructure Engineer',
        joiningDate: now,
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'San Francisco, CA',
        avatarColor: 0xFF4F46E5,
        notes: 'Test hire for executive demo',
        createdAt: now,
        updatedAt: now,
      );

      final success = await provider.addEmployee(newEmp);
      expect(success, true);
      expect(provider.allEmployees.length, 11);
      expect(provider.dashboardStats.totalEmployees, 11);

      // Verify activity log recorded the hire
      final latestLog = provider.activityLogs.first;
      expect(latestLog.actionType, 'CREATE');
      expect(latestLog.description.contains('Alexander Wright'), true);
    });

    test('CREATE Validation: Duplicate employeeId is rejected', () async {
      final now = DateTime.now();
      final duplicateEmp = Employee(
        employeeId: 'NEX-1001', // Already belongs to Sarah Jenkins
        fullName: 'Imposter Person',
        email: 'imposter@nexuscorp.com',
        phone: '+1 (555) 019-0000',
        department: 'Engineering',
        designation: 'Hacker',
        joiningDate: now,
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'Remote',
        avatarColor: 0xFF4F46E5,
        notes: '',
        createdAt: now,
        updatedAt: now,
      );

      final success = await provider.addEmployee(duplicateEmp);
      expect(success, false);
      expect(provider.errorMessage?.contains('already assigned'), true);
      expect(provider.allEmployees.length, 10);
    });

    test('CREATE Validation: Duplicate email is rejected', () async {
      final now = DateTime.now();
      final duplicateEmailEmp = Employee(
        employeeId: 'NEX-8888',
        fullName: 'Duplicate Email Person',
        email: 'sarah.jenkins@nexuscorp.com', // Belongs to NEX-1001
        phone: '+1 (555) 019-1111',
        department: 'Product',
        designation: 'Designer',
        joiningDate: now,
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'New York, NY',
        avatarColor: 0xFF0891B2,
        notes: '',
        createdAt: now,
        updatedAt: now,
      );

      final success = await provider.addEmployee(duplicateEmailEmp);
      expect(success, false);
      expect(provider.errorMessage?.contains('already registered'), true);
    });

    test('UPDATE: Modifies existing employee record in SQLite', () async {
      final sarah = provider.allEmployees.firstWhere((e) => e.employeeId == 'NEX-1001');
      final updatedSarah = sarah.copyWith(
        designation: 'Chief Technology Officer (CTO)',
        employmentStatus: 'Active',
      );

      final success = await provider.updateEmployee(updatedSarah);
      expect(success, true);

      final retrieved = provider.allEmployees.firstWhere((e) => e.employeeId == 'NEX-1001');
      expect(retrieved.designation, 'Chief Technology Officer (CTO)');

      final latestLog = provider.activityLogs.first;
      expect(latestLog.actionType, 'UPDATE');
    });

    test('DELETE: Removes employee and updates stats and logs', () async {
      final initialCount = provider.allEmployees.length;
      final target = provider.allEmployees.firstWhere((e) => e.employeeId == 'NEX-1010');

      final success = await provider.deleteEmployee(target);
      expect(success, true);
      expect(provider.allEmployees.length, initialCount - 1);

      final latestLog = provider.activityLogs.first;
      expect(latestLog.actionType, 'DELETE');
      expect(latestLog.description.contains('Jonathan Reed'), true);
    });

    test('FILTER & SEARCH: Performs accurate multi-factor filtering', () {
      // Search by name
      provider.setSearchQuery('Vance');
      expect(provider.filteredEmployees.length, 1);
      expect(provider.filteredEmployees.first.fullName, 'Marcus Vance');

      // Clear search
      provider.setSearchQuery('');
      expect(provider.filteredEmployees.length, 10);

      // Department filter
      provider.setDepartmentFilter('Engineering');
      expect(provider.filteredEmployees.every((e) => e.department == 'Engineering'), true);

      // Status filter
      provider.setStatusFilter('Probation');
      expect(provider.filteredEmployees.length, 1);
      expect(provider.filteredEmployees.first.fullName, 'Zoe Martin');

      // Clear filters
      provider.clearFilters();
      expect(provider.filteredEmployees.length, 10);
    });
  });
}

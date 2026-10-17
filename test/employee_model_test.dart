import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/employee.dart';
import 'package:flutter_application_1/core/utils/date_formatter.dart';
import 'package:flutter_application_1/core/utils/validators.dart';

void main() {
  group('Employee Model & Utilities', () {
    test('derive initials correctly', () {
      final emp1 = Employee(
        id: 1,
        employeeId: 'NEX-1001',
        fullName: 'Sarah Jenkins',
        email: 'sarah.jenkins@nexuscorp.com',
        phone: '+1 555-0192',
        department: 'Engineering',
        designation: 'VP of Engineering',
        joiningDate: DateTime(2022, 3, 15),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'San Francisco, CA',
        avatarColor: 0xFF4F46E5,
        notes: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(emp1.avatarInitials, 'SJ');

      final empSingle = emp1.copyWith(fullName: 'Marcus');
      expect(empSingle.avatarInitials, 'MA');

      final empThree = emp1.copyWith(fullName: 'Marcus Alexander Vance');
      expect(empThree.avatarInitials, 'MV');
    });

    test('serialization to and from SQLite map', () {
      final now = DateTime.now();
      final original = Employee(
        id: 42,
        employeeId: 'NEX-1042',
        fullName: 'Elena Rostova',
        email: 'elena.rostova@nexuscorp.com',
        phone: '+1 555-9018',
        department: 'Sales',
        designation: 'VP of Sales',
        joiningDate: DateTime(2022, 5, 18),
        employmentType: 'Full-time',
        employmentStatus: 'Active',
        location: 'New York, NY',
        avatarColor: 0xFF7C3AED,
        notes: 'Enterprise account lead.',
        createdAt: now,
        updatedAt: now,
      );

      final map = original.toMap();
      final fromMap = Employee.fromMap(map);

      expect(fromMap.id, 42);
      expect(fromMap.employeeId, 'NEX-1042');
      expect(fromMap.fullName, 'Elena Rostova');
      expect(fromMap.department, 'Sales');
      expect(fromMap.notes, 'Enterprise account lead.');
      expect(fromMap.isActive, true);
    });

    test('validators correctly check email, phone, and name', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name('A'), isNotNull);
      expect(Validators.name('Sarah Jenkins'), isNull);

      expect(Validators.email('invalid-email'), isNotNull);
      expect(Validators.email('sarah@nexuscorp.com'), isNull);

      expect(Validators.phone('123'), isNotNull);
      expect(Validators.phone('+1 (555) 019-2834'), isNull);
    });

    test('DateFormatter tenure calculation', () {
      final now = DateTime.now();
      final threeYearsAgo = DateTime(now.year - 3, now.month, now.day);
      expect(DateFormatter.calculateTenure(threeYearsAgo).contains('3'), true);
    });
  });
}

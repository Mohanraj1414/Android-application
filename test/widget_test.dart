import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/core/theme/app_colors.dart';
import 'package:flutter_application_1/models/employee.dart';
import 'package:flutter_application_1/widgets/avatar_widget.dart';
import 'package:flutter_application_1/widgets/confirmation_dialog.dart';
import 'package:flutter_application_1/widgets/stat_card.dart';
import 'package:flutter_application_1/widgets/status_badge.dart';

void main() {
  group('NEXUS People Enterprise Widgets', () {
    testWidgets('StatCard renders title, value, and trend', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatCard(
              title: 'Total Workforce',
              value: '48',
              subtitle: 'Active headcount',
              icon: Icons.groups_rounded,
              iconColor: AppColors.primary,
              iconBgColor: AppColors.primaryLight,
              trendText: '+15% YoY',
            ),
          ),
        ),
      );

      expect(find.text('Total Workforce'), findsOneWidget);
      expect(find.text('48'), findsOneWidget);
      expect(find.text('+15% YoY'), findsOneWidget);
    });

    testWidgets('StatusBadge displays correct text and colors', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge(status: 'Active'),
                StatusBadge(status: 'On Leave'),
                StatusBadge(status: 'Probation'),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Active'), findsOneWidget);
      expect(find.text('On Leave'), findsOneWidget);
      expect(find.text('Probation'), findsOneWidget);
    });

    testWidgets('AvatarWidget shows initials and status dot', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AvatarWidget(
              initials: 'SJ',
              backgroundColor: AppColors.primary,
              size: 48,
              status: 'Active',
              showStatus: true,
            ),
          ),
        ),
      );

      expect(find.text('SJ'), findsOneWidget);
    });

    testWidgets('ConfirmationDialog shows employee name and delete action', (tester) async {
      final sampleEmployee = Employee(
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

      bool confirmed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConfirmationDialog(
              employee: sampleEmployee,
              onConfirm: () => confirmed = true,
            ),
          ),
        ),
      );

      expect(find.text('Delete Employee Record'), findsOneWidget);
      expect(find.text('Sarah Jenkins'), findsOneWidget);
      expect(find.text('NEX-1001'), findsOneWidget);
      expect(find.text('Delete Employee'), findsOneWidget);

      await tester.tap(find.text('Delete Employee'));
      expect(confirmed, true);
    });
  });
}

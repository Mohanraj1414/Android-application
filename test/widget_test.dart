// Widget tests for the CRUD To-Do list app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Create: add a task', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('No tasks yet. Add one above!'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Buy groceries');
    await tester.tap(find.text('Add'));
    await tester.pump();

    expect(find.text('Buy groceries'), findsOneWidget);
  });

  testWidgets('Update: toggle a task done', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Read a book');
    await tester.tap(find.text('Add'));
    await tester.pump();

    // Find the Checkbox and toggle it
    final checkboxFinder = find.byType(Checkbox);
    expect(checkboxFinder, findsOneWidget);
    await tester.tap(checkboxFinder);
    await tester.pump();

    // The text should now have lineThrough decoration (done)
    final textWidget = tester.widget<Text>(find.text('Read a book'));
    expect(textWidget.style?.decoration, TextDecoration.lineThrough);
  });

  testWidgets('Update: edit a task title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Old title');
    await tester.tap(find.text('Add'));
    await tester.pump();

    // Tap edit icon
    await tester.tap(find.byIcon(Icons.edit_outlined));
    await tester.pumpAndSettle();

    // Dialog should be open
    expect(find.text('Edit Task'), findsOneWidget);

    // Clear and type new title in the dialog's TextField
    await tester.enterText(find.byType(TextField).last, 'New title');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('New title'), findsOneWidget);
    expect(find.text('Old title'), findsNothing);
  });

  testWidgets('Delete: remove a task', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.enterText(find.byType(TextField), 'Task to delete');
    await tester.tap(find.text('Add'));
    await tester.pump();

    // Delete
    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pump();

    // Task should be gone
    expect(find.text('Task to delete'), findsNothing);

    // SnackBar should show the deleted message
    expect(find.textContaining('Deleted'), findsOneWidget);
  });
}

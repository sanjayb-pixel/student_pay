// Smoke test for the StudentPay app.
//
// Verifies that the app boots and the main dashboard renders correctly
// (header, scanner button, table headers, empty state).
//
// It does NOT test the camera / QR scanner, because that requires a real
// device with camera hardware.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_pay/main.dart';

void main() {
  group('StudentPay app', () {
    testWidgets('boots and shows the header + scanner button',
        (WidgetTester tester) async {
      // Build the app and trigger a frame.
      await tester.pumpWidget(const StudentPayApp());

      // Let the first frame settle.
      await tester.pumpAndSettle();

      // Header branding.
      expect(find.text('StudentPay'), findsOneWidget);
      expect(find.text('QR Payment & Redemption'), findsOneWidget);

      // Primary action button.
      expect(find.text('Start Scanner'), findsOneWidget);

      // Table headers (Roll Number | Amount).
      expect(find.text('ROLL NUMBER'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);

      // Empty state before any scan.
      expect(find.text('No students scanned yet'), findsOneWidget);
    });

    testWidgets('shows the "Clear" button and empty-state hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(const StudentPayApp());
      await tester.pumpAndSettle();

      // Clear button exists.
      expect(find.text('Clear'), findsOneWidget);

      // Helper text in empty state mentions "Start Scanner".
      expect(
        find.textContaining('Start Scanner'),
        findsWidgets,
      );
    });

    testWidgets('tapping Clear on an empty list does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(const StudentPayApp());
      await tester.pumpAndSettle();

      // Tap Clear — should be a no-op on empty state.
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Still shows the empty state.
      expect(find.text('No students scanned yet'), findsOneWidget);
    });
  });
}
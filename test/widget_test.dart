// Smoke test for the StudentPay app.
//
// Verifies that:
//   1. The app boots to the Role Selection screen (Admin / Vendor / Employee).
//   2. Navigating Employee → Login → HomeScreen renders the existing
//      StudentPay dashboard correctly (header, scanner button, table
//      headers, empty state, Clear button).
//
// It does NOT test the camera / QR scanner, because that requires a real
// device with camera hardware.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:student_pay/main.dart';
import 'package:student_pay/services/auth_service.dart';

void main() {
  group('StudentPay app — Role Selection', () {
    testWidgets('boots and shows all three role options',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // App title.
      expect(find.text('Management System'), findsOneWidget);
      expect(find.text('Select your role to continue'), findsOneWidget);

      // The three role cards.
      expect(find.text('Admin'), findsOneWidget);
      expect(find.text('Vendor'), findsOneWidget);
      expect(find.text('Employee'), findsOneWidget);

      // Each card has a Continue affordance.
      expect(find.text('Continue'), findsNWidgets(3));
    });
  });

  group('StudentPay app — Employee flow', () {
    setUp(() {
      // Seed an employee so login succeeds during the test.
      // Skip if already added (defensive against test re-runs).
      if (!AuthService.instance.employeeUsernameExists(
        'V1',
        'testemployee',
      )) {
        // Make sure vendor V1 exists first (addEmployee only stores vendorId).
        if (AuthService.instance.findVendorById('V1') == null) {
          AuthService.instance
              .addVendor(username: 'testvendor', password: 'testvendor');
        }
        AuthService.instance.addEmployee(
          vendorId: 'V1',
          username: 'testemployee',
          password: 'testpass',
        );
      }
    });

    testWidgets(
        'Employee login navigates to HomeScreen and shows header + scanner button',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Tap Employee role.
      await tester.tap(find.text('Employee'));
      await tester.pumpAndSettle();

      // Fill login form.
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Employee Username'),
        'testemployee',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'testpass',
      );

      // Tap Login.
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // ---- Your existing HomeScreen assertions ----
      // Header branding.
      expect(find.text('StudentPay'), findsOneWidget);
      expect(find.text('QR Payment & Redemption'), findsOneWidget);

      // Primary action button.
      expect(find.text('Start Scanner'), findsOneWidget);

      // Table headers.
      expect(find.text('ROLL NUMBER'), findsOneWidget);
      expect(find.text('AMOUNT'), findsOneWidget);

      // Empty state before any scan.
      expect(find.text('No students scanned yet'), findsOneWidget);
    });

    testWidgets('HomeScreen shows Clear button and empty-state hint',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Employee'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Employee Username'),
        'testemployee',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'testpass',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Clear button exists.
      expect(find.text('Clear'), findsOneWidget);

      // Empty-state hint mentions "Start Scanner".
      expect(
        find.textContaining('Start Scanner'),
        findsWidgets,
      );
    });

    testWidgets('tapping Clear on an empty list does not crash',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Employee'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Employee Username'),
        'testemployee',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'testpass',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap Clear — no-op on empty list.
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Still shows the empty state.
      expect(find.text('No students scanned yet'), findsOneWidget);
    });
  });
}
import 'package:flutter/material.dart';
import 'role_selection_screen.dart';
import 'services/auth_service.dart';

void main() {
  // ---------------------------------------------------------------
  // PRE-SEED DEFAULT ACCOUNTS
  // Runs once at app startup. Creates a default vendor + employee
  // so you can log in immediately without using the Admin flow.
  //
  // Default credentials after seeding:
  //   Admin    →  admin    / admin123
  //   Vendor   →  vendor1  / vendor1
  //   Employee →  emp1     / emp1
  //
  // NOTE: AuthService is in-memory only. Accounts disappear on
  // every hot restart / app relaunch. That is why we seed here.
  // ---------------------------------------------------------------

  final auth = AuthService.instance;

  if (!auth.vendorUsernameExists('vendor1')) {
    final vendor = auth.addVendor(
      username: 'vendor1',
      password: 'vendor1',
    );

    auth.addEmployee(
      vendorId: vendor.id,
      username: 'emp1',
      password: 'emp1',
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Vendor Employee System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      home: const RoleSelectionScreen(),
    );
  }
}
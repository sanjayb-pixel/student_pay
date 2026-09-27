import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
void main() {
  runApp(const StudentPayApp());
}

class StudentPayApp extends StatelessWidget {
  const StudentPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudentPay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          foregroundColor: Color(0xFF1E293B),
          centerTitle: false,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
import 'package:brawl_tcg/screens/cliente/Login.dart';
import 'package:brawl_tcg/screens/cliente/cliente_shell.dart';
import 'package:brawl_tcg/screens/organizador/org_shell.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brawl TCG',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8A4BFF)),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: ClienteShell(),
    );
  }
}

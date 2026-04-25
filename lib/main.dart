import 'package:brawl_tcg/screens/cliente/Login.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme:
            GoogleFonts.rubikTextTheme(), //la app tendra de font de texto rubik

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      // En tu main.dart o donde navegues:
      home: Login(),
    );
  }
}

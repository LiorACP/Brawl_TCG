import 'package:brawl_tcg/screens/cliente/Login.dart';
import 'package:brawl_tcg/screens/cliente/rol_selection_screen.dart';
import 'package:brawl_tcg/shell/cliente_shell.dart';
import 'package:brawl_tcg/shell/org_shell.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _bgMessageHandler(RemoteMessage message) async {}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Colors.black,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_bgMessageHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        textTheme: GoogleFonts.rubikTextTheme(),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Mientras Firebase comprueba si hay sesión activa muestro el spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1C20),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF8BF54)),
            ),
          );
        }

        // Si no hay usuario logueado voy al login
        if (!snapshot.hasData || snapshot.data == null) {
          return const Login();
        }

        // Si hay sesión compruebo el rol del usuario para mandarlo al shell correcto
        return _RoleRouter(uid: snapshot.data!.uid);
      },
    );
  }
}

class _RoleRouter extends StatefulWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  State<_RoleRouter> createState() => _RoleRouterState();
}

class _RoleRouterState extends State<_RoleRouter> {
  late final Future<String> _roleFuture;

  @override
  void initState() {
    super.initState();
    _roleFuture = _fetchRole();
    _saveFcmToken();
  }

  Future<String> _fetchRole() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.uid)
          .get();
      if (!doc.exists) return 'nuevo';
      final isOrganizer = doc.data()?['organizer'] as bool? ?? false;
      return isOrganizer ? 'Organizador' : 'Cliente';
    } catch (_) {
      return 'Cliente';
    }
  }

  Future<void> _saveFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.uid)
          .update({'fcmToken': token});
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _roleFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            backgroundColor: Color(0xFF1A1C20),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFF8BF54)),
            ),
          );
        }
        return switch (snapshot.data) {
          'nuevo' => const RolSelectionScreen(),
          'Organizador' => const OrgShell(),
          _ => const ClienteShell(),
        };
      },
    );
  }
}

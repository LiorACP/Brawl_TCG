import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:brawl_tcg/screens/cliente/Registro.dart';
import 'package:brawl_tcg/screens/cliente/forgot_password_screen.dart';
import 'package:brawl_tcg/screens/cliente/event_screen.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Si el ancho es mayor a 900px, mostramos la versión PC
          if (constraints.maxWidth > 900) {
            return const DesktopLoginView();
          } else {
            return const MobileLoginView();
          }
        },
      ),
    );
  }
}

//clase vista pc
class DesktopLoginView extends StatelessWidget {
  const DesktopLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // lado izquierdo: Imagen (50% de la pantalla)
        Expanded(
          flex: 1,
          child: Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/BackGround_Login.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ), // Overlay sutil
          ),
        ),
        // lado derecho: Formulario login (50% de la pantalla)
        Expanded(
          flex: 1,
          child: Container(
            color: const Color(0xFF1A1C20),
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: const LoginFormContent(isDesktop: true),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

//clase vista movil
class MobileLoginView extends StatelessWidget {
  const MobileLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo completo
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BackGround_Login.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Formulario centrado con Blur
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                width: 360,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1C20).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: const LoginFormContent(isDesktop: false),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LoginFormContent extends StatefulWidget {
  final bool isDesktop;
  const LoginFormContent({super.key, required this.isDesktop});

  @override
  State<LoginFormContent> createState() => _LoginFormContentState();
}

class _LoginFormContentState extends State<LoginFormContent> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToEventScreen() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const EventScreen()),
      (_) => false,
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rellena todos los campos')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (!mounted) return;
      _goToEventScreen();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = switch (e.code) {
        'user-not-found' => 'No existe una cuenta con ese email',
        'wrong-password' || 'invalid-credential' => 'Contraseña incorrecta',
        'invalid-email' => 'El email no es válido',
        'too-many-requests' => 'Demasiados intentos. Inténtalo más tarde',
        _ => 'Error al iniciar sesión',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) return;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);
      }
      if (!mounted) return;
      _goToEventScreen();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error con Google: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          widget.isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        if (widget.isDesktop) ...[
          Center(
            child: Text(
              "HOLA  JUGADOR",
              style: GoogleFonts.rubik(
                fontSize: 42,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Center(
            child: Text(
              "Bienvenido a BRAWL TCG",
              style: GoogleFonts.rubik(fontSize: 16, color: Colors.white70),
            ),
          ),
          const SizedBox(height: 50),
        ] else ...[
          Text(
            'BRAWL TCG',
            style: GoogleFonts.rubik(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
          const SizedBox(height: 40),
        ],
        _buildField(Icons.email_outlined, "Email", controller: _emailController),
        const SizedBox(height: 20),
        _buildField(
          Icons.lock_outline,
          "Password",
          isPass: true,
          controller: _passwordController,
        ),
        const SizedBox(height: 40),
        _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0XFFF8BF54)),
              )
            : _buildLoginButton(),
        const SizedBox(height: 5),
        _buildForgotPasswordButton(),
        const SizedBox(height: 40),
        _buildRegisterButton(),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "OR REGISTER WITH",
                style: GoogleFonts.rubik(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Expanded(child: Divider(color: Colors.white24, thickness: 1)),
          ],
        ),
        const SizedBox(height: 30),
        _buildGoogleButton(),
      ],
    );
  }

  Widget _buildField(
    IconData icon,
    String hint, {
    bool isPass = false,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPass,
      style: GoogleFonts.rubik(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.black.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [Color(0XFFF8BF54), Color(0xFFEC5544), Color(0xFF9120A6)],
        ),
      ),
      child: ElevatedButton(
        onPressed: _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
          "INICIAR SESIÓN",
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ForgotPasswordScreen()),
          );
        },
        child: Text(
          "¿Olvidaste tu contraseña?",
          style: GoogleFonts.rubik(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RegisterScreen()),
          );
        },
        child: Text(
          "¿No tienes cuenta? Regístrate",
          style: GoogleFonts.rubik(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white.withOpacity(0.3),
      ),
      child: ElevatedButton.icon(
        onPressed: _loginWithGoogle,
        icon: Image.asset('assets/images/google_icon.png', height: 24),
        label: Text(
          "CONTINUAR CON GOOGLE",
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 5, 183, 223),
          shadowColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
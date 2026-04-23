import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/features/auth/registro_screen.dart';
import 'package:brawl_tcg/features/auth/forgot_password_screen.dart';
import 'package:brawl_tcg/shell/cliente_shell.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
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

class DesktopLoginView extends StatelessWidget {
  const DesktopLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
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
            ),
          ),
        ),
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

class MobileLoginView extends StatelessWidget {
  const MobileLoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/BackGround_Login.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
              child: Container(
                width: 360,
                padding: const EdgeInsets.symmetric(
                  horizontal: 30,
                  vertical: 50,
                ),
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

class LoginFormContent extends StatelessWidget {
  final bool isDesktop;
  const LoginFormContent({super.key, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        if (isDesktop) ...[
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

        _buildField(Icons.email_outlined, "Email"),
        const SizedBox(height: 20),
        _buildField(Icons.lock_outline, "Password", isPass: true),
        const SizedBox(height: 40),
        _buildLoginButton(context),
        const SizedBox(height: 5),
        _buildForgotPasswordButton(context),
        const SizedBox(height: 40),
        _buildRegisterButton(context),
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
        _buildGoogleButton(context),
      ],
    );
  }

  Widget _buildField(IconData icon, String hint, {bool isPass = false}) {
    return TextField(
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

  Widget _buildLoginButton(BuildContext context) {
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
        onPressed: () => Navigator.pushAndRemoveUntil(
          context,
          fadeSlideRoute(const ClienteShell()),
          (route) => false,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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

  Widget _buildForgotPasswordButton(BuildContext context) {
    return Center(
      child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
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
}

Widget _buildRegisterButton(BuildContext context) {
  return Center(
    child: TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterScreen()),
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

Widget _buildGoogleButton(BuildContext context) {
  return Container(
    width: double.infinity,
    height: 55,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
      color: Colors.white.withValues(alpha: 0.3),
    ),
    child: ElevatedButton.icon(
      onPressed: () => Navigator.pushAndRemoveUntil(
        context,
        fadeSlideRoute(const ClienteShell()),
        (route) => false,
      ),
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

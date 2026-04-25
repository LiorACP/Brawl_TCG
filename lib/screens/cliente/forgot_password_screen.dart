import 'package:flutter/material.dart';
import 'package:brawl_tcg/widgets/forgot_password_content.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C20),
      // Botón para volver atrás (opcional pero recomendado)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return const Center(
              child: SizedBox(
                width: 500,
                child: SingleChildScrollView(
                  child: ForgotPasswordContent(isDesktop: true),
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 30.0),
              child: Center(
                child: SingleChildScrollView(
                  child: ForgotPasswordContent(isDesktop: false),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

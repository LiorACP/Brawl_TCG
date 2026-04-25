import 'package:flutter/material.dart';
import 'package:brawl_tcg/widgets/RegisterFormContent.dart'; // Tu nuevo componente de formulario

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C20), // Fondo gris oscuro limpio
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return const Center(
              child: SizedBox(
                width: 500, // En PC no queremos que ocupe todo el ancho
                child: SingleChildScrollView(
                  child: RegisterFormContent(isDesktop: true),
                ),
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.all(30.0),
              child: Center(
                child: SingleChildScrollView(
                  child: RegisterFormContent(isDesktop: false),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterFormContent extends StatefulWidget {
  final bool isDesktop;
  const RegisterFormContent({super.key, required this.isDesktop});

  @override
  State<RegisterFormContent> createState() => _RegisterFormContentState();
}

class _RegisterFormContentState extends State<RegisterFormContent> {
  String _selectedRole = 'Cliente';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Center(
          child: Text(
            "ÚNETE AL BRAWL",
            style: GoogleFonts.rubik(
              fontSize: widget.isDesktop ? 40 : 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _selectedRole == 'Cliente'
                  ? "Crea tu cuenta para empezar a competir y demostar lo que vales."
                  : "Sé el mejor tiendero en organizar los mejores torneos.",
              key: ValueKey(_selectedRole),
              textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
              style: GoogleFonts.rubik(
                color: Colors.white54,
                fontSize: 14,
                fontStyle: _selectedRole == 'Organizador'
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
        _buildRoleSelector(),
        const SizedBox(height: 30),
        _buildField(Icons.person_outline, "Nombre de Usuario"),
        const SizedBox(height: 20),
        _buildField(Icons.email_outlined, "Correo Electrónico"),
        const SizedBox(height: 20),
        _buildField(Icons.public, "Ciudad"),
        const SizedBox(height: 20),
        _buildField(Icons.lock_outline, "Contraseña", isPass: true),
        const SizedBox(height: 40),
        _buildRegisterButton(),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Center(
            child: Text(
              "¿Ya tienes cuenta? Inicia sesión",
              style: GoogleFonts.rubik(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleSelector() {
    return Center(
      child: Container(
        height: 50,
        width: widget.isDesktop ? 400 : double.infinity,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Stack(
          children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              alignment: _selectedRole == 'Cliente'
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Container(
                width: (widget.isDesktop
                        ? 400
                        : MediaQuery.of(context).size.width - 60) /
                    2,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEC5544), Color(0xFF9120A6)],
                  ),
                ),
              ),
            ),
            Row(children: [_roleButton("Cliente"), _roleButton("Organizador")]),
          ],
        ),
      ),
    );
  }

  Widget _roleButton(String role) {
    bool isSelected = _selectedRole == role;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedRole = role),
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Text(
            role,
            style: GoogleFonts.rubik(
              color: isSelected ? Colors.white : Colors.white38,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(IconData icon, String hint, {bool isPass = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        obscureText: isPass,
        style: GoogleFonts.rubik(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
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
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          "CREAR CUENTA",
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

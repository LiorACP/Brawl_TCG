import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ForgotPasswordContent extends StatefulWidget {
  final bool isDesktop;
  const ForgotPasswordContent({super.key, required this.isDesktop});

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  bool _mailSent = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _mailSent ? _buildSuccessView() : _buildRequestView(),
    );
  }

  Widget _buildRequestView() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          "¿OLVIDASTE TU CONTRASEÑA?",
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.rubik(
            fontSize: widget.isDesktop ? 32 : 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          "Introduce tu email y te enviaremos las instrucciones para recuperarla.",
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.rubik(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 40),
        _buildField(Icons.email_outlined, "Tu correo electrónico"),
        const SizedBox(height: 40),
        _buildGradientButton(
          text: "ENVIAR INSTRUCCIONES",
          onPressed: () => setState(() => _mailSent = true),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 80, color: Color(0XFFF8BF54)),
        const SizedBox(height: 30),
        Text(
          "¡CORREO ENVIADO!",
          style: GoogleFonts.rubik(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 15),
        Text(
          "Revisa tu bandeja de entrada para cambiar la contraseña. No olvides mirar en la carpeta de spam.",
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(color: Colors.white54, fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 40),
        OutlinedButton(
          onPressed: () {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Correo reenviado")));
          },
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          child: Text(
            "NO HE RECIBIDO NADA, REENVIAR",
            style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        TextButton(
          onPressed: () => setState(() => _mailSent = false),
          child: Text(
            "Intentar con otro email",
            style: GoogleFonts.rubik(color: Colors.white38, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildField(IconData icon, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: TextField(
        style: GoogleFonts.rubik(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70, size: 20),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildGradientButton({required String text, required VoidCallback onPressed}) {
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(text, style: GoogleFonts.rubik(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

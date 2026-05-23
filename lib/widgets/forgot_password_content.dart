import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';

class ForgotPasswordContent extends StatefulWidget {
  final bool isDesktop;
  const ForgotPasswordContent({super.key, required this.isDesktop});

  @override
  State<ForgotPasswordContent> createState() => _ForgotPasswordContentState();
}

class _ForgotPasswordContentState extends State<ForgotPasswordContent> {
  bool _mailSent = false;
  bool _isLoading = false;
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.t('Introduce tu email'))),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (!mounted) return;
      setState(() => _mailSent = true);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'user-not-found'
          ? L10n.t('No existe una cuenta con ese email')
          : L10n.t('Error al enviar el correo');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _mailSent ? _buildSuccessView() : _buildRequestView(),
    );
  }

  // VISTA 1: Pedir el email
  Widget _buildRequestView() {
    return Column(
      key: const ValueKey(1),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.isDesktop
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          L10n.t("¿OLVIDASTE TU CONTRASEÑA?"),
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
          L10n.t("Introduce tu email y te enviaremos las instrucciones para recuperarla."),
          textAlign: widget.isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.rubik(color: Colors.white54, fontSize: 14),
        ),
        const SizedBox(height: 40),

        _buildField(Icons.email_outlined, L10n.t("Tu correo electrónico")),

        const SizedBox(height: 40),

        _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0XFFF8BF54)),
              )
            : _buildGradientButton(
                text: L10n.t("ENVIAR INSTRUCCIONES"),
                onPressed: _sendReset,
              ),
      ],
    );
  }

  // VISTA 2: Mensaje de éxito
  Widget _buildSuccessView() {
    return Column(
      key: const ValueKey(2),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 80,
          color: Color(0XFFF8BF54),
        ),
        const SizedBox(height: 30),
        Text(
          L10n.t("¡CORREO ENVIADO!"),
          style: GoogleFonts.rubik(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          L10n.t("Revisa tu bandeja de entrada para cambiar la contraseña. No olvides mirar en la carpeta de spam."),
          textAlign: TextAlign.center,
          style: GoogleFonts.rubik(
            color: Colors.white54,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),

        OutlinedButton(
          onPressed: _sendReset,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 55),
            side: const BorderSide(color: Colors.white24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
          child: Text(
            L10n.t("NO HE RECIBIDO NADA, REENVIAR"),
            style: GoogleFonts.rubik(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        TextButton(
          onPressed: () => setState(() => _mailSent = false),
          child: Text(
            L10n.t("Intentar con otro email"),
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
        controller: _emailController,
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

  // Reutilizamos tu botón con degradado
  Widget _buildGradientButton({
    required String text,
    required VoidCallback onPressed,
  }) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.rubik(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

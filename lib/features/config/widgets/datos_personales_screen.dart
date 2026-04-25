import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'config_field.dart';

class DatosPersonalesScreen extends StatefulWidget {
  final String nombre;
  final String email;
  final String telefono;
  final List<Color> accent;
  final void Function(String nombre, String email, String telefono)? onSave;

  const DatosPersonalesScreen({
    super.key,
    this.nombre = '',
    this.email = '',
    this.telefono = '',
    this.accent = AppColors.clienteGradient,
    this.onSave,
  });

  @override
  State<DatosPersonalesScreen> createState() => _DatosPersonalesScreenState();
}

class _DatosPersonalesScreenState extends State<DatosPersonalesScreen> {
  late final TextEditingController _nombreCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefonoCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.nombre);
    _emailCtrl = TextEditingController(text: widget.email);
    _telefonoCtrl = TextEditingController(text: widget.telefono);
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final nuevoNombre = _nombreCtrl.text.trim();
    final nuevoEmail = _emailCtrl.text.trim();
    final nuevoTelefono = _telefonoCtrl.text.trim();
    final emailCambio = nuevoEmail.isNotEmpty && nuevoEmail != user.email;

    setState(() => _isLoading = true);
    try {
      // 1. Actualizar Firestore
      await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .update({
        'nombre': nuevoNombre,
        'email': nuevoEmail,
        'telefono': nuevoTelefono,
      });

      // 2. Si el email cambió, actualizar Firebase Auth
      if (emailCambio) {
        // Manda verificación al nuevo email; el cambio en Auth se aplica al pulsar el enlace
        await user.verifyBeforeUpdateEmail(nuevoEmail);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Revisa tu nuevo correo para confirmar el cambio de email.'),
            duration: Duration(seconds: 4),
          ),
        );
      }

      widget.onSave?.call(nuevoNombre, nuevoEmail, nuevoTelefono);
      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final msg = e.code == 'requires-recent-login'
          ? 'Por seguridad, cierra sesión, vuelve a entrar y repite el cambio.'
          : 'Error al actualizar el email: ${e.message}';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar los cambios.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 42,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text('Datos personales',
                        style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(bottom: 28),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: widget.accent,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: const Center(
                            child: Text('👤', style: TextStyle(fontSize: 32)),
                          ),
                        ),
                      ),
                      ConfigField(
                        label: 'Nombre completo',
                        controller: _nombreCtrl,
                        icon: '✏',
                      ),
                      const SizedBox(height: 14),
                      ConfigField(
                        label: 'Email',
                        controller: _emailCtrl,
                        icon: '✉',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 14),
                      ConfigField(
                        label: 'Teléfono',
                        controller: _telefonoCtrl,
                        icon: '📱',
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 32),
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.violet),
                            )
                          : GradBtn(
                              width: double.infinity,
                              size: GradBtnSize.lg,
                              gradient: widget.accent,
                              onTap: _save,
                              child: const Text('Guardar cambios'),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

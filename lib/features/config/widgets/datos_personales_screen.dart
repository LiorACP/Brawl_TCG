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

  void _save() {
    widget.onSave?.call(
      _nombreCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _telefonoCtrl.text.trim(),
    );
    Navigator.pop(context);
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
                      GradBtn(
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

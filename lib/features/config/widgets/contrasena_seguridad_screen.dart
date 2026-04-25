import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'config_field.dart';

class ContrasenaSeguridadScreen extends StatefulWidget {
  final List<Color> accent;
  final String email;
  const ContrasenaSeguridadScreen({
    super.key,
    this.accent = AppColors.clienteGradient,
    this.email = '',
  });

  @override
  State<ContrasenaSeguridadScreen> createState() => _ContrasenaSeguridadScreenState();
}

class _ContrasenaSeguridadScreenState extends State<ContrasenaSeguridadScreen> {
  final _actualCtrl = TextEditingController();
  final _nuevaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _twoFa = false;

  @override
  void dispose() {
    _actualCtrl.dispose();
    _nuevaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  void _savePassword() {
    if (_nuevaCtrl.text != _confirmarCtrl.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Las contraseñas no coinciden',
              style: GoogleFonts.rubik(color: Colors.white)),
          backgroundColor: AppColors.pink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contraseña actualizada',
            style: GoogleFonts.rubik(color: Colors.white)),
        backgroundColor: AppColors.cyan.withValues(alpha: 0.9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    _actualCtrl.clear();
    _nuevaCtrl.clear();
    _confirmarCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 55,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text('Contraseña y seguridad',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.email.isNotEmpty) ...[
                        const ConfigSectionHeader('Cuenta'),
                        BrawlCard(
                          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                          radius: 18,
                          child: Row(
                            children: [
                              Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: AppColors.cyan.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(
                                      color: AppColors.cyan.withValues(alpha: 0.2)),
                                ),
                                child: const Center(
                                  child: Text('✉',
                                      style: TextStyle(
                                          fontSize: 13, color: AppColors.cyan)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Email registrado',
                                        style: GoogleFonts.rubik(
                                            fontSize: 11,
                                            color: AppColors.textMute)),
                                    Text(widget.email,
                                        style: GoogleFonts.rubik(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.text)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const ConfigSectionHeader('Cambiar contraseña'),
                      BrawlCard(
                        padding: const EdgeInsets.all(16),
                        radius: 18,
                        child: Column(
                          children: [
                            ConfigPasswordField(
                              label: 'Contraseña actual',
                              controller: _actualCtrl,
                            ),
                            const SizedBox(height: 14),
                            ConfigPasswordField(
                              label: 'Nueva contraseña',
                              controller: _nuevaCtrl,
                            ),
                            const SizedBox(height: 14),
                            ConfigPasswordField(
                              label: 'Confirmar contraseña',
                              controller: _confirmarCtrl,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      GradBtn(
                        width: double.infinity,
                        gradient: widget.accent,
                        onTap: _savePassword,
                        child: const Text('Actualizar contraseña'),
                      ),
                      const SizedBox(height: 28),
                      const ConfigSectionHeader('Verificación en dos pasos'),
                      BrawlCard(
                        padding: EdgeInsets.zero,
                        radius: 18,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: AppColors.violet.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(9),
                                      border: Border.all(
                                          color: AppColors.violet.withValues(alpha: 0.2)),
                                    ),
                                    child: const Center(
                                      child: Text('🔐', style: TextStyle(fontSize: 14)),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Autenticación 2FA',
                                            style: GoogleFonts.rubik(
                                                fontSize: 13.5,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.text)),
                                        Text(
                                            _twoFa
                                                ? 'Activada · App autenticadora'
                                                : 'Desactivada',
                                            style: GoogleFonts.rubik(
                                                fontSize: 11,
                                                color: AppColors.textMute)),
                                      ],
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => setState(() => _twoFa = !_twoFa),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 38,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        gradient: _twoFa
                                            ? LinearGradient(colors: widget.accent)
                                            : null,
                                        color: _twoFa ? null : AppColors.surfaceHi,
                                        borderRadius: BorderRadius.circular(11),
                                      ),
                                      child: Stack(
                                        children: [
                                          AnimatedPositioned(
                                            duration: const Duration(milliseconds: 200),
                                            top: 2,
                                            left: _twoFa ? null : 2,
                                            right: _twoFa ? 2 : null,
                                            child: Container(
                                              width: 18,
                                              height: 18,
                                              decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_twoFa)
                              Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: AppColors.stroke)),
                                ),
                                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                                child: Text(
                                  'Usa una app como Google Authenticator o Authy para escanear el código QR al iniciar sesión.',
                                  style: GoogleFonts.rubik(
                                      fontSize: 12, color: AppColors.textDim),
                                ),
                              ),
                          ],
                        ),
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

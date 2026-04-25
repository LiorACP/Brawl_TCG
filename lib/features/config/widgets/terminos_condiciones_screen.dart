import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class TerminosCondicionesScreen extends StatelessWidget {
  const TerminosCondicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 90,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text('Términos y condiciones',
                          style: GoogleFonts.rubik(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 32),
                  child: BrawlCard(
                    padding: const EdgeInsets.all(20),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalHeader('Versión 1.4 · Vigente desde el 1 de enero de 2025'),
                        const SizedBox(height: 20),
                        _LegalSection(
                          title: '1. Aceptación de los términos',
                          body:
                              'Al usar Brawl TCG aceptas estos Términos y Condiciones. Si no estás de acuerdo con alguno de ellos, debes dejar de utilizar la aplicación.',
                        ),
                        _LegalSection(
                          title: '2. Descripción del servicio',
                          body:
                              'Brawl TCG es una plataforma de gestión y participación en torneos de juegos de cartas coleccionables (TCG). Permite a los usuarios inscribirse en torneos, consultar resultados y gestionar su perfil de jugador.',
                        ),
                        _LegalSection(
                          title: '3. Cuentas de usuario',
                          body:
                              'Debes ser mayor de 14 años para registrarte. Eres responsable de mantener la confidencialidad de tus credenciales. Nos reservamos el derecho a suspender cuentas que infrinjan estos términos.',
                        ),
                        _LegalSection(
                          title: '4. Torneos y competiciones',
                          body:
                              'La inscripción en un torneo está sujeta a las normas específicas de cada organizador. Brawl TCG no es responsable de las decisiones tomadas por los organizadores ni de posibles disputas entre jugadores.',
                        ),
                        _LegalSection(
                          title: '5. Conducta del usuario',
                          body:
                              'Queda prohibido el uso de la plataforma para actividades ilegales, difamación, acoso o cualquier comportamiento contrario a la buena fe deportiva. Los infractores podrán ser expulsados sin previo aviso.',
                        ),
                        _LegalSection(
                          title: '6. Propiedad intelectual',
                          body:
                              'Todo el contenido de Brawl TCG (diseño, código, logotipos) es propiedad de Brawl TCG S.L. Los nombres y logotipos de juegos de cartas son propiedad de sus respectivos titulares.',
                        ),
                        _LegalSection(
                          title: '7. Limitación de responsabilidad',
                          body:
                              'Brawl TCG no será responsable de daños indirectos, incidentales o consecuentes derivados del uso o imposibilidad de uso del servicio.',
                        ),
                        _LegalSection(
                          title: '8. Modificaciones',
                          body:
                              'Podemos actualizar estos términos en cualquier momento. Te notificaremos los cambios relevantes a través de la aplicación o por email con al menos 15 días de antelación.',
                        ),
                        _LegalSection(
                          title: '9. Legislación aplicable',
                          body:
                              'Estos términos se rigen por la legislación española. Cualquier litigio se someterá a los tribunales de Madrid, España, salvo que la normativa de consumidores obligue a otro fuero.',
                        ),
                      ],
                    ),
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

class _LegalHeader extends StatelessWidget {
  final String text;
  const _LegalHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute));
  }
}

class _LegalSection extends StatelessWidget {
  final String title;
  final String body;
  const _LegalSection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text)),
          const SizedBox(height: 6),
          Text(body,
              style: GoogleFonts.rubik(
                  fontSize: 12.5,
                  color: AppColors.textDim,
                  height: 1.6)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class PoliticaPrivacidadScreen extends StatelessWidget {
  const PoliticaPrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 80,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const BackBtn(),
                    const SizedBox(width: 14),
                    Text('Política de privacidad',
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
                  child: BrawlCard(
                    padding: const EdgeInsets.all(20),
                    radius: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LegalHeader('Última actualización: 25 de abril de 2025'),
                        const SizedBox(height: 20),
                        _LegalSection(
                          title: '1. Datos que recopilamos',
                          body:
                              'Brawl TCG recopila los datos que tú nos proporcionas directamente, como nombre, email y teléfono al crear una cuenta. También recopilamos datos de uso de la aplicación, como torneos consultados, juegos favoritos y preferencias de notificación.',
                        ),
                        _LegalSection(
                          title: '2. Uso de los datos',
                          body:
                              'Utilizamos tus datos para ofrecerte una experiencia personalizada: mostrarte torneos relevantes según tu ubicación y juegos favoritos, enviarte notificaciones que hayas activado y mejorar nuestros servicios.',
                        ),
                        _LegalSection(
                          title: '3. Compartición de datos',
                          body:
                              'No vendemos ni cedemos tus datos a terceros. Únicamente los compartimos con organizadores de torneos cuando te inscribes a un evento, y con proveedores de servicios técnicos (Firebase, Google Cloud) bajo acuerdos de confidencialidad.',
                        ),
                        _LegalSection(
                          title: '4. Tus derechos',
                          body:
                              'Tienes derecho a acceder, rectificar, suprimir, limitar el tratamiento y portabilidad de tus datos en cualquier momento desde el apartado de configuración o contactándonos en privacidad@brawltcg.gg.',
                        ),
                        _LegalSection(
                          title: '5. Seguridad',
                          body:
                              'Implementamos medidas técnicas y organizativas para proteger tus datos contra acceso no autorizado, pérdida o destrucción accidental, incluyendo cifrado en tránsito y en reposo.',
                        ),
                        _LegalSection(
                          title: '6. Cookies y rastreo',
                          body:
                              'La aplicación móvil no utiliza cookies. En la versión web podemos usar cookies técnicas esenciales para el funcionamiento del servicio y cookies analíticas si das tu consentimiento.',
                        ),
                        _LegalSection(
                          title: '7. Contacto',
                          body:
                              'Para cualquier consulta sobre privacidad, puedes contactar con nuestro Delegado de Protección de Datos en privacidad@brawltcg.gg o escribir a Brawl TCG S.L., Calle Mayor 42, 28001 Madrid, España.',
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

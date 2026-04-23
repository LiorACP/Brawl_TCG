import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class OrgAnunciosScreen extends StatefulWidget {
  final bool isCreationFlow;
  const OrgAnunciosScreen({super.key, this.isCreationFlow = false});

  @override
  State<OrgAnunciosScreen> createState() => _OrgAnunciosScreenState();
}

class _OrgAnunciosScreenState extends State<OrgAnunciosScreen> {
  final Map<String, bool> _channels = {
    'Feed de la app': true,
    'Instagram': true,
    'Discord servidor': true,
    'X / Twitter': false,
  };

  void _publish() {
    final active = _channels.entries.where((e) => e.value).map((e) => e.key).toList();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Publicado en: ${active.join(', ')}'),
        backgroundColor: AppColors.violet,
      ),
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _schedule() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Programado para 24h antes del torneo')),
    );
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
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const BackBtn(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: widget.isCreationFlow
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('NUEVO TORNEO',
                                        style: GoogleFonts.rubik(
                                            fontSize: 11,
                                            color: AppColors.textMute,
                                            letterSpacing: 0.5)),
                                    Text('Paso 4 de 4 · Publicar',
                                        style: GoogleFonts.rubik(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('COMPARTIR',
                                        style: GoogleFonts.rubik(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMute,
                                            letterSpacing: 0.5)),
                                    Text('Publicar anuncio',
                                        style: GoogleFonts.rubik(
                                            fontSize: 22,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text,
                                            letterSpacing: -0.5)),
                                  ],
                                ),
                        ),
                        if (widget.isCreationFlow)
                          GestureDetector(
                            onTap: () => ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                                    content: Text('Borrador guardado'))),
                            child: Text('Guardar',
                                style: GoogleFonts.rubik(
                                    fontSize: 12, color: AppColors.textDim)),
                          ),
                      ],
                    ),
                    if (widget.isCreationFlow) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: List.generate(
                          4,
                          (i) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                      colors: AppColors.organizadorGradient),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrawlCard(
                        padding: EdgeInsets.zero,
                        radius: 24,
                        tint: const Color(0xFF0E0A1A),
                        border: Colors.transparent,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 156,
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: -60,
                                    left: -40,
                                    child: Container(
                                      width: 260,
                                      height: 260,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            AppColors.cyan.withValues(alpha: 0.6),
                                            AppColors.violet.withValues(alpha: 0.4),
                                            AppColors.pink.withValues(alpha: 0.2),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Positioned(
                                    top: 14,
                                    left: 16,
                                    child: GameBadge(game: 'MTG', size: 34),
                                  ),
                                  Positioned(
                                    bottom: 14,
                                    left: 16,
                                    right: 16,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('VIERNES · 18:30',
                                            style: GoogleFonts.rubik(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.yellow,
                                                letterSpacing: 0.6)),
                                        const SizedBox(height: 2),
                                        Text('Pioneer FNM Mayo',
                                            style: GoogleFonts.rubik(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w800,
                                                color: AppColors.text,
                                                letterSpacing: -0.3)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('32 plazas · 8 € · Top 8',
                                      style: GoogleFonts.rubik(
                                          fontSize: 12, color: AppColors.textDim)),
                                  Text('12/32',
                                      style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.cyan)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      BrawlCard(
                        radius: 18,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('TEXTO DEL ANUNCIO',
                                style: GoogleFonts.rubik(
                                    fontSize: 10.5,
                                    color: AppColors.textMute,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 6),
                            RichText(
                              text: TextSpan(
                                style: GoogleFonts.rubik(
                                    fontSize: 13.5, color: AppColors.text, height: 1.45),
                                children: [
                                  const TextSpan(
                                      text:
                                          '¡Vuelve el Pioneer FNM! 🗡 32 plazas, 5 rondas + Top 8. Premios en producto y promo exclusiva para Top 4. Inscríbete con el código '),
                                  TextSpan(
                                    text: 'BR79KP',
                                    style: GoogleFonts.rubikMonoOne(
                                        fontSize: 13.5, color: AppColors.magenta),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('#MTG #Pioneer #Barcelona',
                                    style: GoogleFonts.rubik(
                                        fontSize: 11, color: AppColors.textMute)),
                                Text('187/280',
                                    style: GoogleFonts.rubik(
                                        fontSize: 11, color: AppColors.textMute)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SectionLabel('Publicar en'),
                      ...[
                        _ChannelRow(
                          name: 'Feed de la app',
                          sub: '312 seguidores · push opcional',
                          color: AppColors.violet,
                          icon: '⬢',
                          active: _channels['Feed de la app']!,
                          onToggle: (v) =>
                              setState(() => _channels['Feed de la app'] = v),
                        ),
                        _ChannelRow(
                          name: 'Instagram',
                          sub: '@dragonrojostore · story + post',
                          color: AppColors.pink,
                          icon: '◎',
                          active: _channels['Instagram']!,
                          onToggle: (v) => setState(() => _channels['Instagram'] = v),
                        ),
                        _ChannelRow(
                          name: 'Discord servidor',
                          sub: '#anuncios · 428 miembros',
                          color: AppColors.blue,
                          icon: '◆',
                          active: _channels['Discord servidor']!,
                          onToggle: (v) =>
                              setState(() => _channels['Discord servidor'] = v),
                        ),
                        _ChannelRow(
                          name: 'X / Twitter',
                          sub: '@dragonrojo · sin conectar',
                          color: AppColors.textMute,
                          icon: '✕',
                          active: _channels['X / Twitter']!,
                          onToggle: (v) => setState(() => _channels['X / Twitter'] = v),
                        ),
                      ],
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _schedule,
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: Center(
                          child: Text('Programar',
                              style: GoogleFonts.rubik(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: GradBtn(
                        size: GradBtnSize.lg,
                        gradient: AppColors.organizadorGradient,
                        width: double.infinity,
                        onTap: _publish,
                        child: const Text('Publicar ahora ✦'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChannelRow extends StatelessWidget {
  final String name, sub, icon;
  final Color color;
  final bool active;
  final ValueChanged<bool> onToggle;
  const _ChannelRow({
    required this.name,
    required this.sub,
    required this.icon,
    required this.color,
    required this.active,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.stroke : Colors.transparent),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Center(
                  child: Text(icon, style: TextStyle(fontSize: 16, color: color))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: GoogleFonts.rubik(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text)),
                  const SizedBox(height: 1),
                  Text(sub,
                      style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => onToggle(!active),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(colors: AppColors.organizadorGradient)
                      : null,
                  color: active ? null : AppColors.surfaceHi,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      top: 2,
                      left: active ? null : 2,
                      right: active ? 2 : null,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

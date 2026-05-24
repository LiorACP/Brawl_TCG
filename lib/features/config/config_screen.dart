import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/state/app_prefs_notifier.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'viewmodels/config_viewmodel.dart';
import 'widgets/datos_personales_screen.dart';
import 'widgets/contrasena_seguridad_screen.dart';
import 'widgets/juegos_favoritos_screen.dart';
import 'widgets/idioma_screen.dart';
import 'widgets/apariencia_screen.dart';
import 'widgets/unidades_screen.dart';
import 'widgets/politica_privacidad_screen.dart';
import 'widgets/terminos_condiciones_screen.dart';

class SharedConfigScreen extends StatefulWidget {
  final bool isOrg;
  const SharedConfigScreen({super.key, this.isOrg = false});

  @override
  State<SharedConfigScreen> createState() => _SharedConfigScreenState();
}

class _SharedConfigScreenState extends State<SharedConfigScreen> {
  late bool _isOrg;
  final _vm = ConfigViewModel();

  @override
  void initState() {
    super.initState();
    _isOrg = widget.isOrg;
    _vm.addListener(_onVmUpdate);
    _vm.init();
  }

  void _onVmUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmUpdate);
    _vm.dispose();
    super.dispose();
  }

  String get _idiomaLabel =>
      _vm.idioma == 'es' ? L10n.t('Español (España)') : L10n.t('English (UK)');
  String get _aparienciaLabel =>
      _vm.apariencia == 'dark' ? L10n.t('Oscuro') : L10n.t('Claro');

  @override
  Widget build(BuildContext context) {
    final accent =
        _isOrg ? AppColors.organizadorGradient : AppColors.clienteGradient;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 70,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    Text(L10n.t('Configuración'),
                        style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    children: [
                      // Tarjeta de perfil
                      BrawlCard(
                        padding: const EdgeInsets.all(18),
                        radius: 24,
                        tint: AppColors.bgDeep,
                        border: Colors.transparent,
                        child: Row(
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: accent,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_vm.nombre,
                                      style: GoogleFonts.rubik(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(
                                      [
                                        if (_vm.nombre.isNotEmpty)
                                          '@${_vm.nombre.split(' ').first.toLowerCase()}',
                                        if (_vm.joinYear.isNotEmpty)
                                          L10n.fmt('desde {year}',
                                              {'year': _vm.joinYear}),
                                      ].join(' · '),
                                      style: GoogleFonts.rubik(
                                          fontSize: 12,
                                          color: AppColors.textDim)),
                                  const SizedBox(height: 6),
                                  if (_isOrg)
                                    BrawlTag(
                                        label: L10n.t('Organizador'),
                                        color: AppColors.magenta),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                slideRoute(DatosPersonalesScreen(
                                  nombre: _vm.nombre,
                                  email: _vm.email,
                                  telefono: _vm.telefono,
                                  accent: accent,
                                  onSave: _vm.savePersonalData,
                                )),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border:
                                      Border.all(color: AppColors.stroke),
                                ),
                                child: Text(L10n.t('Editar'),
                                    style: GoogleFonts.rubik(
                                        fontSize: 12,
                                        color: AppColors.textDim)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Cuenta
                      _Section(
                        header: L10n.t('Cuenta'),
                        items: [
                          _SettingsItem(
                            title: L10n.t('Datos personales'),
                            sub: '${_vm.nombre} · ${_vm.email}',
                            color: AppColors.cyan,
                            icon: 'i',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(DatosPersonalesScreen(
                                nombre: _vm.nombre,
                                email: _vm.email,
                                telefono: _vm.telefono,
                                accent: accent,
                                onSave: _vm.savePersonalData,
                              )),
                            ),
                          ),
                          _SettingsItem(
                            title: L10n.t('Contraseña y seguridad'),
                            sub: L10n.t('2FA desactivado'),
                            color: AppColors.violet,
                            icon: '⚿',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(ContrasenaSeguridadScreen(
                                  accent: accent, email: _vm.email)),
                            ),
                          ),
                          _SettingsItem(
                            title: L10n.t('Mis juegos favoritos'),
                            sub: L10n.fmt('{n} seleccionados',
                                {'n': '${_vm.selectedGames.length}'}),
                            color: AppColors.pink,
                            icon: '♥',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(JuegosFavoritosScreen(
                                selected: _vm.selectedGames,
                                accent: accent,
                                onSave: (games) =>
                                    setState(() => _vm.selectedGames = games),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Notificaciones generales
                      _ToggleSection(
                        header: L10n.t('Notificaciones'),
                        items: [
                          _ToggleItem(
                              title: L10n.t('Torneos próximos'),
                              sub: L10n.t('Push · 2h antes'),
                              color: AppColors.cyan,
                              icon: '⏰',
                              key: 'Torneos próximos'),
                          _ToggleItem(
                              title: L10n.t('Nuevos eventos cerca'),
                              sub: L10n.t('Radio 10 km'),
                              color: AppColors.orange,
                              icon: '◉',
                              key: 'Nuevos eventos cerca'),
                          _ToggleItem(
                              title: L10n.t('Resultados y emparejamiento'),
                              sub: L10n.t('En tiempo real'),
                              color: AppColors.pink,
                              icon: '⚔',
                              key: 'Resultados y emparejamiento'),
                          _ToggleItem(
                              title: L10n.t('Promociones de tiendas'),
                              sub: L10n.t('Semanal'),
                              color: AppColors.yellow,
                              icon: '✦',
                              key: 'Promociones de tiendas'),
                        ],
                        toggles: _vm.toggles,
                        onToggle: _vm.onNotifToggle,
                        accent: accent,
                      ),
                      const SizedBox(height: 18),

                      // Notificaciones por ciudad
                      if (_vm.loadingCiudades)
                        _CiudadLoadingSection(accent: accent)
                      else if (_vm.ciudadToggles.isNotEmpty)
                        _ToggleSection(
                          header: L10n.t('Notificaciones por ciudad'),
                          items: _vm.ciudadToggles.keys
                              .map((city) => _ToggleItem(
                                    title: city,
                                    sub: L10n.fmt(
                                        'Eventos en {city}', {'city': city}),
                                    icon: '◎',
                                    key: city,
                                    color: AppColors.orange,
                                  ))
                              .toList(),
                          toggles: _vm.ciudadToggles,
                          onToggle: _vm.saveCiudadToggle,
                          accent: accent,
                        ),
                      const SizedBox(height: 18),

                      // Preferencias
                      _Section(
                        header: L10n.t('Preferencias'),
                        items: [
                          _SettingsItem(
                            title: L10n.t('Idioma'),
                            sub: _idiomaLabel,
                            color: AppColors.violet,
                            icon: '🌐',
                            onTap: () async {
                              final uid = _getUid();
                              await Navigator.push(
                                context,
                                slideRoute(IdiomaScreen(
                                  selected: _vm.idioma,
                                  accent: accent,
                                  onSave: (lang) async {
                                    if (uid != null) {
                                      await AppPrefsNotifier.instance
                                          .setIdioma(uid, lang);
                                    }
                                    if (mounted) setState(() {});
                                  },
                                )),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                          _SettingsItem(
                            title: L10n.t('Apariencia'),
                            sub: _aparienciaLabel,
                            color: AppColors.blue,
                            icon: '◐',
                            onTap: () async {
                              final uid = await _getUid();
                              await Navigator.push(
                                context,
                                slideRoute(AparienciaScreen(
                                  selected: _vm.apariencia,
                                  accent: accent,
                                  onSave: (a) async {
                                    if (uid != null) {
                                      await AppPrefsNotifier.instance
                                          .setTema(uid, a);
                                    }
                                    if (mounted) setState(() {});
                                  },
                                )),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                          _SettingsItem(
                            title: L10n.t('Unidades'),
                            sub: '${_vm.distancia} · ${_vm.hora}',
                            color: AppColors.cyan,
                            icon: '△',
                            onTap: () async {
                              final uid = await _getUid();
                              await Navigator.push(
                                context,
                                slideRoute(UnidadesScreen(
                                  distancia: _vm.distancia,
                                  hora: _vm.hora,
                                  accent: accent,
                                  onSave: (d, h) async {
                                    if (uid != null) {
                                      await AppPrefsNotifier.instance
                                          .setDistancia(uid, d);
                                      await AppPrefsNotifier.instance
                                          .setHora(uid, h);
                                    }
                                    if (mounted) setState(() {});
                                  },
                                )),
                              );
                              if (mounted) setState(() {});
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Legal
                      _Section(
                        header: L10n.t('Legal'),
                        items: [
                          _SettingsItem(
                            title: L10n.t('Política de privacidad'),
                            color: AppColors.textMute,
                            icon: '§',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(const PoliticaPrivacidadScreen()),
                            ),
                          ),
                          _SettingsItem(
                            title: L10n.t('Términos y condiciones'),
                            color: AppColors.textMute,
                            icon: '§',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(const TerminosCondicionesScreen()),
                            ),
                          ),
                          _SettingsItem(
                            title: L10n.t('Cerrar sesión'),
                            color: AppColors.pink,
                            icon: '⎋',
                            danger: true,
                            onTap: _vm.logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Brawl TCG · v1.4.2',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(
                              fontSize: 10.5, color: AppColors.textMute)),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const BrawlNavBarSpacer(),
            ],
          ),
        ),
      ),
    );
  }

  String? _getUid() => FirebaseAuth.instance.currentUser?.uid;
}

// ─── Modelos de fila ─────────────────────────────────────────────────────────

class _SettingsItem {
  final String title, icon;
  final String? sub;
  final Color color;
  final bool danger;
  final VoidCallback? onTap;
  const _SettingsItem(
      {required this.title,
      required this.icon,
      this.sub,
      required this.color,
      this.danger = false,
      this.onTap});
}

class _ToggleItem {
  final String title, sub, icon, key;
  final Color color;
  const _ToggleItem(
      {required this.title,
      required this.sub,
      required this.icon,
      required this.key,
      required this.color});
}

// ─── Sección de ajustes con flechas ──────────────────────────────────────────

class _Section extends StatelessWidget {
  final String header;
  final List<_SettingsItem> items;
  const _Section({required this.header, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(header, margin: const EdgeInsets.only(left: 4, bottom: 10)),
        BrawlCard(
          padding: EdgeInsets.zero,
          radius: 18,
          child: Column(
            children: List.generate(items.length, (i) {
              final r = items[i];
              return GestureDetector(
                onTap: r.onTap,
                child: Container(
                  decoration: BoxDecoration(
                    border: i < items.length - 1
                        ? Border(
                            bottom: BorderSide(color: AppColors.stroke))
                        : null,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: r.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                                color: r.color.withValues(alpha: 0.2)),
                          ),
                          child: Center(
                            child: Text(r.icon,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: r.color)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(r.title,
                                  style: GoogleFonts.rubik(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: r.danger
                                          ? AppColors.pink
                                          : AppColors.text)),
                              if (r.sub != null)
                                Text(r.sub!,
                                    style: GoogleFonts.rubik(
                                        fontSize: 11,
                                        color: AppColors.textMute)),
                            ],
                          ),
                        ),
                        Text('›',
                            style: TextStyle(
                                fontSize: 16, color: AppColors.textMute)),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Skeleton de carga para ciudades ─────────────────────────────────────────

class _CiudadLoadingSection extends StatelessWidget {
  final List<Color> accent;
  const _CiudadLoadingSection({required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel('Notificaciones por ciudad',
            margin: const EdgeInsets.only(left: 4, bottom: 10)),
        BrawlCard(
          padding: const EdgeInsets.all(18),
          radius: 18,
          child: Center(
            child: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: accent.first,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Sección con toggles animados ────────────────────────────────────────────

class _ToggleSection extends StatelessWidget {
  final String header;
  final List<_ToggleItem> items;
  final Map<String, bool> toggles;
  final void Function(String, bool) onToggle;
  final List<Color> accent;
  const _ToggleSection(
      {required this.header,
      required this.items,
      required this.toggles,
      required this.onToggle,
      required this.accent});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(header, margin: const EdgeInsets.only(left: 4, bottom: 10)),
        BrawlCard(
          padding: EdgeInsets.zero,
          radius: 18,
          child: Column(
            children: List.generate(items.length, (i) {
              final r = items[i];
              final isOn = toggles[r.key] ?? false;
              return Container(
                decoration: BoxDecoration(
                  border: i < items.length - 1
                      ? Border(bottom: BorderSide(color: AppColors.stroke))
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
                  child: Row(
                    children: [
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: r.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(9),
                          border: Border.all(
                              color: r.color.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(r.icon,
                              style:
                                  TextStyle(fontSize: 13, color: r.color)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(r.title,
                                style: GoogleFonts.rubik(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.text)),
                            Text(r.sub,
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: AppColors.textMute)),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onToggle(r.key, !isOn),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 38,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient:
                                isOn ? LinearGradient(colors: accent) : null,
                            color: isOn ? null : AppColors.surfaceHi,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Stack(
                            children: [
                              AnimatedPositioned(
                                duration: const Duration(milliseconds: 200),
                                top: 2,
                                left: isOn ? null : 2,
                                right: isOn ? 2 : null,
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
              );
            }),
          ),
        ),
      ],
    );
  }
}

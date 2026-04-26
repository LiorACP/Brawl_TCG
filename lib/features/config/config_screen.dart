import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/screens/cliente/Login.dart';
import 'widgets/datos_personales_screen.dart';
import 'widgets/contrasena_seguridad_screen.dart';
import 'widgets/juegos_favoritos_screen.dart';
import 'widgets/idioma_screen.dart';
import 'widgets/apariencia_screen.dart';
import 'widgets/unidades_screen.dart';
import 'widgets/politica_privacidad_screen.dart';
import 'widgets/terminos_condiciones_screen.dart';
import '../eventos/services/eventos_service.dart';

class SharedConfigScreen extends StatefulWidget {
  final bool isOrg;
  const SharedConfigScreen({super.key, this.isOrg = false});

  @override
  State<SharedConfigScreen> createState() => _SharedConfigScreenState();
}

class _SharedConfigScreenState extends State<SharedConfigScreen> {
  late bool _isOrg;

  final Map<String, bool> _toggles = {
    'Torneos próximos': true,
    'Nuevos eventos cerca': true,
    'Resultados y emparejamiento': true,
    'Promociones de tiendas': false,
  };

  Map<String, bool> _ciudadToggles = {};
  bool _loadingCiudades = true;

  // Datos del perfil del usuario cargados desde Firestore
  String _nombre = '';
  String _email = '';
  String _telefono = '';
  String _localidad = '';
  String _joinYear = '';
  Set<String> _selectedGames = {'MTG', 'POK', 'YGO'};

  // Preferencias de la app (idioma, tema, etc.)
  String _idioma = 'es';
  String _apariencia = 'dark';
  String _distancia = 'km';
  String _hora = '24h';

  @override
  void initState() {
    super.initState();
    _isOrg = widget.isOrg;
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _loadingCiudades = false);
      return;
    }

    final creationTime = FirebaseAuth.instance.currentUser?.metadata.creationTime;
    final authEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance.collection('User').doc(uid).get();
      final data = doc.data();
      if (!mounted) return;

      final localidad = data?['localidad'] as String? ?? '';
      final savedNotifCiudades =
          data?['notifCiudades'] as Map<String, dynamic>? ?? {};

      setState(() {
        _nombre = data?['name'] as String? ?? '';
        _email = data?['email'] as String? ?? authEmail;
        _telefono = data?['telefono'] as String? ?? '';
        _joinYear = creationTime != null ? creationTime.year.toString() : '';
        _localidad = localidad;
      });

      _loadCiudadesNotif(uid, localidad, savedNotifCiudades);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _email = authEmail;
        _joinYear = creationTime != null ? creationTime.year.toString() : '';
        _loadingCiudades = false;
      });
    }
  }

  Future<void> _loadCiudadesNotif(
      String uid, String localidad, Map<String, dynamic> savedPrefs) async {
    try {
      final cities = await EventosService.fetchUserCities(uid);
      if (localidad.isNotEmpty) cities.add(localidad);

      final toggles = <String, bool>{};
      for (final city in cities) {
        toggles[city] = savedPrefs[city] as bool? ?? true;
      }

      if (!mounted) return;
      setState(() {
        _ciudadToggles = toggles;
        _loadingCiudades = false;
      });
    } catch (_) {
      if (!mounted) return;
      final toggles = <String, bool>{};
      if (localidad.isNotEmpty) {
        toggles[localidad] = savedPrefs[localidad] as bool? ?? true;
      }
      setState(() {
        _ciudadToggles = toggles;
        _loadingCiudades = false;
      });
    }
  }

  Future<void> _saveCiudadToggle(String city, bool value) async {
    setState(() => _ciudadToggles[city] = value);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance
        .collection('User')
        .doc(uid)
        .update({'notifCiudades.$city': value});
  }

  Future<void> _savePersonalData(String nombre, String email, String telefono) async {
    setState(() {
      _nombre = nombre;
      _email = email;
      _telefono = telefono;
    });
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await FirebaseFirestore.instance.collection('User').doc(uid).update({
      'name': nombre,
      'email': email,
      if (telefono.isNotEmpty) 'telefono': telefono,
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      fadeSlideRoute(const Login()),
      (route) => false,
    );
  }

  String get _idiomaLabel => _idioma == 'es' ? 'Español (España)' : 'English (UK)';
  String get _aparienciaLabel => _apariencia == 'dark' ? 'Oscuro' : 'Claro';

  @override
  Widget build(BuildContext context) {
    final accent = _isOrg ? AppColors.organizadorGradient : AppColors.clienteGradient;

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
                    Text('Configuración',
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
                      // Tarjeta de perfil con foto y nombre
                      BrawlCard(
                        padding: const EdgeInsets.all(18),
                        radius: 24,
                        tint: const Color(0xFF0F0C1A),
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
                                  Text(_nombre,
                                      style: GoogleFonts.rubik(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text(
                                      [
                                        if (_nombre.isNotEmpty)
                                          '@${_nombre.split(' ').first.toLowerCase()}',
                                        if (_joinYear.isNotEmpty)
                                          'desde $_joinYear',
                                      ].join(' · '),
                                      style: GoogleFonts.rubik(
                                          fontSize: 12, color: AppColors.textDim)),
                                  const SizedBox(height: 6),
                                  if (_isOrg)
                                    BrawlTag(
                                        label: 'Organizador',
                                        color: AppColors.magenta),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                slideRoute(DatosPersonalesScreen(
                                  nombre: _nombre,
                                  email: _email,
                                  telefono: _telefono,
                                  accent: accent,
                                  onSave: _savePersonalData,
                                )),
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.stroke),
                                ),
                                child: Text('Editar',
                                    style: GoogleFonts.rubik(
                                        fontSize: 12, color: AppColors.textDim)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Sección de cuenta (email, contraseña...)
                      _Section(
                        header: 'Cuenta',
                        items: [
                          _SettingsItem(
                            title: 'Datos personales',
                            sub: '$_nombre · $_email',
                            color: AppColors.cyan,
                            icon: 'i',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(DatosPersonalesScreen(
                                nombre: _nombre,
                                email: _email,
                                telefono: _telefono,
                                accent: accent,
                                onSave: _savePersonalData,
                              )),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Contraseña y seguridad',
                            sub: '2FA desactivado',
                            color: AppColors.violet,
                            icon: '⚿',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(ContrasenaSeguridadScreen(
                                  accent: accent, email: _email)),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Mis juegos favoritos',
                            sub: '${_selectedGames.length} seleccionados',
                            color: AppColors.pink,
                            icon: '♥',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(JuegosFavoritosScreen(
                                selected: _selectedGames,
                                accent: accent,
                                onSave: (games) =>
                                    setState(() => _selectedGames = games),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Sección de notificaciones generales
                      _ToggleSection(
                        header: 'Notificaciones',
                        items: [
                          _ToggleItem(
                              title: 'Torneos próximos',
                              sub: 'Push · 2h antes',
                              color: AppColors.cyan,
                              icon: '⏰',
                              key: 'Torneos próximos'),
                          _ToggleItem(
                              title: 'Nuevos eventos cerca',
                              sub: 'Radio 10 km',
                              color: AppColors.orange,
                              icon: '◉',
                              key: 'Nuevos eventos cerca'),
                          _ToggleItem(
                              title: 'Resultados y emparejamiento',
                              sub: 'En tiempo real',
                              color: AppColors.pink,
                              icon: '⚔',
                              key: 'Resultados y emparejamiento'),
                          _ToggleItem(
                              title: 'Promociones de tiendas',
                              sub: 'Semanal',
                              color: AppColors.yellow,
                              icon: '✦',
                              key: 'Promociones de tiendas'),
                        ],
                        toggles: _toggles,
                        onToggle: (k, v) => setState(() => _toggles[k] = v),
                        accent: accent,
                      ),
                      const SizedBox(height: 18),

                      // Toggles para activar notificaciones por ciudad
                      const SizedBox(height: 18),
                      if (_loadingCiudades)
                        _CiudadLoadingSection(accent: accent)
                      else if (_ciudadToggles.isNotEmpty)
                        _ToggleSection(
                          header: 'Notificaciones por ciudad',
                          items: _ciudadToggles.keys
                              .map((city) => _ToggleItem(
                                    title: city,
                                    sub: 'Eventos en $city',
                                    icon: '◎',
                                    key: city,
                                    color: AppColors.orange,
                                  ))
                              .toList(),
                          toggles: _ciudadToggles,
                          onToggle: _saveCiudadToggle,
                          accent: accent,
                        ),
                      const SizedBox(height: 18),

                      // Sección de preferencias de la app
                      _Section(
                        header: 'Preferencias',
                        items: [
                          _SettingsItem(
                            title: 'Idioma',
                            sub: _idiomaLabel,
                            color: AppColors.violet,
                            icon: '🌐',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(IdiomaScreen(
                                selected: _idioma,
                                accent: accent,
                                onSave: (lang) =>
                                    setState(() => _idioma = lang),
                              )),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Apariencia',
                            sub: _aparienciaLabel,
                            color: AppColors.blue,
                            icon: '◐',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(AparienciaScreen(
                                selected: _apariencia,
                                accent: accent,
                                onSave: (a) =>
                                    setState(() => _apariencia = a),
                              )),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Unidades',
                            sub: '$_distancia · $_hora',
                            color: AppColors.cyan,
                            icon: '△',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(UnidadesScreen(
                                distancia: _distancia,
                                hora: _hora,
                                accent: accent,
                                onSave: (d, h) => setState(() {
                                  _distancia = d;
                                  _hora = h;
                                }),
                              )),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Sección legal y de privacidad
                      _Section(
                        header: 'Legal',
                        items: [
                          _SettingsItem(
                            title: 'Política de privacidad',
                            color: AppColors.textMute,
                            icon: '§',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(const PoliticaPrivacidadScreen()),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Términos y condiciones',
                            color: AppColors.textMute,
                            icon: '§',
                            onTap: () => Navigator.push(
                              context,
                              slideRoute(const TerminosCondicionesScreen()),
                            ),
                          ),
                          _SettingsItem(
                            title: 'Cerrar sesión',
                            color: AppColors.pink,
                            icon: '⎋',
                            danger: true,
                            onTap: _logout,
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
}

// Widget reutilizable para filas de configuración
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

// Widget para filas con switch
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

// Título de sección con línea separadora
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

// Sección de ciudades con esqueleto de carga
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

// Sección con lista de toggles
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
                          border:
                              Border.all(color: r.color.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(r.icon,
                              style: TextStyle(fontSize: 13, color: r.color)),
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
                                    fontSize: 11, color: AppColors.textMute)),
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

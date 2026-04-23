import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/shell/cliente_shell.dart';
import 'package:brawl_tcg/shell/org_shell.dart';
import 'package:brawl_tcg/features/auth/login_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _isOrg = widget.isOrg;
  }

  void _switchToCliente() {
    Navigator.pushAndRemoveUntil(
      context,
      fadeSlideRoute(const ClienteShell()),
      (route) => false,
    );
  }

  void _switchToOrg() {
    Navigator.pushAndRemoveUntil(
      context,
      fadeSlideRoute(const OrgShell()),
      (route) => false,
    );
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      fadeSlideRoute(const Login()),
      (route) => false,
    );
  }

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
                            fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.text)),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    children: [
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
                                  Text('Marco Ferrer',
                                      style: GoogleFonts.rubik(
                                          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.text)),
                                  const SizedBox(height: 2),
                                  Text('@marco · desde 2023',
                                      style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      BrawlTag(label: 'Cliente', color: AppColors.cyan),
                                      if (_isOrg) ...[
                                        const SizedBox(width: 6),
                                        BrawlTag(label: 'Organizador', color: AppColors.magenta),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.stroke),
                              ),
                              child: Text('Editar',
                                  style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textDim)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      BrawlCard(
                        padding: const EdgeInsets.all(4),
                        radius: 18,
                        child: Row(
                          children: [
                            _RoleTab(
                              label: 'Cliente',
                              active: !_isOrg,
                              gradient: AppColors.clienteGradient,
                              onTap: () {
                                if (_isOrg) _switchToCliente();
                              },
                            ),
                            _RoleTab(
                              label: 'Organizador',
                              active: _isOrg,
                              gradient: AppColors.organizadorGradient,
                              onTap: () {
                                if (!_isOrg) _switchToOrg();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        header: 'Cuenta',
                        items: const [
                          _SettingsItem(
                              title: 'Datos personales',
                              sub: 'Nombre, email, teléfono',
                              color: AppColors.cyan,
                              icon: 'i'),
                          _SettingsItem(
                              title: 'Contraseña y seguridad',
                              sub: '2FA activado',
                              color: AppColors.violet,
                              icon: '⚿'),
                          _SettingsItem(
                              title: 'Mis juegos favoritos',
                              sub: '3 seleccionados',
                              color: AppColors.pink,
                              icon: '♥'),
                        ],
                      ),
                      const SizedBox(height: 18),
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
                      _Section(
                        header: 'Preferencias',
                        items: const [
                          _SettingsItem(
                              title: 'Idioma', sub: 'Español (España)', color: AppColors.violet, icon: '🌐'),
                          _SettingsItem(
                              title: 'Apariencia', sub: 'Oscuro', color: AppColors.blue, icon: '◐'),
                          _SettingsItem(
                              title: 'Unidades', sub: 'Kilómetros · 24h', color: AppColors.cyan, icon: '△'),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _Section(
                        header: 'Legal',
                        items: [
                          _SettingsItem(
                              title: 'Política de privacidad', color: AppColors.textMute, icon: '§'),
                          _SettingsItem(
                              title: 'Términos y condiciones', color: AppColors.textMute, icon: '§'),
                          _SettingsItem(
                              title: 'Cerrar sesión',
                              color: AppColors.pink,
                              icon: '⎋',
                              danger: true,
                              onTap: _logout),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Brawl TCG · v1.4.2',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.rubik(fontSize: 10.5, color: AppColors.textMute)),
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

class _RoleTab extends StatelessWidget {
  final String label;
  final bool active;
  final List<Color> gradient;
  final VoidCallback onTap;
  const _RoleTab(
      {required this.label, required this.active, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 42,
          decoration: BoxDecoration(
            gradient: active ? LinearGradient(colors: gradient) : null,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(label,
                style: GoogleFonts.rubik(
                    fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

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
                            border: Border.all(color: r.color.withValues(alpha: 0.2)),
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
                                      color: r.danger ? AppColors.pink : AppColors.text)),
                              if (r.sub != null)
                                Text(r.sub!,
                                    style:
                                        GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute)),
                            ],
                          ),
                        ),
                        Text('›', style: TextStyle(fontSize: 16, color: AppColors.textMute)),
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
                          border: Border.all(color: r.color.withValues(alpha: 0.2)),
                        ),
                        child: Center(
                          child: Text(r.icon, style: TextStyle(fontSize: 13, color: r.color)),
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
                            gradient: isOn ? LinearGradient(colors: accent) : null,
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
            }),
          ),
        ),
      ],
    );
  }
}

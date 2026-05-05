import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'services/tienda_service.dart';

class OrgTiendaScreen extends StatefulWidget {
  const OrgTiendaScreen({super.key});

  @override
  State<OrgTiendaScreen> createState() => _OrgTiendaScreenState();
}

class _OrgTiendaScreenState extends State<OrgTiendaScreen> {
  bool _editMode = false;
  bool _saving = false;

  final _nameCtrl      = TextEditingController();
  final _addressCtrl   = TextEditingController();
  final _foundedCtrl   = TextEditingController();
  final _horariosCtrl  = TextEditingController();
  final _juegosCtrl    = TextEditingController();
  final _capacidadCtrl = TextEditingController();
  final _redesCtrl     = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    _foundedCtrl.dispose();
    _horariosCtrl.dispose();
    _juegosCtrl.dispose();
    _capacidadCtrl.dispose();
    _redesCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    TiendaService.watchProfile().first.then((data) {
      if (!mounted) return;
      _nameCtrl.text      = data['storeName']          as String? ?? '';
      _addressCtrl.text   = data['storeAddress']       as String? ?? '';
      _foundedCtrl.text   = (data['storeFoundedYear']  as int?)?.toString() ?? '';
      _horariosCtrl.text  = data['storeHorarios']      as String? ?? '';
      _juegosCtrl.text    = data['storeJuegos']        as String? ?? '';
      _capacidadCtrl.text = data['storeCapacidad']     as String? ?? '';
      _redesCtrl.text     = data['storeRedesSociales'] as String? ?? '';
      setState(() {});
    });
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await TiendaService.saveProfile({
      'storeName':          _nameCtrl.text.trim(),
      'storeAddress':       _addressCtrl.text.trim(),
      'storeFoundedYear':   int.tryParse(_foundedCtrl.text.trim()),
      'storeHorarios':      _horariosCtrl.text.trim(),
      'storeJuegos':        _juegosCtrl.text.trim(),
      'storeCapacidad':     _capacidadCtrl.text.trim(),
      'storeRedesSociales': _redesCtrl.text.trim(),
    });
    if (mounted) setState(() { _saving = false; _editMode = false; });
  }

  String get _subtitle {
    final addr    = _addressCtrl.text.trim();
    final founded = _foundedCtrl.text.trim();
    if (addr.isEmpty && founded.isEmpty) return '';
    if (founded.isEmpty) return addr;
    if (addr.isEmpty) return 'Desde $founded';
    return '$addr · Desde $founded';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 41,
        child: SafeArea(
          child: Column(
            children: [
              // ── Cabecera ────────────────────────────────────────────────
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, left: -40,
                      child: _GradBlob(size: 280, colors: AppColors.clienteGradient),
                    ),
                    Positioned(
                      bottom: 20, right: -30,
                      child: _GradBlob(size: 150, colors: [AppColors.orange, AppColors.pink]),
                    ),
                    // Botón editar / guardar
                    Positioned(
                      top: 8, right: 22,
                      child: _saving
                          ? const SizedBox(
                              width: 38, height: 38,
                              child: Center(
                                child: SizedBox(
                                  width: 18, height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          : _GlassBtn(
                              onTap: _editMode ? _save : () => setState(() => _editMode = true),
                              iconWidget: Icon(
                                _editMode ? Icons.check : Icons.edit_outlined,
                                size: 16, color: Colors.white,
                              ),
                            ),
                    ),
                    // Nombre y subtítulo
                    Positioned(
                      bottom: 16, left: 22, right: 70,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _editMode
                              ? _HeaderField(
                                  controller: _nameCtrl,
                                  hint: 'Nombre de tu tienda',
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                )
                              : _PlaceholderText(
                                  value: _nameCtrl.text,
                                  placeholder: 'Nombre de tu tienda',
                                  style: GoogleFonts.rubik(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                          const SizedBox(height: 4),
                          _editMode
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _HeaderField(
                                      controller: _addressCtrl,
                                      hint: 'Dirección',
                                      fontSize: 13,
                                    ),
                                    const SizedBox(height: 4),
                                    _HeaderField(
                                      controller: _foundedCtrl,
                                      hint: 'Año de apertura',
                                      fontSize: 13,
                                      keyboardType: TextInputType.number,
                                    ),
                                  ],
                                )
                              : _PlaceholderText(
                                  value: _subtitle,
                                  placeholder: 'Dirección · Año de apertura',
                                  style: GoogleFonts.rubik(
                                    fontSize: 13,
                                    color: AppColors.textDim,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Cuerpo scrollable ────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stat torneos (desde Firestore)
                      StreamBuilder<int>(
                        stream: TiendaService.watchTorneosCount(),
                        builder: (context, snap) {
                          return SizedBox(
                            width: double.infinity,
                            child: _StatTile(
                              icon: '◈',
                              number: snap.hasData ? snap.data!.toString() : '…',
                              label: 'Torneos',
                            ),
                          );
                        },
                      ),
                      const SectionLabel('Administración'),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 4 : 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: isWide ? 1.6 : 1.4,
                            children: [
                              _AdminTile(
                                icon: '⏱',
                                title: 'Horarios',
                                controller: _horariosCtrl,
                                hint: 'Ej: Lun–Dom 10h–22h',
                                color: AppColors.cyan,
                                editMode: _editMode,
                              ),
                              _AdminTile(
                                icon: '⬢',
                                title: 'Productos vendidos',
                                controller: _juegosCtrl,
                                hint: 'Ej: Cartas · Sobres · Accesorios',
                                color: AppColors.violet,
                                editMode: _editMode,
                              ),
                              _AdminTile(
                                icon: '⬡',
                                title: 'Capacidad',
                                controller: _capacidadCtrl,
                                hint: 'Ej: 40 jugadores · 20 mesas',
                                color: AppColors.orange,
                                editMode: _editMode,
                              ),
                              _AdminTile(
                                icon: '◉',
                                title: 'Redes sociales',
                                controller: _redesCtrl,
                                hint: 'Instagram · Twitter · Discord',
                                color: AppColors.pink,
                                editMode: _editMode,
                              ),
                            ],
                          );
                        },
                      ),
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

// ── Texto con placeholder muted ───────────────────────────────────────────────

class _PlaceholderText extends StatelessWidget {
  final String value;
  final String placeholder;
  final TextStyle style;

  const _PlaceholderText({
    required this.value,
    required this.placeholder,
    required this.style,
  });

  @override
  Widget build(BuildContext context) {
    final isEmpty = value.isEmpty;
    return Text(
      isEmpty ? placeholder : value,
      style: style.copyWith(
        color: isEmpty ? AppColors.textMute.withValues(alpha: 0.5) : style.color,
      ),
    );
  }
}

// ── Campo editable en la cabecera ─────────────────────────────────────────────

class _HeaderField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final double fontSize;
  final FontWeight fontWeight;
  final TextInputType keyboardType;

  const _HeaderField({
    required this.controller,
    required this.hint,
    required this.fontSize,
    this.fontWeight = FontWeight.w400,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.rubik(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: AppColors.text,
        letterSpacing: fontSize > 20 ? -0.6 : 0,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.rubik(
          fontSize: fontSize,
          fontWeight: fontWeight,
          color: AppColors.textMute.withValues(alpha: 0.5),
          letterSpacing: fontSize > 20 ? -0.6 : 0,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}

// ── Tile de administración editable ──────────────────────────────────────────

class _AdminTile extends StatelessWidget {
  final String icon;
  final String title;
  final TextEditingController controller;
  final String hint;
  final Color color;
  final bool editMode;

  const _AdminTile({
    required this.icon,
    required this.title,
    required this.controller,
    required this.hint,
    required this.color,
    required this.editMode,
  });

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(icon, style: TextStyle(fontSize: 16, color: color)),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.rubik(
              fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text,
            ),
          ),
          const SizedBox(height: 2),
          editMode
              ? TextField(
                  controller: controller,
                  style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textDim, height: 1.3),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: GoogleFonts.rubik(
                      fontSize: 11,
                      color: AppColors.textMute.withValues(alpha: 0.5),
                      height: 1.3,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                )
              : _PlaceholderText(
                  value: controller.text,
                  placeholder: hint,
                  style: GoogleFonts.rubik(
                    fontSize: 11, color: AppColors.textDim, height: 1.3,
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Stat tile ─────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  final String icon, number, label;
  const _StatTile({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      padding: const EdgeInsets.all(12),
      radius: 16,
      child: Column(
        children: [
          Text(icon, style: TextStyle(fontSize: 11, color: AppColors.textMute)),
          const SizedBox(height: 2),
          GradText(
            text: number,
            gradient: AppColors.organizadorGradient,
            style: GoogleFonts.rubikMonoOne(fontSize: 20, color: Colors.white),
          ),
          const SizedBox(height: 1),
          Text(
            label.toUpperCase(),
            style: GoogleFonts.rubik(
              fontSize: 10, color: AppColors.textMute, letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Gradiente blob ────────────────────────────────────────────────────────────

class _GradBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _GradBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors[0].withValues(alpha: 0.7),
            colors.last.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

// ── Botón de cristal ──────────────────────────────────────────────────────────

class _GlassBtn extends StatelessWidget {
  final Widget iconWidget;
  final VoidCallback onTap;
  const _GlassBtn({required this.iconWidget, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: const Color(0xB2100A19),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.stroke),
        ),
        child: Center(child: iconWidget),
      ),
    );
  }
}

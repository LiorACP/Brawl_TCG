import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/shell/org_shell.dart';

class OrgAnunciosScreen extends StatefulWidget {
  final bool isCreationFlow;
  final String? eventId;

  const OrgAnunciosScreen({
    super.key,
    this.isCreationFlow = false,
    this.eventId,
  });

  @override
  State<OrgAnunciosScreen> createState() => _OrgAnunciosScreenState();
}

class _OrgAnunciosScreenState extends State<OrgAnunciosScreen> {
  final _textController = TextEditingController();
  final _codeController = TextEditingController();
  bool _isSaving = false;
  bool _loading = true;

  // Datos del torneo cargados desde Firestore para mostrar en el resumen
  String _eventName = '';
  String _dateTimeLabel = '';
  String _gameCode = 'MTG';
  int _plazas = 0;
  double _entryFee = 0;
  int _enrolledCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isCreationFlow && widget.eventId != null) {
      _loadEvent();
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadEvent() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(widget.eventId)
          .get();
      final d = doc.data() ?? {};

      final timestamp = d['date'] as Timestamp?;
      final date = timestamp?.toDate();

      final ruleSet = d['rule_set'] as String? ?? '';
      final gameCode = _parseGameCode(ruleSet);

      setState(() {
        _eventName = d['name'] as String? ?? '';
        _dateTimeLabel = date != null ? _formatDateTime(date) : '';
        _gameCode = gameCode;
        _plazas = (d['participants'] as num?)?.toInt() ?? 0;
        _entryFee = (d['entryFee'] as num?)?.toDouble() ?? 0;
        _enrolledCount = (d['enrolledCount'] as num?)?.toInt() ?? 0;
        _loading = false;
      });
      // Si estamos editando relleno los campos con los datos que ya había
      _textController.text = d['announcementText'] as String? ?? '';
      _codeController.text = d['accessCode'] as String? ?? '';
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  static String _parseGameCode(String ruleSet) {
    final s = ruleSet.toLowerCase();
    if (s.contains('magic') || s.contains('mtg')) return 'MTG';
    if (s.contains('pokémon') || s.contains('pokemon')) return 'POK';
    if (s.contains('yu-gi-oh') || s.contains('yugioh') || s.contains('ygo')) return 'YGO';
    if (s.contains('lorcana') || s.contains('disney')) return 'LRC';
    if (s.contains('flesh') || s.contains('blood')) return 'FAB';
    if (s.contains('one piece')) return 'ONE';
    if (s.contains('dragon ball')) return 'DBS';
    return 'MTG';
  }

  static const _codeChars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';

  void _generateCode() {
    final rng = Random.secure();
    final code = List.generate(
        6, (_) => _codeChars[rng.nextInt(_codeChars.length)]).join();
    _codeController.text = code;
  }

  static String _formatDateTime(DateTime d) {
    const weekdays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];
    final h = d.hour.toString().padLeft(2, '0');
    final m = d.minute.toString().padLeft(2, '0');
    return '${weekdays[d.weekday - 1]} · $h:$m';
  }

  Future<void> _saveDraft() async {
    if (widget.eventId == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(widget.eventId)
          .update({
        'announcementText': _textController.text.trim(),
        if (_codeController.text.trim().isNotEmpty)
          'accessCode': _codeController.text.trim(),
      });
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _saveChanges() async {
    if (widget.eventId == null) return;
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(widget.eventId)
          .update({
        'announcementText': _textController.text.trim(),
        if (_codeController.text.trim().isNotEmpty)
          'accessCode': _codeController.text.trim(),
      });
      if (!mounted) return;
      Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _publish() async {
    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection('Tournaments')
          .doc(widget.eventId)
          .update({
        'status': 'Pending',
        'announcementText': _textController.text.trim(),
        if (_codeController.text.trim().isNotEmpty)
          'accessCode': _codeController.text.trim(),
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrgShell()),
        (_) => false,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al publicar el torneo')),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    _codeController.dispose();
    super.dispose();
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
                            onTap: _isSaving ? null : _saveDraft,
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
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Resumen del torneo encima del formulario
                            if (widget.isCreationFlow)
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
                                          Positioned(
                                            top: 14,
                                            left: 16,
                                            child: GameBadge(game: _gameCode, size: 34),
                                          ),
                                          Positioned(
                                            bottom: 14,
                                            left: 16,
                                            right: 16,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _dateTimeLabel,
                                                  style: GoogleFonts.rubik(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.yellow,
                                                      letterSpacing: 0.6),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _eventName,
                                                  style: GoogleFonts.rubik(
                                                      fontSize: 22,
                                                      fontWeight: FontWeight.w800,
                                                      color: AppColors.text,
                                                      letterSpacing: -0.3),
                                                ),
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
                                          Text(
                                            '$_plazas plazas · ${_entryFee % 1 == 0 ? _entryFee.toInt() : _entryFee} €',
                                            style: GoogleFonts.rubik(
                                                fontSize: 12, color: AppColors.textDim),
                                          ),
                                          Text(
                                            '$_enrolledCount/$_plazas',
                                            style: GoogleFonts.rubik(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.cyan),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const SizedBox(height: 14),
                            // Campo para escribir el texto del anuncio
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
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: _textController,
                                    maxLines: 6,
                                    maxLength: 280,
                                    style: GoogleFonts.rubik(
                                        fontSize: 13.5,
                                        color: AppColors.text,
                                        height: 1.45),
                                    cursorColor: AppColors.violet,
                                    decoration: InputDecoration(
                                      hintText:
                                          '¡Vuelve el torneo! Escribe aquí el texto del anuncio...',
                                      hintStyle: GoogleFonts.rubik(
                                          fontSize: 13.5,
                                          color: AppColors.textMute,
                                          height: 1.45),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                      counterStyle: GoogleFonts.rubik(
                                          fontSize: 11, color: AppColors.textMute),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            // Código de 6 dígitos para que los jugadores se unan
                            BrawlCard(
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('CÓDIGO DE INSCRIPCIÓN',
                                      style: GoogleFonts.rubik(
                                          fontSize: 10.5,
                                          color: AppColors.textMute,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5)),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                                color: AppColors.stroke),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          alignment: Alignment.centerLeft,
                                          child: TextField(
                                            controller: _codeController,
                                            maxLength: 6,
                                            textCapitalization:
                                                TextCapitalization.characters,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[a-zA-Z0-9]')),
                                              TextInputFormatter.withFunction(
                                                  (_, v) => v.copyWith(
                                                      text: v.text
                                                          .toUpperCase())),
                                            ],
                                            style: GoogleFonts.rubikMonoOne(
                                              fontSize: 20,
                                              color: AppColors.text,
                                              letterSpacing: 6,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '······',
                                              hintStyle: GoogleFonts.rubikMonoOne(
                                                fontSize: 20,
                                                color: AppColors.textMute,
                                                letterSpacing: 6,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                              counterText: '',
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: _generateCode,
                                        child: Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                                colors:
                                                    AppColors.organizadorGradient),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('⚡',
                                                  style:
                                                      TextStyle(fontSize: 13)),
                                              const SizedBox(width: 5),
                                              Text('Generar',
                                                  style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Los jugadores usarán este código para inscribirse.',
                                    style: GoogleFonts.rubik(
                                        fontSize: 11,
                                        color: AppColors.textMute),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 80),
                          ],
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: _isSaving
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : GradBtn(
                        size: GradBtnSize.lg,
                        gradient: AppColors.organizadorGradient,
                        width: double.infinity,
                        onTap: widget.isCreationFlow ? _publish : _saveChanges,
                        child: Text(widget.isCreationFlow
                            ? 'Publicar ahora ✦'
                            : 'Guardar cambios'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';

class ClienteCodigoScreen extends StatefulWidget {
  const ClienteCodigoScreen({super.key});

  @override
  State<ClienteCodigoScreen> createState() => _ClienteCodigoScreenState();
}

class _ClienteCodigoScreenState extends State<ClienteCodigoScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  bool _searching = false;
  bool _enrolling = false;
  String _code = '';

  DocumentSnapshot<Map<String, dynamic>>? _tournamentDoc;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000))
      ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.25, end: 0.8).animate(_pulseController);
    _controller.addListener(_onInput);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onInput() {
    final raw =
        _controller.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final trimmed = raw.length > 6 ? raw.substring(0, 6) : raw;
    if (trimmed != _controller.text) {
      _controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
      return;
    }
    if (trimmed != _code) {
      setState(() {
        _code = trimmed;
        _tournamentDoc = null;
        _errorMsg = null;
      });
      if (trimmed.length == 6 && !_searching) _searchTournament(trimmed);
    }
  }

  static String _parseFormat(String? ruleSet) {
    if (ruleSet == null) return '';
    final dot = ruleSet.indexOf('.');
    if (dot >= 0 && dot < ruleSet.length - 1) {
      return ruleSet.substring(dot + 1).trim();
    }
    return ruleSet.trim();
  }

  static bool _requiresDeck(String? ruleSet) {
    final format = _parseFormat(ruleSet).toLowerCase();
    return !['draft', 'sealed', 'sealed battle'].contains(format);
  }

  static String _gameCodeFromRuleSet(String? ruleSet) {
    final s = (ruleSet ?? '').toLowerCase();
    if (s.contains('magic') || s.contains('mtg')) return 'MTG';
    if (s.contains('pokémon') || s.contains('pokemon')) return 'POK';
    if (s.contains('yu-gi-oh') || s.contains('yugioh') || s.contains('ygo')) return 'YGO';
    if (s.contains('lorcana') || s.contains('disney')) return 'LRC';
    if (s.contains('flesh') || s.contains('blood')) return 'FAB';
    if (s.contains('one piece')) return 'ONE';
    if (s.contains('dragon ball')) return 'DBS';
    return 'MTG';
  }

  Future<void> _searchTournament(String code) async {
    setState(() => _searching = true);
    HapticFeedback.mediumImpact();
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Tournaments')
          .where('accessCode', isEqualTo: code)
          .limit(1)
          .get();

      if (!mounted) return;
      if (snap.docs.isEmpty) {
        setState(() {
          _errorMsg = 'Código no encontrado';
          _searching = false;
        });
      } else {
        setState(() {
          _tournamentDoc = snap.docs.first;
          _searching = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMsg = 'Error al buscar el torneo';
        _searching = false;
      });
    }
  }

  Future<void> _showDeckDialog() async {
    final deckController = TextEditingController();
    final deckUrl = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Enlace de tu mazo',
            style: GoogleFonts.rubik(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.text)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pega el enlace de tu lista en Moxfield, Limitless, etc.',
              style: GoogleFonts.rubik(
                  fontSize: 12, color: AppColors.textDim),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: deckController,
              autofocus: true,
              style: GoogleFonts.rubik(
                  fontSize: 13, color: AppColors.text),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                hintText: 'https://moxfield.com/...',
                hintStyle: GoogleFonts.rubik(
                    fontSize: 13, color: AppColors.textMute),
                filled: true,
                fillColor: AppColors.surfaceHi,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar',
                style: GoogleFonts.rubik(
                    fontSize: 13, color: AppColors.textMute)),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(ctx, deckController.text.trim()),
            child: Text('Inscribirme',
                style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cyan)),
          ),
        ],
      ),
    );
    deckController.dispose();
    if (deckUrl == null) return;
    _enroll(deckUrl);
  }

  Future<void> _enroll(String deckUrl) async {
    final doc = _tournamentDoc;
    if (doc == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _enrolling = true);
    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection('User').doc(user.uid);
      final orgRef = doc.data()?['organizerId'] as DocumentReference?;

      // Comprobar si ya está inscrito
      final existing = await doc.reference
          .collection('registration')
          .where('userId', isEqualTo: userRef)
          .limit(1)
          .get();

      if (!mounted) return;
      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ya estás inscrito en este torneo')),
        );
        setState(() => _enrolling = false);
        return;
      }

      final userSnap = await userRef.get();
      final userName = userSnap.data()?['name'] as String? ??
          user.email?.split('@').first ??
          'Jugador';
      final tournamentName = doc.data()?['name'] as String? ?? 'Torneo';

      // 1. Crear inscripción
      await doc.reference.collection('registration').add({
        'userId': userRef,
        'status': 'Pending',
        'player_name': userName,
        'deck': deckUrl,
        'points': 0,
        'creadoEn': FieldValue.serverTimestamp(),
      });

      // 2. Notificar al organizador (no bloquea la inscripción si falla)
      if (orgRef != null) {
        try {
          await db.collection('Notifications').add({
            'userID': orgRef,
            'date': FieldValue.serverTimestamp(),
            'type': 'inscripcion',
            'title': 'Nueva inscripción',
            'mensaje': '$userName quiere apuntarse a $tournamentName',
            'icon': '✉',
            'isRead': false,
            'tournamentId': doc.id,
          });
        } catch (_) {}
      }

      if (!mounted) return;
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                '¡Inscripción enviada! Espera confirmación del organizador.')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al inscribirse: $e')),
      );
    } finally {
      if (mounted) setState(() => _enrolling = false);
    }
  }

  void _reset() {
    _controller.clear();
    setState(() {
      _code = '';
      _tournamentDoc = null;
      _errorMsg = null;
    });
    _focus.requestFocus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final found = _tournamentDoc != null;
    final data = _tournamentDoc?.data();
    final ruleSet = data?['rule_set'] as String?;
    final gameCode = _gameCodeFromRuleSet(ruleSet);
    final tournamentName = data?['name'] as String? ?? '';
    final location = data?['city'] as String? ?? data?['location'] as String? ?? '';
    final needsDeck = _requiresDeck(ruleSet);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 12,
        child: SafeArea(
          child: Stack(
            children: [
              Opacity(
                opacity: 0,
                child: SizedBox(
                  width: 1,
                  height: 1,
                  child: TextField(
                    controller: _controller,
                    focusNode: _focus,
                    autofocus: true,
                    keyboardType: TextInputType.visiblePassword,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    decoration: const InputDecoration(counterText: ''),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => _focus.requestFocus(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                      child: Row(
                        children: [
                          const BackBtn(),
                          const SizedBox(width: 12),
                          Text('Unirme a un torneo',
                              style: GoogleFonts.rubik(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 100,
                      child: Center(
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                AppColors.cyan.withValues(alpha: 0.4),
                                AppColors.violet.withValues(alpha: 0.25),
                                AppColors.pink.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: GoogleFonts.rubik(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                                letterSpacing: -0.8,
                                height: 1.1,
                              ),
                              children: [
                                const TextSpan(text: 'Introduce el\n'),
                                WidgetSpan(
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        const LinearGradient(
                                                colors:
                                                    AppColors.clienteGradient)
                                            .createShader(bounds),
                                    blendMode: BlendMode.srcIn,
                                    child: Text('código del torneo',
                                        style: GoogleFonts.rubik(
                                            fontSize: 32,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -0.8)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'El organizador te lo habrá enviado por email o lo encontrarás en el cartel del evento.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.rubik(
                                fontSize: 13,
                                color: AppColors.textDim,
                                height: 1.4),
                          ),
                          const SizedBox(height: 34),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (i) {
                              final filled = i < _code.length;
                              final isCursor = i == _code.length && !found;
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: found
                                        ? AppColors.cyan.withValues(alpha: 0.15)
                                        : _errorMsg != null
                                            ? AppColors.pink
                                                .withValues(alpha: 0.1)
                                            : filled
                                                ? AppColors.surfaceHi
                                                : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: found
                                          ? AppColors.cyan
                                          : _errorMsg != null
                                              ? AppColors.pink
                                              : isCursor
                                                  ? AppColors.cyan
                                                  : filled
                                                      ? Colors.transparent
                                                      : AppColors.stroke,
                                      width: (isCursor || found) ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: isCursor
                                        ? AnimatedBuilder(
                                            animation: _pulseAnim,
                                            builder: (_, __) => Opacity(
                                              opacity: _pulseAnim.value,
                                              child: Container(
                                                  width: 2,
                                                  height: 24,
                                                  color: AppColors.cyan),
                                            ),
                                          )
                                        : Text(
                                            i < _code.length ? _code[i] : '',
                                            style: GoogleFonts.rubikMonoOne(
                                                fontSize: 24,
                                                color: AppColors.text),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: found
                                ? _StatusRow(
                                    key: const ValueKey('found'),
                                    color: AppColors.cyan,
                                    icon: '✓',
                                    text: '¡Torneo encontrado!',
                                  )
                                : _searching
                                    ? AnimatedBuilder(
                                        key: const ValueKey('searching'),
                                        animation: _pulseAnim,
                                        builder: (_, __) => _StatusRow(
                                          opacity: _pulseAnim.value,
                                          color: AppColors.cyan,
                                          icon: '●',
                                          text: 'Buscando torneo…',
                                        ),
                                      )
                                    : _errorMsg != null
                                        ? _StatusRow(
                                            key: const ValueKey('error'),
                                            color: AppColors.pink,
                                            icon: '✕',
                                            text: _errorMsg!,
                                          )
                                        : const SizedBox.shrink(
                                            key: ValueKey('idle')),
                          ),
                          const SizedBox(height: 28),
                          if (found)
                            Column(
                              children: [
                                BrawlCard(
                                  padding: const EdgeInsets.all(16),
                                  radius: 20,
                                  tint: AppColors.cyan.withValues(alpha: 0.08),
                                  border:
                                      AppColors.cyan.withValues(alpha: 0.25),
                                  child: Row(
                                    children: [
                                      GameBadge(game: gameCode, size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(tournamentName,
                                                style: GoogleFonts.rubik(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.text)),
                                            Text(location,
                                                style: GoogleFonts.rubik(
                                                    fontSize: 12,
                                                    color: AppColors.textDim)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: _reset,
                                      child: Container(
                                        height: 50,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          border: Border.all(
                                              color: AppColors.stroke),
                                        ),
                                        child: Center(
                                          child: Text('Otro código',
                                              style: GoogleFonts.rubik(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.text)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _enrolling
                                          ? const Center(
                                              child: CircularProgressIndicator(
                                                  color: AppColors.cyan),
                                            )
                                          : GradBtn(
                                              size: GradBtnSize.lg,
                                              width: double.infinity,
                                              onTap: needsDeck
                                                  ? _showDeckDialog
                                                  : () => _enroll(''),
                                              child:
                                                  const Text('Inscribirme ✓'),
                                            ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const Spacer(),
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

class _StatusRow extends StatelessWidget {
  final Color color;
  final String icon, text;
  final double opacity;
  const _StatusRow({
    super.key,
    required this.color,
    required this.icon,
    required this.text,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: TextStyle(fontSize: 12, color: color)),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.rubik(
                  fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
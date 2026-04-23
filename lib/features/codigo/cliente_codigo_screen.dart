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
  bool _found = false;
  String _code = '';

  @override
  void initState() {
    super.initState();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
          ..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.25, end: 0.8).animate(_pulseController);

    _controller.addListener(_onInput);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focus.requestFocus());
  }

  void _onInput() {
    final raw = _controller.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    final trimmed = raw.length > 6 ? raw.substring(0, 6) : raw;
    if (trimmed != _controller.text) {
      _controller.value = TextEditingValue(
        text: trimmed,
        selection: TextSelection.collapsed(offset: trimmed.length),
      );
      return;
    }
    if (trimmed != _code) {
      setState(() => _code = trimmed);
      if (trimmed.length == 6 && !_searching) _onCodeComplete();
    }
  }

  void _onCodeComplete() {
    setState(() => _searching = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() { _searching = false; _found = true; });
    });
  }

  void _reset() {
    _controller.clear();
    setState(() { _code = ''; _found = false; _searching = false; });
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
                  width: 1, height: 1,
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
                                        const LinearGradient(colors: AppColors.clienteGradient)
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
                                fontSize: 13, color: AppColors.textDim, height: 1.4),
                          ),
                          const SizedBox(height: 34),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(6, (i) {
                              final filled = i < _code.length;
                              final isCursor = i == _code.length && !_found;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 44,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _found
                                        ? AppColors.cyan.withValues(alpha: 0.15)
                                        : filled
                                            ? AppColors.surfaceHi
                                            : Colors.transparent,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _found
                                          ? AppColors.cyan
                                          : isCursor
                                              ? AppColors.cyan
                                              : filled
                                                  ? Colors.transparent
                                                  : AppColors.stroke,
                                      width: (isCursor || _found) ? 1.5 : 1,
                                    ),
                                    boxShadow: _found
                                        ? [
                                            BoxShadow(
                                              color: AppColors.cyan.withValues(alpha: 0.25),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            )
                                          ]
                                        : filled
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.cyan.withValues(alpha: 0.15),
                                                  blurRadius: 0,
                                                  spreadRadius: 1,
                                                )
                                              ]
                                            : null,
                                  ),
                                  child: Center(
                                    child: isCursor
                                        ? AnimatedBuilder(
                                            animation: _pulseAnim,
                                            builder: (_, __) => Opacity(
                                              opacity: _pulseAnim.value,
                                              child: Container(
                                                  width: 2, height: 24, color: AppColors.cyan),
                                            ),
                                          )
                                        : Text(
                                            i < _code.length ? _code[i] : '',
                                            style: GoogleFonts.rubikMonoOne(
                                                fontSize: 24, color: AppColors.text),
                                          ),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 20),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: _found
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
                                    : const SizedBox.shrink(key: ValueKey('idle')),
                          ),
                          const SizedBox(height: 28),
                          if (_found)
                            Column(
                              children: [
                                BrawlCard(
                                  padding: const EdgeInsets.all(16),
                                  radius: 20,
                                  tint: AppColors.cyan.withValues(alpha: 0.08),
                                  border: AppColors.cyan.withValues(alpha: 0.25),
                                  child: Row(
                                    children: [
                                      const GameBadge(game: 'MTG', size: 40),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Pioneer FNM Mayo',
                                                style: GoogleFonts.rubik(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w700,
                                                    color: AppColors.text)),
                                            Text('Dragón Rojo Store · Hoy 18:30',
                                                style: GoogleFonts.rubik(
                                                    fontSize: 12, color: AppColors.textDim)),
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
                                        padding: const EdgeInsets.symmetric(horizontal: 20),
                                        decoration: BoxDecoration(
                                          color: AppColors.surface,
                                          borderRadius: BorderRadius.circular(999),
                                          border: Border.all(color: AppColors.stroke),
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
                                      child: GradBtn(
                                        size: GradBtnSize.lg,
                                        width: double.infinity,
                                        onTap: () => Navigator.pop(context),
                                        child: const Text('Inscribirme ✓'),
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
  const _StatusRow({super.key, required this.color, required this.icon, required this.text, this.opacity = 1.0});

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

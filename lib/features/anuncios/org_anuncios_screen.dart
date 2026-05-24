import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/shell/org_shell.dart';
import 'viewmodels/anuncios_viewmodel.dart';

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
  final _vm = AnunciosViewModel();

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmUpdate);
    if (widget.isCreationFlow && widget.eventId != null) {
      _vm.loadEvent(widget.eventId!).then((_) {
        _textController.text = '';
        _codeController.text = '';
      });
    } else {
      _vm.loading = false;
    }
  }

  void _onVmUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmUpdate);
    _vm.dispose();
    _textController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _saveDraft() async {
    if (widget.eventId == null) return;
    final ok = await _vm.saveDraft(
        widget.eventId!, _textController.text, _codeController.text);
    if (ok && mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _saveChanges() async {
    if (widget.eventId == null) return;
    final ok = await _vm.saveChanges(
        widget.eventId!, _textController.text, _codeController.text);
    if (ok && mounted) Navigator.pop(context);
  }

  Future<void> _publish() async {
    if (widget.eventId == null) return;
    final ok = await _vm.publish(
        widget.eventId!, _textController.text, _codeController.text);
    if (ok && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const OrgShell()),
        (_) => false,
      );
    } else if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.t('Error al publicar el torneo'))),
      );
    }
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
                                    Text(L10n.t('NUEVO TORNEO'),
                                        style: GoogleFonts.rubik(
                                            fontSize: 11,
                                            color: AppColors.textMute,
                                            letterSpacing: 0.5)),
                                    Text(L10n.t('Paso 4 de 4 · Publicar'),
                                        style: GoogleFonts.rubik(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.text)),
                                  ],
                                )
                              : Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(L10n.t('COMPARTIR'),
                                        style: GoogleFonts.rubik(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textMute,
                                            letterSpacing: 0.5)),
                                    Text(L10n.t('Publicar anuncio'),
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
                            onTap: _vm.isSaving ? null : _saveDraft,
                            child: Text(L10n.t('Guardar'),
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
                child: _vm.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                            child: GameBadge(game: _vm.gameCode, size: 34),
                                          ),
                                          Positioned(
                                            bottom: 14,
                                            left: 16,
                                            right: 16,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  _vm.dateTimeLabel,
                                                  style: GoogleFonts.rubik(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.yellow,
                                                      letterSpacing: 0.6),
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  _vm.eventName,
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
                                            '${_vm.plazas} plazas · ${_vm.entryFee % 1 == 0 ? _vm.entryFee.toInt() : _vm.entryFee} €',
                                            style: GoogleFonts.rubik(
                                                fontSize: 12, color: AppColors.textDim),
                                          ),
                                          Text(
                                            '${_vm.enrolledCount}/${_vm.plazas}',
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
                            BrawlCard(
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(L10n.t('TEXTO DEL ANUNCIO'),
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
                                      hintText: L10n.t('¡Vuelve el torneo! Escribe aquí el texto del anuncio...'),
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
                            BrawlCard(
                              radius: 18,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(L10n.t('CÓDIGO DE INSCRIPCIÓN'),
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
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.stroke),
                                          ),
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          alignment: Alignment.centerLeft,
                                          child: TextField(
                                            controller: _codeController,
                                            maxLength: 6,
                                            textCapitalization: TextCapitalization.characters,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(r'[a-zA-Z0-9]')),
                                              TextInputFormatter.withFunction(
                                                  (_, v) => v.copyWith(
                                                      text: v.text.toUpperCase())),
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
                                        onTap: () => setState(() =>
                                            _codeController.text =
                                                AnunciosViewModel.generateCode()),
                                        child: Container(
                                          height: 44,
                                          padding: const EdgeInsets.symmetric(horizontal: 14),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                                colors: AppColors.organizadorGradient),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text('⚡', style: TextStyle(fontSize: 13)),
                                              const SizedBox(width: 5),
                                              Text(L10n.t('Generar'),
                                                  style: GoogleFonts.rubik(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    L10n.t('Los jugadores usarán este código para inscribirse.'),
                                    style: GoogleFonts.rubik(
                                        fontSize: 11, color: AppColors.textMute),
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
                child: _vm.isSaving
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : GradBtn(
                        size: GradBtnSize.lg,
                        gradient: AppColors.organizadorGradient,
                        width: double.infinity,
                        onTap: widget.isCreationFlow ? _publish : _saveChanges,
                        child: Text(widget.isCreationFlow
                            ? L10n.t('Publicar ahora ✦')
                            : L10n.t('Guardar cambios')),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

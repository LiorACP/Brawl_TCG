import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'data/tournament.dart';
import 'services/torneo_live_service.dart';

class OrgRondasScreen extends StatefulWidget {
  final Tournament tournament;
  const OrgRondasScreen({super.key, required this.tournament});

  @override
  State<OrgRondasScreen> createState() => _OrgRondasScreenState();
}

class _OrgRondasScreenState extends State<OrgRondasScreen> {
  final Map<String, TextEditingController> _p1Ctrl = {};
  final Map<String, TextEditingController> _p2Ctrl = {};
  final Map<String, bool> _saving = {};
  bool _startingNext = false;

  String get _uid =>
      FirebaseAuth.instance.currentUser?.uid ?? '';

  String get _orgId =>
      widget.tournament.organizerId ?? _uid;

  int get _round => widget.tournament.currentRound ?? 1;

  TextEditingController _c1(String id) =>
      _p1Ctrl.putIfAbsent(id, TextEditingController.new);

  TextEditingController _c2(String id) =>
      _p2Ctrl.putIfAbsent(id, TextEditingController.new);

  @override
  void dispose() {
    for (final c in [..._p1Ctrl.values, ..._p2Ctrl.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save(RoundMatch match) async {
    final p1 = int.tryParse(_c1(match.id).text.trim()) ?? 0;
    final p2 = int.tryParse(_c2(match.id).text.trim()) ?? 0;
    setState(() => _saving[match.id] = true);
    try {
      await TorneoLiveService.scoreMatch(
        tournamentId: widget.tournament.id,
        matchId: match.id,
        roundNum: _round,
        player1Uid: match.player1Uid,
        player2Uid: match.player2Uid,
        player1Points: p1,
        player2Points: p2,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving.remove(match.id));
    }
  }

  Future<void> _nextRound() async {
    setState(() => _startingNext = true);
    try {
      await TorneoLiveService.nextRound(
        tournamentId: widget.tournament.id,
        tournamentName: widget.tournament.name,
        organizerId: _orgId,
        currentRound: _round,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _startingNext = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.fmt('Ronda {n}', {'n': '$_round'}),
              style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            Text(widget.tournament.name,
                style: GoogleFonts.rubik(
                    fontSize: 11, color: AppColors.textMute)),
          ],
        ),
      ),
      body: StreamBuilder<List<RoundMatch>>(
        stream: TorneoLiveService.watchRoundMatches(
            widget.tournament.id, _round),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: AppColors.cyan));
          }

          final matches = snapshot.data!;
          if (matches.isEmpty) {
            return Center(
              child: Text('Sin enfrentamientos en esta ronda.',
                  style: GoogleFonts.rubik(
                      fontSize: 14, color: AppColors.textMute)),
            );
          }

          final scored = matches.where((m) => m.scored).length;
          final allScored = scored == matches.length;
          final allDone =
              matches.every((m) => m.player1Done && m.player2Done);

          return Column(
            children: [
              // Barra de estado
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    Text(
                      L10n.fmt('{n} / {total} puntuados', {'n': '$scored', 'total': '${matches.length}'}),
                      style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDim),
                    ),
                    const Spacer(),
                    if (allDone && !allScored)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.cyan.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: AppColors.cyan.withValues(alpha: 0.3)),
                        ),
                        child: Text(L10n.t('Todos terminaron'),
                            style: GoogleFonts.rubik(
                                fontSize: 11, color: AppColors.cyan)),
                      ),
                  ],
                ),
              ),

              // Lista de enfrentamientos
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _MatchCard(
                    match: matches[i],
                    p1Ctrl: _c1(matches[i].id),
                    p2Ctrl: _c2(matches[i].id),
                    saving: _saving[matches[i].id] ?? false,
                    onSave: () => _save(matches[i]),
                  ),
                ),
              ),

              // Botón siguiente ronda
              if (allScored)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                  child: _startingNext
                      ? const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.orange))
                      : GradBtn(
                          gradient: AppColors.organizadorGradient,
                          onTap: _nextRound,
                          child: Text(
                            L10n.fmt('Iniciar Ronda {n}', {'n': '${_round + 1}'}),
                            style: GoogleFonts.rubik(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.white),
                          ),
                        ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final RoundMatch match;
  final TextEditingController p1Ctrl;
  final TextEditingController p2Ctrl;
  final bool saving;
  final VoidCallback onSave;

  const _MatchCard({
    required this.match,
    required this.p1Ctrl,
    required this.p2Ctrl,
    required this.saving,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (match.scored) {
      return _ScoredCard(match: match);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlayerRow(
            name: match.player1Name,
            done: match.player1Done,
            controller: p1Ctrl,
            color: AppColors.blue,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                Expanded(child: Divider(color: AppColors.stroke, height: 1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text('VS',
                      style: GoogleFonts.rubikMonoOne(
                          fontSize: 11, color: AppColors.textMute)),
                ),
                Expanded(child: Divider(color: AppColors.stroke, height: 1)),
              ],
            ),
          ),
          _PlayerRow(
            name: match.player2Name,
            done: match.player2Done,
            controller: p2Ctrl,
            color: AppColors.pink,
          ),
          const SizedBox(height: 14),
          saving
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.cyan),
                  ),
                )
              : GradBtn(
                  gradient: AppColors.organizadorGradient,
                  onTap: onSave,
                  child: Text(
                    L10n.t('Guardar puntuación'),
                    style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                ),
        ],
      ),
    );
  }
}

class _PlayerRow extends StatelessWidget {
  final String name;
  final bool done;
  final TextEditingController controller;
  final Color color;

  const _PlayerRow({
    required this.name,
    required this.done,
    required this.controller,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: done ? AppColors.cyan : AppColors.textMute,
        ),
        const SizedBox(width: 10),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(name,
              style: GoogleFonts.rubik(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text)),
        ),
        SizedBox(
          width: 72,
          height: 38,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            style: GoogleFonts.rubikMonoOne(
                fontSize: 14, color: AppColors.text),
            decoration: InputDecoration(
              hintText: 'pts',
              hintStyle: GoogleFonts.rubik(
                  fontSize: 12, color: AppColors.textMute),
              filled: true,
              fillColor: AppColors.surfaceHi,
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScoredCard extends StatelessWidget {
  final RoundMatch match;
  const _ScoredCard({required this.match});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border:
            Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(match.player1Name,
                    style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                Text('${match.player1Points ?? 0} pts',
                    style: GoogleFonts.rubikMonoOne(
                        fontSize: 14, color: AppColors.cyan)),
              ],
            ),
          ),
          Text('VS',
              style: GoogleFonts.rubikMonoOne(
                  fontSize: 10, color: AppColors.textMute)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(match.player2Name,
                    style: GoogleFonts.rubik(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text)),
                Text('${match.player2Points ?? 0} pts',
                    style: GoogleFonts.rubikMonoOne(
                        fontSize: 14, color: AppColors.pink)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('✓',
                style: TextStyle(fontSize: 12, color: AppColors.cyan)),
          ),
        ],
      ),
    );
  }
}

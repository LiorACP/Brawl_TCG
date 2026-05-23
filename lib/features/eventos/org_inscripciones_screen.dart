import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'data/tournament.dart';
import 'player_profile_sheet.dart';

class OrgInscripcionesScreen extends StatelessWidget {
  final Tournament tournament;
  const OrgInscripcionesScreen({super.key, required this.tournament});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bgDeep,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: AppColors.text, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.t('Inscripciones'),
              style: GoogleFonts.rubik(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.text),
            ),
            Text(
              tournament.name,
              style: GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Tournaments')
            .doc(tournament.id)
            .collection('registration')
            .where('status', isEqualTo: 'Pending')
            .orderBy('creadoEn', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                L10n.t('Error cargando inscripciones'),
                style: GoogleFonts.rubik(color: AppColors.textMute),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✉', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    L10n.t('No hay inscripciones pendientes'),
                    style: GoogleFonts.rubik(
                        fontSize: 15, color: AppColors.textMute),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final doc = docs[i];
              final data = doc.data();
              final playerName = data['player_name'] as String? ?? 'Jugador';
              final deck = data['deck'] as String? ?? '';
              final hasDeck = deck.isNotEmpty;
              final regId = doc.id;

              return _RegistrationCard(
                tournamentId: tournament.id,
                tournamentName: tournament.name,
                regId: regId,
                playerName: playerName,
                playerRef: data['userId'] as DocumentReference?,
                deckUrl: deck,
                hasDeck: hasDeck,
              );
            },
          );
        },
      ),
    );
  }
}

class _RegistrationCard extends StatefulWidget {
  final String tournamentId;
  final String tournamentName;
  final String regId;
  final String playerName;
  final DocumentReference? playerRef;
  final String deckUrl;
  final bool hasDeck;

  const _RegistrationCard({
    required this.tournamentId,
    required this.tournamentName,
    required this.regId,
    required this.playerName,
    required this.playerRef,
    required this.deckUrl,
    required this.hasDeck,
  });

  @override
  State<_RegistrationCard> createState() => _RegistrationCardState();
}

class _RegistrationCardState extends State<_RegistrationCard> {
  bool _loading = false;

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _loading = true);
    try {
      final db = FirebaseFirestore.instance;
      final regRef = db
          .collection('Tournaments')
          .doc(widget.tournamentId)
          .collection('registration')
          .doc(widget.regId);

      await regRef.update({'status': newStatus});

      // Decremento pendingCount siempre (se acepta o rechaza deja de estar pendiente)
      await db
          .collection('Tournaments')
          .doc(widget.tournamentId)
          .update({'pendingCount': FieldValue.increment(-1)});

      if (newStatus == 'Accepted') {
        await db
            .collection('Tournaments')
            .doc(widget.tournamentId)
            .update({'enrolledCount': FieldValue.increment(1)});
      }

      if (widget.playerRef != null) {
        final isAccepted = newStatus == 'Accepted';
        await db.collection('Notifications').add({
          'userID': widget.playerRef,
          'date': FieldValue.serverTimestamp(),
          'type': 'inscripcion_respuesta',
          'title': isAccepted ? L10n.t('Inscripción aceptada') : L10n.t('Inscripción rechazada'),
          'mensaje': isAccepted
              ? L10n.fmt('Tu inscripción a "{name}" ha sido aceptada. ¡Nos vemos!', {'name': widget.tournamentName})
              : L10n.fmt('Tu inscripción a "{name}" ha sido rechazada.', {'name': widget.tournamentName}),
          'icon': isAccepted ? '✅' : '❌',
          'isRead': false,
          'tournamentId': widget.tournamentId,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDeck() async {
    final uri = Uri.tryParse(widget.deckUrl);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.stroke),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => showPlayerProfileSheet(
                  context,
                  playerName: widget.playerName,
                  playerRef: widget.playerRef,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.clienteGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          widget.playerName.isNotEmpty
                              ? widget.playerName[0].toUpperCase()
                              : '?',
                          style: GoogleFonts.rubik(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => showPlayerProfileSheet(
                    context,
                    playerName: widget.playerName,
                    playerRef: widget.playerRef,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Text(
                    widget.playerName,
                    style: GoogleFonts.rubik(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.text),
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.yellow.withValues(alpha: 0.4)),
                ),
                child: Text(
                  L10n.t('Pendiente'),
                  style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.yellow),
                ),
              ),
            ],
          ),
          if (widget.hasDeck) ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _openDeck,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.cyan.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded,
                        size: 14, color: AppColors.cyan),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        widget.deckUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.rubik(
                            fontSize: 12, color: AppColors.cyan),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.open_in_new_rounded,
                        size: 13, color: AppColors.cyan),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          _loading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.cyan),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: L10n.t('Rechazar'),
                        color: AppColors.pink,
                        onTap: () => _updateStatus('Rejected'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: L10n.t('Aceptar'),
                        color: AppColors.cyan,
                        onTap: () => _updateStatus('Accepted'),
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.rubik(
                fontSize: 13, fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ),
    );
  }
}
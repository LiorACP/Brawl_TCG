import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'data/tournament.dart';

class OrgParticipantesScreen extends StatelessWidget {
  final Tournament tournament;
  const OrgParticipantesScreen({super.key, required this.tournament});

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
              'Participantes',
              style: GoogleFonts.rubik(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text),
            ),
            Text(
              tournament.name,
              style:
                  GoogleFonts.rubik(fontSize: 11, color: AppColors.textMute),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Tournaments')
            .doc(tournament.id)
            .collection('registration')
            .where('status', isEqualTo: 'Accepted')
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
                'Error cargando participantes',
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
                  const Text('👥', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    'Sin participantes confirmados',
                    style: GoogleFonts.rubik(
                        fontSize: 15, color: AppColors.textMute),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Acepta inscripciones para que aparezcan aquí',
                    style: GoogleFonts.rubik(
                        fontSize: 12, color: AppColors.textMute),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                child: Row(
                  children: [
                    Text(
                      '${docs.length} confirmado${docs.length == 1 ? '' : 's'}',
                      style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDim),
                    ),
                    const SizedBox(width: 6),
                    if (tournament.totalSlots > 0)
                      Text(
                        '/ ${tournament.totalSlots} plazas',
                        style: GoogleFonts.rubik(
                            fontSize: 12, color: AppColors.textMute),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final name =
                        data['player_name'] as String? ?? 'Jugador';
                    final playerRef =
                        data['userId'] as DocumentReference?;
                    final position = (data['points'] as num?)?.toInt();
                    final tableNumber =
                        (data['tableNumber'] as num?)?.toInt();

                    return _ParticipantCard(
                      index: i,
                      regId: doc.id,
                      tournamentId: tournament.id,
                      tournamentName: tournament.name,
                      playerName: name,
                      playerRef: playerRef,
                      position: position,
                      tableNumber: tableNumber,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ParticipantCard extends StatefulWidget {
  final int index;
  final String regId;
  final String tournamentId;
  final String tournamentName;
  final String playerName;
  final DocumentReference? playerRef;
  final int? position;
  final int? tableNumber;

  const _ParticipantCard({
    required this.index,
    required this.regId,
    required this.tournamentId,
    required this.tournamentName,
    required this.playerName,
    required this.playerRef,
    this.position,
    this.tableNumber,
  });

  @override
  State<_ParticipantCard> createState() => _ParticipantCardState();
}

class _ParticipantCardState extends State<_ParticipantCard> {
  bool _loading = false;

  Future<void> _removePlayer() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Desapuntar jugador',
          style: GoogleFonts.rubik(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.text),
        ),
        content: Text(
          '¿Seguro que quieres eliminar a "${widget.playerName}" del torneo?',
          style:
              GoogleFonts.rubik(fontSize: 13, color: AppColors.textDim),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar',
                style: GoogleFonts.rubik(
                    fontSize: 13, color: AppColors.textMute)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Desapuntar',
                style: GoogleFonts.rubik(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pink)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    setState(() => _loading = true);

    try {
      final db = FirebaseFirestore.instance;
      final regRef = db
          .collection('Tournaments')
          .doc(widget.tournamentId)
          .collection('registration')
          .doc(widget.regId);

      await regRef.update({'status': 'Removed'});

      await db
          .collection('Tournaments')
          .doc(widget.tournamentId)
          .update({'enrolledCount': FieldValue.increment(-1)});

      if (widget.playerRef != null) {
        await db.collection('Notifications').add({
          'userID': widget.playerRef,
          'date': FieldValue.serverTimestamp(),
          'type': 'desapuntado',
          'title': 'Has sido desapuntado',
          'mensaje':
              'El organizador te ha eliminado del torneo "${widget.tournamentName}".',
          'icon': '⚠',
          'isRead': false,
          'tournamentId': widget.tournamentId,
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Row(
        children: [
          // Número de orden
          SizedBox(
            width: 24,
            child: Text(
              '${widget.index + 1}',
              style: GoogleFonts.rubikMonoOne(
                  fontSize: 11, color: AppColors.textMute),
            ),
          ),
          const SizedBox(width: 10),
          // Avatar
          Container(
            width: 34,
            height: 34,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Nombre
          Expanded(
            child: Text(
              widget.playerName,
              style: GoogleFonts.rubik(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.text),
            ),
          ),
          // Mesa o puntos
          if (widget.tableNumber != null)
            _InfoChip(
                label: 'Mesa ${widget.tableNumber}',
                color: AppColors.violet)
          else if (widget.position != null && widget.position! > 0)
            _InfoChip(
                label: '${widget.position} pts', color: AppColors.cyan),
          const SizedBox(width: 8),
          // Botón eliminar o spinner
          if (_loading)
            const SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.pink),
                ),
              ),
            )
          else
            GestureDetector(
              onTap: _removePlayer,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.pink.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppColors.pink.withValues(alpha: 0.25)),
                ),
                child: const Center(
                  child: Text('🗑', style: TextStyle(fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;
  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.rubik(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}
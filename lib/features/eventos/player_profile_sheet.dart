import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';

Future<void> showPlayerProfileSheet(
  BuildContext context, {
  required String playerName,
  DocumentReference? playerRef,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _PlayerProfileSheet(
      playerName: playerName,
      playerRef: playerRef,
    ),
  );
}

class _PlayerProfileSheet extends StatefulWidget {
  final String playerName;
  final DocumentReference? playerRef;

  const _PlayerProfileSheet({required this.playerName, this.playerRef});

  @override
  State<_PlayerProfileSheet> createState() => _PlayerProfileSheetState();
}

class _PlayerProfileSheetState extends State<_PlayerProfileSheet> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (widget.playerRef == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await widget.playerRef!.get();
      if (mounted) {
        setState(() {
          _data = doc.data() as Map<String, dynamic>?;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _data?['name'] as String? ?? widget.playerName;
    final localidad = _data?['localidad'] as String? ?? '';
    final telefono = _data?['telefono'] as String? ?? '';
    final isOrg = _data?['organizer'] as bool? ?? false;
    final hasDetails = localidad.isNotEmpty || telefono.isNotEmpty;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgDeep,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: AppColors.stroke)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.strokeHi,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: CircularProgressIndicator(
                    color: AppColors.cyan, strokeWidth: 2),
              )
            else ...[
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.clienteGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: GoogleFonts.rubik(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '@${name.split(' ').first.toLowerCase()}',
                style: GoogleFonts.rubik(
                    fontSize: 12, color: AppColors.textMute),
              ),
              if (isOrg) ...[
                const SizedBox(height: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.magenta.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.magenta.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'Organizador',
                    style: GoogleFonts.rubik(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.magenta,
                    ),
                  ),
                ),
              ],
              if (hasDetails) ...[
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Column(
                    children: [
                      if (localidad.isNotEmpty)
                        _InfoRow(icon: '◉', label: localidad),
                      if (localidad.isNotEmpty && telefono.isNotEmpty)
                        Divider(color: AppColors.stroke, height: 20),
                      if (telefono.isNotEmpty)
                        _InfoRow(icon: '📞', label: telefono),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String icon;
  final String label;
  const _InfoRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style:
                GoogleFonts.rubik(fontSize: 13, color: AppColors.textDim),
          ),
        ),
      ],
    );
  }
}

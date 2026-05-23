import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';

Future<void> showStoreProfileSheet(
  BuildContext context, {
  required String organizerId,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _StoreProfileSheet(organizerId: organizerId),
  );
}

class _StoreProfileSheet extends StatefulWidget {
  final String organizerId;
  const _StoreProfileSheet({required this.organizerId});

  @override
  State<_StoreProfileSheet> createState() => _StoreProfileSheetState();
}

class _StoreProfileSheetState extends State<_StoreProfileSheet> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('User')
          .doc(widget.organizerId)
          .get();
      if (mounted) {
        setState(() {
          _data = doc.data();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final storeName = _data?['storeName'] as String? ?? '';
    final orgName = _data?['name'] as String? ?? '';
    final displayName = storeName.isNotEmpty ? storeName : orgName;
    final address = _data?['storeAddress'] as String? ?? '';
    final city = _data?['localidad'] as String? ?? '';
    final horarios = _data?['storeHorarios'] as String? ?? '';
    final juegos = _data?['storeJuegos'] as String? ?? '';
    final redes = _data?['storeRedesSociales'] as String? ?? '';
    final telefono = _data?['telefono'] as String? ?? '';

    final rows = <_StoreRow>[
      if (address.isNotEmpty) _StoreRow(icon: '📍', text: address),
      if (city.isNotEmpty && city != address)
        _StoreRow(icon: '◉', text: city),
      if (horarios.isNotEmpty) _StoreRow(icon: '🕐', text: horarios),
      if (juegos.isNotEmpty) _StoreRow(icon: '🎴', text: juegos),
      if (telefono.isNotEmpty) _StoreRow(icon: '📞', text: telefono),
      if (redes.isNotEmpty) _StoreRow(icon: '🔗', text: redes),
    ];

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
          crossAxisAlignment: CrossAxisAlignment.start,
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
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: CircularProgressIndicator(
                      color: AppColors.cyan, strokeWidth: 2),
                ),
              )
            else ...[
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.organizadorGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(
                        displayName.isNotEmpty
                            ? displayName[0].toUpperCase()
                            : '🏪',
                        style: GoogleFonts.rubik(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName.isNotEmpty
                              ? displayName
                              : 'Tienda',
                          style: GoogleFonts.rubik(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        if (storeName.isNotEmpty && orgName.isNotEmpty)
                          Text(
                            orgName,
                            style: GoogleFonts.rubik(
                                fontSize: 12, color: AppColors.textMute),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
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
              ),
              if (rows.isNotEmpty) ...[
                const SizedBox(height: 18),
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
                      for (int i = 0; i < rows.length; i++) ...[
                        _StoreInfoRow(row: rows[i]),
                        if (i < rows.length - 1)
                          Divider(color: AppColors.stroke, height: 16),
                      ],
                    ],
                  ),
                ),
              ] else if (_data != null) ...[
                const SizedBox(height: 16),
                Text(
                  'Esta tienda aún no ha completado su perfil.',
                  style: GoogleFonts.rubik(
                      fontSize: 13, color: AppColors.textMute),
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

class _StoreRow {
  final String icon;
  final String text;
  const _StoreRow({required this.icon, required this.text});
}

class _StoreInfoRow extends StatelessWidget {
  final _StoreRow row;
  const _StoreInfoRow({required this.row});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(row.icon, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            row.text,
            style: GoogleFonts.rubik(
                fontSize: 13, color: AppColors.textDim),
          ),
        ),
      ],
    );
  }
}

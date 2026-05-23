import 'package:brawl_tcg/models/event_model.dart';
import 'package:brawl_tcg/utils/event_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _filtro = 'Eventos Inscritos';

  Stream<List<Evento>> _getEventos() {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final campo =
        _filtro == 'Eventos Inscritos' ? 'inscritos' : 'participados';
    return FirebaseFirestore.instance
        .collection('eventos')
        .where(campo, arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.map(Evento.fromFirestore).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1C20),
      floatingActionButton: _buildFab(),
      body: StreamBuilder<List<Evento>>(
        stream: _getEventos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0XFFF8BF54)),
            );
          }
          final eventos = snapshot.data ?? [];
          return LayoutBuilder(
            builder: (context, constraints) {
              final esPC = constraints.maxWidth > 900;
              return Column(
                children: [
                  _buildHeader(esPC),
                  Expanded(
                    child: eventos.isEmpty
                        ? _buildEmpty()
                        : esPC
                            ? _buildGrid(eventos)
                            : _buildList(eventos),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool esPC) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: esPC ? 100 : 20, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            L10n.t("MIS EVENTOS"),
            style: GoogleFonts.rubik(
              fontSize: esPC ? 32 : 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          _buildSelector(),
        ],
      ),
    );
  }

  Widget _buildSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _filtro,
          dropdownColor: const Color(0xFF1E1E1E),
          style: GoogleFonts.rubik(color: Colors.white),
          items: ['Eventos Inscritos', 'Ya Participados']
              .map((e) => DropdownMenuItem(value: e, child: Text(L10n.t(e))))
              .toList(),
          onChanged: (val) => setState(() => _filtro = val!),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.event_busy, color: Colors.white24, size: 60),
          const SizedBox(height: 16),
          Text(
            _filtro == 'Eventos Inscritos'
                ? L10n.t('No estás inscrito en ningún evento')
                : L10n.t('Todavía no has participado en ningún evento'),
            style: GoogleFonts.rubik(color: Colors.white38, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Evento> eventos) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: eventos.length,
      itemBuilder: (context, i) => EventCard(evento: eventos[i]),
    );
  }

  Widget _buildList(List<Evento> eventos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: eventos.length,
      itemBuilder: (context, i) => Padding(
        padding: const EdgeInsets.only(bottom: 15),
        child: EventCard(evento: eventos[i]),
      ),
    );
  }

  Widget _buildFab() {
    return Container(
      height: 60,
      width: 60,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [Color(0XFFF8BF54), Color(0xFFEC5544), Color(0xFF9120A6)],
        ),
      ),
      child: FloatingActionButton(
        onPressed: _showJoinDialog,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showJoinDialog() {
    final codigoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C20),
        title: Text(
          L10n.t("CÓDIGO DE TORNEO"),
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: codigoController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: L10n.t("Introduce el código"),
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black26,
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              codigoController.dispose();
              Navigator.pop(ctx);
            },
            child: Text(L10n.t("CANCELAR")),
          ),
          ElevatedButton(
            onPressed: () async {
              final codigo = codigoController.text.trim();
              codigoController.dispose();
              Navigator.pop(ctx);
              await _unirseConCodigo(codigo);
            },
            child: Text(L10n.t("UNIRME")),
          ),
        ],
      ),
    );
  }

  Future<void> _unirseConCodigo(String codigo) async {
    if (codigo.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    try {
      final query = await FirebaseFirestore.instance
          .collection('eventos')
          .where('codigo', isEqualTo: codigo)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(L10n.t('Código de torneo no encontrado'))),
        );
        return;
      }
      await query.docs.first.reference.update({
        'inscritos': FieldValue.arrayUnion([uid]),
        'jugadores': FieldValue.increment(1),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.t('¡Te has unido al torneo!'))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(L10n.fmt('Error al unirse: {e}', {'e': '$e'}))),
      );
    }
  }
}
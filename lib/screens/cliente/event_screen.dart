import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// 1. MODELO DE DATOS (Lo dejamos aquí arriba para que no falle nada)
class Evento {
  final String nombre;
  final String subtitulo;
  final String jugadores;
  final String formato;
  final int ranking;

  Evento({
    required this.nombre,
    required this.subtitulo,
    required this.jugadores,
    required this.formato,
    required this.ranking,
  });
}

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  String _filtro = 'Eventos Inscritos';

  // 2. DATOS DE PRUEBA (Hardcoded aquí dentro para que funcione YA)
  final List<Evento> inscritosDemo = [
    Evento(
      nombre: "Brawl TCG Major",
      subtitulo: "Torneo de Invierno",
      jugadores: "128",
      formato: "Moderno",
      ranking: 1,
    ),
    Evento(
      nombre: "Regional Cup",
      subtitulo: "Qualifiers Madrid",
      jugadores: "64",
      formato: "Estándar",
      ranking: 12,
    ),
  ];

  final List<Evento> participadosDemo = [
    Evento(
      nombre: "Old School Battle",
      subtitulo: "Evento Retro",
      jugadores: "16",
      formato: "Legacy",
      ranking: 3,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Seleccionamos la lista según el filtro
    final listaActual = _filtro == 'Eventos Inscritos'
        ? inscritosDemo
        : participadosDemo;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1C20),
      floatingActionButton: _buildFab(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool esPC = constraints.maxWidth > 900;
          return Column(
            children: [
              _buildHeader(esPC),
              Expanded(
                child: esPC ? _buildGrid(listaActual) : _buildList(listaActual),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- CABECERA ---
  Widget _buildHeader(bool esPC) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: esPC ? 100 : 20, vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "MIS EVENTOS",
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
          items: [
            'Eventos Inscritos',
            'Ya Participados',
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (val) => setState(() => _filtro = val!),
        ),
      ),
    );
  }

  // --- LISTADOS ---
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

  // --- BOTÓN FLOTANTE ---
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
        onPressed: () => _showDialog(),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1C20),
        title: const Text(
          "CÓDIGO DE TORNEO",
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Introduce el código",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.black26,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          ElevatedButton(onPressed: () {}, child: const Text("UNIRME")),
        ],
      ),
    );
  }
}

// 3. WIDGET DE LA TARJETA (Todo en el mismo archivo para evitar líos)
class EventCard extends StatelessWidget {
  final Evento evento;
  const EventCard({super.key, required this.evento});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white10,
            child: Icon(Icons.emoji_events, color: Colors.white24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  evento.nombre,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  evento.subtitulo,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.people, size: 14, color: Color(0XFFF8BF54)),
                    const SizedBox(width: 4),
                    Text(
                      evento.jugadores,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 70,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFEC5544), Color(0xFF9120A6)],
              ),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${evento.ranking}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  "RANK",
                  style: TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

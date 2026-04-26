import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/shell/cliente_shell.dart';
import 'package:brawl_tcg/shell/org_shell.dart';

class RolSelectionScreen extends StatefulWidget {
  const RolSelectionScreen({super.key});

  @override
  State<RolSelectionScreen> createState() => _RolSelectionScreenState();
}

class _RolSelectionScreenState extends State<RolSelectionScreen> {
  String _selectedRole = 'Cliente';
  bool _isLoading = false;

  Future<void> _confirm() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance.collection('User').doc(user.uid).set({
        'name': user.displayName ?? user.email?.split('@').first ?? 'Usuario',
        'email': user.email ?? '',
        'organizer': _selectedRole == 'Organizador',
        'creadoEn': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => _selectedRole == 'Organizador'
              ? const OrgShell()
              : const ClienteShell(),
        ),
        (_) => false,
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el perfil.')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final nombre =
        user?.displayName ?? user?.email?.split('@').first ?? 'Usuario';

    return Scaffold(
      backgroundColor: const Color(0xFF1A1C20),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user?.photoURL != null)
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(user!.photoURL!),
                )
              else
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF9120A6),
                  child: Text('👤', style: TextStyle(fontSize: 32)),
                ),
              const SizedBox(height: 16),
              Text(
                '¡Hola, $nombre!',
                style: GoogleFonts.rubik(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '¿Cómo vas a usar Brawl TCG?',
                textAlign: TextAlign.center,
                style: GoogleFonts.rubik(fontSize: 15, color: Colors.white54),
              ),
              const SizedBox(height: 40),
              _RolCard(
                title: 'Cliente',
                subtitle: 'Compite en torneos y sigue tus resultados.',
                icon: '⚔',
                selected: _selectedRole == 'Cliente',
                gradient: const [Color(0xFF00C6FF), Color(0xFF5B5BFF)],
                onTap: () => setState(() => _selectedRole = 'Cliente'),
              ),
              const SizedBox(height: 14),
              _RolCard(
                title: 'Organizador',
                subtitle: 'Crea y gestiona torneos para tu tienda.',
                icon: '◈',
                selected: _selectedRole == 'Organizador',
                gradient: const [Color(0xFFEC5544), Color(0xFF9120A6)],
                onTap: () => setState(() => _selectedRole = 'Organizador'),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFFF8BF54)),
                      )
                    : DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF8BF54),
                              Color(0xFFEC5544),
                              Color(0xFF9120A6),
                            ],
                          ),
                        ),
                        child: ElevatedButton(
                          onPressed: _confirm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: Text(
                            'CONTINUAR COMO ${_selectedRole.toUpperCase()}',
                            style: GoogleFonts.rubik(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RolCard extends StatelessWidget {
  final String title, subtitle, icon;
  final bool selected;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _RolCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected
              ? Colors.black.withValues(alpha: 0.3)
              : Colors.black.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? gradient.last.withValues(alpha: 0.7)
                : Colors.white.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient:
                    selected ? LinearGradient(colors: gradient) : null,
                color: selected
                    ? null
                    : Colors.white.withValues(alpha: 0.06),
              ),
              child: Center(
                child: Text(
                  icon,
                  style: TextStyle(
                    fontSize: 22,
                    color: selected ? Colors.white : Colors.white38,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: GoogleFonts.rubik(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: GoogleFonts.rubik(
                          fontSize: 12, color: Colors.white54)),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient:
                    selected ? LinearGradient(colors: gradient) : null,
                border: selected
                    ? null
                    : Border.all(color: Colors.white24, width: 2),
              ),
              child: selected
                  ? const Center(
                      child:
                          Icon(Icons.check, size: 13, color: Colors.white),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
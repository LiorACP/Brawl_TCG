import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/l10n/app_l10n.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/features/eventos/data/tournament.dart';
import 'data/regla_firestore.dart';
import 'services/reglas_service.dart';

class ReglaDetalleScreen extends StatefulWidget {
  final TcgGame game;
  const ReglaDetalleScreen({super.key, required this.game});

  @override
  State<ReglaDetalleScreen> createState() => _ReglaDetalleScreenState();
}

class _ReglaDetalleScreenState extends State<ReglaDetalleScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  // índices de secciones expandidas (primera abierta por defecto)
  final Set<int> _openSections = {0};

  @override
  void initState() {
    super.initState();
    _searchController.addListener(
      () => setState(() => _query = _searchController.text.trim().toLowerCase()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<RuleSection> _buildSections(List<ReglaFirestore> firestoreRules) {
    final map = <String, List<FaqItem>>{};
    for (final r in firestoreRules) {
      map.putIfAbsent(r.category, () => []).add(
        FaqItem(
          question: r.title,
          answer: r.body,
          keywords: r.searchKeywords,
        ),
      );
    }
    return map.entries
        .map((e) => RuleSection(title: e.key, faqs: e.value))
        .toList();
  }

  List<({RuleSection section, int index, List<FaqItem> faqs})> _filter(
      List<RuleSection> sections) {
    return sections.asMap().entries.map((e) {
      final faqs = _query.isEmpty
          ? e.value.faqs
          : e.value.faqs.where((f) => f.matches(_query)).toList();
      return (section: e.value, index: e.key, faqs: faqs);
    }).where((e) => e.faqs.isNotEmpty).toList();
  }

  void _toggleSection(int index) {
    setState(() {
      if (_openSections.contains(index)) {
        _openSections.remove(index);
      } else {
        _openSections.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 42,
        child: SafeArea(
          child: Column(
            children: [
              // ── Cabecera ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.stroke),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new,
                            size: 16, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          L10n.t('REGLAMENTO'),
                          style: GoogleFonts.rubik(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMute,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          widget.game.fullName,
                          style: GoogleFonts.rubik(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    GameBadge(game: widget.game.code, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Buscador ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.stroke),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, size: 18, color: AppColors.textMute),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: GoogleFonts.rubik(
                              fontSize: 13.5, color: AppColors.text),
                          decoration: InputDecoration(
                            hintText: L10n.t('Buscar término…'),
                            hintStyle: GoogleFonts.rubik(
                                fontSize: 13.5, color: AppColors.textMute),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      if (_query.isNotEmpty)
                        GestureDetector(
                          onTap: () => _searchController.clear(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Icon(Icons.close,
                                size: 16, color: AppColors.textMute),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ── Contenido (Firestore → fallback estático) ───────────────
              Expanded(
                child: StreamBuilder<List<ReglaFirestore>>(
                  stream: ReglasService.watchRules(widget.game.firestoreId),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.violet,
                          strokeWidth: 2,
                        ),
                      );
                    }

                    final sections = _buildSections(snap.data ?? []);
                    final filtered = _filter(sections);
                    final isSearching = _query.isNotEmpty;
                    final totalResults =
                        filtered.fold(0, (s, e) => s + e.faqs.length);

                    return Column(
                      children: [
                        if (isSearching)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 8),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                filtered.isEmpty
                                    ? L10n.fmt('Sin resultados para "{query}"', {'query': _query})
                                    : L10n.fmt(totalResults == 1 ? '{n} resultado' : '{n} resultados', {'n': '$totalResults'}),
                                style: GoogleFonts.rubik(
                                    fontSize: 11, color: AppColors.textMute),
                              ),
                            ),
                          ),
                        Expanded(
                          child: filtered.isEmpty
                              ? _buildEmpty()
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                      22, 0, 22, 20),
                                  itemCount: filtered.length,
                                  itemBuilder: (context, i) {
                                    final entry = filtered[i];
                                    final isOpen = isSearching ||
                                        _openSections.contains(entry.index);
                                    return _SectionAccordion(
                                      section: entry.section,
                                      faqs: entry.faqs,
                                      isOpen: isOpen,
                                      searchQuery: _query,
                                      onToggle: () =>
                                          _toggleSection(entry.index),
                                    );
                                  },
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 36)),
          const SizedBox(height: 12),
          Text(
            L10n.t('Sin resultados'),
            style: GoogleFonts.rubik(
                fontSize: 15,
                color: AppColors.textDim,
                fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            L10n.t('Prueba con otro término'),
            style: GoogleFonts.rubik(fontSize: 12, color: AppColors.textMute),
          ),
        ],
      ),
    );
  }
}

// ── Sección accordion ──────────────────────────────────────────────────────

class _SectionAccordion extends StatelessWidget {
  final RuleSection section;
  final List<FaqItem> faqs;
  final bool isOpen;
  final String searchQuery;
  final VoidCallback onToggle;

  const _SectionAccordion({
    required this.section,
    required this.faqs,
    required this.isOpen,
    required this.searchQuery,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: BrawlCard(
        padding: EdgeInsets.zero,
        radius: 20,
        child: Column(
          children: [
            // Cabecera de sección (tappable)
            GestureDetector(
              onTap: onToggle,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.violet.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.violet.withValues(alpha: 0.25)),
                      ),
                      child: Center(
                        child: Text(
                          section.title[0].toUpperCase(),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.violet,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.title,
                            style: GoogleFonts.rubik(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.text,
                            ),
                          ),
                          Text(
                            L10n.fmt(faqs.length == 1 ? '{n} pregunta' : '{n} preguntas', {'n': '${faqs.length}'}),
                            style: GoogleFonts.rubik(
                                fontSize: 11, color: AppColors.textMute),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: isOpen ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down,
                          size: 20, color: AppColors.textDim),
                    ),
                  ],
                ),
              ),
            ),

            // FAQs expandibles
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: isOpen
                  ? Column(
                      children: [
                        Divider(
                            height: 1,
                            color: AppColors.stroke,
                            thickness: 1),
                        ...faqs.asMap().entries.map((e) => _FaqTile(
                              faq: e.value,
                              isLast: e.key == faqs.length - 1,
                              searchQuery: searchQuery,
                            )),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Item de FAQ expandible ─────────────────────────────────────────────────

class _FaqTile extends StatefulWidget {
  final FaqItem faq;
  final bool isLast;
  final String searchQuery;

  const _FaqTile({
    required this.faq,
    required this.isLast,
    required this.searchQuery,
  });

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    _expanded
                        ? Icons.remove_circle_outline
                        : Icons.add_circle_outline,
                    size: 16,
                    color: _expanded ? AppColors.violet : AppColors.textDim,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HighlightText(
                        text: widget.faq.question,
                        query: widget.searchQuery,
                        style: GoogleFonts.rubik(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text,
                        ),
                        highlightColor: AppColors.yellow,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        child: _expanded
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _HighlightText(
                                  text: widget.faq.answer,
                                  query: widget.searchQuery,
                                  style: GoogleFonts.rubik(
                                    fontSize: 12.5,
                                    color: AppColors.textDim,
                                    height: 1.6,
                                  ),
                                  highlightColor: AppColors.yellow,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.isLast)
          Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: AppColors.stroke.withValues(alpha: 0.5),
              thickness: 1),
      ],
    );
  }
}

// ── Texto con resaltado de términos buscados ───────────────────────────────

class _HighlightText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final Color highlightColor;

  const _HighlightText({
    required this.text,
    required this.query,
    required this.style,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return Text(text, style: style);

    final lower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final idx = lower.indexOf(query, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(TextSpan(
        text: text.substring(idx, idx + query.length),
        style: TextStyle(
          backgroundColor: highlightColor.withValues(alpha: 0.3),
          color: highlightColor,
          fontWeight: FontWeight.w700,
        ),
      ));
      start = idx + query.length;
    }

    return RichText(
      text: TextSpan(style: style, children: spans),
    );
  }
}

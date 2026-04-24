import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'data/store_profile.dart';
import 'viewmodels/org_tienda_viewmodel.dart';

class OrgTiendaScreen extends StatelessWidget {
  const OrgTiendaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const vm = OrgTiendaViewModel.mock;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 41,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 260,
                child: Stack(
                  children: [
                    Positioned(
                      top: -30,
                      left: -40,
                      child: _GradBlob(size: 280, colors: AppColors.clienteGradient),
                    ),
                    Positioned(
                      bottom: 20,
                      right: -30,
                      child: _GradBlob(size: 150, colors: [AppColors.orange, AppColors.pink]),
                    ),
                    Positioned(
                      top: 8,
                      right: 22,
                      child: _GlassBtn(
                          iconWidget: const Icon(Icons.edit_outlined,
                              size: 16, color: Colors.white)),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 22,
                      right: 22,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vm.profile.verified)
                            BrawlTag(label: '★ Tienda verificada', color: AppColors.yellow),
                          const SizedBox(height: 8),
                          Text(
                            vm.profile.name,
                            style: GoogleFonts.rubik(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.6),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vm.profile.subtitle,
                            style: GoogleFonts.rubik(fontSize: 13, color: AppColors.textDim),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatTile(
                            icon: '★',
                            number: vm.stats.ratingLabel,
                            label: 'Rating',
                          ),
                          const SizedBox(width: 8),
                          _StatTile(
                            icon: '☆',
                            number: vm.stats.followers.toString(),
                            label: 'Seguidores',
                          ),
                          const SizedBox(width: 8),
                          _StatTile(
                            icon: '◈',
                            number: vm.stats.tournaments.toString(),
                            label: 'Torneos',
                          ),
                        ],
                      ),
                      const SectionLabel('Administración'),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 600;
                          return GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isWide ? 4 : 2,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: isWide ? 1.6 : 1.4,
                            children: vm.adminSections
                                .map((s) => _AdminTile(section: s))
                                .toList(),
                          );
                        },
                      ),
                      const SectionLabel('Últimas reseñas'),
                      BrawlCard(
                        radius: 20,
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Últimas reseñas',
                                    style: GoogleFonts.rubik(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.text)),
                                Text('Ver todas →',
                                    style: GoogleFonts.rubik(
                                        fontSize: 12, color: AppColors.textDim)),
                              ],
                            ),
                            ...vm.reviews.map((r) => _ReviewRow(review: r)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const BrawlNavBarSpacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final StoreReview review;
  const _ReviewRow({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppColors.organizadorGradient),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      review.authorName,
                      style: GoogleFonts.rubik(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      review.starsLabel,
                      style: const TextStyle(fontSize: 11, color: AppColors.yellow),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  review.body,
                  style: GoogleFonts.rubik(
                      fontSize: 12, color: AppColors.textDim, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;
  const _GradBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            colors[0].withValues(alpha: 0.7),
            colors.last.withValues(alpha: 0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

class _GlassBtn extends StatelessWidget {
  final Widget iconWidget;
  const _GlassBtn({required this.iconWidget});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: const Color(0xB2100A19),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.stroke),
      ),
      child: Center(child: iconWidget),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon, number, label;
  const _StatTile({required this.icon, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: BrawlCard(
        padding: const EdgeInsets.all(12),
        radius: 16,
        child: Column(
          children: [
            Text(icon, style: TextStyle(fontSize: 11, color: AppColors.textMute)),
            const SizedBox(height: 2),
            GradText(
              text: number,
              gradient: AppColors.organizadorGradient,
              style: GoogleFonts.rubikMonoOne(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 1),
            Text(
              label.toUpperCase(),
              style: GoogleFonts.rubik(
                  fontSize: 10, color: AppColors.textMute, letterSpacing: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  final StoreAdminSection section;
  const _AdminTile({required this.section});

  @override
  Widget build(BuildContext context) {
    return BrawlCard(
      padding: const EdgeInsets.all(14),
      radius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: section.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: section.color.withValues(alpha: 0.2)),
            ),
            child: Center(
              child: Text(
                section.icon,
                style: TextStyle(fontSize: 16, color: section.color),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            section.title,
            style: GoogleFonts.rubik(
                fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text),
          ),
          const SizedBox(height: 2),
          Text(
            section.subtitle,
            style: GoogleFonts.rubik(
                fontSize: 11, color: AppColors.textDim, height: 1.3),
          ),
        ],
      ),
    );
  }
}

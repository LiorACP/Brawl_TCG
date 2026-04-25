import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';

class ConfigField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? icon;
  final TextInputType keyboardType;
  final bool obscureText;

  const ConfigField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.rubik(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMute,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: GoogleFonts.rubik(fontSize: 14, color: AppColors.text),
          decoration: InputDecoration(
            prefixIcon: icon != null
                ? Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Text(icon!, style: const TextStyle(fontSize: 16)),
                  )
                : null,
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class ConfigPasswordField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const ConfigPasswordField({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<ConfigPasswordField> createState() => _ConfigPasswordFieldState();
}

class _ConfigPasswordFieldState extends State<ConfigPasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label,
            style: GoogleFonts.rubik(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMute,
                letterSpacing: 0.5)),
        const SizedBox(height: 6),
        TextField(
          controller: widget.controller,
          obscureText: _hidden,
          style: GoogleFonts.rubik(fontSize: 14, color: AppColors.text),
          decoration: InputDecoration(
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 14, right: 8),
              child: Text('🔒', style: TextStyle(fontSize: 15)),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
            suffixIcon: GestureDetector(
              onTap: () => setState(() => _hidden = !_hidden),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Text(
                  _hidden ? '👁' : '🙈',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 0),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: AppColors.stroke),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.cyan, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class ConfigSectionHeader extends StatelessWidget {
  final String text;
  const ConfigSectionHeader(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.rubik(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.textMute,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:brawl_tcg/core/theme/app_colors.dart';
import 'package:brawl_tcg/core/widgets/brawl_widgets.dart';
import 'package:brawl_tcg/core/navigation/transitions.dart';
import 'package:brawl_tcg/features/eventos/org_crear_screen.dart';
import 'viewmodels/org_info_viewmodel.dart';

class OrgInfoScreen extends StatefulWidget {
  const OrgInfoScreen({super.key});

  @override
  State<OrgInfoScreen> createState() => _OrgInfoScreenState();
}

class _OrgInfoScreenState extends State<OrgInfoScreen> {
  final _nameController = TextEditingController();
  DateTime? _date;
  TimeOfDay? _time;
  final _vm = OrgInfoViewModel();

  String get _dateText => _date == null
      ? 'dd/MM'
      : '${_date!.day.toString().padLeft(2, '0')}/${_date!.month.toString().padLeft(2, '0')}';

  String get _timeText => _time == null
      ? 'HH:mm'
      : '${_time!.hour.toString().padLeft(2, '0')}:${_time!.minute.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmUpdate);
  }

  void _onVmUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmUpdate);
    _vm.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.violet,
            onPrimary: Colors.white,
            surface: AppColors.bgDeep,
            onSurface: AppColors.text,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.bgDeep),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 18, minute: 0),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            primary: AppColors.violet,
            onPrimary: Colors.white,
            surface: AppColors.bgDeep,
            onSurface: AppColors.text,
          ),
          dialogTheme: DialogThemeData(backgroundColor: AppColors.bgDeep),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce el nombre del torneo')),
      );
      return false;
    }
    if (_date == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la fecha del torneo')),
      );
      return false;
    }
    if (_time == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona la hora del torneo')),
      );
      return false;
    }
    return true;
  }

  Future<void> _saveDraft() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce al menos el nombre del torneo')),
      );
      return;
    }
    final eventDate = (_date != null && _time != null)
        ? DateTime(_date!.year, _date!.month, _date!.day, _time!.hour, _time!.minute)
        : DateTime.now().add(const Duration(days: 365));
    final ok = await _vm.saveDraft(name: name, eventDate: eventDate);
    if (ok && mounted) Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Future<void> _next() async {
    if (!_validate()) return;
    final eventDate = DateTime(
      _date!.year, _date!.month, _date!.day,
      _time!.hour, _time!.minute,
    );
    final id = await _vm.createTournament(
      name: _nameController.text.trim(),
      eventDate: eventDate,
    );
    if (!mounted) return;
    if (id != null) {
      Navigator.push(
        context,
        fadeSlideRoute(OrgCrearScreen(
          eventId: id,
          eventName: _nameController.text.trim(),
          eventDate: eventDate,
        )),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al guardar el evento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: BrawlBackground(
        seed: 29,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const BackBtn(),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NUEVO TORNEO',
                                  style: GoogleFonts.rubik(
                                      fontSize: 11,
                                      color: AppColors.textMute,
                                      letterSpacing: 0.5)),
                              Text('Paso 1 de 4 · Información',
                                  style: GoogleFonts.rubik(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.text)),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: _vm.isSaving ? null : _saveDraft,
                          child: Text('Guardar',
                              style: GoogleFonts.rubik(
                                  fontSize: 12, color: AppColors.textDim)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: List.generate(
                        4,
                        (i) => Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            child: Container(
                              height: 4,
                              decoration: BoxDecoration(
                                gradient: i < 1
                                    ? const LinearGradient(
                                        colors: AppColors.organizadorGradient)
                                    : null,
                                color: i >= 1 ? AppColors.surfaceHi : null,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BrawlCard(
                        radius: 22,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('NOMBRE DEL TORNEO',
                                style: GoogleFonts.rubik(
                                    fontSize: 11,
                                    color: AppColors.textMute,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5)),
                            const SizedBox(height: 10),
                            TextField(
                              controller: _nameController,
                              style: GoogleFonts.rubik(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.text),
                              cursorColor: AppColors.violet,
                              maxLength: 32,
                              decoration: InputDecoration(
                                hintText: 'Pioneer FNM — Mayo',
                                hintStyle: GoogleFonts.rubik(
                                    fontSize: 17, color: AppColors.textMute),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                counterStyle: GoogleFonts.rubik(
                                    fontSize: 11, color: AppColors.textMute),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickDate,
                              child: BrawlCard(
                                padding: const EdgeInsets.all(16),
                                radius: 18,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('FECHA',
                                        style: GoogleFonts.rubik(
                                            fontSize: 10.5,
                                            color: AppColors.textMute,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          _dateText,
                                          style: GoogleFonts.rubikMonoOne(
                                            fontSize: 20,
                                            color: _date != null
                                                ? AppColors.text
                                                : AppColors.textMute,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.calendar_today_outlined,
                                            size: 15, color: AppColors.textMute),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: _pickTime,
                              child: BrawlCard(
                                padding: const EdgeInsets.all(16),
                                radius: 18,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('HORA',
                                        style: GoogleFonts.rubik(
                                            fontSize: 10.5,
                                            color: AppColors.textMute,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5)),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Text(
                                          _timeText,
                                          style: GoogleFonts.rubikMonoOne(
                                            fontSize: 20,
                                            color: _time != null
                                                ? AppColors.text
                                                : AppColors.textMute,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.access_time_outlined,
                                            size: 15, color: AppColors.textMute),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                child: _vm.isSaving
                    ? const Center(
                        child: CircularProgressIndicator(color: AppColors.orange))
                    : GradBtn(
                        size: GradBtnSize.lg,
                        gradient: AppColors.organizadorGradient,
                        width: double.infinity,
                        onTap: _next,
                        child: const Text('Siguiente · Formato →'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

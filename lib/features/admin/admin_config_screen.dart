import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

class AdminConfigScreen extends StatefulWidget {
  const AdminConfigScreen({super.key});
  @override
  State<AdminConfigScreen> createState() => _AdminConfigScreenState();
}

class _AdminConfigScreenState extends State<AdminConfigScreen> {
  // Credit rates
  double _adelantoRate = 12.0;
  double _nominaRate = 15.0;
  double _simpleRate = 18.0;
  double _revolventeRate = 22.0;

  // Limits
  double _maxCreditLimit = 500000;
  double _maxAdelantoLimit = 30000;
  double _minScoreApproval = 580;

  // Toggles
  bool _autoApproveKyc = false;
  bool _autoApproveDispositions = false;
  bool _aiScoringEnabled = true;
  bool _fraudDetectionEnabled = true;
  bool _smsNotifications = true;
  bool _emailNotifications = true;
  bool _pushNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris), onPressed: () => context.pop()),
        title: Text('Configuracion', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              onPressed: () => _save(),
              icon: const Icon(Icons.save_rounded, size: 16),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credit Rates
            _SectionHeader('Tasas de interes', Icons.percent_rounded, SayoColors.green),
            const SizedBox(height: 8),
            _RateSlider('Adelanto Nomina', _adelantoRate, 8, 20, SayoColors.orange, (v) => setState(() => _adelantoRate = v)),
            _RateSlider('Credito Nomina', _nominaRate, 10, 25, SayoColors.green, (v) => setState(() => _nominaRate = v)),
            _RateSlider('Credito Simple', _simpleRate, 12, 30, SayoColors.blue, (v) => setState(() => _simpleRate = v)),
            _RateSlider('Revolvente', _revolventeRate, 15, 35, SayoColors.purple, (v) => setState(() => _revolventeRate = v)),
            const SizedBox(height: 20),

            // Limits
            _SectionHeader('Limites de credito', Icons.tune_rounded, SayoColors.blue),
            const SizedBox(height: 8),
            _LimitSlider('Limite max credito', _maxCreditLimit, 100000, 2000000, SayoColors.blue, (v) => setState(() => _maxCreditLimit = v)),
            _LimitSlider('Limite max adelanto', _maxAdelantoLimit, 5000, 100000, SayoColors.orange, (v) => setState(() => _maxAdelantoLimit = v)),
            const SizedBox(height: 20),

            // AI Scoring
            _SectionHeader('AI & Scoring', Icons.auto_awesome, SayoColors.purple),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(children: [
                _SliderRow('Score minimo aprobacion', '${_minScoreApproval.toInt()} pts'),
                Slider(value: _minScoreApproval, min: 300, max: 750, divisions: 45, activeColor: SayoColors.purple, onChanged: (v) => setState(() => _minScoreApproval = v)),
                const Divider(height: 16, color: SayoColors.beige),
                _ToggleRow('AI Scoring habilitado', _aiScoringEnabled, SayoColors.purple, (v) => setState(() => _aiScoringEnabled = v)),
                const SizedBox(height: 8),
                _ToggleRow('Deteccion de fraude', _fraudDetectionEnabled, SayoColors.red, (v) => setState(() => _fraudDetectionEnabled = v)),
              ]),
            ),
            const SizedBox(height: 20),

            // Workflows
            _SectionHeader('Workflows', Icons.route_rounded, SayoColors.orange),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(children: [
                _ToggleRow('Auto-aprobar KYC Nivel 1', _autoApproveKyc, SayoColors.orange, (v) => setState(() => _autoApproveKyc = v)),
                const SizedBox(height: 8),
                _ToggleRow('Auto-aprobar disposiciones < \$10K', _autoApproveDispositions, SayoColors.orange, (v) => setState(() => _autoApproveDispositions = v)),
              ]),
            ),
            const SizedBox(height: 20),

            // Notifications
            _SectionHeader('Notificaciones', Icons.notifications_rounded, SayoColors.cafe),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(children: [
                _ToggleRow('SMS', _smsNotifications, SayoColors.blue, (v) => setState(() => _smsNotifications = v)),
                const SizedBox(height: 8),
                _ToggleRow('Email', _emailNotifications, SayoColors.green, (v) => setState(() => _emailNotifications = v)),
                const SizedBox(height: 8),
                _ToggleRow('Push', _pushNotifications, SayoColors.purple, (v) => setState(() => _pushNotifications = v)),
              ]),
            ),
            const SizedBox(height: 20),

            // System info
            _SectionHeader('Sistema', Icons.info_outline_rounded, SayoColors.grisMed),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(children: [
                _InfoRow('Version', 'v1.2.0-demo'),
                const SizedBox(height: 6),
                _InfoRow('Ambiente', 'Staging'),
                const SizedBox(height: 6),
                _InfoRow('Backend', 'NestJS + PostgreSQL'),
                const SizedBox(height: 6),
                _InfoRow('AI Engine', 'Sayo AI v2.0'),
                const SizedBox(height: 6),
                _InfoRow('SPEI', 'PoliPay conectado'),
                const SizedBox(height: 6),
                _InfoRow('KYC', 'MetaMap activo'),
                const SizedBox(height: 6),
                _InfoRow('Ultima actualizacion', '4 Mar 2026'),
              ]),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Configuracion guardada', style: GoogleFonts.urbanist()),
      backgroundColor: SayoColors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
}

// --- WIDGETS ---

class _SectionHeader extends StatelessWidget {
  final String label; final IconData icon; final Color color;
  const _SectionHeader(this.label, this.icon, this.color);
  @override Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Icon(icon, size: 14, color: color)),
    const SizedBox(width: 8),
    Text(label, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
  ]);
}

class _RateSlider extends StatelessWidget {
  final String label; final double value, min, max; final Color color; final ValueChanged<double> onChanged;
  const _RateSlider(this.label, this.value, this.min, this.max, this.color, this.onChanged);
  @override Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        Text('${value.toStringAsFixed(1)}% anual', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
      Slider(value: value, min: min, max: max, divisions: ((max - min) * 2).toInt(), activeColor: color, onChanged: onChanged),
    ]),
  );
}

class _LimitSlider extends StatelessWidget {
  final String label; final double value, min, max; final Color color; final ValueChanged<double> onChanged;
  const _LimitSlider(this.label, this.value, this.min, this.max, this.color, this.onChanged);
  @override Widget build(BuildContext context) {
    final formatted = value >= 1000000 ? '\$${(value / 1000000).toStringAsFixed(1)}M' : '\$${(value / 1000).toStringAsFixed(0)}K';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          Text(formatted, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ]),
        Slider(value: value, min: min, max: max, divisions: 50, activeColor: color, onChanged: onChanged),
      ]),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label, value;
  const _SliderRow(this.label, this.value);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
    Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.purple)),
  ]);
}

class _ToggleRow extends StatelessWidget {
  final String label; final bool value; final Color color; final ValueChanged<bool> onChanged;
  const _ToggleRow(this.label, this.value, this.color, this.onChanged);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.gris)),
    Switch(value: value, activeColor: color, onChanged: onChanged),
  ]);
}

class _InfoRow extends StatelessWidget {
  final String label, value;
  const _InfoRow(this.label, this.value);
  @override Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
    Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
  ]);
}

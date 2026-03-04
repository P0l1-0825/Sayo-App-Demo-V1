import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import '../../shared/data/mock_data.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  bool _faceIdEnabled = true;
  bool _twoFaEnabled = true;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copiado'),
        backgroundColor: SayoColors.cafe,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showKycDetail(String step) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: SayoColors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_rounded, color: SayoColors.green, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                step,
                style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
              const SizedBox(height: 8),
              Text(
                'Verificado el 15 de febrero de 2026',
                style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Este paso fue completado exitosamente durante tu proceso de alta.',
                        style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showChangeNip() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 20),
                Text(
                  'Cambiar NIP',
                  style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
                ),
                const SizedBox(height: 20),
                _PinField(controller: currentCtrl, label: 'NIP actual'),
                const SizedBox(height: 12),
                _PinField(controller: newCtrl, label: 'Nuevo NIP'),
                const SizedBox(height: 12),
                _PinField(controller: confirmCtrl, label: 'Confirmar NIP'),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('NIP actualizado correctamente'),
                          backgroundColor: SayoColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    child: const Text('Actualizar NIP'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSessions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text(
                'Sesiones activas',
                style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.green.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: SayoColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.phone_iphone_rounded, color: SayoColors.green, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('iPhone 15 Pro', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                          Text('Guadalajara, MX · Activo ahora', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: SayoColors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('Actual', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.green)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Solo hay 1 sesion activa. Tu cuenta esta segura.',
                style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocument(String title) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: SayoColors.cafe.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.description_rounded, color: SayoColors.cafe, size: 28),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
              const SizedBox(height: 8),
              Text(
                'Firmado el 15 de febrero de 2026',
                style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Descargando $title...'),
                        backgroundColor: SayoColors.cafe,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download_rounded),
                  label: const Text('Descargar PDF'),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cerrar',
                  style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCerrarSesion() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: SayoColors.cream,
        title: Text(
          'Cerrar sesion',
          style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
        ),
        content: Text(
          'Tendras que iniciar sesion de nuevo para acceder a tu cuenta SAYO.',
          style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: SayoColors.grisMed),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Sesion cerrada (demo)'),
                  backgroundColor: SayoColors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SayoColors.red,
              foregroundColor: SayoColors.white,
            ),
            child: const Text('Cerrar sesion'),
          ),
        ],
      ),
    );
  }

  void _showCondusef() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('CONDUSEF', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _ContactRow(Icons.phone_rounded, 'Telefono', '55 5340 0999'),
                    _ContactRow(Icons.language_rounded, 'Sitio web', 'www.condusef.gob.mx'),
                    _ContactRow(Icons.email_rounded, 'Email', 'asesoria@condusef.gob.mx'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'La CONDUSEF es el organismo que protege tus derechos como usuario de servicios financieros.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpCenter() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              Text('Centro de ayuda', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
              const SizedBox(height: 16),
              _HelpItem(Icons.chat_bubble_outline_rounded, 'Chat en vivo', 'Lun-Vie 9:00 - 18:00'),
              _HelpItem(Icons.phone_outlined, 'Llamar a soporte', '33 1234 5678'),
              _HelpItem(Icons.email_outlined, 'Enviar email', 'soporte@sayo.mx'),
              _HelpItem(Icons.help_outline_rounded, 'Preguntas frecuentes', '15 articulos disponibles'),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: SayoColors.cafe.withValues(alpha: 0.1),
                    child: Text(
                      'JB',
                      style: GoogleFonts.urbanist(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: SayoColors.cafe,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    MockUser.fullName,
                    style: GoogleFonts.urbanist(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: SayoColors.gris,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: SayoColors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded, size: 14, color: SayoColors.green),
                        const SizedBox(width: 4),
                        Text(
                          'Verificado · ${MockUser.kycLevel}',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: SayoColors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // KYC Status — tappable steps
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verificacion KYC',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: SayoColors.gris,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _KycStep('Datos personales', true, onTap: () => _showKycDetail('Datos personales')),
                    _KycStep('INE / Identificacion', true, onTap: () => _showKycDetail('INE / Identificacion')),
                    _KycStep('Comprobante domicilio', true, onTap: () => _showKycDetail('Comprobante domicilio')),
                    _KycStep('Verificacion biometrica', true, onTap: () => _showKycDetail('Verificacion biometrica')),
                    _KycStep('Firma electronica', true, onTap: () => _showKycDetail('Firma electronica')),
                  ],
                ),
              ),
            ),
          ),

          // Account info — copyable rows
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Cuenta SAYO',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _InfoRow('CLABE', formatClabe(MockUser.clabe), onCopy: () => _copyToClipboard(MockUser.clabe, 'CLABE')),
                    _InfoRow('Institucion', 'Solvendom (SAYO)'),
                    _InfoRow('Telefono', MockUser.phone, onCopy: () => _copyToClipboard(MockUser.phone, 'Telefono')),
                    _InfoRow('Email', MockUser.email, onCopy: () => _copyToClipboard(MockUser.email, 'Email')),
                  ],
                ),
              ),
            ),
          ),

          // Cuenta section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Cuenta',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _MenuTile(
                      Icons.receipt_long_rounded, 'Estados de Cuenta', SayoColors.blue,
                      onTap: () => context.push('/estados-cuenta'),
                    ),
                    const Divider(height: 1, indent: 56),
                    _MenuTile(
                      Icons.swap_horiz_rounded, 'Movimientos', SayoColors.green,
                      onTap: () => context.push('/movimientos'),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Security — interactive toggles
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Seguridad',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _SettingToggle(
                      icon: Icons.fingerprint,
                      label: 'Face ID / Biometria',
                      value: _faceIdEnabled,
                      onChanged: (v) => setState(() => _faceIdEnabled = v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingToggle(
                      icon: Icons.lock_outline_rounded,
                      label: '2FA Verificacion',
                      value: _twoFaEnabled,
                      onChanged: (v) => setState(() => _twoFaEnabled = v),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingAction(
                      icon: Icons.pin_outlined,
                      label: 'Cambiar NIP',
                      onTap: _showChangeNip,
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingAction(
                      icon: Icons.devices_rounded,
                      label: 'Sesiones activas',
                      trailing: '1 dispositivo',
                      onTap: _showSessions,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Documents — tappable
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Text(
                'Documentos',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _DocTile('Contrato SAYO', 'Firmado 15 Feb 2026', onTap: () => _showDocument('Contrato SAYO')),
                    const Divider(height: 1, indent: 56),
                    _DocTile('Caratula de credito', 'Firmado 15 Feb 2026', onTap: () => _showDocument('Caratula de credito')),
                    const Divider(height: 1, indent: 56),
                    _DocTile('Pagare', 'Firmado 15 Feb 2026', onTap: () => _showDocument('Pagare')),
                    const Divider(height: 1, indent: 56),
                    _DocTile('Terminos y condiciones', 'Aceptado 15 Feb 2026', onTap: () => _showDocument('Terminos y condiciones')),
                    const Divider(height: 1, indent: 56),
                    _DocTile('Aviso de privacidad', 'Aceptado 15 Feb 2026', onTap: () => _showDocument('Aviso de privacidad')),
                  ],
                ),
              ),
            ),
          ),

          // Legal + help — tappable
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: SayoColors.beige, width: 0.5),
                ),
                child: Column(
                  children: [
                    _MenuTile(
                      Icons.auto_awesome, 'SAYO AI · Asistente', SayoColors.purple,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Usa el boton central del menu para abrir SAYO AI'),
                            backgroundColor: SayoColors.purple,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 56),
                    _MenuTile(
                      Icons.help_outline_rounded, 'Centro de ayuda', SayoColors.blue,
                      onTap: _showHelpCenter,
                    ),
                    const Divider(height: 1, indent: 56),
                    _MenuTile(
                      Icons.gavel_rounded, 'CONDUSEF', SayoColors.grisMed,
                      onTap: _showCondusef,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Logout
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showCerrarSesion,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: SayoColors.red, width: 1),
                        foregroundColor: SayoColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        'Cerrar sesion',
                        style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'SAYO v0.1.0 · SOLVENDOM SOFOM E.N.R.',
                    style: GoogleFonts.urbanist(
                      fontSize: 11,
                      color: SayoColors.grisLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Regulado por CONDUSEF · CNBV',
                    style: GoogleFonts.urbanist(
                      fontSize: 10,
                      color: SayoColors.grisLight,
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _KycStep extends StatelessWidget {
  final String label;
  final bool completed;
  final VoidCallback? onTap;

  const _KycStep(this.label, this.completed, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: completed ? SayoColors.green : SayoColors.beige,
                shape: BoxShape.circle,
              ),
              child: completed
                  ? const Icon(Icons.check, size: 14, color: SayoColors.white)
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.urbanist(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: completed ? SayoColors.gris : SayoColors.grisLight,
                ),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.chevron_right_rounded, size: 18, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _InfoRow(this.label, this.value, {this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris),
              ),
              if (onCopy != null) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onCopy,
                  child: const Icon(Icons.copy_rounded, size: 14, color: SayoColors.cafe),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggle({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 22, color: SayoColors.grisMed),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.gris),
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: SayoColors.green,
          ),
        ],
      ),
    );
  }
}

class _SettingAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingAction({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: SayoColors.grisMed),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.gris),
              ),
            ),
            if (trailing != null)
              Text(trailing!, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _DocTile(this.title, this.subtitle, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SayoColors.beige.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.description_outlined, size: 18, color: SayoColors.grisMed),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  Text(subtitle, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                ],
              ),
            ),
            const Icon(Icons.download_rounded, size: 18, color: SayoColors.cafe),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuTile(this.icon, this.label, this.color, {this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.gris),
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisLight),
          ],
        ),
      ),
    );
  }
}

class _PinField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _PinField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: true,
      keyboardType: TextInputType.number,
      maxLength: 4,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.urbanist(color: SayoColors.grisMed),
        counterText: '',
        filled: true,
        fillColor: SayoColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SayoColors.beige),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: SayoColors.beige),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: SayoColors.cafe),
        ),
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: SayoColors.grisMed),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpItem(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: SayoColors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: SayoColors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                Text(subtitle, style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 20, color: SayoColors.grisLight),
        ],
      ),
    );
  }
}

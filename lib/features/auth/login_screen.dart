import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passController = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _login() {
    if (_phoneController.text.isEmpty || _passController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa todos los campos'),
          backgroundColor: SayoColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/dashboard');
    });
  }

  void _loginBiometric() {
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
      context.go('/dashboard');
    });
  }

  void _showForgotPassword() {
    final emailCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 24),
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: SayoColors.cafe.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_reset_rounded, size: 28, color: SayoColors.cafe),
              ),
              const SizedBox(height: 16),
              Text(
                'Recuperar contrasena',
                style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
              const SizedBox(height: 8),
              Text(
                'Ingresa tu correo electronico y te enviaremos instrucciones para restablecer tu contrasena.',
                textAlign: TextAlign.center,
                style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icon(Icons.email_outlined, color: SayoColors.grisLight),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (emailCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Ingresa tu correo electronico'),
                        backgroundColor: SayoColors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    return;
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Instrucciones enviadas a ${emailCtrl.text.trim()}'),
                      backgroundColor: SayoColors.green,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                },
                child: const Text('Enviar instrucciones'),
              ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [SayoColors.cafe, SayoColors.cafeLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'S',
                          style: GoogleFonts.urbanist(
                            fontSize: 28, fontWeight: FontWeight.w800,
                            color: SayoColors.white, letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SAYO',
                      style: GoogleFonts.urbanist(
                        fontSize: 28, fontWeight: FontWeight.w800,
                        color: SayoColors.cafe, letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by SOLVENDOM',
                      style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight, letterSpacing: 2),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              Text(
                'Iniciar sesion',
                style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.gris),
              ),
              const SizedBox(height: 6),
              Text(
                'Ingresa tu telefono y contrasena',
                style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed),
              ),

              const SizedBox(height: 28),

              // Phone
              Text('Telefono', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: InputDecoration(
                  hintText: '33 1234 5678',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🇲🇽', style: GoogleFonts.urbanist(fontSize: 18)),
                        const SizedBox(width: 6),
                        Text('+52', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 20, color: SayoColors.beige),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Password
              Text('Contrasena', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
              const SizedBox(height: 8),
              TextField(
                controller: _passController,
                obscureText: _obscurePass,
                decoration: InputDecoration(
                  hintText: 'Tu contrasena',
                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: SayoColors.grisLight),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: SayoColors.grisLight,
                    ),
                    onPressed: () => setState(() => _obscurePass = !_obscurePass),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: Text(
                    'Olvide mi contrasena',
                    style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.cafe),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: SayoColors.white))
                    : const Text('Iniciar sesion'),
              ),

              const SizedBox(height: 16),

              // Biometric
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _loginBiometric,
                icon: const Icon(Icons.fingerprint_rounded, size: 22),
                label: const Text('Entrar con biometrico'),
              ),

              const SizedBox(height: 16),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: SayoColors.beige)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('o', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                  ),
                  const Expanded(child: Divider(color: SayoColors.beige)),
                ],
              ),

              const SizedBox(height: 16),

              // Register link
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No tienes cuenta? ',
                      style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Crear cuenta',
                        style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.cafe),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Legal
              Center(
                child: Text(
                  'SOLVENDOM, S.A.P.I. DE C.V., SOFOM, E.N.R.',
                  style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

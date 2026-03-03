import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 0;
  bool _isLoading = false;

  // Step 1 — Personal
  final _nameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _birthCtrl = TextEditingController();
  final _curpCtrl = TextEditingController();

  // Step 2 — Contact
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _otpSent = false;
  final List<TextEditingController> _otpCtrls = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocus = List.generate(6, (_) => FocusNode());

  // Step 3 — Security
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _lastNameCtrl.dispose();
    _birthCtrl.dispose();
    _curpCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    for (final c in _otpCtrls) {
      c.dispose();
    }
    for (final f in _otpFocus) {
      f.dispose();
    }
    super.dispose();
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _nameCtrl.text.isNotEmpty && _lastNameCtrl.text.isNotEmpty && _birthCtrl.text.isNotEmpty && _curpCtrl.text.length == 18;
      case 1:
        if (!_otpSent) return _phoneCtrl.text.length == 10;
        return _otpCtrls.every((c) => c.text.isNotEmpty);
      case 2:
        return _passCtrl.text.length >= 8 && _passCtrl.text == _confirmCtrl.text && _acceptTerms;
      default:
        return false;
    }
  }

  void _next() {
    if (_step == 1 && !_otpSent) {
      setState(() {
        _otpSent = true;
        _isLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          setState(() => _isLoading = false);
          _otpFocus[0].requestFocus();
        }
      });
      return;
    }

    if (_step < 2) {
      setState(() => _step++);
    } else {
      // Complete registration
      setState(() => _isLoading = true);
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() => _isLoading = false);
        context.go('/kyc');
      });
    }
  }

  void _back() {
    if (_step == 1 && _otpSent) {
      setState(() => _otpSent = false);
      return;
    }
    if (_step > 0) {
      setState(() => _step--);
    } else {
      context.go('/login');
    }
  }

  void _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime(now.year - 18, now.month, now.day),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: SayoColors.cafe, onPrimary: SayoColors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _birthCtrl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
                  ),
                  const Spacer(),
                  Text(
                    'Paso ${_step + 1} de 3',
                    style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: List.generate(3, (i) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                      decoration: BoxDecoration(
                        color: i <= _step ? SayoColors.cafe : SayoColors.beige,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _step == 0
                      ? _buildStep1()
                      : _step == 1
                          ? _buildStep2()
                          : _buildStep3(),
                ),
              ),
            ),

            // Bottom
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: Column(
                children: [
                  ElevatedButton(
                    onPressed: (_canContinue && !_isLoading) ? _next : null,
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: SayoColors.white))
                        : Text(_step == 2 ? 'Crear cuenta' : (_step == 1 && !_otpSent ? 'Enviar codigo' : 'Continuar')),
                  ),
                  if (_step == 0) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Ya tienes cuenta? ', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed)),
                          GestureDetector(
                            onTap: () => context.go('/login'),
                            child: Text('Iniciar sesion', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.cafe)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Personal data
  Widget _buildStep1() {
    return Column(
      key: const ValueKey('step1'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Datos personales', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        const SizedBox(height: 6),
        Text('Ingresa tu informacion como aparece en tu INE', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
        const SizedBox(height: 24),

        _FieldLabel('Nombre(s)'),
        const SizedBox(height: 6),
        TextField(
          controller: _nameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Jose Ignacio'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        _FieldLabel('Apellidos'),
        const SizedBox(height: 6),
        TextField(
          controller: _lastNameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Gonzalez Perez'),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),

        _FieldLabel('Fecha de nacimiento'),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _selectDate,
          child: AbsorbPointer(
            child: TextField(
              controller: _birthCtrl,
              decoration: const InputDecoration(
                hintText: 'DD/MM/AAAA',
                suffixIcon: Icon(Icons.calendar_today_rounded, color: SayoColors.grisLight, size: 20),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        _FieldLabel('CURP'),
        const SizedBox(height: 6),
        TextField(
          controller: _curpCtrl,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
            LengthLimitingTextInputFormatter(18),
          ],
          decoration: InputDecoration(
            hintText: 'GOPL950101HJCNRS09',
            suffixIcon: _curpCtrl.text.length == 18
                ? const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 20)
                : null,
          ),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Step 2: Contact + OTP
  Widget _buildStep2() {
    if (!_otpSent) {
      return Column(
        key: const ValueKey('step2a'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Contacto', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          const SizedBox(height: 6),
          Text('Verifica tu numero de telefono', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
          const SizedBox(height: 24),

          _FieldLabel('Telefono'),
          const SizedBox(height: 6),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
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
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 18),

          _FieldLabel('Correo electronico'),
          const SizedBox(height: 6),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              hintText: 'correo@ejemplo.com',
              prefixIcon: Icon(Icons.email_outlined, color: SayoColors.grisLight),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    // OTP verification
    return Column(
      key: const ValueKey('step2b'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Verificacion', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        const SizedBox(height: 6),
        Text(
          'Ingresa el codigo de 6 digitos enviado al +52 ${_phoneCtrl.text}',
          style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
        ),
        const SizedBox(height: 32),

        // OTP fields
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(6, (i) {
            return SizedBox(
              width: 46,
              child: TextField(
                controller: _otpCtrls[i],
                focusNode: _otpFocus[i],
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w700, color: SayoColors.gris),
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _otpCtrls[i].text.isNotEmpty ? SayoColors.cafe : SayoColors.beige,
                      width: _otpCtrls[i].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: _otpCtrls[i].text.isNotEmpty ? SayoColors.cafe : SayoColors.beige,
                      width: _otpCtrls[i].text.isNotEmpty ? 2 : 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: SayoColors.cafe, width: 2),
                  ),
                  filled: true,
                  fillColor: SayoColors.white,
                ),
                onChanged: (v) {
                  setState(() {});
                  if (v.isNotEmpty && i < 5) {
                    _otpFocus[i + 1].requestFocus();
                  }
                  if (v.isEmpty && i > 0) {
                    _otpFocus[i - 1].requestFocus();
                  }
                },
              ),
            );
          }),
        ),

        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Codigo reenviado'),
                  backgroundColor: SayoColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text('Reenviar codigo', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.cafe)),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // Step 3: Security
  Widget _buildStep3() {
    return Column(
      key: const ValueKey('step3'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Crea tu contrasena', style: GoogleFonts.urbanist(fontSize: 22, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        const SizedBox(height: 6),
        Text('Minimo 8 caracteres con letras y numeros', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
        const SizedBox(height: 24),

        _FieldLabel('Contrasena'),
        const SizedBox(height: 6),
        TextField(
          controller: _passCtrl,
          obscureText: _obscure1,
          decoration: InputDecoration(
            hintText: 'Minimo 8 caracteres',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: SayoColors.grisLight),
            suffixIcon: IconButton(
              icon: Icon(_obscure1 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: SayoColors.grisLight),
              onPressed: () => setState(() => _obscure1 = !_obscure1),
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        // Password strength
        if (_passCtrl.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          _PasswordStrength(password: _passCtrl.text),
        ],

        const SizedBox(height: 16),

        _FieldLabel('Confirmar contrasena'),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmCtrl,
          obscureText: _obscure2,
          decoration: InputDecoration(
            hintText: 'Repite tu contrasena',
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: SayoColors.grisLight),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confirmCtrl.text.isNotEmpty && _passCtrl.text == _confirmCtrl.text)
                  const Icon(Icons.check_circle_rounded, color: SayoColors.green, size: 20),
                IconButton(
                  icon: Icon(_obscure2 ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: SayoColors.grisLight),
                  onPressed: () => setState(() => _obscure2 = !_obscure2),
                ),
              ],
            ),
          ),
          onChanged: (_) => setState(() {}),
        ),

        const SizedBox(height: 24),

        // Terms
        GestureDetector(
          onTap: () => setState(() => _acceptTerms = !_acceptTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: _acceptTerms ? SayoColors.cafe : SayoColors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _acceptTerms ? SayoColors.cafe : SayoColors.beige, width: 1.5),
                ),
                child: _acceptTerms ? const Icon(Icons.check_rounded, size: 16, color: SayoColors.white) : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'Acepto los ',
                    style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                    children: [
                      TextSpan(
                        text: 'Terminos y Condiciones',
                        style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.cafe),
                      ),
                      const TextSpan(text: ' y el '),
                      TextSpan(
                        text: 'Aviso de Privacidad',
                        style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.cafe),
                      ),
                      const TextSpan(text: ' de SOLVENDOM SOFOM E.N.R.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris));
  }
}

class _PasswordStrength extends StatelessWidget {
  final String password;
  const _PasswordStrength({required this.password});

  @override
  Widget build(BuildContext context) {
    final hasLength = password.length >= 8;
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#\$%\^&\*]'));
    final score = [hasLength, hasLetter, hasNumber, hasSpecial].where((b) => b).length;

    Color barColor;
    String label;
    switch (score) {
      case 1:
        barColor = SayoColors.red;
        label = 'Debil';
        break;
      case 2:
        barColor = SayoColors.orange;
        label = 'Regular';
        break;
      case 3:
        barColor = SayoColors.green;
        label = 'Buena';
        break;
      case 4:
        barColor = SayoColors.green;
        label = 'Fuerte';
        break;
      default:
        barColor = SayoColors.beige;
        label = '';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < score ? barColor : SayoColors.beige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: barColor)),
      ],
    );
  }
}

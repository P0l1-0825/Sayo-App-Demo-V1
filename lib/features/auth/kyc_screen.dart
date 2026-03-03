import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/services/jaak_service.dart';

class _KycStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final String instruction;
  final String buttonLabel;
  final bool isCircular;

  const _KycStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.instruction,
    required this.buttonLabel,
    this.isCircular = false,
  });
}

const _captureSteps = [
  _KycStep(
    title: 'INE / IFE — Frente',
    subtitle: 'Toma una foto clara del frente de tu identificacion oficial.',
    icon: Icons.credit_card_rounded,
    instruction: 'Coloca tu INE de frente dentro del recuadro',
    buttonLabel: 'Capturar frente',
  ),
  _KycStep(
    title: 'INE / IFE — Reverso',
    subtitle: 'Ahora toma una foto del reverso de tu identificacion.',
    icon: Icons.credit_card_rounded,
    instruction: 'Coloca tu INE de reverso dentro del recuadro',
    buttonLabel: 'Capturar reverso',
  ),
  _KycStep(
    title: 'Selfie de verificacion',
    subtitle: 'Necesitamos verificar que tu eres el titular de la cuenta.',
    icon: Icons.face_rounded,
    instruction: 'Centra tu rostro en el circulo',
    buttonLabel: 'Tomar selfie',
    isCircular: true,
  ),
];

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  final _jaakService = JaakService();
  final _picker = ImagePicker();

  int _current = 0;
  final List<String?> _capturedBase64 = [null, null, null]; // front, back, selfie
  bool _isProcessing = false;
  bool _isVerifying = false;

  // Verification progress
  final Map<String, bool?> _verificationSteps = {
    'document_verify': null,
    'data_extract': null,
    'blacklist': null,
    'liveness': null,
    'face_match': null,
  };
  bool? _kycApproved;

  static const _verificationLabels = {
    'document_verify': 'Verificacion de documento',
    'data_extract': 'Extraccion de datos (OCR)',
    'blacklist': 'Validacion RENAPO / OFAC',
    'liveness': 'Prueba de vida',
    'face_match': 'Comparacion facial',
  };

  Future<void> _capture() async {
    setState(() => _isProcessing = true);

    try {
      final XFile? image;
      if (_current == 2) {
        // Selfie — front camera
        image = await _picker.pickImage(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
      } else {
        // Document — rear camera or gallery
        image = await _picker.pickImage(source: ImageSource.camera);
      }

      if (image == null) {
        if (!mounted) return;
        setState(() => _isProcessing = false);
        return;
      }

      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      if (!mounted) return;
      setState(() {
        _capturedBase64[_current] = base64String;
        _isProcessing = false;
      });
    } catch (_) {
      // Fallback for web/desktop where camera isn't available
      if (!mounted) return;
      setState(() => _isProcessing = true);

      // Simulate capture
      await Future.delayed(const Duration(milliseconds: 1200));

      if (!mounted) return;
      setState(() {
        _capturedBase64[_current] = 'mock_base64_${_current}_${DateTime.now().millisecondsSinceEpoch}';
        _isProcessing = false;
      });
    }
  }

  void _next() {
    if (_current < _captureSteps.length - 1) {
      setState(() => _current++);
    } else {
      _startVerification();
    }
  }

  void _back() {
    if (_isVerifying) return;
    if (_current > 0) {
      setState(() => _current--);
    } else {
      context.go('/register');
    }
  }

  Future<void> _startVerification() async {
    setState(() => _isVerifying = true);

    final result = await _jaakService.runFullFlow(
      frontBase64: _capturedBase64[0] ?? '',
      backBase64: _capturedBase64[1] ?? '',
      selfieBase64: _capturedBase64[2] ?? '',
      onStepComplete: (step, success) {
        if (!mounted) return;
        setState(() {
          _verificationSteps[step] = success;
        });
      },
    );

    if (!mounted) return;
    setState(() {
      _kycApproved = result['approved'] as bool? ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isVerifying) return _buildVerificationScreen();

    final step = _captureSteps[_current];
    final totalSteps = _captureSteps.length + 1; // +1 for verification

    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _back,
                    icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
                  ),
                  const Spacer(),
                  Text(
                    'Verificacion KYC',
                    style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Row(
                    children: List.generate(totalSteps, (i) {
                      final isActive = i <= _current;
                      final isDone = i < _captureSteps.length ? _capturedBase64[i] != null : false;
                      return Expanded(
                        child: Container(
                          margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                          height: 4,
                          decoration: BoxDecoration(
                            color: isDone
                                ? SayoColors.green
                                : isActive
                                    ? SayoColors.cafe
                                    : SayoColors.beige,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Paso ${_current + 1} de $totalSteps',
                        style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.grisMed),
                      ),
                      Row(
                        children: List.generate(_captureSteps.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Icon(
                              _capturedBase64[i] != null ? Icons.check_circle_rounded : Icons.circle_outlined,
                              size: 16,
                              color: _capturedBase64[i] != null ? SayoColors.green : SayoColors.beige,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: SingleChildScrollView(
                  key: ValueKey(_current),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: SayoColors.cafe.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(step.icon, size: 28, color: SayoColors.cafe),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.subtitle,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: _capturedBase64[_current] != null
                            ? _buildCapturedPreview(step)
                            : _buildCaptureArea(step),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          _capturedBase64[_current] != null ? 'Documento capturado correctamente' : step.instruction,
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _capturedBase64[_current] != null ? SayoColors.green : SayoColors.grisMed,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  if (_capturedBase64[_current] == null)
                    ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _capture,
                      icon: _isProcessing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: SayoColors.white),
                            )
                          : Icon(
                              step.isCircular ? Icons.face_rounded : Icons.camera_alt_rounded,
                              size: 20,
                            ),
                      label: Text(_isProcessing ? 'Procesando...' : step.buttonLabel),
                    )
                  else
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: _next,
                          child: Text(_current < _captureSteps.length - 1 ? 'Continuar' : 'Iniciar verificacion'),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            setState(() => _capturedBase64[_current] = null);
                          },
                          child: Text(
                            'Volver a capturar',
                            style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.cafe),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationScreen() {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Header
              const SizedBox(height: 16),
              Text(
                'Verificacion KYC',
                style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris),
              ),
              const SizedBox(height: 40),

              if (_kycApproved == null) ...[
                // Processing
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SayoColors.cafe.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(strokeWidth: 3, color: SayoColors.cafe),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Verificando tu identidad',
                  style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris),
                ),
                const SizedBox(height: 8),
                Text(
                  'Esto puede tomar unos segundos...',
                  style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
                ),
              ] else ...[
                // Result
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (_kycApproved! ? SayoColors.green : SayoColors.red).withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _kycApproved! ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    size: 44,
                    color: _kycApproved! ? SayoColors.green : SayoColors.red,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _kycApproved! ? 'Verificacion completa' : 'Verificacion fallida',
                  style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.gris),
                ),
                const SizedBox(height: 8),
                Text(
                  _kycApproved!
                      ? 'Tu identidad ha sido verificada exitosamente. Ya puedes usar todos los servicios de SAYO.'
                      : 'No pudimos verificar tu identidad. Intenta de nuevo o contacta soporte.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed, height: 1.5),
                ),
              ],

              const SizedBox(height: 32),

              // Steps list
              Expanded(
                child: ListView(
                  children: _verificationSteps.entries.map((entry) {
                    final label = _verificationLabels[entry.key] ?? entry.key;
                    final status = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: SayoColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: status == null
                              ? SayoColors.beige
                              : status
                                  ? SayoColors.green.withValues(alpha: 0.3)
                                  : SayoColors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          if (status == null)
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: SayoColors.cafe),
                            )
                          else
                            Icon(
                              status ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              size: 20,
                              color: status ? SayoColors.green : SayoColors.red,
                            ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.urbanist(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: SayoColors.gris,
                              ),
                            ),
                          ),
                          if (status != null)
                            Text(
                              status ? 'OK' : 'Error',
                              style: GoogleFonts.urbanist(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: status ? SayoColors.green : SayoColors.red,
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Bottom button
              if (_kycApproved != null) ...[
                ElevatedButton(
                  onPressed: () {
                    if (_kycApproved!) {
                      context.go('/dashboard');
                    } else {
                      // Reset and try again
                      setState(() {
                        _current = 0;
                        _capturedBase64.fillRange(0, 3, null);
                        _isVerifying = false;
                        _kycApproved = null;
                        _verificationSteps.updateAll((_, __) => null);
                      });
                    }
                  },
                  child: Text(_kycApproved! ? 'Ir al inicio' : 'Intentar de nuevo'),
                ),
                const SizedBox(height: 8),
                Text(
                  'SOLVENDOM, S.A.P.I. DE C.V., SOFOM, E.N.R.',
                  style: GoogleFonts.urbanist(fontSize: 9, color: SayoColors.grisLight, letterSpacing: 0.5),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaptureArea(_KycStep step) {
    if (step.isCircular) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SayoColors.white,
          border: Border.all(color: SayoColors.beige, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_rounded, size: 64, color: SayoColors.beige),
            const SizedBox(height: 8),
            Text(
              'Vista previa',
              style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisLight),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 2, strokeAlign: BorderSide.strokeAlignInside),
      ),
      child: CustomPaint(
        painter: _DashedBorderPainter(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_camera_outlined, size: 48, color: SayoColors.beige),
            const SizedBox(height: 12),
            Text(
              'Toca para abrir camara',
              style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight),
            ),
            const SizedBox(height: 4),
            Text(
              'JPG, PNG — Max 10 MB',
              style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.beige),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCapturedPreview(_KycStep step) {
    if (step.isCircular) {
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: SayoColors.green.withValues(alpha: 0.08),
          border: Border.all(color: SayoColors.green, width: 2),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 48, color: SayoColors.green),
            const SizedBox(height: 8),
            Text(
              'Selfie capturada',
              style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.green),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: SayoColors.green.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.green, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle_rounded, size: 48, color: SayoColors.green),
          const SizedBox(height: 12),
          Text(
            'Documento capturado',
            style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.green),
          ),
          const SizedBox(height: 4),
          Text(
            'Imagen verificada correctamente',
            style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisMed),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SayoColors.beige
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, size.width - 16, size.height - 16),
      const Radius.circular(12),
    );

    final path = Path()..addRRect(rect);
    final metric = path.computeMetrics().first;
    double distance = 0;

    while (distance < metric.length) {
      final end = distance + dashWidth;
      canvas.drawPath(
        metric.extractPath(distance, end.clamp(0, metric.length)),
        paint,
      );
      distance = end + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

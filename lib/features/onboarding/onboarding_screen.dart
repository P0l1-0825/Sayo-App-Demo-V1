import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/sayo_colors.dart';

class _SlideData {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String accent;

  const _SlideData({
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.accent,
  });
}

const _slides = [
  _SlideData(
    icon: Icons.description_rounded,
    iconBg: SayoColors.cafe,
    title: 'Tu credito,\nen minutos',
    subtitle: 'Solicita, aprueba y dispon de fondos\ndesde tu celular. 100% digital,\nsin burocracia ni filas.',
    accent: 'Sin papeleo  ·  Sin sucursales',
  ),
  _SlideData(
    icon: Icons.credit_card_rounded,
    iconBg: SayoColors.orange,
    title: 'Tarjeta SAYO\nMasterCard',
    subtitle: 'Virtual al instante, fisica a tu puerta.\nCompra en cualquier tienda del mundo\ny controla tu gasto desde la app.',
    accent: 'Virtual + Fisica  ·  Control total',
  ),
  _SlideData(
    icon: Icons.grid_view_rounded,
    iconBg: SayoColors.blue,
    title: 'Todo en un\necosistema',
    subtitle: 'SPEI 24/7 · Cobrar con QR · Adelanto\nde nomina · Marketplace de beneficios.\nTu vida financiera, simplificada.',
    accent: 'SPEI  ·  QR  ·  Nomina  ·  Marketplace',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      context.go('/login');
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [SayoColors.cafe, SayoColors.cafeLight],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'S',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: SayoColors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'SAYO',
                        style: GoogleFonts.urbanist(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: SayoColors.cafe,
                          letterSpacing: 3,
                        ),
                      ),
                    ],
                  ),
                  // Skip
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: Text(
                        'Saltar',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: SayoColors.grisMed,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) {
                  final slide = _slides[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: slide.iconBg.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            size: 52,
                            color: slide.iconBg,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Title
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: SayoColors.gris,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Subtitle
                        Text(
                          slide.subtitle,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.urbanist(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: SayoColors.grisMed,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Accent badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: SayoColors.cafe.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            slide.accent,
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: SayoColors.cafe,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _slides.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: SayoColors.cafe,
                      dotColor: SayoColors.beige,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3.5,
                      spacing: 8,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _slides.length - 1 ? 'Comenzar' : 'Siguiente',
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_currentPage == _slides.length - 1)
                    Text(
                      'SOLVENDOM, S.A.P.I. DE C.V., SOFOM, E.N.R.',
                      style: GoogleFonts.urbanist(
                        fontSize: 9,
                        color: SayoColors.grisLight,
                        letterSpacing: 0.5,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

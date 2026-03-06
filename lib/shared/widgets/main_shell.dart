import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/tarjetas')) return 1;
    if (location.startsWith('/credito')) return 3;
    if (location.startsWith('/perfil')) return 4;
    return 0;
  }

  void _openSayoAI(BuildContext context) {
    context.push('/sayo-ai');
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      body: child,
      extendBody: false,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: SayoColors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Row(
              children: [
                Expanded(
                  child: _TabItem(
                    icon: Icons.home_rounded,
                    label: 'Inicio',
                    isActive: index == 0,
                    onTap: () => context.go('/dashboard'),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.credit_card_rounded,
                    label: 'Tarjetas',
                    isActive: index == 1,
                    onTap: () => context.go('/tarjetas'),
                  ),
                ),
                Expanded(
                  child: _CenterAIButton(onTap: () => _openSayoAI(context)),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.trending_up_rounded,
                    label: 'Credito',
                    isActive: index == 3,
                    onTap: () => context.go('/credito'),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: Icons.person_rounded,
                    label: 'Perfil',
                    isActive: index == 4,
                    onTap: () => context.go('/perfil'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterAIButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CenterAIButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SayoColors.purple, Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: SayoColors.purple.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: SayoColors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'SAYO AI',
            style: GoogleFonts.urbanist(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: SayoColors.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: isActive ? SayoColors.cafe.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: isActive ? SayoColors.cafe : SayoColors.grisLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.urbanist(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? SayoColors.cafe : SayoColors.grisLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SAYO AI Interactive Chat Sheet ──

class _SayoAISheet extends StatefulWidget {
  const _SayoAISheet();

  @override
  State<_SayoAISheet> createState() => _SayoAISheetState();
}

class _SayoAISheetState extends State<_SayoAISheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _showSuggestions = true;
  bool _isTyping = false;

  static const _mockResponses = {
    'gastos': 'He analizado tus gastos del ultimo mes:\n\n'
        '• Compras en linea: \$1,299 (25%)\n'
        '• Servicios: \$847 (16%)\n'
        '• Transporte: \$189 (4%)\n'
        '• Tienda: \$156 (3%)\n\n'
        'Sugerencia: Tu gasto en compras online subio 15% vs el mes anterior. Te recomiendo establecer un limite mensual.',
    'resumen': 'Aqui esta tu resumen financiero:\n\n'
        '• Saldo disponible: \$47,520.83\n'
        '• Credito usado: \$42,000 de \$150,000 (28%)\n'
        '• Proximo pago: \$3,500 el 15 Mar\n'
        '• KYC: Nivel 3 (completo)\n\n'
        'Tu salud financiera es buena. Estas usando solo el 28% de tu linea de credito.',
    'credito': 'Simulacion de credito rapida:\n\n'
        'Con tu disponible de \$108,000:\n'
        '• 6 meses → \$18,280/mes\n'
        '• 12 meses → \$9,436/mes\n'
        '• 24 meses → \$4,914/mes\n\n'
        'Tasa anual: 9.0%. Ve a la seccion de Credito para una simulacion detallada.',
    'pago': 'Tus recordatorios de pago:\n\n'
        '• Pago credito: \$3,500 → 15 Mar 2026 (en 12 dias)\n'
        '• CFE: ~\$850 → 28 Mar 2026\n\n'
        'Tienes fondos suficientes para cubrir ambos pagos. Te notificare 3 dias antes de cada vencimiento.',
  };

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _showSuggestions = false;
      _isTyping = true;
    });
    _controller.clear();

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMessage(text: _getResponse(text), isUser: false));
      });
      _scrollToBottom();
    });
  }

  String _getResponse(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('gasto') || lower.contains('analiza')) {
      return _mockResponses['gastos']!;
    }
    if (lower.contains('resumen') || lower.contains('estado') || lower.contains('saldo')) {
      return _mockResponses['resumen']!;
    }
    if (lower.contains('credito') || lower.contains('simula') || lower.contains('prestamo')) {
      return _mockResponses['credito']!;
    }
    if (lower.contains('pago') || lower.contains('recordatorio') || lower.contains('alerta')) {
      return _mockResponses['pago']!;
    }
    return 'Entiendo tu pregunta. Como asistente financiero de SAYO, puedo ayudarte con:\n\n'
        '• Analizar tus gastos y patrones\n'
        '• Darte un resumen financiero\n'
        '• Simular creditos\n'
        '• Configurar recordatorios de pago\n\n'
        'Intenta preguntar sobre alguno de estos temas.';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _onSuggestionTap(String title) {
    _sendMessage(title);
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, dragController) {
        return Container(
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SayoColors.beige,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [SayoColors.purple, Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: SayoColors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SAYO AI',
                            style: GoogleFonts.urbanist(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: SayoColors.gris,
                            ),
                          ),
                          Text(
                            'Tu asistente financiero',
                            style: GoogleFonts.urbanist(
                              fontSize: 12,
                              color: SayoColors.grisLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_messages.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _messages.clear();
                            _showSuggestions = true;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: SayoColors.beige.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.refresh_rounded, size: 18, color: SayoColors.grisMed),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: SayoColors.beige),

              // Chat area
              Expanded(
                child: _showSuggestions && _messages.isEmpty
                    ? ListView(
                        controller: dragController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        children: [
                          // Welcome message
                          _AIChatBubble(
                            text: 'Hola Benito! Soy SAYO, tu asistente financiero. ¿En que puedo ayudarte hoy?',
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Sugerencias',
                            style: GoogleFonts.urbanist(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: SayoColors.grisMed,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _AISuggestionCard(
                            emoji: '💡',
                            title: 'Analiza mis gastos',
                            subtitle: 'Revisa patrones y sugerencias de ahorro',
                            onTap: () => _onSuggestionTap('Analiza mis gastos'),
                          ),
                          _AISuggestionCard(
                            emoji: '📊',
                            title: 'Resumen financiero',
                            subtitle: 'Estado actual de tu credito y cuenta',
                            onTap: () => _onSuggestionTap('Resumen financiero'),
                          ),
                          _AISuggestionCard(
                            emoji: '🎯',
                            title: 'Simula un credito',
                            subtitle: 'Calcula pagos con diferentes plazos',
                            onTap: () => _onSuggestionTap('Simula un credito'),
                          ),
                          _AISuggestionCard(
                            emoji: '🔔',
                            title: 'Recordatorios de pago',
                            subtitle: 'Configura alertas para no olvidar',
                            onTap: () => _onSuggestionTap('Recordatorios de pago'),
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, i) {
                          if (i == _messages.length && _isTyping) {
                            return _TypingIndicator();
                          }
                          final msg = _messages[i];
                          if (msg.isUser) {
                            return _UserChatBubble(text: msg.text);
                          }
                          return _AIChatBubble(text: msg.text);
                        },
                      ),
              ),

              // Input bar
              Container(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 8,
                  top: 10,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 10,
                ),
                decoration: BoxDecoration(
                  color: SayoColors.white,
                  border: Border(top: BorderSide(color: SayoColors.beige.withValues(alpha: 0.5))),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _sendMessage,
                        style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.gris),
                        decoration: InputDecoration(
                          hintText: 'Preguntale algo a SAYO...',
                          hintStyle: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _sendMessage(_controller.text),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [SayoColors.purple, Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.send_rounded, color: SayoColors.white, size: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  const _ChatMessage({required this.text, required this.isUser});
}

class _AIChatBubble extends StatelessWidget {
  final String text;
  const _AIChatBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SayoColors.purple, Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: SayoColors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SayoColors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                border: Border.all(color: SayoColors.beige, width: 0.5),
              ),
              child: Text(
                text,
                style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.gris, height: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserChatBubble extends StatelessWidget {
  final String text;
  const _UserChatBubble({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 40),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: SayoColors.cafe,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.white, height: 1.4),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 40),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [SayoColors.purple, Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.auto_awesome, color: SayoColors.white, size: 14),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _Dot(delay: 0),
                const SizedBox(width: 4),
                _Dot(delay: 1),
                const SizedBox(width: 4),
                _Dot(delay: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _anim = Tween(begin: 0.3, end: 0.8).animate(CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    ));
    Future.delayed(Duration(milliseconds: widget.delay * 200), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: SayoColors.purple.withValues(alpha: _anim.value),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _AISuggestionCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _AISuggestionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SayoColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: SayoColors.beige, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SayoColors.purple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(emoji, style: const TextStyle(fontSize: 18))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.urbanist(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: SayoColors.gris,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.urbanist(
                      fontSize: 12,
                      color: SayoColors.grisLight,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: SayoColors.grisLight, size: 20),
          ],
        ),
      ),
    );
  }
}

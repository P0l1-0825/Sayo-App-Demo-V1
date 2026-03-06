import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';

class TarjetasScreen extends StatefulWidget {
  const TarjetasScreen({super.key});

  @override
  State<TarjetasScreen> createState() => _TarjetasScreenState();
}

class _TarjetasScreenState extends State<TarjetasScreen> {
  bool _showCvv = false;
  bool _isLocked = false;
  Timer? _cvvTimer;
  int _cvvCountdown = 0;
  int _selectedCard = 0;

  void _revealCvv() {
    setState(() {
      _showCvv = true;
      _cvvCountdown = 30;
    });
    _cvvTimer?.cancel();
    _cvvTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { timer.cancel(); return; }
      setState(() {
        _cvvCountdown--;
        if (_cvvCountdown <= 0) {
          _showCvv = false;
          timer.cancel();
        }
      });
    });
  }

  void _toggleLock() {
    final willLock = !_isLocked;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SayoColors.cream,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(willLock ? Icons.lock_rounded : Icons.lock_open_rounded, color: willLock ? SayoColors.red : SayoColors.green, size: 22),
            const SizedBox(width: 10),
            Text(
              willLock ? 'Bloquear tarjeta?' : 'Desbloquear tarjeta?',
              style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w800, color: SayoColors.gris),
            ),
          ],
        ),
        content: Text(
          willLock
              ? 'Tu tarjeta terminada en ${_selectedCard == 0 ? '4832' : '9156'} sera bloqueada temporalmente. No podras realizar compras.'
              : 'Tu tarjeta sera desbloqueada y podras realizar compras nuevamente.',
          style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancelar', style: GoogleFonts.urbanist(fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: willLock ? SayoColors.red : SayoColors.green,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _isLocked = willLock);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    willLock ? 'Tarjeta bloqueada' : 'Tarjeta desbloqueada',
                    style: GoogleFonts.urbanist(),
                  ),
                  backgroundColor: willLock ? SayoColors.red : SayoColors.green,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(willLock ? 'Bloquear' : 'Desbloquear'),
          ),
        ],
      ),
    );
  }

  void _showLimits() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _LimitsSheet(),
    );
  }

  void _onWallet(String wallet) {
    final last4 = _selectedCard == 0 ? '4832' : '9156';
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: SayoColors.cream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color: (wallet == 'Apple Pay' ? SayoColors.gris : SayoColors.blue).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                wallet == 'Apple Pay' ? Icons.apple : Icons.g_mobiledata_rounded,
                color: wallet == 'Apple Pay' ? SayoColors.gris : SayoColors.blue,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text('Agregar a $wallet', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            const SizedBox(height: 8),
            Text(
              'Tu tarjeta SAYO terminada en $last4 se vinculara a $wallet para pagos sin contacto.',
              textAlign: TextAlign.center,
              style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Tarjeta', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                    Text('SAYO •••• $last4', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Tipo', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                    Text(_selectedCard == 0 ? 'Virtual' : 'Fisica', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  ]),
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Wallet', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                    Text(wallet, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                  ]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Tarjeta vinculada a $wallet exitosamente', style: GoogleFonts.urbanist()),
                    backgroundColor: SayoColors.green,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              },
              child: Text('Vincular a $wallet'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cvvTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SayoColors.cream,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 16, left: 20, right: 20, bottom: 8),
              child: Text('Mis Tarjetas', style: GoogleFonts.urbanist(fontSize: 24, fontWeight: FontWeight.w800, color: SayoColors.gris)),
            ),
          ),

          // Card carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 220,
              child: PageView(
                onPageChanged: (i) => setState(() {
                  _selectedCard = i;
                  _showCvv = false;
                  _cvvTimer?.cancel();
                }),
                children: [
                  _CardWidget(
                    type: 'Virtual', last4: '4832', showCvv: _showCvv, cvv: '847', expiry: '03/28',
                    gradient: const [SayoColors.cafe, SayoColors.cafeLight], isLocked: _isLocked,
                  ),
                  _CardWidget(
                    type: 'Fisica', last4: '9156', showCvv: false, cvv: '291', expiry: '07/29',
                    gradient: const [Color(0xFF1A1A2E), Color(0xFF16213E)], isLocked: false,
                  ),
                ],
              ),
            ),
          ),

          // Dots
          SliverToBoxAdapter(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(2, (i) => Container(
                width: _selectedCard == i ? 24 : 8, height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                decoration: BoxDecoration(color: _selectedCard == i ? SayoColors.cafe : SayoColors.beige, borderRadius: BorderRadius.circular(4)),
              )),
            ),
          ),

          // Action chips
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionChip(
                      icon: Icons.visibility_rounded,
                      label: _showCvv ? 'CVV: 847 ($_cvvCountdown s)' : 'Ver CVV',
                      onTap: _revealCvv,
                      active: _showCvv,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionChip(
                      icon: _isLocked ? Icons.lock_open_rounded : Icons.lock_rounded,
                      label: _isLocked ? 'Desbloquear' : 'Bloquear',
                      onTap: _toggleLock,
                      active: _isLocked,
                      activeColor: SayoColors.red,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionChip(
                      icon: Icons.tune_rounded,
                      label: 'Limites',
                      onTap: _showLimits,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Wallets
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text('Agregar a wallet', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _WalletButton(label: 'Apple Pay', icon: Icons.apple, onTap: () => _onWallet('Apple Pay')),
                  const SizedBox(width: 10),
                  _WalletButton(label: 'Google Pay', icon: Icons.g_mobiledata_rounded, onTap: () => _onWallet('Google Pay')),
                ],
              ),
            ),
          ),

          // Spending
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Text('Gastos del mes', style: GoogleFonts.urbanist(fontSize: 16, fontWeight: FontWeight.w700, color: SayoColors.gris)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: SayoColors.beige, width: 0.5)),
                child: Column(
                  children: [
                    Text(formatMoney(8491.50), style: GoogleFonts.urbanist(fontSize: 28, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                    const SizedBox(height: 4),
                    Text('Total gastado en marzo', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
                    const SizedBox(height: 16),
                    _SpendingCategory('Comida', 3200, 0.38, SayoColors.orange),
                    _SpendingCategory('Transporte', 2100, 0.25, SayoColors.blue),
                    _SpendingCategory('Compras', 1891, 0.22, SayoColors.purple),
                    _SpendingCategory('Servicios', 1300, 0.15, SayoColors.green),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}

// --- LIMITS SHEET ---

class _LimitsSheet extends StatefulWidget {
  const _LimitsSheet();
  @override
  State<_LimitsSheet> createState() => _LimitsSheetState();
}

class _LimitsSheetState extends State<_LimitsSheet> {
  double _dailyLimit = 15000;
  double _onlineLimit = 10000;
  bool _intlEnabled = false;
  bool _contactlessEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: SayoColors.cafe.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.tune_rounded, color: SayoColors.cafe, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Limites de tarjeta', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
          ]),
          const SizedBox(height: 24),

          // Daily limit
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Limite diario', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
            Text(formatMoney(_dailyLimit), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: SayoColors.cafe)),
          ]),
          Slider(value: _dailyLimit, min: 1000, max: 50000, divisions: 49, activeColor: SayoColors.cafe, inactiveColor: SayoColors.beige,
            onChanged: (v) => setState(() => _dailyLimit = v)),
          const SizedBox(height: 8),

          // Online limit
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Limite compras en linea', style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
            Text(formatMoney(_onlineLimit), style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w700, color: SayoColors.cafe)),
          ]),
          Slider(value: _onlineLimit, min: 0, max: 30000, divisions: 30, activeColor: SayoColors.cafe, inactiveColor: SayoColors.beige,
            onChanged: (v) => setState(() => _onlineLimit = v)),
          const SizedBox(height: 12),

          // Toggles
          _LimitToggle('Compras internacionales', _intlEnabled, (v) => setState(() => _intlEnabled = v)),
          _LimitToggle('Pago contactless (NFC)', _contactlessEnabled, (v) => setState(() => _contactlessEnabled = v)),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Limites actualizados', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              );
            },
            child: const Text('Guardar cambios'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _LimitToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _LimitToggle(this.label, this.value, this.onChanged);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w500, color: SayoColors.gris)),
          Switch.adaptive(value: value, onChanged: onChanged, activeColor: SayoColors.cafe),
        ],
      ),
    );
  }
}

// --- CARD WIDGET ---

class _CardWidget extends StatelessWidget {
  final String type, last4, cvv, expiry;
  final bool showCvv, isLocked;
  final List<Color> gradient;

  const _CardWidget({required this.type, required this.last4, required this.showCvv, required this.cvv, required this.expiry, required this.gradient, this.isLocked = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: gradient.first.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('SAYO', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w800, color: SayoColors.white, letterSpacing: 4)),
                    Row(children: [
                      if (isLocked) Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(color: SayoColors.red.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                        child: Row(children: [
                          const Icon(Icons.lock_rounded, size: 10, color: SayoColors.white),
                          const SizedBox(width: 4),
                          Text('Bloqueada', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: SayoColors.white)),
                        ]),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(type, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                      ),
                    ]),
                  ]),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('····  ····  ····  $last4', style: GoogleFonts.urbanist(fontSize: 20, fontWeight: FontWeight.w600, color: SayoColors.white, letterSpacing: 2)),
                      if (showCvv) ...[
                        const SizedBox(height: 4),
                        Text('CVV: $cvv', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white.withValues(alpha: 0.9))),
                      ],
                    ],
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('JOSE IGNACIO BENITO', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.6), letterSpacing: 1)),
                      Text(expiry, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white.withValues(alpha: 0.8))),
                    ]),
                    Row(children: [
                      Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.9), shape: BoxShape.circle)),
                      Transform.translate(offset: const Offset(-10, 0), child: Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.9), shape: BoxShape.circle))),
                    ]),
                  ]),
                ],
              ),
            ),
          ),
          if (isLocked) Container(
            height: 200,
            decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Icon(Icons.lock_rounded, size: 48, color: SayoColors.white)),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  final Color? activeColor;

  const _ActionChip({required this.icon, required this.label, required this.onTap, this.active = false, this.activeColor});

  @override
  Widget build(BuildContext context) {
    final aColor = activeColor ?? SayoColors.cafe;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? aColor.withValues(alpha: 0.08) : SayoColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? aColor.withValues(alpha: 0.3) : SayoColors.beige, width: 0.5),
        ),
        child: Column(children: [
          Icon(icon, size: 20, color: active ? aColor : SayoColors.grisMed),
          const SizedBox(height: 4),
          Text(label, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: active ? aColor : SayoColors.grisMed), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

class _WalletButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _WalletButton({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 22, color: SayoColors.gris),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
          ]),
        ),
      ),
    );
  }
}

class _SpendingCategory extends StatelessWidget {
  final String label; final double amount, percent; final Color color;
  const _SpendingCategory(this.label, this.amount, this.percent, this.color);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed))),
        Text(formatMoney(amount), style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
        const SizedBox(width: 8),
        SizedBox(width: 60, child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(value: percent, backgroundColor: SayoColors.beige.withValues(alpha: 0.5), valueColor: AlwaysStoppedAnimation(color), minHeight: 4),
        )),
      ]),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/utils/formatters.dart';
import 'admin_mock_data.dart';

class AdminWalletsScreen extends StatefulWidget {
  const AdminWalletsScreen({super.key});

  @override
  State<AdminWalletsScreen> createState() => _AdminWalletsScreenState();
}

class _AdminWalletsScreenState extends State<AdminWalletsScreen> {
  String _filter = 'todos'; // todos, activo, pendiente, suspendido
  String _search = '';
  String _sortBy = 'balance'; // balance, name, activity

  List<AdminWalletUser> get _filteredUsers {
    var list = List<AdminWalletUser>.from(mockAdminUsers);

    if (_filter != 'todos') {
      list = list.where((u) => u.status == _filter).toList();
    }

    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list.where((u) =>
        u.name.toLowerCase().contains(q) ||
        u.email.toLowerCase().contains(q) ||
        u.id.toLowerCase().contains(q) ||
        u.clabe.contains(q)
      ).toList();
    }

    switch (_sortBy) {
      case 'balance':
        list.sort((a, b) => b.balance.compareTo(a.balance));
      case 'name':
        list.sort((a, b) => a.name.compareTo(b.name));
      case 'activity':
        list.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final users = _filteredUsers;
    final totalBalance = users.fold(0.0, (sum, u) => sum + u.balance);

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Text('Gestion de Wallets', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort_rounded, color: SayoColors.grisMed),
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              PopupMenuItem(value: 'balance', child: Text('Ordenar por saldo', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: _sortBy == 'balance' ? FontWeight.w700 : FontWeight.w400))),
              PopupMenuItem(value: 'name', child: Text('Ordenar por nombre', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: _sortBy == 'name' ? FontWeight.w700 : FontWeight.w400))),
              PopupMenuItem(value: 'activity', child: Text('Ordenar por actividad', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: _sortBy == 'activity' ? FontWeight.w700 : FontWeight.w400))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.gris),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, email, CLABE...',
                hintStyle: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight),
                prefixIcon: const Icon(Icons.search_rounded, color: SayoColors.grisLight, size: 20),
                filled: true,
                fillColor: SayoColors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: SayoColors.beige, width: 0.5)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: SayoColors.cafe, width: 1.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _FilterChip(label: 'Todos', isSelected: _filter == 'todos', onTap: () => setState(() => _filter = 'todos')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Activos', isSelected: _filter == 'activo', color: SayoColors.green, onTap: () => setState(() => _filter = 'activo')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Pendientes', isSelected: _filter == 'pendiente', color: SayoColors.orange, onTap: () => setState(() => _filter = 'pendiente')),
                const SizedBox(width: 8),
                _FilterChip(label: 'Suspendidos', isSelected: _filter == 'suspendido', color: SayoColors.red, onTap: () => setState(() => _filter = 'suspendido')),
              ],
            ),
          ),

          // Summary bar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${users.length} wallets', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
                Text('Saldo total: ${formatMoney(totalBalance)}', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w700, color: SayoColors.green)),
              ],
            ),
          ),

          // List
          Expanded(
            child: users.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded, size: 48, color: SayoColors.grisLight.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text('Sin resultados', style: GoogleFonts.urbanist(fontSize: 15, fontWeight: FontWeight.w600, color: SayoColors.grisLight)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: users.length,
                    itemBuilder: (ctx, i) => GestureDetector(
                      onTap: () => context.push('/admin/wallets/detail', extra: {'userId': users[i].id}),
                      child: _WalletCard(user: users[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// --- WIDGETS ---

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = color ?? SayoColors.cafe;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? c.withValues(alpha: 0.1) : SayoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? c : SayoColors.beige, width: isSelected ? 1.5 : 0.5),
        ),
        child: Text(
          label,
          style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: isSelected ? c : SayoColors.grisMed),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  final AdminWalletUser user;

  const _WalletCard({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SayoColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SayoColors.beige, width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: SayoColors.cafe.withValues(alpha: 0.1),
                child: Text(user.initials, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.cafe)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(user.name, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: user.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(user.statusLabel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: user.statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text('${user.email}  ·  ${user.kycLevel}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: SayoColors.cream, borderRadius: BorderRadius.circular(12)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _MiniStat('Saldo', formatMoney(user.balance), SayoColors.green),
                Container(width: 1, height: 30, color: SayoColors.beige),
                _MiniStat('Credito usado', formatMoney(user.creditUsed), SayoColors.orange),
                Container(width: 1, height: 30, color: SayoColors.beige),
                _MiniStat('Disponible', formatMoney(user.creditAvailable), SayoColors.blue),
              ],
            ),
          ),
          if (user.creditLimit > 0) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: user.creditUsedPercent,
                backgroundColor: SayoColors.beige.withValues(alpha: 0.5),
                valueColor: AlwaysStoppedAnimation(
                  user.creditUsedPercent > 0.9 ? SayoColors.red :
                  user.creditUsedPercent > 0.7 ? SayoColors.orange : SayoColors.green,
                ),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Linea: ${formatMoney(user.creditLimit)}', style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
                Text('${(user.creditUsedPercent * 100).toStringAsFixed(0)}% utilizado', style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MiniStat(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 10, color: SayoColors.grisLight)),
        const SizedBox(height: 2),
        Text(value, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w700, color: color)),
      ],
    );
  }
}

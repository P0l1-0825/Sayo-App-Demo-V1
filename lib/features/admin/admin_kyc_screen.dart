import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';

// --- KYC MOCK DATA ---

class KycRequest {
  final String id;
  final String userId;
  final String userName;
  final String email;
  final String currentLevel;
  final String requestedLevel;
  final String status; // pendiente, aprobado, rechazado
  final DateTime submittedAt;
  final List<KycDocument> documents;

  const KycRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.email,
    required this.currentLevel,
    required this.requestedLevel,
    required this.status,
    required this.submittedAt,
    required this.documents,
  });

  Color get statusColor {
    switch (status) {
      case 'pendiente': return SayoColors.orange;
      case 'aprobado': return SayoColors.green;
      case 'rechazado': return SayoColors.red;
      default: return SayoColors.grisMed;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pendiente': return 'Pendiente';
      case 'aprobado': return 'Aprobado';
      case 'rechazado': return 'Rechazado';
      default: return status;
    }
  }
}

class KycDocument {
  final String name;
  final String type; // ine, domicilio, ingresos, bancario, selfie
  final String status; // verificado, pendiente, rechazado
  final DateTime? uploadedAt;

  const KycDocument({required this.name, required this.type, required this.status, this.uploadedAt});

  IconData get icon {
    switch (type) {
      case 'ine': return Icons.badge_rounded;
      case 'domicilio': return Icons.home_rounded;
      case 'ingresos': return Icons.receipt_long_rounded;
      case 'bancario': return Icons.account_balance_rounded;
      case 'selfie': return Icons.face_rounded;
      default: return Icons.description_rounded;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'verificado': return SayoColors.green;
      case 'pendiente': return SayoColors.orange;
      case 'rechazado': return SayoColors.red;
      default: return SayoColors.grisMed;
    }
  }
}

final mockKycRequests = <KycRequest>[
  KycRequest(
    id: 'KYC001',
    userId: 'USR005',
    userName: 'Roberto Hernández',
    email: 'roberto.h@outlook.com',
    currentLevel: 'Nivel 0',
    requestedLevel: 'Nivel 1',
    status: 'pendiente',
    submittedAt: DateTime(2026, 3, 1),
    documents: [
      KycDocument(name: 'INE Frente', type: 'ine', status: 'pendiente', uploadedAt: DateTime(2026, 3, 1)),
      KycDocument(name: 'INE Reverso', type: 'ine', status: 'pendiente', uploadedAt: DateTime(2026, 3, 1)),
      KycDocument(name: 'Selfie con INE', type: 'selfie', status: 'pendiente', uploadedAt: DateTime(2026, 3, 1)),
    ],
  ),
  KycRequest(
    id: 'KYC002',
    userId: 'USR009',
    userName: 'Elena Morales Ríos',
    email: 'elena.morales@mail.com',
    currentLevel: 'Nivel 1',
    requestedLevel: 'Nivel 2',
    status: 'pendiente',
    submittedAt: DateTime(2026, 3, 2),
    documents: [
      KycDocument(name: 'INE', type: 'ine', status: 'verificado', uploadedAt: DateTime(2026, 2, 15)),
      KycDocument(name: 'Comprobante domicilio', type: 'domicilio', status: 'pendiente', uploadedAt: DateTime(2026, 3, 2)),
      KycDocument(name: 'Comprobante ingresos', type: 'ingresos', status: 'pendiente', uploadedAt: DateTime(2026, 3, 2)),
    ],
  ),
  KycRequest(
    id: 'KYC003',
    userId: 'USR010',
    userName: 'Miguel Ángel Castillo',
    email: 'miguel.castillo@empresa.mx',
    currentLevel: 'Nivel 2',
    requestedLevel: 'Nivel 3',
    status: 'pendiente',
    submittedAt: DateTime(2026, 3, 3),
    documents: [
      KycDocument(name: 'INE', type: 'ine', status: 'verificado'),
      KycDocument(name: 'Comprobante domicilio', type: 'domicilio', status: 'verificado'),
      KycDocument(name: 'Comprobante ingresos', type: 'ingresos', status: 'verificado'),
      KycDocument(name: 'Estado de cuenta bancario', type: 'bancario', status: 'pendiente', uploadedAt: DateTime(2026, 3, 3)),
    ],
  ),
  KycRequest(
    id: 'KYC004',
    userId: 'USR002',
    userName: 'María García López',
    email: 'maria.garcia@email.com',
    currentLevel: 'Nivel 2',
    requestedLevel: 'Nivel 3',
    status: 'aprobado',
    submittedAt: DateTime(2026, 2, 20),
    documents: [
      KycDocument(name: 'INE', type: 'ine', status: 'verificado'),
      KycDocument(name: 'Comprobante domicilio', type: 'domicilio', status: 'verificado'),
      KycDocument(name: 'Comprobante ingresos', type: 'ingresos', status: 'verificado'),
      KycDocument(name: 'Estado de cuenta', type: 'bancario', status: 'verificado'),
    ],
  ),
  KycRequest(
    id: 'KYC005',
    userId: 'USR011',
    userName: 'Jorge Ramírez',
    email: 'jorge.ramirez@correo.mx',
    currentLevel: 'Nivel 0',
    requestedLevel: 'Nivel 1',
    status: 'rechazado',
    submittedAt: DateTime(2026, 2, 25),
    documents: [
      KycDocument(name: 'INE Frente', type: 'ine', status: 'rechazado'),
      KycDocument(name: 'INE Reverso', type: 'ine', status: 'rechazado'),
      KycDocument(name: 'Selfie', type: 'selfie', status: 'pendiente'),
    ],
  ),
];

// --- SCREEN ---

class AdminKycScreen extends StatefulWidget {
  const AdminKycScreen({super.key});

  @override
  State<AdminKycScreen> createState() => _AdminKycScreenState();
}

class _AdminKycScreenState extends State<AdminKycScreen> {
  String _filter = 'pendiente';

  List<KycRequest> get _filtered {
    if (_filter == 'todos') return mockKycRequests;
    return mockKycRequests.where((r) => r.status == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final requests = _filtered;
    final pending = mockKycRequests.where((r) => r.status == 'pendiente').length;

    return Scaffold(
      backgroundColor: SayoColors.cream,
      appBar: AppBar(
        backgroundColor: SayoColors.cream,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
          onPressed: () => context.pop(),
        ),
        title: Text('Verificacion KYC', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
        actions: [
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: SayoColors.orange.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('$pending pendientes', style: GoogleFonts.urbanist(fontSize: 12, fontWeight: FontWeight.w600, color: SayoColors.orange)),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: Row(
              children: [
                _Chip('Pendientes', 'pendiente', _filter, SayoColors.orange, (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _Chip('Aprobados', 'aprobado', _filter, SayoColors.green, (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _Chip('Rechazados', 'rechazado', _filter, SayoColors.red, (v) => setState(() => _filter = v)),
                const SizedBox(width: 8),
                _Chip('Todos', 'todos', _filter, SayoColors.cafe, (v) => setState(() => _filter = v)),
              ],
            ),
          ),

          // Count
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('${requests.length} solicitudes', style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.grisMed)),
            ),
          ),

          // List
          Expanded(
            child: requests.isEmpty
                ? Center(child: Text('Sin solicitudes', style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight)))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: requests.length,
                    itemBuilder: (ctx, i) => GestureDetector(
                      onTap: () => _showKycDetail(context, requests[i]),
                      child: _KycCard(request: requests[i]),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  void _showKycDetail(BuildContext context, KycRequest request) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: SayoColors.cream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 4, decoration: BoxDecoration(color: SayoColors.beige, borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Revision KYC', style: GoogleFonts.urbanist(fontSize: 18, fontWeight: FontWeight.w800, color: SayoColors.gris)),
                          Text(request.userName, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisMed)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: request.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text(request.statusLabel, style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w700, color: request.statusColor)),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // Info
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: SayoColors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: SayoColors.beige, width: 0.5)),
                      child: Column(
                        children: [
                          _InfoRow('ID', request.id),
                          const SizedBox(height: 8),
                          _InfoRow('Email', request.email),
                          const SizedBox(height: 8),
                          _InfoRow('Nivel actual', request.currentLevel),
                          const SizedBox(height: 8),
                          _InfoRow('Nivel solicitado', request.requestedLevel),
                          const SizedBox(height: 8),
                          _InfoRow('Fecha solicitud', '${request.submittedAt.day}/${request.submittedAt.month}/${request.submittedAt.year}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Documents
                    Text('Documentos (${request.documents.length})', style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                    const SizedBox(height: 8),
                    ...request.documents.map((doc) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SayoColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: doc.statusColor.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: doc.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                            child: Icon(doc.icon, color: doc.statusColor, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc.name, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
                              Text(doc.status == 'verificado' ? 'Verificado' : doc.status == 'pendiente' ? 'Pendiente de revision' : 'Rechazado', style: GoogleFonts.urbanist(fontSize: 11, color: doc.statusColor)),
                            ],
                          )),
                          if (doc.status == 'pendiente')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${doc.name} aprobado', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: SayoColors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.check_rounded, size: 16, color: SayoColors.green),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GestureDetector(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('${doc.name} rechazado', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(color: SayoColors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: const Icon(Icons.close_rounded, size: 16, color: SayoColors.red),
                                  ),
                                ),
                              ],
                            ),
                          if (doc.status != 'pendiente')
                            Icon(
                              doc.status == 'verificado' ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: doc.statusColor,
                              size: 20,
                            ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),

                    // Action buttons
                    if (request.status == 'pendiente')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('KYC de ${request.userName} rechazado', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.red, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                );
                              },
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: SayoColors.red), foregroundColor: SayoColors.red),
                              icon: const Icon(Icons.close_rounded, size: 16),
                              label: const Text('Rechazar'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('KYC de ${request.userName} aprobado → ${request.requestedLevel}', style: GoogleFonts.urbanist()), backgroundColor: SayoColors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                                );
                              },
                              icon: const Icon(Icons.check_rounded, size: 16),
                              label: const Text('Aprobar KYC'),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS ---

class _Chip extends StatelessWidget {
  final String label;
  final String value;
  final String selected;
  final Color color;
  final ValueChanged<String> onTap;

  const _Chip(this.label, this.value, this.selected, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isActive = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.1) : SayoColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : SayoColors.beige, width: isActive ? 1.5 : 0.5),
        ),
        child: Text(label, style: GoogleFonts.urbanist(fontSize: 12, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? color : SayoColors.grisMed)),
      ),
    );
  }
}

class _KycCard extends StatelessWidget {
  final KycRequest request;

  const _KycCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final pendingDocs = request.documents.where((d) => d.status == 'pendiente').length;
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
                radius: 20,
                backgroundColor: request.statusColor.withValues(alpha: 0.1),
                child: Icon(Icons.person_rounded, color: request.statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.userName, style: GoogleFonts.urbanist(fontSize: 14, fontWeight: FontWeight.w700, color: SayoColors.gris)),
                  Text('${request.currentLevel} → ${request.requestedLevel}', style: GoogleFonts.urbanist(fontSize: 12, color: SayoColors.grisMed)),
                ],
              )),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: request.statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(request.statusLabel, style: GoogleFonts.urbanist(fontSize: 10, fontWeight: FontWeight.w600, color: request.statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${request.documents.length} documentos', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
              if (pendingDocs > 0)
                Text('$pendingDocs por revisar', style: GoogleFonts.urbanist(fontSize: 11, fontWeight: FontWeight.w600, color: SayoColors.orange)),
              Text('${request.submittedAt.day}/${request.submittedAt.month}/${request.submittedAt.year}', style: GoogleFonts.urbanist(fontSize: 11, color: SayoColors.grisLight)),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.urbanist(fontSize: 13, color: SayoColors.grisLight)),
        Text(value, style: GoogleFonts.urbanist(fontSize: 13, fontWeight: FontWeight.w600, color: SayoColors.gris)),
      ],
    );
  }
}

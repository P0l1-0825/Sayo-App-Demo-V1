import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/sayo_colors.dart';
import '../../core/services/tapi_service.dart';
import '../../core/models/tapi_models.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  State<ServiciosScreen> createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final _tapiService = TapiService();
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedCategoryId;
  List<ServiceCompany> _companies = [];
  bool _loadingCompanies = false;

  List<ServiceCategory> get _categories => _tapiService.getCategories();

  List<ServiceCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories
        .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _selectCategory(ServiceCategory category) async {
    setState(() {
      _selectedCategoryId = category.id;
      _loadingCompanies = true;
    });
    final companies = await _tapiService.getCompanies(category.id);
    if (!mounted) return;
    setState(() {
      _companies = companies;
      _loadingCompanies = false;
    });
  }

  void _selectCompany(ServiceCompany company) {
    context.push('/servicios/pago', extra: {
      'companyId': company.id,
      'companyName': company.name,
      'categoryId': company.categoryId,
    });
  }

  void _goBack() {
    if (_selectedCategoryId != null) {
      setState(() {
        _selectedCategoryId = null;
        _companies = [];
      });
    } else {
      context.pop();
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back_rounded, color: SayoColors.gris),
                  ),
                  const Spacer(),
                  Text(
                    _selectedCategoryId != null
                        ? (_categories.where((c) => c.id == _selectedCategoryId).firstOrNull?.name ?? 'Pago de servicios')
                        : 'Pago de servicios',
                    style: GoogleFonts.urbanist(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: SayoColors.gris,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Search bar (only in categories view)
            if (_selectedCategoryId == null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: SayoColors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SayoColors.beige),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.gris),
                    decoration: InputDecoration(
                      hintText: 'Buscar servicio...',
                      hintStyle: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisLight),
                      prefixIcon: const Icon(Icons.search_rounded, color: SayoColors.grisLight, size: 20),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),
              ),

            // Content
            Expanded(
              child: _selectedCategoryId == null
                  ? _buildCategoriesGrid()
                  : _buildCompaniesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final categories = _filteredCategories;
    if (categories.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: SayoColors.beige),
            const SizedBox(height: 12),
            Text(
              'No se encontraron servicios',
              style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, i) {
        final cat = categories[i];
        return GestureDetector(
          onTap: () => _selectCategory(cat),
          child: Container(
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(cat.icon, size: 28, color: cat.color),
                ),
                const SizedBox(height: 12),
                Text(
                  cat.name,
                  style: GoogleFonts.urbanist(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: SayoColors.gris,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompaniesList() {
    if (_loadingCompanies) {
      return const Center(child: CircularProgressIndicator(color: SayoColors.cafe));
    }

    if (_companies.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_rounded, size: 48, color: SayoColors.beige),
            const SizedBox(height: 12),
            Text(
              'No hay servicios disponibles',
              style: GoogleFonts.urbanist(fontSize: 14, color: SayoColors.grisMed),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: _companies.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final company = _companies[i];
        final cat = _categories.firstWhere(
          (c) => c.id == _selectedCategoryId,
          orElse: () => _categories.first,
        );
        return GestureDetector(
          onTap: () => _selectCompany(company),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: SayoColors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: SayoColors.beige.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cat.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(cat.icon, size: 22, color: cat.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    company.name,
                    style: GoogleFonts.urbanist(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: SayoColors.gris,
                    ),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: SayoColors.grisLight, size: 22),
              ],
            ),
          ),
        );
      },
    );
  }
}
